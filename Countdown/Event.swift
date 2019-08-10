//
//  Event.swift
//  Countdown
//
//  Created by Adem Salih on 05/08/2019.
//  Copyright © 2019 Adem Salih. All rights reserved.
//

import Foundation

class Event: NSObject {
    
    @objc dynamic let title: String
    @objc dynamic let daysLeft: Int
    
    init(title: String, daysLeft: Int) {
        self.title = title
        self.daysLeft = daysLeft
    }
}
