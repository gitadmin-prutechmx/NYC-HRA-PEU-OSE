//
//  SurveyAPI.swift
//  EngageNYC
//
//  Created by Kamal on 21/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation
import SalesforceSDKCore

final class SurveyAPI:SFCommonAPI{
    
    private static var sharedInstance: SurveyAPI = {
        let instance = SurveyAPI()
        return instance
    }()
    
    class var shared:SurveyAPI!{
        get{
            return sharedInstance
        }
    }
    
    func getAllUpdatedSurveyResponses() -> [SurveyResponse]?{
        
        let surveyResponseRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.surveyResponse.rawValue ,predicateFormat: "actionStatus == %@",predicateValue:actionStatus.completeSurvey.rawValue, isPredicate:true) as? [SurveyResponse]
        
        return surveyResponseRes
    }
    
    func updateAssignmentLocationUnitId(salesforceAssignmentLocUnitId:String,iOSAssignmentLocUnitId:String){
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["assignmentLocUnitId"] = salesforceAssignmentLocUnitId as AnyObject
        
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.surveyResponse.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocUnitId == %@", predicateValue:  iOSAssignmentLocUnitId,isPredicate: true)
        
    }
    
    func updateClientId(salesforceClientId:String,iOSClientId:String){
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["clientId"] = salesforceClientId as AnyObject
        
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.surveyResponse.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "clientId == %@", predicateValue:  iOSClientId,isPredicate: true)
        
    }
    
    
    
    
    func syncUpCompletion(completion: @escaping (()->()))
    {
        if let arrSurveyResponses = getAllUpdatedSurveyResponses(){
            
            let surveyResGroup = DispatchGroup()
            
            for surveyRes in arrSurveyResponses{
                
                var surveyResDict:[String:AnyObject] = [:]
                var surveyResParams:[String:String] = [:]
                
                
             
                
                //...........assignmentLocUnit info
                
                let isiOSAssignmentLocUnitId = Utility.isiOSGeneratedId(generatedId: surveyRes.assignmentLocUnitId!)
                
                //if isiOSLocationUnitId is a UUID string then get salesforce assignmentlocationUnit from unit object
                if(isiOSAssignmentLocUnitId != nil){
                    let assignmentLocUnitId = LocationUnitAPI.shared.getSalesforceAssignmentLocationUnitId(iOSAssignmentLocUnitId: surveyRes.assignmentLocUnitId!)

                    surveyRes.assignmentLocUnitId = assignmentLocUnitId //update assignmentlocUnitId
                    
                    if(Utility.isiOSGeneratedId(generatedId: assignmentLocUnitId) != nil){
                        print("Error:- ios assignmentlocationunitid")
                        return
                    }
                    else{
                        //update assignmentLocationUnitId here
                        
                        //updateAssignmentLocationUnitId(salesforceAssignmentLocUnitId: assignmentLocUnitId, iOSAssignmentLocUnitId: surveyRes.assignmentLocUnitId!)
                    }
                }
                
                if(surveyRes.clientId != noClientName.unknown.rawValue){
                    
                    let isiOSClientId = Utility.isiOSGeneratedId(generatedId: surveyRes.clientId!)
                    
                    //if isiOSClientId is a UUID string then get salesforce clientid from contact object
                    if(isiOSClientId != nil){
                        let clientId = ContactAPI.shared.getSalesforceClientId(iOSClientId: surveyRes.clientId!)
                        
                         surveyRes.clientId = clientId //update clientId
                        
                        if(Utility.isiOSGeneratedId(generatedId: clientId) != nil){
                            print("Error:- ios clientId")
                            return
                        }
                        else{
                            //update assignmentLocationUnitId here
                            
                            //updateClientId(salesforceClientId: clientId, iOSClientId: surveyRes.clientId!)
                        }
                    }
                }
                else{
                    surveyRes.clientId = ""
                }
                
                
                
                
                surveyResDict["byContactId"] = surveyRes.canvasserContactId as AnyObject?
                //surveyResDict["byUserId"] = surveyResData.userId! as AnyObject?
                surveyResDict["forClient"] = surveyRes.clientId as AnyObject?
                surveyResDict["surveyId"] = surveyRes.surveyId as AnyObject?
                surveyResDict["assignmentLocUnitId"] = surveyRes.assignmentLocUnitId as AnyObject?
                surveyResDict["QuestionList"] = surveyRes.surveyRes as AnyObject?
                surveyResDict["signature"] = surveyRes.surveySignature as AnyObject?
                
               
                surveyResParams["surveyResponseFile"] = Utility.jsonToString(json: surveyResDict as AnyObject)!
                
                let req = SFRestRequest(method: .POST, path: SalesforceRestApiUrl.submitSurveyResponse, queryParams: nil)
                
                do {
                    
                    let bodyData = try JSONSerialization.data(withJSONObject: surveyResParams, options: [])
                    req.setCustomRequestBodyData(bodyData, contentType: "application/json")
                }
                catch{
                    
                    
                }
                
                req.endpoint = ""
                
                surveyResGroup.enter()
                
                self.sendRequest(request: req, callback: { (response) in
                    
                    DispatchQueue.main.async {
                        
                        self.parseSurveyResponse(jsonObject: response as! Dictionary<String, AnyObject>)
                        
                        surveyResGroup.leave()
                        
                        print("SurveyResponseGroup: \(surveyRes.surveyId!)")
                    }
                    
                    
                    
                }) { (error) in
                    Logger.shared.log(level: .error, msg: error)
                    Utility.displayErrorMessage(errorMsg: error)
                    //failure(error)
                }
                
            }
            
            surveyResGroup.notify(queue: .main) {
                completion()
            }
            
        }
        else{
            completion()
        }
        
        
    }
    
    
    
    func parseSurveyResponse(jsonObject: Dictionary<String, AnyObject>){
        
        let assignmentLocUnitId = jsonObject["assignmentLocationUnitId"] as? String
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["actionStatus"] = actionStatus.doneSurvey.rawValue as AnyObject
        
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.surveyResponse.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocUnitId == %@", predicateValue:  assignmentLocUnitId,isPredicate: true)
        
        //update sync date
        if(assignmentLocUnitId !=  nil){
            LocationUnitAPI.shared.updateSyncDate(assignmentLocUnitId: assignmentLocUnitId!)
        }
        
        
    }
    
    
    
    
    /// Get all the surveyresponses from core data.
    ///
    /// - Returns: array of surveyresponses.
    func getAllSurveyResponses(assignmentId:String)->[String:String] {
        
        let surveyRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.surveyResponse.rawValue,predicateFormat: "assignmentId == %@",predicateValue: assignmentId, isPredicate:true) as! [SurveyResponse]
        
        var surveyResDict:[String:String] = [:]
        
        if(surveyRes.count > 0){
            
            for surveyResData in surveyRes{
                
                if surveyResDict[surveyResData.assignmentLocUnitId!] == nil{
                    surveyResDict[surveyResData.assignmentLocUnitId!] = surveyResData.actionStatus
                }
            }
            
            
        }
        
        return surveyResDict
        
    }
    
    func deleteSurvey(assignmentLocUnitId:String){
        
        ManageCoreData.deleteRecord(salesforceEntityName: coreDataEntity.surveyResponse.rawValue, predicateFormat: "assignmentLocUnitId == %@", predicateValue: assignmentLocUnitId, isPredicate: true)
        
    }
    
    
    func saveSurvey(surveyObj:SurveyDO,status:String){
        
        let surveyResObj = SurveyResponse(context: context)
        
        surveyResObj.surveyId = surveyObj.surveyId
        
        surveyResObj.assignmentLocUnitId = surveyObj.assignmentLocUnitId
        
        surveyResObj.actionStatus = status
        surveyResObj.surveySignature = surveyObj.surveySign
        
        
        surveyResObj.canvasserContactId = surveyObj.canvasserContactId
        surveyResObj.clientId = surveyObj.clientId
        
       
        surveyResObj.surveyRes = surveyObj.surveyRes as NSObject?
        
        surveyResObj.questionAnswers = surveyObj.surveyOutput as NSObject?
        
        surveyResObj.surveyQuestionIndex = Int64(surveyObj.surveyQuestionArrayIndex)
        
        surveyResObj.assignmentId = surveyObj.assignmentId
        
        appDelegate.saveContext()
        
    }
    
    func updateSurvey(surveyObj:SurveyDO,status:String){
        
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["surveyId"] = surveyObj.surveyId as AnyObject?
        
        updateObjectDic["surveyRes"] = surveyObj.surveyRes as NSObject?
        
        updateObjectDic["actionStatus"] = status as AnyObject?
        updateObjectDic["surveySignature"] = surveyObj.surveySign as AnyObject?
        
        updateObjectDic["canvasserContactId"] = surveyObj.canvasserContactId as AnyObject?
        updateObjectDic["clientId"] = surveyObj.clientId as AnyObject?
        
        updateObjectDic["surveyQuestionIndex"] = Int64(surveyObj.surveyQuestionArrayIndex) as AnyObject?
        
        
        updateObjectDic["questionAnswers"] = surveyObj.surveyOutput as NSObject?
        
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.surveyResponse.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocUnitId == %@", predicateValue: surveyObj.assignmentLocUnitId,isPredicate: true)
        
        
    }
    
    func getSavedSurvey(assignmentLocUnitId:String)->SurveyResponse?{
        
        let surveyResArr = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.surveyResponse.rawValue,predicateFormat: "assignmentLocUnitId == %@" ,predicateValue: assignmentLocUnitId, isPredicate:true) as! [SurveyResponse]
        
        if(surveyResArr.count > 0){
            return surveyResArr.first
        }
        return nil
        
    }
    
    func isSurveyQuesExist(surveyId:String)->SurveyQuestion?{
        
        let surveyQuesArr = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.surveyQuestion.rawValue,predicateFormat: "surveyId == %@" ,predicateValue: surveyId, isPredicate:true) as! [SurveyQuestion]
        
        if(surveyQuesArr.count > 0){
            return surveyQuesArr.first
        }
        return nil
        
    }
    
    func getDefaultSurvey(assignmentId:String)->SurveyQuestion?{
        
        let surveyQuesResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.surveyQuestion.rawValue ,predicateFormat: "assignmentId == %@ && isDefault == %@" ,predicateValue: assignmentId,predicateValue2: "true",isPredicate:true) as! [SurveyQuestion]
        
        if(surveyQuesResults.count > 0){
            return surveyQuesResults.first
        }
        return nil
        
    }
    
    func getSurvey(assignmentId:String,surveyId:String)->SurveyQuestion?{
        
        let surveyQuesResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.surveyQuestion.rawValue ,predicateFormat: "assignmentId == %@ && surveyId == %@" ,predicateValue: assignmentId,predicateValue2: surveyId,isPredicate:true) as! [SurveyQuestion]
        
        if(surveyQuesResults.count > 0){
            return surveyQuesResults.first
        }
        return nil
        
    }
    
    func getAllSurveys(assignmentId:String)->[SurveyQuestion]?{
        
         let surveyQuesRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.surveyQuestion.rawValue,predicateFormat: "assignmentId == %@" ,predicateValue: assignmentId,isPredicate:true) as? [SurveyQuestion]
        
        return surveyQuesRes
        
        
    }
    
    

}


