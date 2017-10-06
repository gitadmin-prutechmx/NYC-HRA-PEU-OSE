//
//  CaseDO.swift
//  TestApplication
//
//  Created by Kamal on 29/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import Foundation

class CaseDO{

    var sequence:String = ""
    var pickListValue:String = ""
    var fieldName:String = ""
    var dataType:String = ""
    var apiName:String = ""
    var sectionName:String = ""
    
    

init(sequence:String,pickListValue:String,fieldName:String,dataType:String,apiName:String,sectionName:String) {
        self.sequence = sequence
        self.pickListValue = pickListValue
        self.fieldName = fieldName
        self.dataType = dataType
        self.apiName = apiName
        self.sectionName = sectionName
        
        
    }
}
