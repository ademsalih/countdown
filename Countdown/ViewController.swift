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
        
    }
    
    func getEvents() -> [Event] {
        
        var events: [Event] = []
        
        let url = Bundle.main.url(forResource: "events", withExtension: "json")!
        let data = try! Data(contentsOf: url)
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

