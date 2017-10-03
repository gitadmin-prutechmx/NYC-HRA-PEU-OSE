//
//  LocationDO.swift
//  Knock
//
//  Created by Kamal on 14/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import Foundation
class LocationDO{
    
    var locId:String
    var assignmentLocId:String
    var fullAddress:String
    var totalUnits:String
    var noOfUnitsAttempt:String
    var noOfClients:String
    
    init(locId:String,assignmentLocId:String,fullAddress:String,totalUnits:String,noOfClients:String,noOfUnitsAttempt:String) {
        
        self.locId = locId
        self.assignmentLocId = assignmentLocId
        self.fullAddress = fullAddress
        self.totalUnits = totalUnits
        self.noOfClients = noOfClients
        self.noOfUnitsAttempt = noOfUnitsAttempt
    }
}
