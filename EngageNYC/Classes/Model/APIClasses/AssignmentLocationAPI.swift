//
//  AssignmentLocationAPI.swift
//  EngageNYC
//
//  Created by Kamal on 14/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation
import SalesforceSDKCore


final class AssignmentLocationAPI:SFCommonAPI {
    
    
    private static var sharedInstance: AssignmentLocationAPI = {
        let instance = AssignmentLocationAPI()
        return instance
    }()
    
    class var shared:AssignmentLocationAPI!{
        get{
            return sharedInstance
        }
    }
    
    func getAssignmentLocation(assignmentLocId:String) -> AssignmentLocation?{
        
        let assignmentLocResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.assignmentLocation.rawValue ,predicateFormat: "assignmentLocId == %@",predicateValue:assignmentLocId, isPredicate:true) as! [AssignmentLocation]
        
        if(assignmentLocResults.count > 0){
            return assignmentLocResults.first
        }
        
        return nil
    }
    
    func updateAssignmentLocation(assignmentLocInfoObj:AssignmentLocationInfoDO){
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["attempt"] = assignmentLocInfoObj.attempted as AnyObject?
        updateObjectDic["locStatus"] = assignmentLocInfoObj.locStatus as AnyObject?
        updateObjectDic["notes"] = assignmentLocInfoObj.notes as AnyObject?
        updateObjectDic["actionStatus"] = actionStatus.edit.rawValue as AnyObject?
        updateObjectDic["propertyName"] = assignmentLocInfoObj.propertyName as AnyObject?
        updateObjectDic["propertyContactTitle"] = assignmentLocInfoObj.propertyContactTitle as AnyObject?
        updateObjectDic["phoneNo"] = assignmentLocInfoObj.phoneNo as AnyObject?
        updateObjectDic["phoneExt"] = assignmentLocInfoObj.phoneExt as AnyObject?
        
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.assignmentLocation.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocId == %@", predicateValue:  assignmentLocInfoObj.assignmentLocationId,isPredicate: true)
        
    }
    
    
    func syncUpCompletion(completion: @escaping (()->()))
    {
        if let arrAssignmentLocations = getAllUpdatedAssignmentLocations(){
            
            let assignmentLocGroup = DispatchGroup()
            
            for assignmentLocation in arrAssignmentLocations{
                
                var assignmentLocDict:[String:String] = [:]
                var assignmentLocParams:[String:String] = [:]
                
                assignmentLocDict["status"] = assignmentLocation.locStatus
                assignmentLocDict["assignmentLocationId"] = assignmentLocation.assignmentLocId
                assignmentLocDict["Notes"] = assignmentLocation.notes
                assignmentLocDict["attempt"] = assignmentLocation.attempt
                
                 assignmentLocDict["locationId"] = assignmentLocation.locationId
                 assignmentLocDict["propertyName"] = assignmentLocation.propertyName
                 assignmentLocDict["propertyContactTitle"] = assignmentLocation.propertyContactTitle
                 assignmentLocDict["phoneNo"] = assignmentLocation.phoneNo
                 assignmentLocDict["phoneExt"] = assignmentLocation.phoneExt
                
                
                assignmentLocParams["location"] = Utility.jsonToString(json: assignmentLocDict as AnyObject)!
                
                let req = SFRestRequest(method: .POST, path: SalesforceRestApiUrl.updateAssignmentLocation, queryParams: nil)
                
                do {
                    
                    let bodyData = try JSONSerialization.data(withJSONObject: assignmentLocParams, options: [])
                    req.setCustomRequestBodyData(bodyData, contentType: "application/json")
                }
                catch{
                    
                    
                }
                
                req.endpoint = ""
                
                assignmentLocGroup.enter()
                
                self.sendRequest(request: req, callback: { (response) in
                 
                    DispatchQueue.main.async {
                        
                        self.parseAssignmentLocation(jsonObject: response as! Dictionary<String, AnyObject>)
                        
                         assignmentLocGroup.leave()
                        
                        print("assignmentLocGroup: \(assignmentLocation.assignmentLocId!)")
                    }
                    
                   
                   
                }) { (error) in
                    Logger.shared.log(level: .error, msg: error)
                    Utility.displayErrorMessage(errorMsg: error)
                    
                    //failure(error)
                }
                
            }
            
            assignmentLocGroup.notify(queue: .main) {
                 completion()
            }
            
        }
        else{
            completion()
        }
        
        
    }
    
    func parseAssignmentLocation(jsonObject: Dictionary<String, AnyObject>){
        
        let assignmentLocId = jsonObject["assignmentLocationId"] as? String
        
        let assignmentLocRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.assignmentLocation.rawValue,predicateFormat: "actionStatus == %@ AND assignmentLocId == %@" ,predicateValue: actionStatus.edit.rawValue,predicateValue2: assignmentLocId,isPredicate:true) as! [AssignmentLocation]
        
        if(assignmentLocRes.count > 0){
            
            var updateObjectDic:[String:AnyObject] = [:]
            
            updateObjectDic["actionStatus"] = "" as AnyObject
           
            
            ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.assignmentLocation.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocId == %@", predicateValue:  assignmentLocId,isPredicate: true)
    
            
        }
        
        
    }
    
    
    func getAllUpdatedAssignmentLocations()->[AssignmentLocation]?{
        
        let assignmentLocResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.assignmentLocation.rawValue ,predicateFormat: "actionStatus == %@",predicateValue:actionStatus.edit.rawValue, isPredicate:true) as? [AssignmentLocation]
        
        
        return assignmentLocResults
        
    }
    
}


