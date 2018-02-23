//
//  AssignmentLocationUnitAPI.swift
//  EngageNYC
//
//  Created by Kamal on 14/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation
import SalesforceSDKCore

final class CaseAPI:SFCommonAPI {
    
    
    private static var sharedInstance: CaseAPI = {
        let instance = CaseAPI()
        return instance
    }()
    
    class var shared:CaseAPI!{
        get{
            return sharedInstance
        }
    }
    
    func getAllUpdatedCases() -> [Cases]?{
        
        let caseResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.cases.rawValue ,predicateFormat: "actionStatus == %@ || actionStatus == %@",predicateValue:actionStatus.create.rawValue,predicateValue2: actionStatus.edit.rawValue, isPredicate:true) as? [Cases]
        
        return caseResults
    }
    
    func updateClientId(salesforceClientId:String,iOSClientId:String){
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["clientId"] = salesforceClientId as AnyObject
        
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.cases.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "clientId == %@", predicateValue:  iOSClientId,isPredicate: true)
        
    }
    
    
    func updateAssignmentLocationUnitId(salesforceAssignmentLocUnitId:String,iOSAssignmentLocUnitId:String){
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["assignmentLocUnitId"] = salesforceAssignmentLocUnitId as AnyObject
        
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.cases.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocUnitId == %@", predicateValue:  iOSAssignmentLocUnitId,isPredicate: true)
        
    }
    
    
    func syncUpCompletion(completion: @escaping (()->()))
    {
        if let arrCases = getAllUpdatedCases(){
            
            let caseGroup = DispatchGroup()
            
            for caseData in arrCases{
                
                var caseDict:[String:AnyObject] = [:]
                var caseParams:[String:String] = [:]
                
                
                var sfdcClientId = caseData.clientId
                
                
                
                //...........assignmentLocUnit info
                
                //update clientId
                let isiOSClientId = Utility.isiOSGeneratedId(generatedId: sfdcClientId!)
                
                //if isiOSClientId is a UUID string then get salesforce contactId from contact object
                if(isiOSClientId != nil){
                    let contactId = ContactAPI.shared.getSalesforceClientId(iOSClientId: sfdcClientId!)
                    
                    sfdcClientId = contactId //update contact id here
                    
                    if(Utility.isiOSGeneratedId(generatedId: contactId) != nil){
                        print("Error:- ios contactId")
                        return
                    }
                    else{
                        //update contactId here
                        
                        //updateClientId(salesforceClientId: contactId, iOSClientId: caseData.clientId!)
                    }
                }
                
                
               
                
                
                var caseResponseDict = caseData.caseResponse as! Dictionary<String,AnyObject>
                
                caseResponseDict["ContactId"] = sfdcClientId as AnyObject?
                caseResponseDict["OwnerId"] = caseData.caseOwnerId as AnyObject?
                
                
                caseDict["caseResponse"] = Utility.jsonToString(json: caseResponseDict as AnyObject) as AnyObject
                
                caseDict["iOSCaseId"] = caseData.caseId as AnyObject?
                
              
                caseParams["jsonCase"] = Utility.jsonToString(json: caseDict as AnyObject)!
                
                let req = SFRestRequest(method: .POST, path: SalesforceRestApiUrl.createCase, queryParams: nil)
                
                do {
                    
                    let bodyData = try JSONSerialization.data(withJSONObject: caseParams, options: [])
                    req.setCustomRequestBodyData(bodyData, contentType: "application/json")
                }
                catch{
                    
                    
                }
                
                req.endpoint = ""
                
                caseGroup.enter()
                
                self.sendRequest(request: req, callback: { (response) in
                    
                    DispatchQueue.main.async {
                        
                        self.parseCase(jsonObject: response as! Dictionary<String, AnyObject>)
                        
                        caseGroup.leave()
                        
                        print("CaseGroup: \(caseData.caseId!)")
                    }
                    
                    
                    
                }) { (error) in
                    
                   
                    Logger.shared.log(level: .error, msg: error)
                    Utility.displayErrorMessage(errorMsg: error)
                    
                    print(error)
                  
                }
                
            }
            
            caseGroup.notify(queue: .main) {
                completion()
            }
            
        }
        else{
            completion()
        }
        
        
    }
    
    
    func parseCase(jsonObject: Dictionary<String, AnyObject>){
        
        guard let isError = jsonObject["hasError"] as? Bool,
            
            let message = jsonObject["message"] as? String,
            
            let caseDataDictonary = jsonObject["caseData"] as? [String: AnyObject] else { return }
        
        
        if(isError == false){
            
            updateCaseIdInCoreData(caseDataDict: caseDataDictonary)
            
            
//            updateCaseIdInIssue(caseDataDict: caseDataDictonary)
//            updateCaseIdInCaseNotes(caseDataDict: caseDataDictonary)
            
        }
        else{
            let errorMsg = "Error while adding new case to salesforce.\(message)"
            
            Logger.shared.log(level: .error, msg: errorMsg)
            Utility.displayErrorMessage(errorMsg: errorMsg)
          
        }
        
    
        
        
    }
    
    func updateCaseIdInCoreData(caseDataDict:[String:AnyObject]){
        
        
        let iOSCaseId = caseDataDict["iOSCaseId"] as! String?
        let caseId = caseDataDict["caseId"] as! String?
        let caseNumber = caseDataDict["caseNo"] as! String?
        
        
        let caseResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.cases.rawValue,predicateFormat: "caseId == %@" ,predicateValue: iOSCaseId, isPredicate:true) as! [Cases]
        
        
        
        if(caseResults.count > 0){
            
            var updateObjectDic:[String:AnyObject] = [:]
            updateObjectDic["caseId"] = caseId as AnyObject
            updateObjectDic["caseNo"] = caseNumber as AnyObject
            updateObjectDic["actionStatus"] = "" as AnyObject
            updateObjectDic["caseNotes"] = "" as AnyObject
            
            ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.cases.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "caseId == %@", predicateValue: iOSCaseId,isPredicate: true)
            
            print("update CaseIdInCoreData")
            
        }
        
    }
    
    func updateCaseIdInCaseNotes(caseDataDict:[String:AnyObject]){
        
        let iOSCaseId = caseDataDict["iOSCaseId"] as! String?
        let caseId = caseDataDict["caseId"] as! String?
        
        
        let caseNotesResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.caseNotes.rawValue,predicateFormat: "caseId == %@ && actionStatus == %@" ,predicateValue: iOSCaseId,predicateValue2: actionStatus.edit.rawValue ,isPredicate:true) as! [CaseNotes]
        
        
        
        if(caseNotesResults.count > 0){
            
            var updateObjectDic:[String:AnyObject] = [:]
            updateObjectDic["caseId"] = caseId as AnyObject
            updateObjectDic["actionStatus"] = "" as AnyObject
          
            
            ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.caseNotes.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "caseId == %@ && actionStatus == %@" ,predicateValue: iOSCaseId,predicateValue2: actionStatus.edit.rawValue ,isPredicate:true)
            
            print("update CaseNotes InCoreData")
            
        }
        
    }
    
    func updateCaseIdInIssue(caseDataDict:[String:AnyObject]){
        
        let iOSCaseId = caseDataDict["iOSCaseId"] as! String?
        let caseId = caseDataDict["caseId"] as! String?
        
        
        
        let issueResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.issues.rawValue,predicateFormat: "caseId == %@" ,predicateValue: iOSCaseId, isPredicate:true) as! [Issues]
        
        if(issueResults.count > 0){
        
            for _ in issueResults{
                
                
                var updateObjectDic:[String:AnyObject] = [:]
                updateObjectDic["caseId"] = caseId as AnyObject
                
                ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.issues.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "caseId == %@", predicateValue: iOSCaseId,isPredicate: true)
                
                print("update CaseIdInIssue")
                
                
            }
        }
        
        
        
    }
    
    
    
    
    /// Get all the cases from core data.
    ///
    /// - Returns: array of cases.
    func getAllCases(assignmentId:String,assignmentLocId:String)->[Cases]? {
        
        let casesRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.cases.rawValue,predicateFormat: "assignmentId == %@ && assignmentLocId == %@",predicateValue: assignmentId,predicateValue2: assignmentLocId, isPredicate:true) as? [Cases]
        
       
        return casesRes
        
    }
    
    
  
    
    /// Get all the open cases from core data.
    ///
    /// - Returns: array of cases.
    func getAllOpenCases(assignmentId:String,assignmentLocId:String)->[Cases]? {
        
        let casesRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.cases.rawValue,predicateFormat: "assignmentId == %@ && assignmentLocId == %@ && caseStatus == %@",predicateValue: assignmentId,predicateValue2: assignmentLocId,predicateValue3: enumCaseStaus.open.rawValue, isPredicate:true) as? [Cases]
        
        
        return casesRes
        
    }
    
    /// Get all the cases from core data.
    ///
    /// - Returns: array of cases.
    func getAllCasesOnClient(clientId:String,assignmentLocUnitId:String)->[Cases]? {
        
        let casesRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.cases.rawValue,predicateFormat: "clientId == %@ && assignmentLocUnitId == %@",predicateValue: clientId,predicateValue2: assignmentLocUnitId, isPredicate:true) as? [Cases]
        
        
        return casesRes
        
    }
    
    /// Get case config from core data.
    ///
    /// - Returns: metadataconfig.
    func getCaseConfig()->MetadataConfig? {
        
        let caseConfigResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.metadataConfig.rawValue ,predicateFormat: "type == %@", predicateValue: MetadataConfigEnum.cases.rawValue,isPredicate:true) as! [MetadataConfig]
        
        if(caseConfigResults.count > 0){
            return caseConfigResults.first
        }
        
        return nil
    }
    
    func getAllTempCasesOnAssigmentLocationUnit(assignmentLocUnitId:String)->[Cases]?{
        
        let tempCaseResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.cases.rawValue,predicateFormat: "assignmentLocUnitId == %@ && actionStatus == %@",predicateValue: assignmentLocUnitId, predicateValue2: actionStatus.temp.rawValue, isPredicate:true) as? [Cases]
        
        return tempCaseResults
        
    }
    
    
    /// Get all the issues notes from core data.
    ///
    /// - Returns: array of issues notes.
    func getAllCaseNotesOnCase(caseId:String,assignmentLocUnitId:String)->[CaseNotes]? {
        
        
        let caseNotesRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.caseNotes.rawValue,predicateFormat: "caseId == %@ && assignmentLocUnitId == %@",predicateValue: caseId,predicateValue2: assignmentLocUnitId, isPredicate:true) as? [CaseNotes]
        
        
        return caseNotesRes
        
    }
    
    func isTempCaseExist(assignmentLocUnitId:String)->Bool{
        
        let tempCaseResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.cases.rawValue,predicateFormat: "assignmentLocUnitId == %@ && actionStatus == %@",predicateValue: assignmentLocUnitId, predicateValue2: actionStatus.temp.rawValue, isPredicate:true) as! [Cases]
        
        if(tempCaseResults.count > 0){
            return true
        }
         return false
        
    }
    
    
    func saveCase(objCase:CaseDO){
        
        let caseData = Cases(context:context)
        caseData.caseId = UUID().uuidString
        caseData.caseNo = ""
        caseData.assignmentId = objCase.assignmentId
        caseData.caseOwner = objCase.ownerName
        caseData.caseOwnerId = objCase.ownerId
        caseData.clientId = objCase.clientId
        caseData.caseDynamic = objCase.caseApiResponseDict as NSObject
        caseData.assignmentLocId = objCase.assignmentLocId
        caseData.assignmentLocUnitId = objCase.assignmentLocUnitId
        caseData.iOSCaseId =  caseData.caseId
        caseData.caseStatus = enumCaseStaus.open.rawValue
        
        caseData.caseResponse = objCase.caseApiResponseDict as NSObject
        caseData.caseNotes = objCase.caseNotes
        caseData.createdDate = objCase.dateOfIntake
      
        
        if(objCase.clientId.isEmpty){
             caseData.actionStatus = actionStatus.temp.rawValue
        }
        else{
            caseData.actionStatus = actionStatus.create.rawValue
        }
        
        
        
        appDelegate.saveContext()
      
       if(!objCase.caseNotes.isEmpty){
            saveCaseNotes(caseId: caseData.caseId!, objCase: objCase)
        }
        
    }
    
    func saveCaseNotes(caseId:String,objCase:CaseDO){
        
        let caseNoteObject = CaseNotes(context:context)
        
        caseNoteObject.caseId = caseId
        
        caseNoteObject.createdDate = Utility.currentDateAndTime()
        caseNoteObject.notes = objCase.caseNotes
        
        caseNoteObject.actionStatus = actionStatus.edit.rawValue
        
        caseNoteObject.assignmentLocUnitId = objCase.assignmentLocUnitId
        
        caseNoteObject.assignmentId = objCase.assignmentId
        
        appDelegate.saveContext()
        
    }
    
   
    
    func updateAllTempCases(clientId:String,assignmentLocUnitId:String){
        
        if let tempCaseResults = getAllTempCasesOnAssigmentLocationUnit(assignmentLocUnitId: assignmentLocUnitId){
            
            for tempCaseData in tempCaseResults{
                
                var updateObjectDic:[String:AnyObject] = [:]
                
                updateObjectDic["clientId"] = clientId as AnyObject
                updateObjectDic["actionStatus"] = actionStatus.create.rawValue as AnyObject
                
                ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.cases.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "caseId == %@ && actionStatus == %@", predicateValue: tempCaseData.caseId,predicateValue2: actionStatus.temp.rawValue, isPredicate: true)
                
            }
            
        }
        
        
        
    }
    
    
    func updateCaseNotes(objCase:CaseDO){
        
        if(checkCaseNotesExist(objCase: objCase)){
            
            if(objCase.caseNotes.isEmpty){
                
                ManageCoreData.deleteRecord(salesforceEntityName: coreDataEntity.caseNotes.rawValue, predicateFormat: "caseId == %@ && actionStatus == %@ && assignmentLocUnitId == %@", predicateValue: objCase.caseId,predicateValue2:actionStatus.edit.rawValue, predicateValue3: objCase.assignmentLocUnitId, isPredicate: true)
                
                
            }
            else{
                
                var updateObjectDic:[String:AnyObject] = [:]
                updateObjectDic["notes"] = objCase.caseNotes as AnyObject?
                updateObjectDic["createdDate"] = Utility.currentDateAndTime() as AnyObject?
                
                
                
                ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.caseNotes.rawValue , updateKeyValue: updateObjectDic, predicateFormat: "caseId == %@ && actionStatus == %@ && assignmentLocUnitId == %@", predicateValue: objCase.caseId,predicateValue2:actionStatus.edit.rawValue, predicateValue3: objCase.assignmentLocUnitId, isPredicate: true)
            }
            
            
        }
        else{
            if(!objCase.caseNotes.isEmpty){
                saveCaseNotes(caseId: objCase.caseId, objCase: objCase)
            }
            
        }
        
    }
    
    func checkCaseNotesExist(objCase:CaseDO)->Bool{
        
        let caseNotesResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.caseNotes.rawValue,predicateFormat: "caseId == %@ && actionStatus == %@ && assignmentLocUnitId == %@", predicateValue: objCase.caseId,predicateValue2:actionStatus.edit.rawValue, predicateValue3: objCase.assignmentLocUnitId, isPredicate: true) as! [CaseNotes]
        
        if(caseNotesResults.count > 0){
            return true
        }
        return false
        
    }
    
   
    
    func deleteTempCaseRecords(){
        ManageCoreData.deleteRecord(salesforceEntityName: coreDataEntity.cases.rawValue, predicateFormat: "actionStatus == %@", predicateValue: actionStatus.temp.rawValue, isPredicate: true)
    }
    
    func deleteTempCase(objCase:CaseDO){
        ManageCoreData.deleteRecord(salesforceEntityName: coreDataEntity.cases.rawValue, predicateFormat: "caseId == %@", predicateValue: objCase.caseId, isPredicate: true)
        
        ManageCoreData.deleteRecord(salesforceEntityName: coreDataEntity.caseNotes.rawValue, predicateFormat: "caseId == %@", predicateValue: objCase.caseId, isPredicate: true)
    }
    
    
    
    func getSalesforceCaseId(iOSCaseId:String)->String{
        
        var caseId:String = ""
        
        let caseRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.cases.rawValue,predicateFormat: "iOSCaseId == %@" ,predicateValue: iOSCaseId, isPredicate:true) as! [Cases]
        
        if(caseRes.count > 0){
            caseId = (caseRes.first?.caseId)!
        }
        
        return caseId
    }
    
    
}

extension CaseAPI{
    
   
    
    func updateCase(objCase:CaseDO){
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["caseNotes"] = objCase.caseNotes as AnyObject?
        updateObjectDic["caseResponse"] = objCase.caseApiResponseDict as AnyObject?
        updateObjectDic["createdDate"] = objCase.dateOfIntake as AnyObject?
        updateObjectDic["caseDynamic"] = objCase.caseApiResponseDict as AnyObject?
        updateObjectDic["assignmentLocUnitId"] = objCase.assignmentLocUnitId as AnyObject?
        
        
        updateObjectDic["caseNotes"] = objCase.caseNotes as AnyObject?
        
        
        //only Edit when actionStatus is blank
        
        if(objCase.dbActionStatus.isEmpty){
            updateObjectDic["actionStatus"] = actionStatus.edit.rawValue as AnyObject?
        }
        
        let queryString = getQueryString(caseId: objCase.caseId) + "&& assignmentLocId == %@"
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.cases.rawValue , updateKeyValue: updateObjectDic, predicateFormat: queryString, predicateValue: objCase.caseId,predicateValue2: objCase.assignmentLocId, isPredicate: true)
        
        
        updateCaseNotes(objCase: objCase)
        
    }
    
    
    
    func getQueryString(caseId:String)->String{
        
        var queryString = ""
        let isiOSCaseId = Utility.isiOSGeneratedId(generatedId: caseId)
        
        //if isiOSCaseId is a UUID string
        if(isiOSCaseId != nil){
            queryString = "iOSCaseId == %@"
        }
        else{
            queryString = "caseId == %@"
        }
        
        return queryString
        
        
    }
    
    
    
}

