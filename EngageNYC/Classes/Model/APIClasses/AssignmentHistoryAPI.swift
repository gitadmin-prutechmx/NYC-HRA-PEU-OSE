//
//  AssignmentHistory.swift
//  EngageNYC
//
//  Created by Kamal on 18/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation
import SalesforceSDKCore

final class AssignmentNotesAPI:SFCommonAPI {
    
    
    private static var sharedInstance: AssignmentNotesAPI = {
        let instance = AssignmentNotesAPI()
        return instance
    }()
    
    class var shared:AssignmentNotesAPI!{
        get{
            return sharedInstance
        }
    }
    
    func getAssignmentLocationNotes(assignmentLocId:String) -> [AssignmentNotes]?{
        
        let res = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.assignmentnotes.rawValue ,predicateFormat: "assignmentLocId == %@",predicateValue:assignmentLocId, isPredicate:true) as! [AssignmentNotes]

        return res
    }
    
    func getAssignmentLocationUnitNotes(assignmentLocUnitId:String) -> [AssignmentNotes]?{
        
        let res = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.assignmentnotes.rawValue ,predicateFormat: "assignmentLocUnitId == %@",predicateValue:assignmentLocUnitId, isPredicate:true) as! [AssignmentNotes]
        
        return res
    }
    
    
}


