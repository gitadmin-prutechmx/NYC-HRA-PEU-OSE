//
//  IssueAPI.swift
//  EngageNYC
//
//  Created by Kamal on 27/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation
import SalesforceSDKCore

final class IssueAPI:SFCommonAPI {
    
    
    private static var sharedInstance: IssueAPI = {
        let instance = IssueAPI()
        return instance
    }()
    
    class var shared:IssueAPI!{
        get{
            return sharedInstance
        }
    }
    
    func getAllUpdatedIssues() -> [Issues]?{
        
        let issueResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.issues.rawValue ,predicateFormat: "actionStatus == %@ || actionStatus == %@",predicateValue:actionStatus.create.rawValue,predicateValue2: actionStatus.edit.rawValue, isPredicate:true) as? [Issues]
        
        return issueResults
    }
    
    func updateCaseId(salesforceCaseId:String,iOSCaseId:String){
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["caseId"] = salesforceCaseId as AnyObject
        
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.issues.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "caseId == %@", predicateValue:  iOSCaseId,isPredicate: true)
        
    }
    
    
    
    
    func syncUpCompletion(completion: @escaping (()->()))
    {
        if let arrIssues = getAllUpdatedIssues(){
            
            let issueGroup = DispatchGroup()
            
            for issueData in arrIssues{
                
                var issueDict:[String:AnyObject] = [:]
                var issueParams:[String:String] = [:]
                
                
                
                //...........
                
                let isiOSCaseId = Utility.isiOSGeneratedId(generatedId: issueData.caseId!)
                
                //if isiOSClientId is a UUID string then get salesforce contactId from contact object
                if(isiOSCaseId != nil){
                    let caseId = CaseAPI.shared.getSalesforceCaseId(iOSCaseId: issueData.caseId!)
                    
                    issueData.caseId = caseId //update case id here
                    
                    if(Utility.isiOSGeneratedId(generatedId: caseId) != nil){
                        print("Error:- ios caseId")
                        return
                    }
                    else{
                        //update caseId here
                        updateCaseId(salesforceCaseId: caseId, iOSCaseId: issueData.caseId!)
                    }
                }
                
                
                if(issueData.actionStatus == actionStatus.edit.rawValue){
                   issueDict["issueId"] = issueData.issueId as AnyObject?
                   issueDict["iOSIssueId"] = issueData.issueId as AnyObject
                }
                else{
                    issueDict["iOSIssueId"] = issueData.issueId as AnyObject
                }
                
              
                
                issueDict["caseId"] = issueData.caseId as AnyObject?
                
                issueDict["issueType"] = issueData.issueType as AnyObject?
                
                issueDict["issueNotes"] = issueData.notes as AnyObject?
                
                
                issueParams["jsonIssue"] = Utility.jsonToString(json: issueDict as AnyObject)!
                
                let req = SFRestRequest(method: .POST, path: SalesforceRestApiUrl.createIssue, queryParams: nil)
                
                do {
                    
                    let bodyData = try JSONSerialization.data(withJSONObject: issueParams, options: [])
                    req.setCustomRequestBodyData(bodyData, contentType: "application/json")
                }
                catch{
                    
                    
                }
                
                req.endpoint = ""
                
                issueGroup.enter()
                
                self.sendRequest(request: req, callback: { (response) in
                    
                    DispatchQueue.main.async {
                        
                        self.parseIssue(jsonObject: response as! Dictionary<String, AnyObject>)
                        
                        issueGroup.leave()
                        
                        print("IssueGroup: \(issueData.issueId!)")
                    }
                    
                    
                    
                }) { (error) in
                    Logger.shared.log(level: .error, msg: error)
                    Utility.displayErrorMessage(errorMsg: error)
                    //failure(error)
                }
                
            }
            
            issueGroup.notify(queue: .main) {
                completion()
            }
            
        }
        else{
            completion()
        }
        
        
    }
    
    func parseIssue(jsonObject: Dictionary<String, AnyObject>){
        
        guard let isError = jsonObject["hasError"] as? Bool,
            
            let message = jsonObject["message"] as? String,
            
            let issueDataDictonary = jsonObject["issueData"] as? [String: AnyObject] else { return }
        
        
        
        
        if(isError == false){
            
            updateIssueIdInCoreData(issueDataDict: issueDataDictonary)
            updateIssueIdInIssueNotes(issueDataDict: issueDataDictonary)
            
        }
        else{
            let errorMsg = "Error while adding new issue to salesforce.\(message)"
            
            Logger.shared.log(level: .error, msg: errorMsg)
            Utility.displayErrorMessage(errorMsg: errorMsg)
           
            
        }
        
        
        
        
    }
    
    func updateIssueIdInCoreData(issueDataDict:[String:AnyObject]){
        
        let iOSIssueId = issueDataDict["iOSIssueId"] as! String?
        let issueId = issueDataDict["issueId"] as! String?
        let issueNo = issueDataDict["issueNumber"] as! String?
        
       
        
        let issueResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.issues.rawValue,predicateFormat: "issueId == %@" ,predicateValue: iOSIssueId, isPredicate:true) as! [Issues]
        
        
        
        if(issueResults.count > 0){
            
            var updateObjectDic:[String:AnyObject] = [:]
            updateObjectDic["issueId"] = issueId as AnyObject
            updateObjectDic["issueNo"] = issueNo as AnyObject
            updateObjectDic["actionStatus"] = "" as AnyObject
            updateObjectDic["notes"] = "" as AnyObject
            
            ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.issues.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "issueId == %@", predicateValue: iOSIssueId,isPredicate: true)
            
            
            
        }
        
        
    }
    
    
    func updateIssueIdInIssueNotes(issueDataDict:[String:AnyObject]){
        
        let iOSIssueId = issueDataDict["iOSIssueId"] as! String?
        let issueId = issueDataDict["issueId"] as! String?
        
        
        let issueNotesResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.issueNotes.rawValue,predicateFormat: "issueId == %@ && actionStatus == %@" ,predicateValue: iOSIssueId,predicateValue2: actionStatus.edit.rawValue ,isPredicate:true) as! [IssueNotes]
        
        
        
        if(issueNotesResults.count > 0){
            
            var updateObjectDic:[String:AnyObject] = [:]
            updateObjectDic["issueId"] = issueId as AnyObject
            updateObjectDic["actionStatus"] = "" as AnyObject
            
            
            ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.issueNotes.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "issueId == %@ && actionStatus == %@" ,predicateValue: iOSIssueId,predicateValue2: actionStatus.edit.rawValue ,isPredicate:true)
            
            print("update IssueNotes InCoreData")
            
        }
        
    }
    
    
    
    
    /// Get all the issues notes from core data.
    ///
    /// - Returns: array of issues notes.
    func getAllIssuesNotesOnIssue(issueId:String,assignmentId:String)->[IssueNotes]? {
        
        let issuesNotesRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.issueNotes.rawValue,predicateFormat: "issueId == %@ && assignmentId == %@",predicateValue: issueId,predicateValue2: assignmentId, isPredicate:true) as? [IssueNotes]
        
        
        return issuesNotesRes
        
    }
    
    
    
    /// Get all the issues from core data.
    ///
    /// - Returns: array of issues.
    func getAllIssuesOnCase(caseId:String,assignmentId:String)->[Issues]? {
        
        let issuesRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.issues.rawValue,predicateFormat: "caseId == %@ && assignmentId == %@",predicateValue: caseId,predicateValue2: assignmentId, isPredicate:true) as? [Issues]
        
        
        return issuesRes
        
    }
    
    func getAllTempIssuesOnAssignment(assignmentId:String)->[Issues]?{
        
        let tempIssueResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.issues.rawValue,predicateFormat: "assignmentId == %@ && actionStatus == %@",predicateValue: assignmentId, predicateValue2: actionStatus.temp.rawValue, isPredicate:true) as? [Issues]
        
        return tempIssueResults
        
    }
    
    func isTempIssueExist(assignmentId:String)->Bool{
        
        let tempIssueResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.issues.rawValue,predicateFormat: "assignmentId == %@ && actionStatus == %@",predicateValue: assignmentId, predicateValue2: actionStatus.temp.rawValue, isPredicate:true) as! [Issues]
        
        if(tempIssueResults.count > 0){
            return true
        }
        return false
        
    }
    
    
    func saveIssue(objIssue:IssueDO){
        
        let issueData = Issues(context:context)
        issueData.issueId = UUID().uuidString
        issueData.issueNo = ""
        issueData.issueType = objIssue.issueType
        issueData.assignmentId = objIssue.assignmentId
        issueData.caseId = objIssue.caseId
        issueData.notes = objIssue.notes

        
        if(objIssue.caseId.isEmpty){
            issueData.actionStatus = actionStatus.temp.rawValue
        }
        else{
            issueData.actionStatus = actionStatus.create.rawValue
        }
        
        appDelegate.saveContext()
        
        
        if(!objIssue.notes.isEmpty){
            saveIssueNotes(issueId: issueData.issueId!, objIssue: objIssue)
        }
        
        
    }
    
    func saveIssueNotes(issueId:String,objIssue:IssueDO){
        
        let issueNoteObject = IssueNotes(context:context)
        
        issueNoteObject.issueId = issueId
        
        issueNoteObject.createdDate = Utility.currentDateAndTime()
        
        issueNoteObject.notes = objIssue.notes
        
        issueNoteObject.actionStatus = actionStatus.edit.rawValue
        
        issueNoteObject.assignmentId = objIssue.assignmentId
        
        appDelegate.saveContext()
       
        
    }
    
    func updateIssueNotes(objIssue:IssueDO){
        
        if(checkIssueNotesExist(objIssue: objIssue)){
            
            if(objIssue.notes.isEmpty){
                
                ManageCoreData.deleteRecord(salesforceEntityName: coreDataEntity.issueNotes.rawValue, predicateFormat: "issueId == %@ && actionStatus == %@ && assignmentId == %@", predicateValue: objIssue.issueId,predicateValue2:actionStatus.edit.rawValue, predicateValue3: objIssue.assignmentId, isPredicate: true)
                
                
            }
            else{
                
                var updateObjectDic:[String:AnyObject] = [:]
                updateObjectDic["notes"] = objIssue.notes as AnyObject?
                updateObjectDic["createdDate"] = Utility.currentDateAndTime() as AnyObject?
                
                
                
                ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.issueNotes.rawValue , updateKeyValue: updateObjectDic, predicateFormat: "issueId == %@ && actionStatus == %@ && assignmentId == %@", predicateValue: objIssue.issueId,predicateValue2:actionStatus.edit.rawValue, predicateValue3: objIssue.assignmentId, isPredicate: true)
            }
            
            
        }
        else{
            if(!objIssue.notes.isEmpty){
                saveIssueNotes(issueId: objIssue.issueId, objIssue: objIssue)
            }
            
        }
        
    }
    
    func checkIssueNotesExist(objIssue:IssueDO)->Bool{
        
        let issueNotesResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.issueNotes.rawValue,predicateFormat: "issueId == %@ && actionStatus == %@ && assignmentId == %@", predicateValue: objIssue.issueId,predicateValue2:actionStatus.edit.rawValue, predicateValue3: objIssue.assignmentId, isPredicate: true) as! [IssueNotes]
        
        if(issueNotesResults.count > 0){
            return true
        }
        return false
        
    }
    
    
    
    
    func updateIssue(objIssue:IssueDO){
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["issueType"] = objIssue.issueType as AnyObject?
        
        
        updateObjectDic["notes"] = objIssue.notes as AnyObject?
        
        
        //only Edit when actionStatus is blank
        if(objIssue.dbActionStatus.isEmpty){
            updateObjectDic["actionStatus"] = actionStatus.edit.rawValue as AnyObject?
        }
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.issues.rawValue , updateKeyValue: updateObjectDic, predicateFormat: "issueId == %@ && assignmentId == %@", predicateValue:  objIssue.issueId,predicateValue2: objIssue.assignmentId, isPredicate: true)
        
        
         updateIssueNotes(objIssue: objIssue)
        
    }
    
    
    
    func updateAllTempIssues(caseId:String,assignmentId:String,tempCaseId:String){
        
        if let tempIssueResults = getAllTempIssuesOnAssignment(assignmentId: assignmentId){
            
            for tempIssueData in tempIssueResults{
                
                
                var updateObjectDic:[String:AnyObject] = [:]
                
                if(!caseId.isEmpty){
                    updateObjectDic["caseId"] = caseId as AnyObject
                }
                else{
                    updateObjectDic["caseId"] = tempCaseId as AnyObject
                }
                updateObjectDic["actionStatus"] = actionStatus.create.rawValue as AnyObject
                
                
                ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.issues.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "issueId == %@ && actionStatus == %@", predicateValue: tempIssueData.issueId,predicateValue2: actionStatus.temp.rawValue, isPredicate: true)
                
                
            }
            
        }
        
        
        
    }
    
    func deleteIssueTempRecord(){
        ManageCoreData.deleteRecord(salesforceEntityName: coreDataEntity.issues.rawValue, predicateFormat: "actionStatus == %@", predicateValue: actionStatus.temp.rawValue, isPredicate: true)
    }
    
    
    
}
