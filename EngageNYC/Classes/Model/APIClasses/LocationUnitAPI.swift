//
//  NewUnitAPI.swift
//  EngageNYCDev
//
//  Created by Kamal on 11/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation
import SalesforceSDKCore


final class LocationUnitAPI:SFCommonAPI {
    
    
    private static var sharedInstance: LocationUnitAPI = {
        let instance = LocationUnitAPI()
        return instance
    }()
    
    class var shared:LocationUnitAPI!{
        get{
            return sharedInstance
        }
    }
    
    
    /// Get all the locationUnits from core data.
    ///
    /// - Returns: array of locationUnits.
    func getAllLocationUnits(assignmentId:String,assignmentLocId:String)->[LocationUnit]? {

        let locationUnitRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.locationUnit.rawValue,predicateFormat: "assignmentId == %@ && assignmentLocId == %@" ,predicateValue: assignmentId, predicateValue2: assignmentLocId,isPredicate:true) as? [LocationUnit]

        return locationUnitRes
    }
    
    /// Get all the locationUnits from core data.
    ///
    /// - Returns: array of locationUnits.
    func getAllLocationUnitsWithoutVirtualUnit(assignmentId:String,assignmentLocId:String)->[LocationUnit]? {
        
        let locationUnitRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.locationUnit.rawValue,predicateFormat: "assignmentId == %@ && assignmentLocId == %@ && isVirtualUnit == %@" ,predicateValue: assignmentId, predicateValue2: assignmentLocId, predicateValue3: virtualUnitEnum.VUFalse.rawValue, isPredicate:true) as? [LocationUnit]
        
        return locationUnitRes
    }
    
    func saveNewUnit(objNewUnit:NewUnitDO){
        
        let newUnit = LocationUnit(context:context)
        newUnit.assignmentId = objNewUnit.assignmentId
        newUnit.assignmentLocId = objNewUnit.assignmentLocId
        newUnit.locationId = objNewUnit.locationId
        
        newUnit.unitName = objNewUnit.unitName
        newUnit.notes = objNewUnit.unitNotes
        newUnit.isVirtualUnit = objNewUnit.isVirtualUnit
        newUnit.isPrivateHome = objNewUnit.isPrivateHome
        newUnit.actionStatus = objNewUnit.actionStatus
        
        newUnit.locationUnitId = objNewUnit.iOSLocUnitId
        newUnit.assignmentLocUnitId = objNewUnit.iOSAssignmentLocUnitId
        
        newUnit.iOSLoctionUnitId = objNewUnit.iOSLocUnitId
        newUnit.iOSAssignmentLocUnitId = objNewUnit.iOSAssignmentLocUnitId
        newUnit.syncDate = objNewUnit.syncDate
        
        appDelegate.saveContext()
        
        //create assignment location unit here
        AssignmentLocationUnitAPI.shared.createNewTempAssignmentLocationUnit(assignmentLocUnitId: objNewUnit.iOSAssignmentLocUnitId, assignmentId: objNewUnit.assignmentId)
        
        
    }
    
    
    func syncUpCompletion(completion: @escaping (()->()))
    {
        if let arrLocUnits = getAllNewUnits(){
            
            let locationUnitGroup = DispatchGroup()
            
            for locationUnit in arrLocUnits{
                
                var locationUnitDict:[String:String] = [:]
                var locationUnitParams:[String:String] = [:]
                
                
                locationUnitDict["unitName"] = locationUnit.unitName
                
                locationUnitDict["apartmentNumber"] = locationUnit.unitName
                
                locationUnitDict["privateHome"] = locationUnit.isPrivateHome
                
                locationUnitDict["virtualUnit"] = locationUnit.isVirtualUnit
                
                locationUnitDict["notes"] = locationUnit.notes
                
                locationUnitDict["locationId"] = locationUnit.locationId
                
                locationUnitDict["assignLocId"] = locationUnit.assignmentLocId
                
                locationUnitDict["iOSLocUnitId"] = locationUnit.iOSLoctionUnitId
                
                locationUnitDict["iOSAssignmentLocUnitId"] = locationUnit.iOSAssignmentLocUnitId
               
                
                locationUnitParams["unit"] = Utility.jsonToString(json: locationUnitDict as AnyObject)!
                
                let req = SFRestRequest(method: .POST, path: SalesforceRestApiUrl.createLocationUnit, queryParams: nil)
                
                do {
                    
                    let bodyData = try JSONSerialization.data(withJSONObject: locationUnitParams, options: [])
                    req.setCustomRequestBodyData(bodyData, contentType: "application/json")
                }
                catch{
                    
                    
                }
                
                req.endpoint = ""
                
                locationUnitGroup.enter()
                
                self.sendRequest(request: req, callback: { (response) in
                    
                    DispatchQueue.main.async {
                        
                        self.parseLocationUnit(jsonObject: response as! Dictionary<String, AnyObject>)
                        
                        locationUnitGroup.leave()
                        
                        print("LocationUnitGroup: \(locationUnit.unitName!)")
                    }
                    
                    
                    
                }) { (error) in
                    Logger.shared.log(level: .error, msg: error)
                    Utility.displayErrorMessage(errorMsg: error)
                    //failure(error)
                }
                
            }
            
            locationUnitGroup.notify(queue: .main) {
                completion()
            }
            
        }
        else{
            completion()
        }
        
        
    }
    
    func parseLocationUnit(jsonObject: Dictionary<String, AnyObject>){

        //locationUnitId
            //-> Contact
        
        guard let isError = jsonObject["hasError"] as? Bool,
            
            let message = jsonObject["message"] as? String,
            
            let unitDataDict = jsonObject["unitData"] as? [String: AnyObject] else { return}

        if(isError == false){
            
            //update locationUnitId and assignmentLocationUnitId
            updateLocationUnit(unitDataDict: unitDataDict)
            
            //update assignmentlocationUnitId
            updateAssignmentLocationUnit(unitDataDict: unitDataDict)
            
            //update locationUnitId and and assignmentLocationUnitId
            updateContact(unitDataDict: unitDataDict)

            //update assignmentlocationUnitId
            updateSurveyResponse(unitDataDict: unitDataDict)
            
           //update assignmentlocationUnitId
           updateCases(unitDataDict: unitDataDict)
            
             //update case notes
            updateAssignmentLocUnitInCaseNotes(unitDataDict: unitDataDict)
           
             //No need right now
            //update assignment notes

            
            
        }
        else{
            
            let errorMsg = "Error while adding new unit to salesforce.\(message)"
            
            Logger.shared.log(level: .error, msg: errorMsg)
            Utility.displayErrorMessage(errorMsg: errorMsg)
            
            
            
        }
        
        
        
    }
    
    func displayErrorMessage(errorMsg:String){
//        Utilities.isBackgroundSync = false
//        Utilities.isRefreshBtnClick = false
        
     //   SVProgressHUD.dismiss()
        //Utilities.showSwiftErrorMessage(error: errorMsg)
    }
    
    func updateSyncDate(assignmentLocUnitId:String){
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["syncDate"]  = Utility.currentDateAndTime() as AnyObject
        
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.locationUnit.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocUnitId == %@", predicateValue: assignmentLocUnitId,isPredicate: true)
        
        
    }
    
    
  
     func updateLocationUnit(unitDataDict:[String:AnyObject]){
        
        
        let locUnitId = unitDataDict["unitId"] as! String?
        let assignmentLocUnitId = unitDataDict["assignmentLocUnitId"] as! String?
        
        let iOSLocUnitId = unitDataDict["iOSLocUnitId"] as! String?
        
       
        
        var updateObjectDic:[String:AnyObject] = [:]
        updateObjectDic["locationUnitId"] = locUnitId as AnyObject
        updateObjectDic["assignmentLocUnitId"] = assignmentLocUnitId as AnyObject
        updateObjectDic["actionStatus"] = "" as AnyObject
        updateObjectDic["syncDate"]  = Utility.currentDateAndTime() as AnyObject
        
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.locationUnit.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "locationUnitId == %@", predicateValue: iOSLocUnitId,isPredicate: true)
        
        
    }
 
    func updateAssignmentLocationUnit(unitDataDict:[String:AnyObject]){
        
     
        let assignmentLocUnitId = unitDataDict["assignmentLocUnitId"] as! String?

        let iOSAssignmentLocUnitId = unitDataDict["iOSAssignmentLocUnitId"] as! String?
        
        var updateObjectDic:[String:AnyObject] = [:]
        updateObjectDic["assignmentLocUnitId"] = assignmentLocUnitId as AnyObject
        
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.locationUnit.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocUnitId == %@", predicateValue: iOSAssignmentLocUnitId,isPredicate: true)
        
    }
    
    func updateContact(unitDataDict:[String:AnyObject]){
        
        let locUnitId = unitDataDict["unitId"] as! String?
        let assignmentLocUnitId = unitDataDict["assignmentLocUnitId"] as! String?
       
        let iOSLocUnitId = unitDataDict["iOSLocUnitId"] as! String?
        
        let contactResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.contact.rawValue,predicateFormat: "locationUnitId == %@" ,predicateValue: iOSLocUnitId,isPredicate:true) as! [Contact]
        
        if(contactResults.count > 0){
            
            for _ in contactResults{
                
                var updateObjectDic:[String:AnyObject] = [:]
                updateObjectDic["locationUnitId"] = locUnitId as AnyObject
                updateObjectDic["assignmentLocUnitId"] = assignmentLocUnitId as AnyObject
             
                ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.contact.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "locationUnitId == %@", predicateValue: iOSLocUnitId,isPredicate: true)
            
                
                print("ContactResults update locationUnitId")
            }
        }
        
    }
    
    func updateSurveyResponse(unitDataDict:[String:AnyObject]){
        
       
        let assignmentLocUnitId = unitDataDict["assignmentLocUnitId"] as! String?
        
        let iOSAssignmentLocUnitId = unitDataDict["iOSAssignmentLocUnitId"] as! String?
        
         let surveyResResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.surveyResponse.rawValue,predicateFormat: "assignmentLocUnitId == %@" ,predicateValue: iOSAssignmentLocUnitId,isPredicate:true) as! [SurveyResponse]
        
        if(surveyResResults.count > 0){
            
            for _ in surveyResResults{
                
                var updateObjectDic:[String:AnyObject] = [:]
                updateObjectDic["assignmentLocUnitId"] = assignmentLocUnitId as AnyObject
                
                ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.surveyResponse.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocUnitId == %@", predicateValue: iOSAssignmentLocUnitId,isPredicate: true)
                
                
                print("SurveyResponse Results update assignmentlocunitId")
            }
        }
        
        
    }
    
    func updateCases(unitDataDict:[String:AnyObject]){
        
        
        let assignmentLocUnitId = unitDataDict["assignmentLocUnitId"] as! String?
        
        let iOSAssignmentLocUnitId = unitDataDict["iOSAssignmentLocUnitId"] as! String?
        
        let caseResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.cases.rawValue,predicateFormat: "assignmentLocUnitId == %@" ,predicateValue: iOSAssignmentLocUnitId,isPredicate:true) as! [Cases]
        
        if(caseResults.count > 0){
            
            for _ in caseResults{
                
                var updateObjectDic:[String:AnyObject] = [:]
                updateObjectDic["assignmentLocUnitId"] = assignmentLocUnitId as AnyObject
                
                ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.cases.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocUnitId == %@", predicateValue: iOSAssignmentLocUnitId,isPredicate: true)
                
                
                print("Case Results update assignmentlocunitId")
            }
        }
        
        
    }
    
    
    func updateAssignmentLocUnitInCaseNotes(unitDataDict:[String:AnyObject]){
        
        
        let assignmentLocUnitId = unitDataDict["assignmentLocUnitId"] as! String?
        
        let iOSAssignmentLocUnitId = unitDataDict["iOSAssignmentLocUnitId"] as! String?
        
        let caseNotesResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.caseNotes.rawValue,predicateFormat: "assignmentLocUnitId == %@" ,predicateValue: iOSAssignmentLocUnitId,isPredicate:true) as! [CaseNotes]
        
        if(caseNotesResults.count > 0){
            
            for _ in caseNotesResults{
                
                var updateObjectDic:[String:AnyObject] = [:]
                updateObjectDic["assignmentLocUnitId"] = assignmentLocUnitId as AnyObject
                
                ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.caseNotes.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocUnitId == %@", predicateValue: iOSAssignmentLocUnitId,isPredicate: true)
                
                
                print("Case Notes Results update assignmentlocunitId")
            }
        }
        
        
    }
    
    
    
    
    func getAllNewUnits()->[LocationUnit]?{
        
        let locUnitResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.locationUnit.rawValue ,predicateFormat: "actionStatus == %@",predicateValue:actionStatus.create.rawValue, isPredicate:true) as? [LocationUnit]

        return locUnitResults
        
    }
    
    func getSalesforceLocationUnitId(iOSLocUnitId:String)->String{
        
        var locationUnitId:String = ""
        
        let locationUnitRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.locationUnit.rawValue,predicateFormat: "iOSLoctionUnitId == %@" ,predicateValue: iOSLocUnitId, isPredicate:true) as! [LocationUnit]
        
        if(locationUnitRes.count > 0){
            locationUnitId = (locationUnitRes.first?.locationUnitId)!
        }
        
        return locationUnitId
    }
    
    
    func getSalesforceAssignmentLocationUnitId(iOSAssignmentLocUnitId:String)->String{
        
        var assignmentLocationUnitId:String = ""
        
        let locationUnitRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.locationUnit.rawValue,predicateFormat: "iOSAssignmentLocUnitId == %@" ,predicateValue: iOSAssignmentLocUnitId, isPredicate:true) as! [LocationUnit]
        
        if(locationUnitRes.count > 0){
            assignmentLocationUnitId = (locationUnitRes.first?.assignmentLocUnitId)!
        }
        
        return assignmentLocationUnitId
    }
    
    
    
    
    
    


}
