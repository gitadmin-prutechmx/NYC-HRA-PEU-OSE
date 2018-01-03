//
//  SyncUtility.swift
//  Knock
//
//  Created by Kamal on 04/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import Foundation
import Crashlytics
import SalesforceSDKCore

class SyncUtility{
    
    
    static var editLocationResultsArr = [EditLocation]()
    static var unitResultsArr = [Unit]()
    static var editUnitResultsArr = [EditUnit]()
    static var surveyUnitResultsArr = [SurveyUnit]()
    static var tenantResultsArr  = [Tenant]()
    static var surveyResResultsArr = [SurveyResponse]()
    
    static var issueResultsArr = [Issues]()
    static var caseResultsArr = [AddCase]()
    
    static var isPullData:Bool = false
    static var loginViewController:LoginViewController? = nil
    
    class func syncDataWithSalesforce(isPullDataFromSFDC:Bool,controller:LoginViewController?=nil){
        
        
        isPullData = isPullDataFromSFDC
        loginViewController = controller
        
        
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
            else{
                Utilities.isBackgroundSync = false
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
                
                
                
                
                //                    var params:[String:AnyObject] = [:]
                //                    params["externalId"] = "123nik" as AnyObject
                //
                
                let request = SalesforceConnection.generateSFDCRequest(restApiUrl: SalesforceRestApiUrl.updateLocation, params: editLoc, methodType: SFRestMethod.POST)
                
                SFRestAPI.sharedInstance().send(request, fail: {
                    error in
                    
                    
                    let errormsg = "SyncUtility:- UpdateEditLocData:- " + String(describing: error)
                    Utilities.displayErrorMessage(errorMsg: errormsg)
                    
                    
                }, complete: {
                    response in
                    
                    DispatchQueue.main.async {
                        Utilities.parseEditLocation(jsonObject: response as! Dictionary<String, AnyObject>)
                        locGroup.leave()
                        
                        
                        print("locGroup: \(editLocData.notes!)")
                    }
                    
                    
                })
                
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
                else{
                    Utilities.isBackgroundSync = false
                }
            }
            
        }
        
    }
    
    
    class func updateUnitData(){
        var isError:Bool = false
        
        let unitGroup = DispatchGroup()
        
        
        
        var unitDict:[String:String] = [:]
        var saveUnit : [String:String] = [:]
        
        
        if( unitResultsArr.count > 0){
            
            
            
            for unitData in  unitResultsArr{
                
                unitGroup.enter()
                
                unitDict = Utilities.createUnitDicData(unitName: unitData.name!, apartmentNumber: unitData.apartment!,privateHome:unitData.privateHome!, locationId: unitData.locationId!, assignmentLocId: unitData.assignmentLocId!, notes: unitData.notes!, iosLocUnitId: unitData.id!, iosAssignLocUnitId: unitData.assignmentLocUnitId!)
                
                
                
                saveUnit["unit"] = Utilities.jsonToString(json: unitDict as AnyObject)!
                //Utilities.encryptedParams(dictParameters: unitDict as AnyObject)
                
                
                
                let request = SalesforceConnection.generateSFDCRequest(restApiUrl: SalesforceRestApiUrl.createUnit, params: saveUnit, methodType: SFRestMethod.POST)
                
                SFRestAPI.sharedInstance().send(request, fail: {
                    error in
                    
                    
                    
                    let errormsg = "SyncUtility:- UpdateUnitData:- " + String(describing: error)
                    Utilities.displayErrorMessage(errorMsg: errormsg)
                    
                    
                }, complete: {
                    response in
                    
                    DispatchQueue.main.async {
                        isError = Utilities.parseAddNewUnitResponse(jsonObject: response as! Dictionary<String, AnyObject>)
                        
                        unitGroup.leave()
                        
                        print("UnitGroup: \(unitData.name!)")
                    }
                })
                
                
                
                
            }//end for loop
            
        }
        else{
            unitGroup.enter()
            unitGroup.leave()
        }
        
        
        
        unitGroup.notify(queue: .main) {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
            
            if(isError == false){
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
                    else{
                        Utilities.isBackgroundSync = false
                    }
                }
                
            }
            else{
                SVProgressHUD.dismiss()
            }
            
        }
    }
    
    
    class func updateTenantData(){
        
        var isError:Bool = false
        
        let tenantGroup = DispatchGroup()
        
        var tenantDict:[String:String] = [:]
        var editTenant : [String:String] = [:]
        
        
        
        if(tenantResultsArr.count > 0){
            
            
            
            for tenantData in tenantResultsArr{
                
                tenantGroup.enter()
                
                let tenantId = tenantData.id!
                var locUnitId = tenantData.unitId!
                
                
                var assignmentLocId:String = ""
                
                var attempt:String = ""
                var contact:String = ""
                var contactOutcome:String = ""
                var notes:String = ""
                var streetNum:String = ""
                var streetName:String = ""
                var borough:String = ""
                var zip:String = ""
                var aptNo:String = ""
                var aptFloor:String = ""
                
                
                if let tempAssignmentLocId = tenantData.assignmentLocId{
                    assignmentLocId = tempAssignmentLocId
                }
                if let tempAttempt = tenantData.attempt{
                    attempt = tempAttempt
                }
                if let tempContact = tenantData.contact{
                    contact = tempContact
                }
                if let tempNotes = tenantData.notes{
                    notes = tempNotes
                }
                if let tempStreetNum = tenantData.streetNum{
                    streetNum = tempStreetNum
                }
                if let tempStreetName = tenantData.streetName{
                    streetName = tempStreetName
                }
                if let tempBorough = tenantData.borough{
                    borough = tempBorough
                }
                if let tempZip = tenantData.zip{
                    zip = tempZip
                }
                if let tempAptNo = tenantData.aptNo{
                    aptNo = tempAptNo
                }
                if let tempAptFloor = tenantData.aptFloor{
                    aptFloor = tempAptFloor
                }
                
                
                
                let isiOSUnitId =  isiOSGeneratedId(generatedId: locUnitId)
                
                
                
                //if iOSClientId is a UUID string then get salesforce unitId from unit object
                if(isiOSUnitId != nil){
                    locUnitId = getSalesforceUnitId(unitId: locUnitId)
                    
                    if(isiOSGeneratedId(generatedId: locUnitId) != nil){
                        Utilities.showSwiftErrorMessage(error: "updateTenantData:- LocUnitId:")
                    }
                }
                
                
                //end
                
                
                
                tenantDict = Utilities.createAndEditTenantData(firstName: tenantData.firstName!, lastName: tenantData.lastName!, middleName:tenantData.middleName!,suffix:tenantData.suffix!, email: tenantData.email!, phone: tenantData.phone!, dob: tenantData.dob!,attempt:attempt,contact:contact,contactOutcome: contactOutcome,notes:notes,streetNum:streetNum,streetName:streetName,borough:borough,zip:zip,aptNo: aptNo,aptFloor: aptFloor, locationUnitId: locUnitId, currentTenantId: tenantId, iOSTenantId: tenantId,assignmentLocId: assignmentLocId, type:tenantData.actionStatus!)
                
                
                
                editTenant["tenant"] = Utilities.jsonToString(json: tenantDict as AnyObject)!
                //Utilities.encryptedParams(dictParameters: tenantDict as AnyObject)
                
                
                
                let request = SalesforceConnection.generateSFDCRequest(restApiUrl: SalesforceRestApiUrl.createTenant, params: editTenant, methodType: SFRestMethod.POST)
                
                SFRestAPI.sharedInstance().send(request, fail: {
                    error in
                    
                    
                    let errormsg = "SyncUtility:- UpdateTenantData:- " + String(describing: error)
                    Utilities.displayErrorMessage(errorMsg: errormsg)
                    
                    
                }, complete: {
                    response in
                    
                    DispatchQueue.main.async {
                        isError = Utilities.parseTenantResponse(jsonObject: response as! Dictionary<String, AnyObject>)
                        tenantGroup.leave()
                        print("tenantGroup: \(tenantData.firstName!)")
                    }
                    
                })
                
                
            }//end for loop
            
        }
        else{
            tenantGroup.enter()
            tenantGroup.leave()
        }
        
        
        
        tenantGroup.notify(queue: .main) {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateClientView"), object: nil)
            
            
            if(isError == false){
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
                    else{
                        Utilities.isBackgroundSync = false
                    }
                }
            }
            else{
                SVProgressHUD.dismiss()
            }
            
        }
        
        
        
    }
    
    
    class func updateSurveyResponseData(){
        
        let surveyResponseGroup = DispatchGroup()
        
        
        //var surveyResponseStr:String = ""
        var formatString:String = ""
        var responseDict : [String:AnyObject] = [:]
        var surveyResponseParam : [String:String] = [:]
        
        
        if( surveyResResultsArr.count > 0){
            
            for surveyResData in  surveyResResultsArr{
                
                surveyResponseGroup.enter()
                
                
                
                //Code for updating salesforceId
                var updatedClientId:String = surveyResData.clientId!
                var updatedAssigLocUnitId:String = surveyResData.assignmentLocUnitId!
                
                let isiOSClientId =  isiOSGeneratedId(generatedId: updatedClientId)
                let isiOSAssignmentLocUnitId =  isiOSGeneratedId(generatedId: updatedAssigLocUnitId)
                
                
                
                //if iOSClientId is a UUID string then get salesforce clientId from tenant object
                if(isiOSClientId != nil){
                    updatedClientId = getSalesforceClientId(clientId: updatedClientId)
                    
                    if(isiOSGeneratedId(generatedId: updatedClientId) != nil){
                        Utilities.showSwiftErrorMessage(error: "updateSurveyResponseData:- ClientId:")
                    }
                }
                
                //if isiOSAssignmentLocUnitId is a UUID string then get salesforce assignmentLocUnitId from unit object
                if(isiOSAssignmentLocUnitId != nil){
                    updatedAssigLocUnitId = getSalesforceAssignmentLocUnitId(assignmentLocUnitId: updatedAssigLocUnitId)
                    
                    if(isiOSGeneratedId(generatedId: updatedAssigLocUnitId) != nil){
                        Utilities.showSwiftErrorMessage(error: "updateSurveyResponseData:- assignmentLocUnitId:")
                    }
                }
                
                //end
                
                responseDict["byContactId"] = surveyResData.contactId! as AnyObject?
                responseDict["byUserId"] = surveyResData.userId! as AnyObject?
                
                responseDict["forClient"] = updatedClientId as AnyObject?
                
                
                responseDict["surveyId"] = surveyResData.surveyId! as AnyObject?
                responseDict["assignmentLocUnitId"] = updatedAssigLocUnitId as AnyObject?
                //unitid
                responseDict["QuestionList"] = surveyResData.surveyQuestionRes! as AnyObject?
                responseDict["signature"] = surveyResData.surveySignature! as AnyObject?
                
                
                formatString = Utilities.jsonToString(json: responseDict as AnyObject)!
                
                
                
                // surveyResponseStr = try! formatString.aesEncrypt(SalesforceConfig.key, iv: SalesforceConfig.iv)
                
                
                surveyResponseParam["surveyResponseFile"] = formatString
                //surveyResponseStr
                
                
                
                let request = SalesforceConnection.generateSFDCRequest(restApiUrl: SalesforceRestApiUrl.submitSurveyResponse, params: surveyResponseParam, methodType: SFRestMethod.POST)
                
                SFRestAPI.sharedInstance().send(request, fail: {
                    error in
                    
                    
                    let errormsg = "SyncUtility:- UpdateSurveyResponseData:- " + String(describing: error)
                    Utilities.displayErrorMessage(errorMsg: errormsg)
                    
                    
                }, complete: {
                    response in
                    
                    DispatchQueue.main.async {
                        Utilities.parseSurveyResponse(jsonObject: response as! Dictionary<String, AnyObject>)
                        surveyResponseGroup.leave()
                        print("surveyResponseGroup: \(surveyResData.surveyId!)")
                    }
                    
                })
                
                
                
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
                else{
                    Utilities.isBackgroundSync = false
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
                
                //Code for updating salesforceId
                var updatedClientId:String = editUnitData.tenantId!
                var updatedAssigLocUnitId:String = editUnitData.assignmentLocUnitId!
                
                let isiOSClientId =  isiOSGeneratedId(generatedId: updatedClientId)
                let isiOSAssignmentLocUnitId =  isiOSGeneratedId(generatedId: updatedAssigLocUnitId)
                
                
                
                //if iOSClientId is a UUID string then get salesforce clientId from tenant object
                if(isiOSClientId != nil){
                    updatedClientId = getSalesforceClientId(clientId: updatedClientId)
                    
                    if(isiOSGeneratedId(generatedId: updatedClientId) != nil){
                        Utilities.showSwiftErrorMessage(error: "updateEditUnitData:- ClientId:")
                    }
                }
                
                //if isiOSAssignmentLocUnitId is a UUID string then get salesforce assignmentLocUnitId from unit object
                if(isiOSAssignmentLocUnitId != nil){
                    updatedAssigLocUnitId = getSalesforceAssignmentLocUnitId(assignmentLocUnitId: updatedAssigLocUnitId)
                    
                    if(isiOSGeneratedId(generatedId: updatedAssigLocUnitId) != nil){
                        Utilities.showSwiftErrorMessage(error: "updateEditUnitData:- assignmentLocUnitId:")
                    }
                }
                
                //end
                
                
                
                editUnitDict = Utilities.editUnitTenantAndSurveyDicData(intake:editUnitData.inTake!, notes: editUnitData.unitNotes!, attempt: editUnitData.attempt!, contact: editUnitData.isContact!, reKnockNeeded: editUnitData.reKnockNeeded!, reason: editUnitData.reason!, contactOutcome:editUnitData.contactOutcome!,assignmentLocationUnitId: updatedAssigLocUnitId,selectedSurveyId: editUnitData.surveyId!,selectedTenantId: updatedClientId,followUpType: editUnitData.followUpType!,followUpDate: editUnitData.followUpDate!,lastCanvassedBy: "")
                
                
                //lastCanvassedBy: SalesforceConfig.currentUserContactId
                
                updateUnit["unit"] = Utilities.jsonToString(json: editUnitDict as AnyObject)!
                //Utilities.encryptedParams(dictParameters: editUnitDict as AnyObject)
                
                
                let request = SalesforceConnection.generateSFDCRequest(restApiUrl: SalesforceRestApiUrl.updateUnit, params: updateUnit, methodType: SFRestMethod.POST)
                
                SFRestAPI.sharedInstance().send(request, fail: {
                    error in
                    
                    
                    let errormsg = "SyncUtility:- UpdateEditUnitData:- " + String(describing: error)
                    Utilities.displayErrorMessage(errorMsg: errormsg)
                    
                    
                }, complete: {
                    response in
                    
                    DispatchQueue.main.async {
                        Utilities.parseEditUnit(jsonObject: response as! Dictionary<String, AnyObject>)
                        editUnitGroup.leave()
                    }
                    
                })
                
                
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
                else{
                    Utilities.isBackgroundSync = false
            }
            
        }
        
    }
    
    class func updateCaseData(){
        
        var isError:Bool = false
        
        let caseGroup = DispatchGroup()
        
        
        var caseJsonDict:[String:AnyObject] = [:]
        var caseResponseParam : [String:String] = [:]
        
        if( caseResultsArr.count > 0){
            
            
            for caseData in  caseResultsArr{
                
                caseGroup.enter()
                
                //Code for updating salesforceId
                var updatedClientId:String = caseData.clientId!
                
                let isiOSClientId =  isiOSGeneratedId(generatedId: updatedClientId)
                
                
                
                //if iOSClientId is a UUID string then get salesforce clientId from tenant object
                if(isiOSClientId != nil){
                    updatedClientId = getSalesforceClientId(clientId: updatedClientId)
                    
                    if(isiOSGeneratedId(generatedId: updatedClientId) != nil){
                        Utilities.showSwiftErrorMessage(error: "updateCaseData:- ClientId:")
                    }
                }
                
                
                var caseResponseDict = caseData.caseResponse as! Dictionary<String,AnyObject>
                
                caseResponseDict["ContactId"] = updatedClientId as AnyObject?
                
                caseResponseDict["OwnerId"] =  caseData.ownerId! as AnyObject?
                
                
                caseJsonDict["iOSCaseId"] = caseData.caseId! as AnyObject?
                
                caseJsonDict["caseResponse"] = Utilities.jsonToString(json: caseResponseDict as AnyObject) as AnyObject
                
                caseResponseParam["jsonCase"] = Utilities.jsonToString(json: caseJsonDict as AnyObject)!
                
                
                let request = SalesforceConnection.generateSFDCRequest(restApiUrl: SalesforceRestApiUrl.createCase, params: caseResponseParam, methodType: SFRestMethod.POST)
                
                SFRestAPI.sharedInstance().send(request, fail: {
                    error in
                    
                    let errormsg = "SyncUtility:- UpdateCaseData:- " + String(describing: error)
                    Utilities.displayErrorMessage(errorMsg: errormsg)
                    
                    
                }, complete: {
                    response in
                    
                    DispatchQueue.main.async {
                        isError = Utilities.parseCaseResponse(jsonObject: response as! Dictionary<String, AnyObject>)
                        caseGroup.leave()
                    }
                    
                })
                
            }
        }
            
        else{
            caseGroup.enter()
            caseGroup.leave()
        }
        
        
        
        
        
        caseGroup.notify(queue: .main) {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateCaseView"), object: nil)
            
            if(isError == false){
                if( issueResultsArr.count > 0){
                    updateIssueData()
                }
                else
                    if(isPullData){
                        Utilities.fetchAllDataFromSalesforce(loginViewController: loginViewController)
                    }
                    else{
                        Utilities.isBackgroundSync = false
                }
            }
            else{
                SVProgressHUD.dismiss()
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
                
                //Code for updating salesforceId
                var updatedCaseId:String = issueData.caseId!
                
                let isiOSCaseId =  isiOSGeneratedId(generatedId: updatedCaseId)
                
                
                
                //if isiOSCaseId is a UUID string then get salesforce caseId from case object
                if(isiOSCaseId != nil){
                    updatedCaseId = getSalesforceCaseId(caseId: updatedCaseId)
                    
                    if(isiOSGeneratedId(generatedId: updatedCaseId) != nil){
                        Utilities.showSwiftErrorMessage(error: "updateIssueData:- CaseId:")
                    }
                }
                
                
                
                issueDict = Utilities.createAndEditIssueData(issueType: issueData.issueType!, issueNotes: issueData.notes!,caseId:updatedCaseId, currentIssueId: issueData.issueId!, iOSIssueId: issueData.issueId!,type:issueData.actionStatus!)
                
                
                
                editIssue["jsonIssue"] = Utilities.jsonToString(json: issueDict as AnyObject)!
                
                
                let request = SalesforceConnection.generateSFDCRequest(restApiUrl: SalesforceRestApiUrl.createIssue, params: editIssue, methodType: SFRestMethod.POST)
                
                SFRestAPI.sharedInstance().send(request, fail: {
                    error in
                    
                    let errormsg = "SyncUtility:- UpdateIssueData:- " + String(describing: error)
                    Utilities.displayErrorMessage(errorMsg: errormsg)
                    
                    
                }, complete: {
                    response in
                    
                    DispatchQueue.main.async {
                        _ = Utilities.parseIssueResponse(jsonObject: response as! Dictionary<String, AnyObject>)
                        issueGroup.leave()
                        print("issueGroup: \(issueData.issueType!)")
                    }
                })
                
                
                
                
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
            else{
                Utilities.isBackgroundSync = false
            }
        }
        
        
    }
    
    
    
    class func getSalesforceClientId(clientId:String)->String{
        
        let clientRes = ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "iOSTenantId == %@" ,predicateValue: clientId, isPredicate:true) as! [Tenant]
        
        if(clientRes.count > 0){
            return clientRes[0].id!
        }
        
        return clientId
        
    }
    
    class func getSalesforceUnitId(unitId:String)->String{
        
        let unitRes = ManageCoreData.fetchData(salesforceEntityName: "Unit",predicateFormat: "iOSUnitId == %@" ,predicateValue: unitId, isPredicate:true) as! [Unit]
        
        if(unitRes.count > 0){
            return unitRes[0].id!
        }
        
        return unitId
        
    }
    
    
    class func getSalesforceAssignmentLocUnitId(assignmentLocUnitId:String)->String{
        
        let unitRes = ManageCoreData.fetchData(salesforceEntityName: "Unit",predicateFormat: "iOSAssigLocUnitId == %@" ,predicateValue: assignmentLocUnitId, isPredicate:true) as! [Unit]
        
        if(unitRes.count > 0){
            return unitRes[0].assignmentLocUnitId!
        }
        
        return assignmentLocUnitId
        
    }
    
    class func getSalesforceCaseId(caseId:String)->String{
        
        let caseRes = ManageCoreData.fetchData(salesforceEntityName: "Case",predicateFormat: "iOSCaseId== %@" ,predicateValue: caseId, isPredicate:true) as! [AddCase]
        
        if(caseRes.count > 0){
            return caseRes[0].caseId!
        }
        
        return caseId
        
    }
    
    
    
    class func isiOSGeneratedId(generatedId:String)->NSUUID?{
        return NSUUID(uuidString: generatedId)
    }
    
    
    
    
    
}
