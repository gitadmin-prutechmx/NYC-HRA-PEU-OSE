//
//  AssignmentDO.swift
//  Knock
//
//  Created by Kamal on 13/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import Foundation

class AssignmentDO{
    
    var assignmentId:String!
    var assignmentName:String!
    var eventId:String!
    
    init(eventId:String,assignmentId:String,assignmentName:String) {
        self.eventId = eventId
        self.assignmentId = assignmentId
        self.assignmentName = assignmentName
    }
    
}
