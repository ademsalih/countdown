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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        events = getEvents()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func addEventButtonAction(_ sender: Any) {
        
        let eventTitle = titleField.stringValue
        let date = datePickerField.dateValue
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd'-'MM'-'yyyy"
        
        let eventDate = dateFormatter.string(from: date)
        
        addNewEventWith(title: eventTitle, date: eventDate)
    }
    
    func addNewEventWith(title: String, date: String) {
        
        var newArray: [[String: Any]] = []
        
        let fileURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        
        let filename = fileURL?.appendingPathComponent("events.json")
        

        let data = try! Data(contentsOf: filename!)
        let JSON = try! JSONSerialization.jsonObject(with: data, options: [])
        
        if let jsonArray = JSON as? [[String: Any]] {
            for item in jsonArray {
                newArray.append(item)
            }
        }
        
        var item: [String: String] = [:]
        
        item["name"] = title
        item["date"] = date
        
        newArray.append(item)
    
        let text = json(from: newArray)
        
        
        do {
            try text?.write(to: filename!, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("no")
        }
        
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
        
        let fileURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let filename = fileURL?.appendingPathComponent("events.json")
        
        let data = try! Data(contentsOf: filename!)
        let JSON = try! JSONSerialization.jsonObject(with: data, options: [])
        
        if let jsonArray = JSON as? [[String: Any]] {
            for item in jsonArray {
                let title = item["name"] as? String ?? "No Title"
                let date = item["date"] as? String ?? "No Date"
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd'-'MM'-'yyyy"
                
                let eventDate = dateFormatter.date(from: date)!
                
                let now = Date()
                
                let diffInDays = Calendar.current.dateComponents([.day], from: now, to: eventDate).day

                let event = Event(title: title, daysLeft: diffInDays! + 1)
                events.append(event)
            }
        }
        
        return events
    }

}

