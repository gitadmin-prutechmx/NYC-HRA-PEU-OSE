//
//  SyncUtility.swift
//  Knock
//
//  Created by Kamal on 04/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import Foundation
import Crashlytics

class SyncUtility{
    
    
    static var editLocationResultsArr = [EditLocation]()
    static var unitResultsArr = [Unit]()
    static var editUnitResultsArr = [EditUnit]()
    static var surveyUnitResultsArr = [SurveyUnit]()
    static var tenantResultsArr  = [Tenant]()
    static var tenantAssignResultsArr = [TenantAssign]()
    static var surveyResResultsArr = [SurveyResponse]()
    
    static var issueResultsArr = [Issues]()
    static var caseResultsArr = [AddCase]()
    
    static var isPullData:Bool = false
    static var loginViewController:LoginViewController? = nil
    
    class func syncDataWithSalesforce(isPullDataFromSFDC:Bool,controller:LoginViewController?=nil){
        
        
        isPullData = isPullDataFromSFDC
        loginViewController = controller
        
        SalesforceConnection.loginToSalesforce() {isLoginTrue in
            
            if(isLoginTrue){
                editLocationResultsArr = ManageCoreData.fetchData(salesforceEntityName: "EditLocation",predicateFormat: "actionStatus == %@" ,predicateValue: "edit", isPredicate:true) as! [EditLocation]
                
                unitResultsArr = ManageCoreData.fetchData(salesforceEntityName: "Unit",predicateFormat: "actionStatus == %@" ,predicateValue: "create",isPredicate:true) as! [Unit]
                
                tenantResultsArr = ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "actionStatus == %@ OR actionStatus == %@" ,predicateValue: "edit",predicateValue2: "create", isPredicate:true) as! [Tenant]
                
                surveyResResultsArr = ManageCoreData.fetchData(salesforceEntityName: "SurveyResponse",predicateFormat: "actionStatus == %@" ,predicateValue: "Complete", isPredicate:true) as! [SurveyResponse]
                
                
                editUnitResultsArr = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "actionStatus == %@ OR actionStatus == %@" ,predicateValue: "edit",predicateValue2: "create",isPredicate:true) as! [EditUnit]
                
                
                caseResultsArr = ManageCoreData.fetchData(salesforceEntityName: "AddCase",predicateFormat: "actionStatus == %@" ,predicateValue: "create",isPredicate:true) as! [AddCase]
                
                issueResultsArr = ManageCoreData.fetchData(salesforceEntityName: "Issues",predicateFormat: "actionStatus == %@ OR actionStatus == %@" ,predicateValue: "edit",predicateValue2: "create",isPredicate:true) as! [Issues]
                
                
                if( editLocationResultsArr.count > 0){
                    updateEditLocData()
                }
                else if( unitResultsArr.count > 0){
                    updateUnitData()
                }
                else if( tenantResultsArr.count > 0){
                    updateTenantData()
                }
                else if( surveyResResultsArr.count > 0){
                    updateSurveyResponseData()
                }
                else if( editUnitResultsArr.count > 0){
                    updateEditUnitData()
                }
                else if( caseResultsArr.count > 0){
                    updateCaseData()
                }
                else if( issueResultsArr.count > 0){
                    updateIssueData()
                }
                else{
                    if(isPullData){
                        Utilities.fetchAllDataFromSalesforce(loginViewController: loginViewController)
                    }
                }
                
            }
            
            
        }
    }
    
    
    
    class func updateEditLocData(){
        
        let locGroup = DispatchGroup()
        
        
        var locDict:[String:String] = [:]
        var editLoc : [String:String] = [:]
        
        
        
        if( editLocationResultsArr.count>0){
            
            for editLocData in  editLocationResultsArr{
                
                locGroup.enter()
                
                locDict = Utilities.editLocData(canvassingStatus: editLocData.canvassingStatus!, assignmentLocationId: editLocData.assignmentLocId!, notes: editLocData.notes!, attempt: editLocData.attempt!)
                
                
                
                editLoc["location"] = Utilities.jsonToString(json: locDict as AnyObject)!
                //Utilities.encryptedParams(dictParameters: locDict as AnyObject)
                
                
                
                
                
                
                SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.updateLocation, params: editLoc){ jsonData in
                    
                    
                    Utilities.parseEditLocation(jsonObject: jsonData.1)
                    locGroup.leave()
                    
                    
                    print("locGroup: \(editLocData.notes!)")
                    
                    
                    
                }//login to unit rest api
                
                
            }//end for loop
            
        }//end of if
            
        else{
            locGroup.enter()
            locGroup.leave()
        }
        
        locGroup.notify(queue: .main) {
            
            //Utilities.resetAllActionStatusFromEditLocation()
            
            if( unitResultsArr.count>0){
                updateUnitData()
            }
            else if( tenantResultsArr.count > 0){
                updateTenantData()
            }
            else if( surveyResResultsArr.count > 0){
                updateSurveyResponseData()
            }
            else if( editUnitResultsArr.count > 0){
                updateEditUnitData()
            }
            else if( caseResultsArr.count > 0){
                updateCaseData()
            }
            else if( issueResultsArr.count > 0){
                updateIssueData()
            }
            else{
                if(isPullData){
                    Utilities.fetchAllDataFromSalesforce(loginViewController: loginViewController)
                }
            }
            
        }
        
    }
    
    
    class func updateUnitData(){
        
        let unitGroup = DispatchGroup()
        
        
        
        var unitDict:[String:String] = [:]
        var saveUnit : [String:String] = [:]
        
        
        if( unitResultsArr.count > 0){
            
            
            
            for unitData in  unitResultsArr{
                
                unitGroup.enter()
                
                unitDict = Utilities.createUnitDicData(unitName: unitData.name!, apartmentNumber: unitData.apartment!, locationId: unitData.locationId!, assignmentLocId: unitData.assignmentLocId!, notes: unitData.notes!, iosLocUnitId: unitData.id!, iosAssignLocUnitId: unitData.assignmentLocUnitId!)
                
                
                
                saveUnit["unit"] = Utilities.jsonToString(json: unitDict as AnyObject)!
                //Utilities.encryptedParams(dictParameters: unitDict as AnyObject)
                
                
                SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.createUnit, params: saveUnit){ jsonData in
                    
                    
                    
                    _ = Utilities.parseAddNewUnitResponse(jsonObject: jsonData.1)
                    
                    unitGroup.leave()
                    
                    print("UnitGroup: \(unitData.name!)")
                    
                }//login to salesforce
                
            }//end for loop
            
        }
        else{
            unitGroup.enter()
            unitGroup.leave()
        }
        
        
        
        unitGroup.notify(queue: .main) {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
            
            if( tenantResultsArr.count > 0){
                updateTenantData()
            }
            else if( surveyResResultsArr.count > 0){
                updateSurveyResponseData()
            }
            else if( editUnitResultsArr.count > 0){
                updateEditUnitData()
            }
            else if( caseResultsArr.count > 0){
                updateCaseData()
            }
            else if( issueResultsArr.count > 0){
                updateIssueData()
            }
            else{
                if(isPullData){
                    Utilities.fetchAllDataFromSalesforce(loginViewController: loginViewController)
                }
            }
            
        }
    }
    
    
    class func updateTenantData(){
        
        let tenantGroup = DispatchGroup()
        
        var tenantDict:[String:String] = [:]
        var editTenant : [String:String] = [:]
        
        
        
        if(tenantResultsArr.count > 0){
            
            
            
            for tenantData in tenantResultsArr{
                
                tenantGroup.enter()
                
                let tenantId = tenantData.id!
                let locUnitId = tenantData.unitId!
                
                tenantDict = Utilities.createAndEditTenantData(firstName: tenantData.firstName!, lastName: tenantData.lastName!, email: tenantData.email!, phone: tenantData.phone!, dob: tenantData.dob!, locationUnitId: locUnitId, currentTenantId: tenantId, iOSTenantId: tenantId,type:tenantData.actionStatus!)
                
                
                
                editTenant["tenant"] = Utilities.jsonToString(json: tenantDict as AnyObject)!
                //Utilities.encryptedParams(dictParameters: tenantDict as AnyObject)
                
                
                
                
                
                SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.createTenant, params: editTenant){ jsonData in
                    
                    
                    _ = Utilities.parseTenantResponse(jsonObject: jsonData.1)
                    tenantGroup.leave()
                    print("tenantGroup: \(tenantData.firstName!)")
                    
                    
                }//login to unit rest api
            }//end for loop
            
        }
        else{
            tenantGroup.enter()
            tenantGroup.leave()
        }
        
        
        
        tenantGroup.notify(queue: .main) {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateClientView"), object: nil)
            
            if( surveyResResultsArr.count > 0){
                updateSurveyResponseData()
            }
            else if( editUnitResultsArr.count > 0){
                updateEditUnitData()
            }
            else if( caseResultsArr.count > 0){
                updateCaseData()
            }
            else if( issueResultsArr.count > 0){
                updateIssueData()
            }
            else{
                if(isPullData){
                    Utilities.fetchAllDataFromSalesforce(loginViewController: loginViewController)
                }
            }
            
        }
        
        
        
    }
    
    
    class func updateSurveyResponseData(){
        
        let surveyResponseGroup = DispatchGroup()
        
        
        var surveyResponseStr:String = ""
        var formatString:String = ""
        var responseDict : [String:AnyObject] = [:]
        var surveyResponseParam : [String:String] = [:]
        
        
        if( surveyResResultsArr.count > 0){
            
            for surveyResData in  surveyResResultsArr{
                
                surveyResponseGroup.enter()
                
                responseDict["surveyId"] = surveyResData.surveyId! as AnyObject?
                responseDict["assignmentLocUnitId"] = surveyResData.assignmentLocUnitId! as AnyObject?
                //unitid
                responseDict["QuestionList"] = surveyResData.surveyQuestionRes! as AnyObject?
                responseDict["signature"] = surveyResData.surveySignature! as AnyObject?
                
                formatString = Utilities.jsonToString(json: responseDict as AnyObject)!
                
                
                
                // surveyResponseStr = try! formatString.aesEncrypt(SalesforceConfig.key, iv: SalesforceConfig.iv)
                
                
                surveyResponseParam["surveyResponseFile"] = formatString
                //surveyResponseStr
                
                
                
                SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.submitSurveyResponse, params: surveyResponseParam){ jsonData in
                    
                    
                    Utilities.parseSurveyResponse(jsonObject: jsonData.1)
                    surveyResponseGroup.leave()
                    print("surveyResponseGroup: \(surveyResData.surveyId!)")
                    
                }//login to unit rest api
            }//end for loop
            
        }
            
        else{
            surveyResponseGroup.enter()
            surveyResponseGroup.leave()
        }
        
        surveyResponseGroup.notify(queue: .main) {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
            
            if( editUnitResultsArr.count > 0){
                updateEditUnitData()
            }
            else if( caseResultsArr.count > 0){
                updateCaseData()
            }
            else if( issueResultsArr.count > 0){
                updateIssueData()
            }
            else{
                if(isPullData){
                    Utilities.fetchAllDataFromSalesforce(loginViewController: loginViewController)
                }
            }
            
            //assignmentdetail and charrts api
            
        }
        
        
    }
    
    
    
    
    class func updateEditUnitData(){
        
        let editUnitGroup = DispatchGroup()
        
        
        
        var updateUnit : [String:String] = [:]
        var editUnitDict : [String:String] = [:]
        
        
        
        
        if( editUnitResultsArr.count > 0){
            
            
            for editUnitData in  editUnitResultsArr{
                
                editUnitGroup.enter()
                
                
                editUnitDict = Utilities.editUnitTenantAndSurveyDicData(intake:editUnitData.inTake!, notes: editUnitData.unitNotes!, attempt: editUnitData.attempt!, contact: editUnitData.isContact!, reKnockNeeded: editUnitData.reKnockNeeded!, reason: editUnitData.reason!, assignmentLocationUnitId: editUnitData.assignmentLocUnitId!,selectedSurveyId: editUnitData.surveyId!,selectedTenantId: editUnitData.tenantId!,lastCanvassedBy: SalesforceConfig.currentUserContactId)
                
                
                
                updateUnit["unit"] = Utilities.jsonToString(json: editUnitDict as AnyObject)!
                //Utilities.encryptedParams(dictParameters: editUnitDict as AnyObject)
                
                SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.updateUnit, params: updateUnit){ jsonData in
                    
                    Utilities.parseEditUnit(jsonObject: jsonData.1)
                    editUnitGroup.leave()
                    //  print("editUnitGroup: \(editUnitData.tenantStatus!)")
                    
                }//login to unit rest api
                
                
                
            }
        }
            
        else{
            editUnitGroup.enter()
            editUnitGroup.leave()
        }
        
        
        
        
        
        editUnitGroup.notify(queue: .main) {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
            
            if( caseResultsArr.count > 0){
                updateCaseData()
            }
                
            else if( issueResultsArr.count > 0){
                updateIssueData()
            }
            else
                if(isPullData){
                    Utilities.fetchAllDataFromSalesforce(loginViewController: loginViewController)
            }
            
        }
        
    }
    
    class func updateCaseData(){
        
        let caseGroup = DispatchGroup()
        
        
        var caseJsonDict:[String:AnyObject] = [:]
        var caseResponseParam : [String:String] = [:]
        
        if( caseResultsArr.count > 0){
            
            
            for caseData in  caseResultsArr{
                
                caseGroup.enter()
                
                var caseResponseDict = caseData.caseResponse as! Dictionary<String,AnyObject>
                
                caseResponseDict["ContactId"] = caseData.clientId! as AnyObject?
                
                caseResponseDict["OwnerId"] =  SalesforceConnection.salesforceUserId as AnyObject?
                
                
                caseJsonDict["iOSCaseId"] = caseData.caseId! as AnyObject?
                
                caseJsonDict["caseResponse"] = Utilities.jsonToString(json: caseResponseDict as AnyObject) as AnyObject
                
                caseResponseParam["jsonCase"] = Utilities.jsonToString(json: caseJsonDict as AnyObject)!
                
                
                SalesforceConnection.SalesforceCaseData(restApiUrl: SalesforceRestApiUrl.createCase, params: caseResponseParam){ jsonData in
                    
                    Utilities.parseCaseResponse(jsonObject: jsonData.1)
                    caseGroup.leave()
                    //  print("editUnitGroup: \(editUnitData.tenantStatus!)")
                    
                }//login to unit rest api
                
                
                
            }
        }
            
        else{
            caseGroup.enter()
            caseGroup.leave()
        }
        
        
        
        
        
        caseGroup.notify(queue: .main) {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateCaseView"), object: nil)
            
            if( issueResultsArr.count > 0){
                updateIssueData()
            }
            else
                if(isPullData){
                    Utilities.fetchAllDataFromSalesforce(loginViewController: loginViewController)
            }
            
        }
    }
    
    class func updateIssueData(){
        let issueGroup = DispatchGroup()
        
        var issueDict:[String:AnyObject] = [:]
        var editIssue : [String:String] = [:]
        
        
        
        if(issueResultsArr.count > 0){
            
            
            
            for issueData in issueResultsArr{
                
                issueGroup.enter()
                
                issueDict = Utilities.createAndEditIssueData(issueType: issueData.issueType!, issueNotes: issueData.notes!,caseId:issueData.caseId!, currentIssueId: issueData.issueId!, iOSIssueId: issueData.issueId!,type:issueData.actionStatus!)
                
                
                
                editIssue["jsonIssue"] = Utilities.jsonToString(json: issueDict as AnyObject)!
                
                
                
                
                SalesforceConnection.SalesforceCaseData(restApiUrl: SalesforceRestApiUrl.createIssue, params: editIssue){ jsonData in
                    
                    
                    _ = Utilities.parseIssueResponse(jsonObject: jsonData.1)
                    issueGroup.leave()
                    print("issueGroup: \(issueData.issueType!)")
                    
                    
                }//login to unit rest api
            }//end for loop
            
        }
        else{
            issueGroup.enter()
            issueGroup.leave()
        }
        
        
        
        issueGroup.notify(queue: .main) {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateIssueView"), object: nil)
            
            
            if(isPullData){
                Utilities.fetchAllDataFromSalesforce(loginViewController: loginViewController)
            }
            
        }
        
        
    }
    
    
    
    
}
