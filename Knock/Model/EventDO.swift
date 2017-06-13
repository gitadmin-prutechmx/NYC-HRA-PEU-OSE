//
//  EventDO.swift
//  Knock
//
//  Created by Kamal on 13/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import Foundation

class EventDO{
    var eventId:String!
    var eventName:String!
    var startDate:String!
    var endDate:String!
    
    init(eventId:String,eventName:String,startDate:String,endDate:String) {
        self.eventId = eventId
        self.eventName = eventName
        self.startDate = startDate
        self.endDate = endDate
    }
    
}
