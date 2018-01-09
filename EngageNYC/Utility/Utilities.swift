//
//  Utilities.swift
//  Knock
//
//  Created by Kamal on 12/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import Foundation
import UIKit
import ArcGIS
import SwiftMessages
import SalesforceSDKCore

import Toast_Swift

import Zip


enum inTakeSegment: Int{
    case clients = 0
    case cases
    case issues
    
}

class Utilities {
    
    static var isClientDoesNotReveal:Bool = false
    
    static var isSelectContactSelect:Bool = false
    
    static var inTakeVC:InTakeViewController!
    
    
    static var clientAddressDict: [String:String] = [:]
    
    
    static var unitClientDict: [String:UnitDO] = [:]
    
    static var caseDict: [String:String] = [:]
    static var caseOpenDict: [String:Int] = [:]
    static var caseConfigDict:[String:AnyObject] = [:]
    
    
    static var countCases:Int  = 1
    static var openCountCases:Int  = 1
    
    static var timer:Timer?
    
    static let inProgressSurvey:String = "InProgress"
    static let completeSurvey:String = "Complete"
    
    static var inProgressSurveyIds = [String]()
    static var completeSurveyIds = [String]()
    
    
    
    // static var selectedDateTimeDictYYYYMMDD:[String:String?] = [:]
    // static var selectedDateTimeDictInMMDDYYYY:[String:String?] = [:]
    
    // static var selectedDatePicker:[String:Date] = [:]
    
    
    
    static var currentApiName:String = ""
    
    
    static var currentSurveyInTake:String = "Client"
    
    static var currentShowHideAssignments:Bool = true
    static var currentSortingFieldName:String = "Assignment"
    static var currentSortingTypeAscending:Bool = true
    
    
    static var currentUnitSortingFieldName:String = "UnitName"
    static var currentUnitSortingTypeAscending:Bool = true
    
    static var currentClientSortingFieldName:String = "UnitName"
    static var currentClientSortingTypeAscending:Bool = true
    
    
    
    static var currentUnitClientPage:String = "Unit"
    
    static let encryptDecryptKey = "hdsfjksdhf548954"
    static let encryptDecryptIV = "1234567890123456"
    
    
    static var isSyncing:Bool = false
    
    
    
    
    static var basemapAGSMapView:AGSMapView!
    
    static var basemapMap:AGSMap?
    
    static var currentSegmentedControl:String = ""
    
    // for skiplogic survey
    static var skipLogicParentChildDict : [String:[SkipLogic]] = [:]
    
    static var prevSkipLogicParentChildDict : [String:[SkipLogic]] = [:]
    
    static var isSubmitSurvey:Bool = false
    static var isExitFromSurvey:Bool = false
    
    static var isEditLoc:Bool = false
    static var CanvassingStatus:String = ""
    static var isRefreshBtnClick:Bool = false
    static var isBackgroundSync:Bool = false
    
    static var answerSurvey:String = ""
    
    static var SurveyOutput:[String:SurveyResult]=[:]
    
    static var surveyQuestionArray = [structSurveyQuestion]()
    
    static var surveyQuestionArrayIndex = -1
    
    static var currentSurveyPage = 0
    
    static var totalSurveyQuestions = 0
    
    static var currentLocationRowIndex = 0
    
    static var offlineSyncTime = 0
    
    
    //    static var isMapFileCorrupted:Bool = false
    //    static var isGeodatabaseFileCorrupted:Bool = false
    
    
    
    class func getClientName(tenantId:String)-> String{
        
        let clientName = ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "id == %@" ,predicateValue: tenantId,isPredicate:true) as! [Tenant]
        
        if(clientName.count > 0){
            return clientName[0].name!
        }
        else{
            return ""
            
        }
        
    }
    
    
    class func switchBetweenViewControllers(senderVC: UIViewController, fromVC : UIViewController, toVC: UIViewController){
        let newVC = toVC
        let oldVC = fromVC
        
        oldVC.willMove(toParentViewController: nil)
        senderVC.addChildViewController(newVC)
        newVC.view.frame = oldVC.view.frame
        senderVC.transition(from: oldVC, to: newVC, duration: 0.25, options: .transitionCrossDissolve, animations: {
            //nothing
        }) { (finished) in
            oldVC.removeFromParentViewController()
            newVC.didMove(toParentViewController: senderVC)
        }
    }
    
    
    class func startBackgroundSyncing(){
        // Scheduling timer to Call the function **Countdown** with the interval of 1 seconds
        
        
        let userSettingData = ManageCoreData.fetchData(salesforceEntityName: "Setting", isPredicate:false) as! [Setting]
        
        if(userSettingData.count > 0){
            
            
            offlineSyncTime = Int(userSettingData[0].offlineSyncTime!)!
            
            
            let syncTime:TimeInterval = TimeInterval(CGFloat(offlineSyncTime * 60))
            
            Utilities.timer = Timer.scheduledTimer(timeInterval: syncTime, target: self, selector: #selector(Utilities.checkConnection), userInfo: nil, repeats: true)
            
            print("offlineSyncTime")
            print("Timer initialize")
        }
        
        
        
    }
    
    @objc class func checkConnection(){
        
        if(Network.reachability?.isReachable)!{
            
            if(Utilities.isRefreshBtnClick == false){
                
                Utilities.isBackgroundSync = true
                
                print("\(Utilities.offlineSyncTime) minutes")
                SyncUtility.syncDataWithSalesforce(isPullDataFromSFDC: false)
            }
        }
        
    }
    
    
    class func deleteSkipSurveyData(startingIndex:Int,count:Int){
        
        for questionIndex in startingIndex...count {
            
            
            //Clear data which questions skipped
            let objTempSurveyQues =  Utilities.surveyQuestionArray[questionIndex].objectSurveyQuestion
            
            if(Utilities.SurveyOutput[(objTempSurveyQues?.questionNumber)!] != nil){
                
                //delete data from dictionary
                Utilities.SurveyOutput.removeValue(forKey: (objTempSurveyQues?.questionNumber)!)
            }
            
            
        }
        
        
        
    }
    
    
    class func convertToJSON(text: String) ->  [String: Any]? {
        
        if let data = text.data(using: .utf8) {
            
            do {
                
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
            } catch {
                
                print(error.localizedDescription)
                
            }
            
        }
        
        return nil
        
    }
    
    class func jsonToString(json: AnyObject)->String?{
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            
            
            
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            
            // print(convertedString!)
            
            return convertedString!
            
            // print(convertedString) // <-- here is ur string
            
        } catch let myJSONError {
            print(myJSONError)
        }
        
        return nil
        
    }
    
    //    class func decryptJsonData(jsonEncryptString:String) -> String{
    //
    //
    //
    //        //  var returnjsonData:Data?
    //
    //
    //        //Remove first two characters
    //
    //        let startIndex = jsonEncryptString.index(jsonEncryptString.startIndex, offsetBy: 1)
    //
    //        let headString = jsonEncryptString.substring(from: startIndex)
    //
    //
    //
    //        //Remove last two characters
    //
    //        let endIndex = headString.index(headString.endIndex, offsetBy: -1)
    //
    //        let trailString = headString.substring(to: endIndex)
    //
    //
    //        let decryptData = try! trailString.aesDecrypt(SalesforceConfig.key, iv: SalesforceConfig.iv)
    //
    //
    //
    //        // returnjsonData = decryptData.data(using: .utf8)
    //
    //
    //
    //
    //        return decryptData
    //
    //    }
    
    //    class func encryptedParams(dictParameters:AnyObject)-> String{
    //        let convertedString = Utilities.jsonToString(json: dictParameters as AnyObject)
    //
    //
    //
    //        let encryptSaveUnitStr = try! convertedString?.aesEncrypt(SalesforceConfig.key, iv: SalesforceConfig.iv)
    //
    //        return encryptSaveUnitStr!
    //    }
    
    class func showErrorMessage(toastView:UIView,message:String,delay:TimeInterval,toastPosition:ToastPosition){
        
        toastView.makeToast(message, duration: delay, position: toastPosition)
    }
    
    
    class func createUnitDicData(unitName:String,apartmentNumber:String,privateHome:String,locationId:String,assignmentLocId:String,notes:String,iosLocUnitId:String,iosAssignLocUnitId:String)->[String:String]{
        
        var newUnitDic:[String:String] = [:]
        
        newUnitDic["unitName"] =  unitName//"Apt " + apartmentNumberVal
        
        newUnitDic["apartmentNumber"] = apartmentNumber
        
        newUnitDic["privateHome"] = privateHome
        
        newUnitDic["locationId"] = locationId//SalesforceConnection.locationId
        
        newUnitDic["assignLocId"] = assignmentLocId//SalesforceConnection.assignmentLocationId
        
        newUnitDic["notes"] = notes//notesVal
        
        //................
        newUnitDic["iOSLocUnitId"] = iosLocUnitId //UUID().uuidString
        
        newUnitDic["iOSAssignmentLocUnitId"] = iosAssignLocUnitId//UUID().uuidString
        
        return newUnitDic
    }
    
    class func editUnitTenantAndSurveyDicData(intake:String?=nil,notes:String?=nil,attempt:String?=nil,contact:String?=nil,reKnockNeeded:String?=nil,reason:String?=nil,contactOutcome:String?=nil,assignmentLocationUnitId:String?=nil,selectedSurveyId:String?=nil,selectedTenantId:String?=nil,followUpType:String?=nil,followUpDate:String?=nil,lastCanvassedBy:String?=nil)->[String:String]{
        
        var editUnitDict:[String:String] = [:]
        
        editUnitDict["assignmentLocationUnitId"] = assignmentLocationUnitId
        
        
        editUnitDict["intake"] = intake
        editUnitDict["reason"] = reason
        editUnitDict["notes"] = notes
        editUnitDict["attempt"] = attempt
        editUnitDict["contact"] = contact
        editUnitDict["reKnockNeeded"] = reKnockNeeded
        
        editUnitDict["contactOutcome"] = contactOutcome
        
        
        
        editUnitDict["surveyId"] = selectedSurveyId
        editUnitDict["tenantId"] = selectedTenantId
        
        editUnitDict["lastCanvassedBy"] = lastCanvassedBy
        
        if(followUpDate != ""){
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let date = dateFormatter.date(from: followUpDate!)!
            
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            editUnitDict["followUpDate"] = dateFormatter.string(from: date)
        }
        
        editUnitDict["followUpType"] = followUpType
        
        return editUnitDict
    }
    
    class func editLocData(canvassingStatus:String,assignmentLocationId:String,notes:String,attempt:String)->[String:String]{
        
        var editLocDict:[String:String] = [:]
        
        editLocDict["status"] = canvassingStatus
        editLocDict["assignmentLocationId"] = assignmentLocationId
        editLocDict["Notes"] = notes
        editLocDict["attempt"] = attempt
        
        
        return editLocDict
        
    }
    
    
    
    class func createAndEditIssueData(issueType:String,issueNotes:String,caseId:String, currentIssueId:String,iOSIssueId:String,type:String)->[String:AnyObject]{
        
        var editIssueDict:[String:AnyObject] = [:]
        
        if(type == "edit"){
            editIssueDict["issueId"] = currentIssueId as AnyObject?
        }
        
        
        editIssueDict["iOSIssueId"] = iOSIssueId as AnyObject?
        
        editIssueDict["caseId"] = caseId as AnyObject?
        
        editIssueDict["issueType"] = issueType as AnyObject?
        
        editIssueDict["issueNotes"] = issueNotes as AnyObject?
        
        
        
        return editIssueDict
        
    }
    
    
    
    class func createAndEditTenantData(firstName:String,lastName:String,middleName:String,suffix:String,email:String,phone:String,dob:String,attempt:String,contact:String,contactOutcome:String,notes:String,streetNum:String,streetName:String,borough:String,zip:String,aptNo:String,aptFloor:String,locationUnitId:String,currentTenantId:String,iOSTenantId:String,assignmentLocId:String,type:String)->[String:String]{
        
        var editTenantDict:[String:String] = [:]
        
        if(type == "edit"){
            editTenantDict["tenantId"] = currentTenantId
        }
        
        
        
        
        editTenantDict["iOSTenantId"] = iOSTenantId
        
        
        editTenantDict["locationUnitId"] = locationUnitId
        
        editTenantDict["firstName"] = firstName
        
        editTenantDict["lastName"] = lastName
        
        editTenantDict["email"] = email
        
        editTenantDict["phone"] = phone
        
        editTenantDict["middleName"] = middleName
        
        editTenantDict["suffix"] = suffix
        
        editTenantDict["attempt"] = attempt
        
        editTenantDict["contact"] = contact
        
        editTenantDict["contactOutcome"] = contactOutcome
        
        editTenantDict["notes"] = notes
        
        //...........address info
        
        editTenantDict["streetNum"] = streetNum
        
        editTenantDict["streetName"] = streetName
        
        editTenantDict["borough"] = borough
        
        editTenantDict["zip"] = zip
        
        editTenantDict["aptNo"] = aptNo
        
        editTenantDict["aptFloor"] = aptFloor
        
        
        
        editTenantDict["assignmentLocationId"] = assignmentLocId
        
        
        
        if(dob != ""){
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let date = dateFormatter.date(from: dob)!
            
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            editTenantDict["birthdate"] = dateFormatter.string(from: date)
        }
        
        
        
        
        
        return editTenantDict
        
    }
    
    
    
    //    class func assignTenantDicData(selectedTenantId:String,assignmentLocUnitId:String)->[String:String]{
    //
    //
    //        var tenantAssignDict:[String:String] = [:]
    //
    //        tenantAssignDict["contactId"] = selectedTenantId
    //        tenantAssignDict["assignmentLocationUnitId"] = assignmentLocUnitId
    //
    //        return tenantAssignDict
    //    }
    
    
    
    //    class func parseEditUnitResponse(jsonObject: Dictionary<String, AnyObject>)->Bool {
    //
    //
    //        guard let isError = jsonObject["hasError"] as? Bool,
    //
    //            let unitDataDict = jsonObject["unitData"] as? [String: AnyObject] else { return true}
    //
    //        if(isError == false){
    //
    //
    //            updateUnitDetail(unitDataDict: unitDataDict)
    //
    //
    //        }
    //
    //
    //        return isError
    //
    //
    //
    //    }
    
    
    
    
    class func displayErrorMessage(errorMsg:String){
        Utilities.isBackgroundSync = false
        Utilities.isRefreshBtnClick = false
        
        SVProgressHUD.dismiss()
        Utilities.showSwiftErrorMessage(error: errorMsg)
    }
    
    
    class func parseAddNewUnitResponse(jsonObject: Dictionary<String, AnyObject>)->Bool {
        
        
        guard let isError = jsonObject["hasError"] as? Bool,
            
            let message = jsonObject["message"] as? String,
            
            let unitDataDict = jsonObject["unitData"] as? [String: AnyObject] else { return true}
        
        
        
        
        if(isError == false){
            
            //update unitId and assignmentLocUnitId
            updateUnitDetail(unitDataDict: unitDataDict)
            updateEditUnitDetail(unitDataDict: unitDataDict)
            updateTenantDetail(unitDataDict: unitDataDict)
            updateSurveyResponseDetail(unitDataDict: unitDataDict)
            updateCases(unitDataDict: unitDataDict)
            
            // updateSurveyUnitDetail(unitDataDict: unitDataDict)
            // updateTenantAssignDetail(unitDataDict: unitDataDict)
            // updateAssignmentUnitCount()
            
            
            
        }
        else{
            
            displayErrorMessage(errorMsg: "Error while adding new unit to salesforce.\(message)")
            
        }
        
        
        return isError
        
        
        
    }
    
    
    class func parseTenantResponse(jsonObject: Dictionary<String, AnyObject>)->Bool{
        
        guard let isError = jsonObject["hasError"] as? Bool,
            
            let message = jsonObject["message"] as? String,
            
            let tenantDataDictonary = jsonObject["tenantData"] as? [String: AnyObject] else { return true }
        
        
        
        
        if(isError == false){
            
            
            updateTenantIdInCoreData(tenantDataDict: tenantDataDictonary)
            
            updateTenantIdInTenantAssign(tenantDataDict: tenantDataDictonary)
            
            updateTenantIdInCase(tenantDataDict: tenantDataDictonary)
            updateTenantIdInAddCase(tenantDataDict: tenantDataDictonary)
            
            updateTenantIdInSurveyResponse(tenantDataDict: tenantDataDictonary)
            
        }
        else{
            displayErrorMessage(errorMsg: "Error while adding new tenant to salesforce.\(message)")
        }
        
        return isError
        
        
    }
    
    class func parseCaseResponse(jsonObject: Dictionary<String, AnyObject>)->Bool{
        
        guard let isError = jsonObject["hasError"] as? Bool,
            
            let message = jsonObject["message"] as? String,
            
            let caseDataDictonary = jsonObject["caseData"] as? [String: AnyObject] else { return true }
        
        
        
        
        if(isError == false){
            
            updateCaseIdInAddCase(caseDataDict: caseDataDictonary)
            
            updateCaseIdInCoreData(caseDataDict: caseDataDictonary)
            updateCaseIdInIssue(caseDataDict: caseDataDictonary)
            
        }
        else{
            displayErrorMessage(errorMsg: "Error while adding new case to salesforce.\(message)")
        }
        
        
        return isError
        
        
    }
    
    class func parseIssueResponse(jsonObject: Dictionary<String, AnyObject>)->Bool{
        
        guard let isError = jsonObject["hasError"] as? Bool,
            
            let message = jsonObject["message"] as? String,
            
            let issueDataDictonary = jsonObject["issueData"] as? [String: AnyObject] else { return true }
        
        
        
        
        if(isError == false){
            
            updateIssueIdInCoreData(issueDataDict: issueDataDictonary)
            
        }
        else{
            
            displayErrorMessage(errorMsg: "Error while adding new issue to salesforce.\(message)")
        }
        
        return isError
        
        
    }
    
    
    
    
    
    class func parseEditLocation(jsonObject: Dictionary<String, AnyObject>){
        
        let assignmentLocId = jsonObject["assignmentLocationId"] as? String
        
        let editLocResults = ManageCoreData.fetchData(salesforceEntityName: "EditLocation",predicateFormat: "actionStatus == %@ AND assignmentLocId == %@" ,predicateValue: "edit",predicateValue2: assignmentLocId,isPredicate:true) as! [EditLocation]
        
        if(editLocResults.count > 0){
            
            var updateObjectDic:[String:String] = [:]
            
            updateObjectDic["actionStatus"] = ""
            
            ManageCoreData.updateRecord(salesforceEntityName: "EditLocation", updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocId == %@", predicateValue: assignmentLocId,isPredicate: true)
            
            
        }
        
        
    }
    
    
    class func parseEditUnit(jsonObject: Dictionary<String, AnyObject>){
        
        
        let assignmentLocUnitId = jsonObject["assignmentLocationUnitId"] as? String
        
        let editUnitResults = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "actionStatus == %@ OR actionStatus == %@ AND assignmentLocUnitId == %@" ,predicateValue: "edit",predicateValue2: "create",predicateValue3: assignmentLocUnitId,isPredicate:true) as! [EditUnit]
        
        if(editUnitResults.count > 0){
            
            var updateObjectDic:[String:String] = [:]
            
            updateObjectDic["actionStatus"] = ""
            
            ManageCoreData.updateRecord(salesforceEntityName: "EditUnit", updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocUnitId == %@", predicateValue: assignmentLocUnitId,isPredicate: true)
            
            
        }
        
        if(assignmentLocUnitId !=  nil){
            updateSyncDate(assignmentLocUnitId: assignmentLocUnitId!)
        }
        
        
    }
    
    class func parseSurveyResponse(jsonObject: Dictionary<String, AnyObject>){
        
        let assignmentLocUnitId = jsonObject["assignmentLocationUnitId"] as? String
        
        let surveyResResults = ManageCoreData.fetchData(salesforceEntityName: "SurveyResponse",predicateFormat: "actionStatus == %@ AND assignmentLocUnitId == %@" ,predicateValue: "Complete",predicateValue2: assignmentLocUnitId,isPredicate:true) as! [SurveyResponse]
        
        if(surveyResResults.count > 0){
            
            var updateObjectDic:[String:String] = [:]
            
            updateObjectDic["actionStatus"] = "Done"
            
            ManageCoreData.updateRecord(salesforceEntityName: "SurveyResponse", updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocUnitId == %@", predicateValue: assignmentLocUnitId,isPredicate: true)
            
            print("update survey response: \(assignmentLocUnitId)")
        }
        
        
    }
    
    
    
    
    
    class func updateIssueIdInCoreData(issueDataDict:[String:AnyObject]){
        
        let iOSIssueId = issueDataDict["iOSIssueId"] as! String?
        let issueId = issueDataDict["issueId"] as! String?
        let issueNo = issueDataDict["issueNumber"] as! String?
        
        if(GlobalIssue.currentIssueId == iOSIssueId){
            GlobalIssue.currentIssueId =  issueId!
            print("issueId updated")
        }
        
        let issueResults = ManageCoreData.fetchData(salesforceEntityName: "Issues",predicateFormat: "actionStatus == %@ OR actionStatus == %@ AND issueId == %@" ,predicateValue: "create",predicateValue2: "edit", predicateValue3: iOSIssueId, isPredicate:true) as! [Issues]
        
        
        
        if(issueResults.count > 0){
            
            var updateObjectDic:[String:String] = [:]
            updateObjectDic["issueId"] = issueId
            updateObjectDic["issueNo"] = issueNo
            updateObjectDic["actionStatus"] = ""
            
            ManageCoreData.updateRecord(salesforceEntityName: "Issues", updateKeyValue: updateObjectDic, predicateFormat: "issueId == %@", predicateValue: iOSIssueId,isPredicate: true)
            
            
            
        }
        
        
    }
    
    
    
    class func updateCaseIdInAddCase(caseDataDict: [String:AnyObject]){
        
        let iOSCaseId = caseDataDict["iOSCaseId"] as! String?
        let caseId = caseDataDict["caseId"] as! String?
        
        if(GlobalCase.caseId == iOSCaseId){
            GlobalCase.caseId =  caseId!
            print("caseId updated")
        }
        
        let caseResults = ManageCoreData.fetchData(salesforceEntityName: "AddCase",predicateFormat: "caseId == %@" ,predicateValue: iOSCaseId, isPredicate:true) as! [AddCase]
        
        if(caseResults.count > 0){
            
            var updateObjectDic:[String:String] = [:]
            
            updateObjectDic["actionStatus"] = ""
            
            ManageCoreData.updateRecord(salesforceEntityName: "AddCase", updateKeyValue: updateObjectDic, predicateFormat: "caseId == %@", predicateValue: iOSCaseId,isPredicate: true)
            
            print("updateCaseIdInAddCase: \(iOSCaseId)")
        }
        
    }
    
    
    class func updateCaseIdInCoreData(caseDataDict:[String:AnyObject]){
        
        let iOSCaseId = caseDataDict["iOSCaseId"] as! String?
        let caseId = caseDataDict["caseId"] as! String?
        let caseNumber = caseDataDict["caseNo"] as! String?
        
        
        let caseResults = ManageCoreData.fetchData(salesforceEntityName: "Cases",predicateFormat: "caseId == %@" ,predicateValue: iOSCaseId, isPredicate:true) as! [Cases]
        
        
        
        if(caseResults.count > 0){
            
            var updateObjectDic:[String:String] = [:]
            updateObjectDic["caseId"] = caseId
            updateObjectDic["caseNo"] = caseNumber
            
            ManageCoreData.updateRecord(salesforceEntityName: "Cases", updateKeyValue: updateObjectDic, predicateFormat: "caseId == %@", predicateValue: iOSCaseId,isPredicate: true)
            
            print("updateCaseIdInCoreData")
            
        }
        
        
    }
    
    class func updateCaseIdInIssue(caseDataDict:[String:AnyObject]){
        
        let iOSCaseId = caseDataDict["iOSCaseId"] as! String?
        let caseId = caseDataDict["caseId"] as! String?
        
        
        
        let issueResults = ManageCoreData.fetchData(salesforceEntityName: "Issues",predicateFormat: "caseId == %@" ,predicateValue: iOSCaseId, isPredicate:true) as! [Issues]
        
        
        
        if(issueResults.count > 0){
            
            var updateObjectDic:[String:String] = [:]
            updateObjectDic["caseId"] = caseId
            
            ManageCoreData.updateRecord(salesforceEntityName: "Issues", updateKeyValue: updateObjectDic, predicateFormat: "caseId == %@", predicateValue: iOSCaseId,isPredicate: true)
            
            print("updateCaseIdInIssue")
            
            
        }
        
        
        
    }
    
    
    
    class func updateTenantIdInCoreData(tenantDataDict:[String:AnyObject]){
        
        let iosTenantId = tenantDataDict["iOSTenantId"] as! String?
        let tenantId = tenantDataDict["tenantId"] as! String?
        
        if(GlobalClient.currentTenantId == iosTenantId){
            GlobalClient.currentTenantId =  tenantId!
            print("tenantId updated")
        }
        
        let tenantCreateResults = ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "actionStatus == %@ OR actionStatus == %@ AND id == %@" ,predicateValue: "create",predicateValue2: "edit", predicateValue3: iosTenantId, isPredicate:true) as! [Tenant]
        
        
        
        if(tenantCreateResults.count > 0){
            
            var updateObjectDic:[String:String] = [:]
            updateObjectDic["id"] = tenantId
            updateObjectDic["actionStatus"] = ""
            
            ManageCoreData.updateRecord(salesforceEntityName: "Tenant", updateKeyValue: updateObjectDic, predicateFormat: "id == %@", predicateValue: iosTenantId,isPredicate: true)
            
            if(tenantCreateResults[0].assignmentLocUnitId !=  nil){
                updateSyncDate(assignmentLocUnitId: tenantCreateResults[0].assignmentLocUnitId!)
                
                print("Tenant:- clientId updated")
                
            }
            
        }
        
        
    }
    
    
    
    class func updateTenantIdInTenantAssign(tenantDataDict:[String:AnyObject]){
        
        let iosTenantId = tenantDataDict["iOSTenantId"] as! String?
        let tenantId = tenantDataDict["tenantId"] as! String?
        
        
        let tenantAssignResults = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "tenantId == %@" ,predicateValue: iosTenantId, isPredicate:true) as! [EditUnit]
        
        
        
        if(tenantAssignResults.count > 0){
            
            var updateObjectDic:[String:String] = [:]
            updateObjectDic["tenantId"] = tenantId
            
            
            ManageCoreData.updateRecord(salesforceEntityName: "EditUnit", updateKeyValue: updateObjectDic, predicateFormat: "tenantId == %@", predicateValue: iosTenantId,isPredicate: true)
            
            print("Edit Unit:- clientId updated")
            
            
        }
    }
    
    class func updateTenantIdInCase(tenantDataDict:[String:AnyObject]){
        
        let iosTenantId = tenantDataDict["iOSTenantId"] as! String?
        let tenantId = tenantDataDict["tenantId"] as! String?
        
        
        let caseResults = ManageCoreData.fetchData(salesforceEntityName: "Cases",predicateFormat: "contactId == %@" ,predicateValue: iosTenantId, isPredicate:true) as! [Cases]
        
        
        
        if(caseResults.count > 0){
            
            var updateObjectDic:[String:String] = [:]
            updateObjectDic["contactId"] = tenantId
            
            
            ManageCoreData.updateRecord(salesforceEntityName: "Cases", updateKeyValue: updateObjectDic, predicateFormat: "contactId == %@", predicateValue: iosTenantId,isPredicate: true)
            
            print("Cases:- clientId updated")
            
        }
    }
    
    
    class func updateTenantIdInSurveyResponse(tenantDataDict:[String:AnyObject]){
        
        let iosTenantId = tenantDataDict["iOSTenantId"] as! String?
        let tenantId = tenantDataDict["tenantId"] as! String?
        
        
        let surveyResResults = ManageCoreData.fetchData(salesforceEntityName: "SurveyResponse",predicateFormat: "clientId == %@",predicateValue: iosTenantId,isPredicate:true) as! [SurveyResponse]
        
        
        
        if(surveyResResults.count > 0){
            
            
            var updateObjectDic:[String:String] = [:]
            updateObjectDic["clientId"] = tenantId
            
            
            
            ManageCoreData.updateRecord(salesforceEntityName: "SurveyResponse", updateKeyValue: updateObjectDic, predicateFormat: "clientId == %@", predicateValue: iosTenantId,isPredicate: true)
            
            print("surveyResResults:- clientId updated")
        }
        
        
        
    }
    
    
    
    
    class func updateTenantIdInAddCase(tenantDataDict:[String:AnyObject]){
        
        let iosTenantId = tenantDataDict["iOSTenantId"] as! String?
        let tenantId = tenantDataDict["tenantId"] as! String?
        
        
        let caseResults = ManageCoreData.fetchData(salesforceEntityName: "AddCase",predicateFormat: "clientId == %@" ,predicateValue: iosTenantId, isPredicate:true) as! [AddCase]
        
        
        
        if(caseResults.count > 0){
            
            var updateObjectDic:[String:String] = [:]
            updateObjectDic["clientId"] = tenantId
            
            
            ManageCoreData.updateRecord(salesforceEntityName: "AddCase", updateKeyValue: updateObjectDic, predicateFormat: "clientId == %@", predicateValue: iosTenantId,isPredicate: true)
            
        }
    }
    
    
    
    
    class func updateSyncDate(assignmentLocUnitId:String){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        
        
        var updateObjectDic:[String:String] = [:]
        updateObjectDic["unitSyncDate"]  = dateFormatter.string(from: Date())
        
        
        ManageCoreData.updateRecord(salesforceEntityName: "Unit", updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocUnitId ==%@", predicateValue: assignmentLocUnitId,isPredicate: true)
        
        print("Sync Date updated")
        
    }
    
    //Tested
    class func updateUnitDetail(unitDataDict:[String:AnyObject]){
        
        
        let locUnitId = unitDataDict["unitId"] as! String?
        let locAssignmentUnitId = unitDataDict["assignmentLocUnitId"] as! String?
        let iosLocUnitId = unitDataDict["iOSLocUnitId"] as! String?
        let iosAssignmentLocUnitId = unitDataDict["iOSAssignmentLocUnitId"] as! String?
        
        
        if(SalesforceConnection.unitId == iosLocUnitId){
            SalesforceConnection.unitId =  locUnitId!
            print("location UnitId updated")
        }
        
        if(SalesforceConnection.assignmentLocationUnitId == iosAssignmentLocUnitId){
            SalesforceConnection.assignmentLocationUnitId =  locAssignmentUnitId!
            print("assignment location UnitId updated")
        }
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        
        
        var updateObjectDic:[String:String] = [:]
        updateObjectDic["id"] = locUnitId
        updateObjectDic["assignmentLocUnitId"] = locAssignmentUnitId
        updateObjectDic["actionStatus"] = ""
        updateObjectDic["unitSyncDate"]  = dateFormatter.string(from: Date())
        
        
        ManageCoreData.updateRecord(salesforceEntityName: "Unit", updateKeyValue: updateObjectDic, predicateFormat: "id == %@ AND assignmentLocUnitId ==%@", predicateValue: iosLocUnitId,predicateValue2: iosAssignmentLocUnitId,isPredicate: true)
        
        
    }
    
    
    
    class func updateTenantDetail(unitDataDict:[String:AnyObject]){
        
        
        let locUnitId = unitDataDict["unitId"] as! String?
        let locAssignmentUnitId = unitDataDict["assignmentLocUnitId"] as! String?
        let iosLocUnitId = unitDataDict["iOSLocUnitId"] as! String?
        let iosAssignmentLocUnitId = unitDataDict["iOSAssignmentLocUnitId"] as! String?
        
        let tenantResults = ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "unitId == %@ AND assignmentLocUnitId == %@" ,predicateValue: iosLocUnitId,predicateValue2: iosAssignmentLocUnitId,isPredicate:true) as! [Tenant]
        
        
        
        
        
        if(tenantResults.count > 0){
            
            for tenantData in tenantResults{
                
                var updateObjectDic:[String:String] = [:]
                updateObjectDic["unitId"] = locUnitId
                updateObjectDic["assignmentLocUnitId"] = locAssignmentUnitId
                
                
                ManageCoreData.updateRecord(salesforceEntityName: "Tenant", updateKeyValue: updateObjectDic, predicateFormat: "unitId == %@ AND assignmentLocUnitId ==%@ AND id == %@", predicateValue: iosLocUnitId, predicateValue2: iosAssignmentLocUnitId,predicateValue3: tenantData.id!, isPredicate: true)
                
                print("tenantResults update")
            }
        }
        
    }
    
    
    class func updateEditUnitDetail(unitDataDict:[String:AnyObject]){
        
        
        let locUnitId = unitDataDict["unitId"] as! String?
        let locAssignmentUnitId = unitDataDict["assignmentLocUnitId"] as! String?
        let iosLocUnitId = unitDataDict["iOSLocUnitId"] as! String?
        let iosAssignmentLocUnitId = unitDataDict["iOSAssignmentLocUnitId"] as! String?
        
        let editUnitResults = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "unitId == %@ AND assignmentLocUnitId == %@" ,predicateValue: iosLocUnitId,predicateValue2: iosAssignmentLocUnitId,isPredicate:true) as! [EditUnit]
        
        
        
        
        
        if(editUnitResults.count > 0){
            
            
            var updateObjectDic:[String:String] = [:]
            updateObjectDic["unitId"] = locUnitId
            updateObjectDic["assignmentLocUnitId"] = locAssignmentUnitId
            //updateObjectDic["actionStatus"] = ""
            
            ManageCoreData.updateRecord(salesforceEntityName: "EditUnit", updateKeyValue: updateObjectDic, predicateFormat: "unitId == %@ AND assignmentLocUnitId ==%@", predicateValue: iosLocUnitId, predicateValue2: iosAssignmentLocUnitId,isPredicate: true)
            
            print("EditUnit updated")
        }
        
        
    }
    
    
    class func updateSurveyResponseDetail(unitDataDict:[String:AnyObject]){
        
        
        let locUnitId = unitDataDict["unitId"] as! String?
        let locAssignmentUnitId = unitDataDict["assignmentLocUnitId"] as! String?
        let iosLocUnitId = unitDataDict["iOSLocUnitId"] as! String?
        let iosAssignmentLocUnitId = unitDataDict["iOSAssignmentLocUnitId"] as! String?
        
        
        let surveyResResults = ManageCoreData.fetchData(salesforceEntityName: "SurveyResponse",predicateFormat: "unitId == %@ AND assignmentLocUnitId ==%@",predicateValue: iosLocUnitId,predicateValue2: iosAssignmentLocUnitId,isPredicate:true) as! [SurveyResponse]
        
        
        
        if(surveyResResults.count > 0){
            
            
            var updateObjectDic:[String:String] = [:]
            updateObjectDic["unitId"] = locUnitId
            updateObjectDic["assignmentLocUnitId"] = locAssignmentUnitId
            
            
            ManageCoreData.updateRecord(salesforceEntityName: "SurveyResponse", updateKeyValue: updateObjectDic, predicateFormat: "unitId == %@ AND assignmentLocUnitId ==%@", predicateValue: iosLocUnitId,predicateValue2: iosAssignmentLocUnitId,isPredicate: true)
            
            print("surveyResResults updated")
        }
        
        if(locAssignmentUnitId !=  nil){
            updateSyncDate(assignmentLocUnitId: locAssignmentUnitId!)
        }
        
    }
    
    class func updateCases(unitDataDict:[String:AnyObject]){
        
        let locUnitId = unitDataDict["unitId"] as! String?
        let locAssignmentUnitId = unitDataDict["assignmentLocUnitId"] as! String?
        let iosLocUnitId = unitDataDict["iOSLocUnitId"] as! String?
        let iosAssignmentLocUnitId = unitDataDict["iOSAssignmentLocUnitId"] as! String?
        
        
        let caseResults = ManageCoreData.fetchData(salesforceEntityName: "Cases",predicateFormat: "unitId == %@ AND assignmentLocUnitId ==%@",predicateValue: iosLocUnitId,predicateValue2: iosAssignmentLocUnitId,isPredicate:true) as! [Cases]
        
        
        
        if(caseResults.count > 0){
            
            
            var updateObjectDic:[String:String] = [:]
            updateObjectDic["unitId"] = locUnitId
            updateObjectDic["assignmentLocUnitId"] = locAssignmentUnitId
            
            
            ManageCoreData.updateRecord(salesforceEntityName: "Cases", updateKeyValue: updateObjectDic, predicateFormat: "unitId == %@ AND assignmentLocUnitId ==%@", predicateValue: iosLocUnitId,predicateValue2: iosAssignmentLocUnitId,isPredicate: true)
            
            print("Cases updated")
        }
        
    }
    
    
    
    
    class func updateAssignmentUnitCount(){
        
        let assignementResults = ManageCoreData.fetchData(salesforceEntityName: "Assignment",predicateFormat: "id == %@" ,predicateValue: SalesforceConnection.assignmentId,isPredicate:true) as! [Assignment]
        
        if(assignementResults.count > 0){
            
            let totalUnits = String(Int(assignementResults[0].totalUnits!)! + 1)
            
            
            ManageCoreData.updateData(salesforceEntityName: "Assignment", valueToBeUpdate: totalUnits,updatekey:"totalUnits", predicateFormat: "id == %@", predicateValue: SalesforceConnection.assignmentId, isPredicate: true)
        }
    }
    
    
    
    
    //for assignmentDetail api
    
    
    class func deleteBasemap() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: path)
            for file in files {
                let remove = file.hasSuffix(".mmpk")
                if remove {
                    try FileManager.default.removeItem(atPath: (path as NSString).appendingPathComponent(file))
                    print("deleting file: \(file)")
                }
            }
            print("deleted basemap")
        }
        catch {
            print(error)
        }
    }
    
    class func deleteGeodatabase() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: path)
            for file in files {
                let remove = file.hasSuffix(".geodatabase")
                if remove {
                    try FileManager.default.removeItem(atPath: (path as NSString).appendingPathComponent(file))
                    print("deleting geodatabase: \(file)")
                }
            }
            print("deleted geodatabase")
        }
        catch {
            print(error)
        }
    }
    
    class func setInProgressCompleteSurveyIds(){
        
        
        let surveyResponseResults =
            ManageCoreData.fetchData(salesforceEntityName: "SurveyResponse" , isPredicate:false) as! [SurveyResponse]
        
        if(surveyResponseResults.count > 0){
            for surveyResponseResult in surveyResponseResults{
                if let status = surveyResponseResult.actionStatus
                {
                    if status == Utilities.inProgressSurvey{
                        Utilities.inProgressSurveyIds.append(surveyResponseResult.surveyId!)
                    }
                    else{
                        Utilities.completeSurveyIds.append(surveyResponseResult.surveyId!)
                    }
                }
                
            }
        }
        
        
    }
    
    class func downloadESRIFeatureLayers(loginVC:LoginViewController?=nil){
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let fullPath = "\(path)/NewYorkLayers.geodatabase"
        
        
        if (Utilities.isGeoDatabseExist()==false) {
            
            //This will call when first then user install app
            //download first layers data then basemap
            DownloadESRILayers.DownloadData(loginViewController: loginVC,downloadPath:fullPath)
            
            
        }
    }
    
    
    class func fetchAllDataFromSalesforce(loginViewController:LoginViewController?=nil){
        
        
        var userParams : [String:String] = [:]
        
        if(loginViewController == nil){
            SVProgressHUD.show(withStatus: "Syncing data..", maskType: SVProgressHUDMaskType.gradient)
        }
        
        SalesforceConnection.salesforceUserId  = (SFUserAccountManager.sharedInstance().currentUser?.idData.userId)!
        
        //SFUserAccountManager.sharedInstance().currentUserIdentity?.userId
        userParams["userId"] = SalesforceConnection.salesforceUserId
        
        
        
        let userDetailReq = SalesforceConnection.generateSFDCRequest(restApiUrl: SalesforceRestApiUrl.userDetail, params: userParams, methodType: SFRestMethod.POST)
        
        SFRestAPI.sharedInstance().send(userDetailReq, fail: {
            error in
            
            Utilities.showSwiftErrorMessage(error: "Utilities:- FetchAllDataFromSFDC:- UserDetailRequest:- \(String(describing: error))")
            
        }, complete: {
            userInfoJsonData in
            
            DispatchQueue.main.async {
                
                Utilities.parseUserInfoData(jsonObject: userInfoJsonData as! Dictionary<String, AnyObject>)
                self.PullDataFromSFDC(loginViewController:loginViewController)
                
            }
            
        })
        
        
        
        
    }//end of class
    
    
    class func PullDataFromSFDC(loginViewController:LoginViewController?=nil){
        
        var externalIdParams : [String:String] = [:]
        
        externalIdParams["externalId"] = SalesforceConfig.currentUserExternalId
        
        let eventAssignmentReq = SalesforceConnection.generateSFDCRequest(restApiUrl: SalesforceRestApiUrl.getAllEventAssignmentData, params: externalIdParams, methodType: SFRestMethod.POST)
        
        SFRestAPI.sharedInstance().send(eventAssignmentReq, fail: {
            error in
            
            Utilities.showSwiftErrorMessage(error: "Utilities:- FetchAllDataFromSFDC:- EventAssignmentRequest:- \(String(describing: error))")
            
        }, complete: {
            assignmentJsonData in
            
            let chartReq = SalesforceConnection.generateSFDCRequest(restApiUrl: SalesforceRestApiUrl.assignmentdetailchart, params: externalIdParams, methodType: SFRestMethod.POST)
            
            SFRestAPI.sharedInstance().send(chartReq, fail: {
                error in
                
                Utilities.showSwiftErrorMessage(error: "Utilities:- FetchAllDataFromSFDC:- ChartRequest:- \(String(describing: error))")
                
            }, complete: {
                chartJsonData in
                
                let pickListReq = SalesforceConnection.generateSFDCRequest(restApiUrl: SalesforceRestApiUrl.picklistValue, methodType: SFRestMethod.GET)
                
                SFRestAPI.sharedInstance().send(pickListReq, fail: {
                    error in
                    
                    Utilities.showSwiftErrorMessage(error: "Utilities:- FetchAllDataFromSFDC:- PickListRequest:- \(String(describing: error))")
                    
                }, complete: {
                    picklistData in
                    
                    let caseReq = SalesforceConnection.generateSFDCRequest(restApiUrl: SalesforceRestApiUrl.caseConfiguration, methodType: SFRestMethod.GET)
                    
                    SFRestAPI.sharedInstance().send(caseReq, fail: {
                        error in
                        
                        Utilities.showSwiftErrorMessage(error: "Utilities:- FetchAllDataFromSFDC:- CaseRequest:- \(String(describing: error))")
                        
                    }, complete: {
                        caseData in
                        
                        
                        EventsConfigAPI.shared.syncDownWithCompletion{
                            
                            EventsAPI.shared.syncDownWithCompletion{
                                
                                
                                DispatchQueue.main.async {
                                    
                                    updateDashBoard(assignmentJsonData: assignmentJsonData as! [String : AnyObject], chartJsonData: chartJsonData as! [String : AnyObject],pickListJsonData: picklistData as! [String : AnyObject],caseJsonData:caseData as! [String : AnyObject])
                                    
                                    if(loginViewController != nil){
                                        
                                        loginViewController?.loadingSpinner.stopAnimating()
                                        loginViewController?.loadingSpinner.hidesWhenStopped = true
                                        loginViewController?.message.text = ""
                                        
                                        
                                        DispatchQueue.main.async {
                                            loginViewController?.performSegue(withIdentifier: "loginIdentifier", sender: nil)
                                        }
                                    }
                                        
                                    else{
                                        DownloadESRILayers.RefreshData()
                                    }
                                    
                                    
                                    
                                    
                                    //                            if(loginViewController != nil){
                                    //
                                    //
                                    //                                 if (Utilities.isGeoDatabseExist()==false) {
                                    //
                                    //                                    //download geodatabase from salesforce
                                    //                                    Download.downloadNewYorkCityData(loginViewController: loginViewController)
                                    //                                }
                                    //
                                    //
                                    //                                else{
                                    //
                                    //                                    SVProgressHUD.dismiss()
                                    //                                    DispatchQueue.main.async {
                                    //                                        loginViewController?.performSegue(withIdentifier: "loginIdentifier", sender: nil)
                                    //                                    }
                                    //
                                    //
                                    //                                }
                                    //
                                    //
                                    //
                                    //                            }
                                    //                            else{
                                    //
                                    //                                //This will happen when refresh icon press
                                    //                                    DownloadESRILayers.RefreshData()
                                    //
                                    //                            }//end of else
                                    
                                }
                            }
                        }
                        
                        
                    })
                    
                    
                    
                })
                
                
                
            })
            
            
            
        })
        
        
    }
    
    
    class func isBaseMapExist()->Bool{
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let fullPath = "\(path)/NewYorkCity.mmpk"
        
        
        let filemanager = FileManager.default
        
        if filemanager.fileExists(atPath: fullPath) {
            return true
        }
        else{
            return false
        }
    }
    
    class func isGeoDatabseExist()->Bool{
        
        
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let fullPath = "\(path)/NewYorkLayersGeodatabase/NewYorkLayers.geodatabase"
        
        
        let filemanager = FileManager.default
        
        if filemanager.fileExists(atPath: fullPath) {
            return true
        }
        else{
            return false
        }
    }
    
    class func UnzipFile(){
        
        do {
            
            //let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            
            let mapDataPath = Bundle.main.path(forResource: "MapData", ofType: "zip")
            let mapLayerPath = "\(String(describing: mapDataPath))/MapData/NewYorkLayers.geodatabase"
            
            let filemanager = FileManager.default
            
            if !(filemanager.fileExists(atPath: mapLayerPath)) {
                
                //let filePath = Bundle.main.url(forResource: extractZipFilePath, withExtension: "zip")!
                
                
                let unZipFilePath = try Zip.quickUnzipFile(URL(string: mapDataPath!)!) // Unzip
                print(unZipFilePath)
            }
            
            //            let zipFilePath = try Zip.quickZipFiles([filePath], fileName: "archive") // Zip
        }
        catch {
            Utilities.showSwiftErrorMessage(error: "Something went wrong while unzip geodatabase.")
        }
        
        
    }
    
    //    class func UnzipFile(){
    //
    //        do {
    //
    //            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    //
    //            let extractZipFilePath = "\(path)/NewYorkLayersGeodatabase.zip"
    //            let databasePath = "\(path)/NewYorkLayersGeodatabase/NewYorkLayers.geodatabase"
    //
    //            let filemanager = FileManager.default
    //
    //            if !(filemanager.fileExists(atPath: databasePath)) {
    //
    //                //let filePath = Bundle.main.url(forResource: extractZipFilePath, withExtension: "zip")!
    //
    //
    //                let unZipFilePath = try Zip.quickUnzipFile(URL(string: extractZipFilePath)!) // Unzip
    //                print(unZipFilePath)
    //            }
    //
    //            //            let zipFilePath = try Zip.quickZipFiles([filePath], fileName: "archive") // Zip
    //        }
    //        catch {
    //            Utilities.showSwiftErrorMessage(error: "Something went wrong while unzip geodatabase.")
    //        }
    //
    //
    //    }
    
    
    
    class func updateDashBoard(assignmentJsonData:[String:AnyObject],chartJsonData:[String:AnyObject],pickListJsonData:[String:AnyObject],caseJsonData:[String:AnyObject]){
        
        //first take surveyIds which is inprogress and complete state
        //delete only those surveyIds(surveyquestion) which is complete
        //now add only those whose surveyId does not contain inprogress surveyids
        
        //Reset and fetch inprogres survey ids
        //        Utilities.inProgressSurveyIds = []
        //        Utilities.completeSurveyIds = []
        //        setInProgressCompleteSurveyIds()
        //
        
        ManageCoreData.DeleteAllDataFromEntities()
        
        
        Utilities.parseEventAssignmentData(jsonObject: assignmentJsonData)
        
        Utilities.parseChartData(jsonObject: chartJsonData)
        
        Utilities.parsePickListData(jsonObject: pickListJsonData)
        
        Utilities.parseCaseConfigData(jsonObject: caseJsonData)
        
       
        
    }
    
    
    class func parseCaseConfigData(jsonObject: Dictionary<String, AnyObject>){
        //save case config
        let metadataConfig = MetadataConfig(context: context)
        
        metadataConfig.configData = jsonObject as NSObject?
        metadataConfig.type = MetadataConfigEnum.cases.rawValue
        
        appDelegate.saveContext()
        
        //end
    }
    
   
    
   
    
    class func callNotificationCenter(){
        
        SVProgressHUD.dismiss()
        
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateAssignmentView"), object: nil)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateLocationView"), object: nil)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateClientView"), object: nil)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateSurveyView"), object: nil)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateCaseView"), object: nil)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateIssueView"), object: nil)
        
        
        Utilities.isRefreshBtnClick = false
        Utilities.isBackgroundSync = false
    }
    
    
    
    
    class func parseChartData(jsonObject: Dictionary<String, AnyObject>){
        
        //  "{\"Chart4\":{\"FollowUpNeeded\":1},\"Chart3\":{\"NoResponse\":0},\"Chart2\":{\"UnitsCompleted\":12.0},\"Chart1\":{\"TotalUnits\":945.0}}"
        
        
        let chart1 = jsonObject["Chart1"] as? [String: AnyObject]
        let chart2 = jsonObject["Chart2"] as? [String: AnyObject]
        let chart3 = jsonObject["Chart3"] as? [String: AnyObject]
        let chart4 = jsonObject["Chart4"] as? [String: AnyObject]
        
        
        
        let chart1Obj = Chart(context: context)
        chart1Obj.chartType = "Chart1"
        chart1Obj.chartField = "TotalUnits"
        chart1Obj.chartLabel = "Total Units"
        chart1Obj.chartValue = String(chart1?["TotalUnits"] as! Int)
        
        print(chart1Obj.chartValue!)
        
        appDelegate.saveContext()
        
        
        
        
        let chart2Object = Chart(context: context)
        chart2Object.chartType = "Chart2"
        chart2Object.chartField = "UnitsCompleted"
        chart2Object.chartLabel = "Units Completed"
        chart2Object.chartValue = String(chart2?["UnitsCompleted"] as! Int)
        
        print(chart2Object.chartValue!)
        
        appDelegate.saveContext()
        
        let chart3Object = Chart(context: context)
        chart3Object.chartType = "Chart3"
        chart3Object.chartField = "NoResponse"
        chart3Object.chartLabel = "No Response"
        chart3Object.chartValue = String(chart3?["NoResponse"] as! Int)
        
        print( chart3Object.chartValue!)
        
        appDelegate.saveContext()
        
        let chart4Object = Chart(context: context)
        chart4Object.chartType = "Chart4"
        chart4Object.chartField = "FollowUpNeeded"
        chart4Object.chartLabel = "FollowUp Needed"
        chart4Object.chartValue = String(chart4?["FollowUpNeeded"] as! Int)
        
        print(chart4Object.chartValue!)
        
        appDelegate.saveContext()
        
        
        
    }
    
    
    class func parseUserInfoData(jsonObject: Dictionary<String, AnyObject>){
        
        ManageCoreData.DeleteAllRecords(salesforceEntityName: "UserInfo")
        
        let today = NSDate()
        
        //let dateAfterThreeDays = Calendar.current.date(byAdding: .day, value: 3, to: today)
        
        
        
        SalesforceConfig.currentUserContactId = jsonObject["contactId"] as? String  ?? ""
        SalesforceConfig.currentUserExternalId = jsonObject["externalId"] as? String  ?? ""
        SalesforceConfig.currentUserEmail = jsonObject["email"] as? String  ?? ""
        SalesforceConfig.currentContactName = jsonObject["contactName"] as? String  ?? ""
        
        
        SalesforceConfig.currentBaseMapUrl = jsonObject["esriBaseMapLink"] as? String  ?? ""
        SalesforceConfig.currentFeatureLayerUrl = jsonObject["esriLayerLink"] as? String  ?? ""
        
        SalesforceConfig.currentGeodatabaseUrl = jsonObject["esriGeodatabase"] as? String  ?? ""
        
        SalesforceConfig.currentProfileName = jsonObject["profileName"] as? String  ?? ""
        
        let basemapDate = jsonObject["esriBaseMapModifiedDate"] as? String  ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: basemapDate)
        
        SalesforceConfig.currentBaseMapDate = date as NSDate?
        
        
        
        let userInfoData =  ManageCoreData.fetchData(salesforceEntityName: "UserInfo", predicateFormat:"userName == %@",predicateValue:  SalesforceConfig.userName, isPredicate:true) as! [UserInfo]
        
        let userSettingData = ManageCoreData.fetchData(salesforceEntityName: "Setting", predicateFormat:"settingsId == %@",predicateValue:"1", isPredicate:true) as! [Setting]
        
        
        
        if(userInfoData.count == 0){
            
            //save userInfo
            let objUserInfo = UserInfo(context: context)
            
            objUserInfo.contactId = SalesforceConfig.currentUserContactId
            objUserInfo.externalId = SalesforceConfig.currentUserExternalId
            objUserInfo.contactEmail = SalesforceConfig.currentUserEmail
            objUserInfo.userName = SalesforceConfig.userName
            objUserInfo.contactName = SalesforceConfig.currentContactName
            
            objUserInfo.userId =  SalesforceConnection.salesforceUserId
            objUserInfo.passwordExpDate = today
            objUserInfo.password = ""
            objUserInfo.isSaveUserName = SalesforceConfig.isSavedUserName
            objUserInfo.profileName =  SalesforceConfig.currentProfileName
            
            appDelegate.saveContext()
            
            
        }
        
        
        //update usersetting
        if(userSettingData.count > 0){
            
            if let basemapDate = userSettingData[0].basemapDate {
                
                if(SalesforceConfig.currentBaseMapDate.equalToDate(dateToCompare: basemapDate)){
                    SalesforceConfig.isBaseMapNeedToDownload = false
                }
                else{
                    SalesforceConfig.isBaseMapNeedToDownload = true
                }
                
            }
            else{
                SalesforceConfig.isBaseMapNeedToDownload = true
            }
            
            
            
            var updateObjectDic:[String:AnyObject] = [:]
            
            updateObjectDic["basemapUrl"] = SalesforceConfig.currentBaseMapUrl as AnyObject?
            updateObjectDic["featureLayerUrl"] = SalesforceConfig.currentFeatureLayerUrl as AnyObject?
            updateObjectDic["basemapDate"] = SalesforceConfig.currentBaseMapDate as AnyObject?
            updateObjectDic["geodatabaseUrl"] = SalesforceConfig.currentGeodatabaseUrl as AnyObject?
            
            
            ManageCoreData.updateDate(salesforceEntityName: "Setting", updateKeyValue: updateObjectDic, predicateFormat: "settingsId == %@", predicateValue: "1",isPredicate: true)
            
        }
        
    }
    
    class func parsePickListData(jsonObject: Dictionary<String, AnyObject>){
        
        guard let pickListResults = jsonObject["objects"] as? [[String: AnyObject]] else{ return }
        
        //need to check location id and unit id
        
        for pickListData in pickListResults {
            
            guard let fieldListResults = pickListData["fieldList"] as? [[String: AnyObject]]  else { break }
            
            
            
            for fieldListData in fieldListResults{
                
                let dropDownObject = DropDown(context: context)
                
                dropDownObject.object = pickListData["objectName"] as? String ?? ""
                
                dropDownObject.fieldName = fieldListData["fieldName"] as? String ?? ""
                dropDownObject.value = fieldListData["picklistValue"] as? String ?? ""
                
                appDelegate.saveContext()
            }
            
            
            
        }
    }
    
    
    class func getEventFormattedAddress(eventObj:Events)->String{
        
        let streetNum = eventObj.streetNum ?? ""
        let streetName = eventObj.streetName ?? ""
        let borough = eventObj.borough ?? ""
        let zip = eventObj.zip ?? ""
        
        let address = "\(streetNum) \(streetName), \(borough),\(zip)"
        
        return address
        
    }
    
    
    class func parseEventAssignmentData(jsonObject: Dictionary<String, AnyObject>){
        
        
        
        guard let _ = jsonObject["errorMessage"] as? String,
            let assignmentObjectResults = jsonObject["AssignmentData"] as? [[String: AnyObject]] else { return }
        
        //need to check location id and unit id
        
        for assignmentData in assignmentObjectResults {
            
            let eventObject = AssignmentEvent(context: context)
            eventObject.id = assignmentData["eventId"] as? String  ?? ""
            eventObject.name = assignmentData["eventName"] as? String  ?? ""
            eventObject.startDate = assignmentData["eventStartDate"] as? String  ?? ""
            eventObject.endDate = assignmentData["eventEndDate"] as? String  ?? ""
            
            
            
            appDelegate.saveContext()
            //
            //            guard let assignmentResults = eventData["Assignment"] as? [[String: AnyObject]]  else { break }
            //
            //            for assignmentData in assignmentResults {
            let assignmentObject = Assignment(context: context)
            assignmentObject.id = assignmentData["assignmentId"] as? String  ?? ""
            assignmentObject.name = assignmentData["assignmentName"] as? String  ?? ""
            
            
            
            assignmentObject.status = assignmentData["status"] as? String  ?? ""
            assignmentObject.eventId = eventObject.id
            
            assignmentObject.totalLocations = String(assignmentData["totalLocation"] as! Int)
            assignmentObject.totalUnits = String(assignmentData["totalLocationUnit"] as! Int)
            assignmentObject.totalSurvey = String(assignmentData["totalSurvey"] as! Int)
            assignmentObject.totalCanvassed = String(assignmentData["totalCanvassed"] as! Int)
            assignmentObject.completePercent = String(assignmentData["totalCanvassed"] as! Int)
            assignmentObject.noOfClients = String(assignmentData["numberOfClients"] as! Int)
            
            
            assignmentObject.noOfClients = String(assignmentData["numberOfClients"] as! Int)
            
            
            
            let assignedDate = assignmentData["assignedStatusDate"] as? String  ?? ""
            
            let completedDate = assignmentData["completeStatusDate"] as? String  ?? ""
            
            if(assignedDate != ""){
                
                let dateFormatter = DateFormatter()
                //  dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let date = dateFormatter.date(from: assignedDate)
                
                assignmentObject.assignedDate = date as NSDate?
                
            }
            else{
                assignmentObject.assignedDate = nil
            }
            
            
            if(completedDate != ""){
                
                let dateFormatter = DateFormatter()
                //  dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let date = dateFormatter.date(from: completedDate)
                
                assignmentObject.completedDate = date as NSDate?
                
                
            }
            else{
                
                assignmentObject.completedDate = assignmentObject.assignedDate?.addDays(daysToAdd: -3)
            }
            
            //String(assignmentData["completePercent"] as! Int)
            
            //assignmentIdArray.append(assignmentObject.id!)
            
            //read surveydata
            guard let surveyResults = assignmentData["AssignmentSurvey"] as? [[String: AnyObject]] else { break }
            
            
            for surveyData in surveyResults {
                
                let assignmentId = assignmentObject.id!
                let surveyId = surveyData["surveyId"] as? String  ?? ""
                let surveyName = surveyData["surveyName"] as? String  ?? ""
                let isDefault = surveyData["isDefault"] as? Bool  ?? false
                
                let convertedJsonString = Utilities.jsonToString(json: surveyData as AnyObject)
                
                
                
                let surveyObject = SurveyQuestion(context: context)
                surveyObject.assignmentId = assignmentId
                surveyObject.surveyId = surveyId
                surveyObject.surveyName = surveyName
                surveyObject.surveyQuestionData = convertedJsonString
                
                //surveyObject.isDefault = "true"
                
                surveyObject.isDefault = String(isDefault)
                
                
                appDelegate.saveContext()
                //                    if(!Utilities.inProgressSurveyIds.contains(surveyId)){
                //                        appDelegate.saveContext()
                //                    }
                
            }
            
            
            
            //read location data
            guard let locationResults = assignmentData["assignmentLocation"] as? [[String: AnyObject]]  else { break }
            
            
            /*    var totalUnits = 0;
             
             if(locationResults.count>0){
             
             assignmentObject.totalLocations = String(locationResults.count)
             
             for locationData in locationResults {
             
             let unit = locationData["totalUnits"] as? String  ?? "0"
             
             totalUnits =  totalUnits + Int(unit)!
             
             
             }
             }
             else{
             assignmentObject.totalLocations = "0"
             }
             
             assignmentObject.totalUnits = String(totalUnits)
             
             */
            
            
            
            appDelegate.saveContext()
            
            for locationData in locationResults {
                
                let locationObject = Location(context: context)
                locationObject.id = locationData["locId"] as? String  ?? ""
                locationObject.name = locationData["name"] as? String  ?? ""
                locationObject.state = locationData["state"] as? String  ?? ""
                locationObject.city = locationData["city"] as? String  ?? ""
                locationObject.zip = locationData["zip"] as? String  ?? ""
                let streetNumber = locationData["streetNumber"] as? String  ?? ""
                let streetName = locationData["street"] as? String  ?? ""
                
                locationObject.streetNumber = streetNumber
                locationObject.streetName = streetName
                
                locationObject.street = streetNumber + " " + streetName
                locationObject.assignmentLocId = locationData["AssignLocId"] as? String  ?? ""
                locationObject.totalUnits = locationData["totalUnits"] as? String  ?? "0"
                locationObject.syncDate = locationData["locationSyncDate"] as? String  ?? ""
                
                locationObject.assignmentId = assignmentObject.id!
                locationObject.locStatus = locationData["status"] as? String  ?? ""
                
                
                
                locationObject.noOfClients = String(locationData["numberOfClients"] as! Int)
                locationObject.noOfUnitsAttempt  = String(locationData["numberOfUnitsAttempted"] as! Int)
                
                locationObject.borough = locationData["borough"] as? String  ?? ""
                
                appDelegate.saveContext()
                
                //EditLocation
                
                let editlocationObject = EditLocation(context: context)
                editlocationObject.locationId = locationObject.id!
                editlocationObject.assignmentId = assignmentObject.id!
                editlocationObject.assignmentLocId = locationObject.assignmentLocId!
                
                editlocationObject.canvassingStatus = locationData["status"] as? String  ?? ""
                editlocationObject.attempt = locationData["attempt"] as? String  ?? ""
                editlocationObject.noOfUnits = locationObject.totalUnits!
                
                editlocationObject.notes = locationData["notes"] as? String  ?? ""
                editlocationObject.actionStatus = ""
                editlocationObject.lastModifiedName = locationData["lastModifiedName"] as? String  ?? ""
                
                appDelegate.saveContext()
                
                //New Client Info
                
                guard let newClientInfoResults = locationData["TenantInfo"] as? [[String: AnyObject]]  else { break }
                
                for newClientInfoData in newClientInfoResults {
                    
                    let tenantObject = Tenant(context: context)
                    tenantObject.id = newClientInfoData["tenantId"] as? String  ?? ""
                    tenantObject.name = newClientInfoData["name"] as? String  ?? ""
                    tenantObject.firstName = newClientInfoData["firstName"] as? String  ?? ""
                    tenantObject.lastName =  newClientInfoData["lastName"] as? String  ?? ""
                    
                    tenantObject.phone = newClientInfoData["phone"] as? String  ?? ""
                    tenantObject.email = newClientInfoData["email"] as? String  ?? ""
                    tenantObject.age = newClientInfoData["age"] as? String  ?? ""
                    tenantObject.dob = newClientInfoData["dob"] as? String  ?? ""
                    
                    tenantObject.middleName = newClientInfoData["middleName"] as? String  ?? ""
                    tenantObject.suffix = newClientInfoData["suffix"] as? String  ?? ""
                    
                    
                    
                    
                    
                    tenantObject.assignmentId = assignmentObject.id!
                    tenantObject.locationId = locationObject.id!
                    tenantObject.unitId = ""
                    tenantObject.actionStatus = ""
                    tenantObject.assignmentLocUnitId = ""
                    tenantObject.assignmentLocId = locationObject.assignmentLocId!
                    
                    //unit name
                    
                    tenantObject.virtualUnit = ""
                    
                    tenantObject.contact = newClientInfoData["contact"] as? String  ?? ""
                    
                    tenantObject.attempt = newClientInfoData["attempt"] as? String  ?? ""
                    
                    tenantObject.contactOutcome = newClientInfoData["contactOutcome"] as? String  ?? ""
                    
                    tenantObject.notes = newClientInfoData["notes"] as? String  ?? ""
                    
                    
                    tenantObject.aptNo = newClientInfoData["aptNo"] as? String  ?? ""
                    tenantObject.aptFloor = newClientInfoData["aptFloor"] as? String  ?? ""
                    tenantObject.streetNum = newClientInfoData["streetNum"] as? String  ?? ""
                    tenantObject.streetName = newClientInfoData["streetName"] as? String  ?? ""
                    tenantObject.borough = newClientInfoData["borough"] as? String  ?? ""
                    tenantObject.zip = newClientInfoData["zip"] as? String  ?? ""
                    
                    tenantObject.sourceList = newClientInfoData["sourceList"] as? String  ?? ""
                    
                    tenantObject.createById = newClientInfoData["CreatedById"] as? String ?? ""
                    
                    appDelegate.saveContext()
                }
                
                guard let unitResults = locationData["assignmentLocUnit"] as? [[String: AnyObject]]  else { break }
                
                for unitData in unitResults {
                    
                    
                    let unitObject = Unit(context: context)
                    unitObject.id = unitData["locationUnitId"] as? String  ?? ""
                    unitObject.name = unitData["Name"] as? String  ?? ""
                    unitObject.apartment = unitData["apartmentNumber"] as? String  ?? ""
                    unitObject.floor = unitData["floorNumber"] as? String  ?? ""
                    unitObject.assignmentId = assignmentObject.id!
                    
                    unitObject.locationId = locationObject.id!
                    unitObject.assignmentLocId = locationObject.assignmentLocId!
                    
                    unitObject.actionStatus = ""
                    
                    let virtualUnit = unitData["virtualUnit"] as? Bool  ?? false
                    
                    unitObject.virtualUnit = String(virtualUnit)
                    
                    
                    
                    unitObject.unitSyncDate = unitData["unitSyncDate"] as? String  ?? ""
                    
                    let surveySyncDate = unitData["surveySyncDate"] as? String  ?? ""
                    
                    
                    if(surveySyncDate != ""){
                        unitObject.surveyStatus = "Completed"
                    }
                    else{
                        unitObject.surveyStatus = ""
                    }
                    
                    unitObject.privateHome = ""
                    
                    
                    unitObject.assignmentLocUnitId = unitData["assignmentLocUnitId"] as? String  ?? ""
                    
                    appDelegate.saveContext()
                    
                    //EditUnit
                    
                    let editUnitObject = EditUnit(context: context)
                    editUnitObject.locationId = locationObject.id!
                    editUnitObject.assignmentId = assignmentObject.id!
                    editUnitObject.assignmentLocId = locationObject.assignmentLocId!
                    editUnitObject.unitId = unitObject.id!
                    editUnitObject.assignmentLocUnitId = unitObject.assignmentLocUnitId!
                    editUnitObject.attempt = unitData["attempt"] as? String  ?? ""
                    editUnitObject.inTake = unitData["intake"] as? String  ?? ""
                    editUnitObject.reason = unitData["reason"] as? String  ?? ""
                    editUnitObject.contactOutcome = unitData["contactOutcome"] as? String  ?? ""
                    // editUnitObject.inTakeStatus = unitData["intakeStatus"] as? String  ?? ""
                    editUnitObject.reKnockNeeded = unitData["reKnockNeeded"] as? String  ?? ""
                    editUnitObject.privateHome = unitData["privateHome"] as? String  ?? ""
                    
                    // editUnitObject.tenantStatus = unitData["tenantStatus"] as? String  ?? ""
                    editUnitObject.unitNotes = unitData["notes"] as? String  ?? ""
                    editUnitObject.isContact = unitData["isContact"] as? String  ?? ""
                    editUnitObject.actionStatus = ""
                    editUnitObject.tenantId = unitData["tenant"] as? String  ?? ""
                    editUnitObject.surveyId = unitData["survey"] as? String  ?? ""
                    
                    editUnitObject.followUpType = unitData["followUpType"] as? String  ?? ""
                    editUnitObject.followUpDate = unitData["followUpDate"] as? String  ?? ""
                    
                    appDelegate.saveContext()
                    
                    
                    
                    guard let tenantInfoResults = unitData["TenantInfo"] as? [[String: AnyObject]]  else { break }
                    
                    for tenantData in tenantInfoResults {
                        
                        let tenantObject = Tenant(context: context)
                        tenantObject.id = tenantData["tenantId"] as? String  ?? ""
                        tenantObject.name = tenantData["name"] as? String  ?? ""
                        tenantObject.firstName = tenantData["firstName"] as? String  ?? ""
                        tenantObject.lastName =  tenantData["lastName"] as? String  ?? ""
                        
                        tenantObject.phone = tenantData["phone"] as? String  ?? ""
                        tenantObject.email = tenantData["email"] as? String  ?? ""
                        tenantObject.age = tenantData["age"] as? String  ?? ""
                        tenantObject.dob = tenantData["dob"] as? String  ?? ""
                        
                        tenantObject.middleName = tenantData["middleName"] as? String  ?? ""
                        tenantObject.suffix = tenantData["suffix"] as? String  ?? ""
                        
                        
                        
                        
                        
                        tenantObject.assignmentId = assignmentObject.id!
                        tenantObject.locationId = locationObject.id!
                        tenantObject.unitId = unitObject.id!
                        tenantObject.actionStatus = ""
                        tenantObject.assignmentLocUnitId = unitObject.assignmentLocUnitId!
                        
                        tenantObject.virtualUnit = unitObject.virtualUnit!
                        tenantObject.assignmentLocId = locationObject.assignmentLocId!
                        
                        
                        tenantObject.contact = tenantData["contact"] as? String  ?? ""
                        
                        tenantObject.attempt = tenantData["attempt"] as? String  ?? ""
                        
                        tenantObject.contactOutcome = tenantData["contactOutcome"] as? String  ?? ""
                        
                        tenantObject.notes = tenantData["notes"] as? String  ?? ""
                        
                        
                        tenantObject.aptNo = tenantData["aptNo"] as? String  ?? ""
                        tenantObject.aptFloor = tenantData["aptFloor"] as? String  ?? ""
                        tenantObject.streetNum = tenantData["streetNum"] as? String  ?? ""
                        tenantObject.streetName = tenantData["streetName"] as? String  ?? ""
                        tenantObject.borough = tenantData["borough"] as? String  ?? ""
                        tenantObject.zip = tenantData["zip"] as? String  ?? ""
                        
                        tenantObject.sourceList = tenantData["sourceList"] as? String  ?? ""
                        
                        tenantObject.createById = tenantData["CreatedById"] as? String ?? ""
                        
                        appDelegate.saveContext()
                        
                    }
                    
                    guard let casesInfoResults = unitData["caseInfo"] as? [[String: AnyObject]]  else { break }
                    
                    for casesInfo in casesInfoResults {
                        
                        guard let caseResults = casesInfo["caseList"] as? [[String: AnyObject]]  else { break }
                        
                        for caseData in caseResults{
                            
                            let caseObject = Cases(context: context)
                            
                            caseObject.caseId = caseData["Id"] as? String  ?? ""
                            
                            caseObject.caseNo = caseData["CaseNumber"] as? String  ?? ""
                            caseObject.caseStatus = caseData["Status"] as? String  ?? ""
                            
                            caseObject.unitId = unitObject.id
                            caseObject.assignmentLocUnitId = unitObject.assignmentLocUnitId
                            caseObject.actionStatus = ""
                            
                            
                            let contactResult = caseData["Contact"] as? [String: AnyObject]
                            
                            caseObject.contactId = contactResult?["Id"] as? String  ?? ""
                            caseObject.contactName = contactResult?["Name"] as? String  ?? ""
                            
                            let ownerResult = caseData["Owner"] as? [String: AnyObject]
                            
                            caseObject.caseOwnerId = ownerResult?["Id"] as? String  ?? ""
                            caseObject.caseOwner = ownerResult?["Name"] as? String  ?? ""
                            
                            
                            let dateOfIntake = caseData["Date_of_Intake__c"] as? String ?? ""
                            
                            if(dateOfIntake.isEmpty){
                                caseObject.createdDate = ""
                            }
                            else{
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                let formattedDate = dateFormatter.date(from: dateOfIntake)
                                
                                
                                let dateFormatter1 = DateFormatter()
                                dateFormatter1.dateFormat = "MM/dd/yyyy hh:mm a"
                                let dateString = dateFormatter1.string(from: formattedDate!)
                                
                                caseObject.createdDate = dateString
                            }
                            
                            //                                let createdDate = caseData["CreatedDate"] as? String  ?? ""
                            //
                            //
                            //                                let dateFormatter = DateFormatter()
                            //                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                            //                                let formattedDate = dateFormatter.date(from: createdDate)
                            //
                            //
                            //                                let dateFormatter1 = DateFormatter()
                            //                                dateFormatter1.dateFormat = "MM/dd/yyyy hh:mm a"
                            //                                let dateString = dateFormatter1.string(from: formattedDate!)
                            //
                            //                                caseObject.createdDate = dateString
                            
                            caseObject.caseDynamic = caseData as NSObject
                            
                            appDelegate.saveContext()
                        }
                        
                        
                        guard let issueResults = casesInfo["issueList"] as? [[String: AnyObject]]  else { break }
                        
                        for issueInfo in issueResults {
                            
                            let issueObject = Issues(context: context)
                            issueObject.caseId = issueInfo["caseId"] as? String  ?? ""
                            issueObject.actionStatus = ""
                            issueObject.issueNo = issueInfo["issueNumber"] as? String  ?? ""
                            issueObject.issueId = issueInfo["issueId"] as? String  ?? ""
                            issueObject.issueType = issueInfo["issueType"] as? String  ?? ""
                            issueObject.notes = issueInfo["issueNotes"] as? String  ?? ""
                            issueObject.contactName = issueInfo["contactName"] as? String  ?? ""
                            
                            
                            appDelegate.saveContext()
                            
                            guard let issueNotesResult = issueInfo["issueNotesList"] as? [[String: AnyObject]]  else { break }
                            
                            for issueNotesInfo in issueNotesResult{
                                
                                let issueNoteObject = IssueNotes(context: context)
                                issueNoteObject.issueId = issueObject.issueId
                                issueNoteObject.notes = issueNotesInfo["description"] as? String  ?? ""
                                issueNoteObject.action = ""
                                
                                appDelegate.saveContext()
                            }
                            
                            if(issueNotesResult.count == 0){
                                //add note
                                let issueNoteObject = IssueNotes(context: context)
                                issueNoteObject.issueId = issueObject.issueId
                                issueNoteObject.notes = issueObject.notes
                                appDelegate.saveContext()
                            }
                        }
                        
                    }
                    
                }
                
            }
            // }
            
            
            
        }
        
        
        
    }
    
    
    
    class func startBackgroundSync(){
        
        let userSettingData = ManageCoreData.fetchData(salesforceEntityName: "Setting", isPredicate:false) as! [Setting]
        
        if(userSettingData.count > 0){
            
            let date = userSettingData[0].backgroundTime!
            
            
            //let date = Date().addingTimeInterval(5)
            
            
            
            let timer = Timer(fireAt: date as Date, interval: 0, target: self, selector: #selector(backgroundSyncing), userInfo: nil, repeats: false)
            
            RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
            
        }
        
        
    }
    
    
    @objc class func backgroundSyncing(){
        
        print("start backgroundSyncing")
        
        //        if(Utilities.isRefreshBtnClick == false){
        //            print("start backgroundSyncing")
        //        }
    }
    
    
    class func createOpenCaseDictionary(){
        
        openCountCases = 1
        
        let openCaseResults =  ManageCoreData.fetchData(salesforceEntityName: "Cases",predicateFormat: "caseStatus==%@",predicateValue: "Open", isPredicate:true) as! [Cases]
        
        if(openCaseResults.count > 0){
            
            for openCaseData in openCaseResults{
                
                if caseOpenDict[openCaseData.contactId!] == nil{
                    
                    openCountCases = 1
                    caseOpenDict[openCaseData.contactId!] = countCases
                }
                else{
                    
                    let count = caseOpenDict[openCaseData.contactId!]
                    openCountCases = count! + 1
                    caseOpenDict[openCaseData.contactId!] = countCases
                }
                
                
            }
        }
        
    }
    
    
    class func createCaseDictionary(){
        
        countCases = 1
        
        let caseResults =  ManageCoreData.fetchData(salesforceEntityName: "Cases", isPredicate:false) as! [Cases]
        
        if(caseResults.count > 0){
            
            for caseData in caseResults{
                
                if caseDict[caseData.contactId!] == nil{
                    
                    countCases = 1
                    caseDict[caseData.contactId!] = String(countCases)
                }
                else{
                    
                    let count = caseDict[caseData.contactId!]
                    countCases = Int(count!)! + 1
                    caseDict[caseData.contactId!] = String(countCases)
                }
                
                
            }
        }
        
    }
    
    
    
    
    
    class func createUnitDictionary(){
        
        
        
        let unitClientResults =  ManageCoreData.fetchData(salesforceEntityName: "Unit", isPredicate:false) as! [Unit]
        
        if(unitClientResults.count > 0){
            
            for unitClientData in unitClientResults{
                
                if unitClientDict[unitClientData.id!] == nil{
                    var unitSurveyStatus:String = ""
                    if let surStatus = unitClientData.surveyStatus{
                        unitSurveyStatus = surStatus
                    }
                    
                    unitClientDict[unitClientData.id!] = UnitDO(unitId: unitClientData.id!, unitName: unitClientData.name!,surveyStatus: unitSurveyStatus)
                }
                
                
            }
        }
        
    }
    
    
    class func showSwiftErrorMessage(error:String,title:String? = "Error"){
        
        let view: MessageView
        
        
        view = try! SwiftMessages.viewFromNib()
        
        
        
        view.configureContent(title: title, body: error, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: "Dismiss", buttonTapHandler: { _ in SwiftMessages.hide() })
        
        let iconStyle: IconStyle
        
        iconStyle = .light
        
        //view.configureTheme(.error, iconStyle: iconStyle)
        
        view.configureTheme(backgroundColor: UIColor.init(red: 76.0/255.0, green: 76.0/255.0, blue: 76.0/255.0, alpha: 1.0), foregroundColor: UIColor.white, iconImage: nil, iconText: "")
        
        //view.button?.setImage(Icon.ErrorSubtle.image, for: .normal)
        //view.button?.setTitle("Dismiss", for: .normal)
        
        
        view.configureDropShadow()
        
        
        //view.button?.isHidden = true
        
        
        //view.iconImageView?.isHidden = true
        //view.iconLabel?.isHidden = true
        
        //view.titleLabel?.isHidden = true
        
        //view.bodyLabel?.isHidden = true
        
        
        // Config setup
        
        var config = SwiftMessages.defaultConfig
        
        //        switch presentationStyle.selectedSegmentIndex {
        //        case 1:
        //            config.presentationStyle = .bottom
        //        case 2: break
        //
        //        default:
        //            break
        //        }
        
        //        switch presentationContext.selectedSegmentIndex {
        //        case 1:
        //            config.presentationContext = .window(windowLevel: UIWindowLevelNormal)
        //        case 2:
        //            config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        //        default:
        //            break
        //        }
        //
        
        // config.duration = .forever
        
        config.duration = .seconds(seconds: 5)
        
        config.dimMode = .gray(interactive: true)
        
        
        config.shouldAutorotate = true
        
        config.interactiveHide = false
        
        // Set status bar style unless using card view (since it doesn't
        // go behind the status bar).
        //        if case .top = config.presentationStyle, layout.selectedSegmentIndex != 1 {
        //            switch theme.selectedSegmentIndex {
        //            case 1...4:
        //                config.preferredStatusBarStyle = .lightContent
        //            default:
        //                break
        //            }
        //        }
        
        // Show
        SwiftMessages.show(config: config, view: view)
    }
    
    
    class func forceSyncDataWithSalesforce(vc:UIViewController) {
        
        if(Network.reachability?.isReachable)!{
            
            if(Utilities.isBackgroundSync == false){
                
                Utilities.isRefreshBtnClick = true
                
                SVProgressHUD.show(withStatus: "Syncing data..", maskType: SVProgressHUDMaskType.gradient)
                SyncUtility.syncDataWithSalesforce(isPullDataFromSFDC: true)
            }
            else{
                vc.view.makeToast("Background syncing is in progress. Please try after some time.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    
                }
            }
        }
        else{
            vc.view.makeToast("No internet connection.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
            }
        }
    }
    
    
}

