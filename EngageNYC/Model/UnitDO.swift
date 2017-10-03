//
//  UnitDO.swift
//  Knock
//
//  Created by Kamal on 24/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import Foundation

class UnitDO{
    var unitId:String!
    var unitName:String!
    var surveyStatus:String!
    
    init(unitId:String,unitName:String,surveyStatus:String) {
        self.unitId = unitId
        self.unitName = unitName
        self.surveyStatus = surveyStatus
    }
    
}
