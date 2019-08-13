//
//  ViewController.swift
//  Countdown
//
//  Created by Adem Salih on 05/08/2019.
//  Copyright © 2019 Adem Salih. All rights reserved.
//

import Cocoa
import Foundation

class ViewController: NSViewController {

    @IBOutlet weak var titleField: NSTextField!
    @IBOutlet weak var datePickerField: NSDatePicker!
    @IBOutlet weak var tableView: NSTableView!
    @objc dynamic var events: [Event] = []
    var currentSelectedEvent: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        datePickerField.dateValue = Date()
        events = getEvents()
    }

    override var representedObject: Any? {
        didSet {
        }
    }
    
    func getDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd'-'MM'-'yyyy"
        return dateFormatter
    }
    
    @IBAction func addEventButtonAction(_ sender: Any) {
        let eventTitle = titleField.stringValue
        let date = datePickerField.dateValue
        
        let dateFormatter = getDateFormatter()
        let eventDate = dateFormatter.string(from: date)
        
        addNewEvent(title: eventTitle, date: eventDate)
        
        titleField.stringValue = ""
    }
    
    func addNewEvent(title: String, date: String) {
        var currentEvents: [[String: Any]] = []
        
        // Get JSON file with events in Application Support
        let fileURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let filename = fileURL?.appendingPathComponent("events.json")
        
        let data = try! Data(contentsOf: filename!)
        let JSON = try! JSONSerialization.jsonObject(with: data, options: [])
        
        if let jsonArray = JSON as? [[String: Any]] {
            for item in jsonArray {
                currentEvents.append(item)
            }
        }
        
        var newEvent: [String: Any] = [:]
        
        newEvent["name"] = title
        newEvent["date"] = date
        
        currentEvents.append(newEvent)
        
        let dateFormatter = getDateFormatter()
        
        let allEventsSorted = currentEvents.sorted { left, right in
            let leftDate = dateFormatter.date(from: left["date"] as! String)!
            let rightDate = dateFormatter.date(from: right["date"] as! String)!
            return leftDate.compare(rightDate) == .orderedAscending
        }
        
        let jsonString = json(from: allEventsSorted)
        
        do {
            try jsonString?.write(to: filename!, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Error: Could not write JSON to file")
        }
        
        updateTableView()
    }
    
    func updateTableView() {
        events = getEvents()
        tableView.reloadData()
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    func getEvents() -> [Event] {
        var events: [Event] = []
        let eventsFromJSON = getEventsFromJSON()
        
        for item in eventsFromJSON {
            let title = item["name"] as? String ?? "No Title"
            let date = item["date"] as? String ?? "No Date"
            
            let eventDate = getDateFormatter().date(from: date)!
            let days = Calendar.current.dateComponents([.day], from: Date(), to: eventDate).day
            
            let event = Event(title: title, daysLeft: days!)
            events.append(event)
        }

        return events
    }
    
    func getEventsFromJSON() -> [[String:Any]]{
        var currentEvents: [[String: Any]] = []
        
        // Get JSON file with events in Application Support
        let fileURL = getEventsFileURL()
        
        let data = try! Data(contentsOf: fileURL)
        let JSON = try! JSONSerialization.jsonObject(with: data, options: [])
        
        if let jsonArray = JSON as? [[String: Any]] {
            for item in jsonArray {
                currentEvents.append(item)
            }
        }
        
        return currentEvents
    }
    
    func getEventsFileURL() -> URL {
        let fileLocationURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let fileURL = fileLocationURL?.appendingPathComponent("events.json")
        return fileURL!
    }

    @IBAction func deleteEventButtonAction(_ sender: Any) {
        
        if currentSelectedEvent > -1 {
            var currentEvents = getEventsFromJSON()
            currentEvents.remove(at: currentSelectedEvent)
            
            let jsonString = json(from: currentEvents)
            
            do {
                try jsonString?.write(to: getEventsFileURL(), atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("Error: Could not write JSON to file")
            }
            
            updateTableView()
            
            currentSelectedEvent = -1
        }
        
    }
}

extension ViewController: NSTableViewDelegate {
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        currentSelectedEvent = (notification.object as? NSTableView)!.selectedRow
    }
}

