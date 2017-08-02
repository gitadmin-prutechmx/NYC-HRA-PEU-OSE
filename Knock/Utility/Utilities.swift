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

import Toast_Swift


class Utilities {
    
    static var currentApiName:String = ""
    static var selectedDateTimeDict:[String:String] = [:]
    
    static var selectedDatePicker:[String:Date] = [:]
    
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
    static var isEditLoc:Bool = false
    static var CanvassingStatus:String = ""
    static var isRefreshBtnClick:Bool = false
    
    static var answerSurvey:String = ""
    
    static var SurveyOutput:[String:SurveyResult]=[:]
    
    static var surveyQuestionArray = [structSurveyQuestion]()
    
    static var surveyQuestionArrayIndex = -1
    
    static var currentSurveyPage = 0
    
    static var totalSurveyQuestions = 0
    
    static var currentLocationRowIndex = 0
    
    
    
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
    
    class func decryptJsonData(jsonEncryptString:String) -> String{
        
        
        
        //  var returnjsonData:Data?
        
        
        //Remove first two characters
        
        let startIndex = jsonEncryptString.index(jsonEncryptString.startIndex, offsetBy: 1)
        
        let headString = jsonEncryptString.substring(from: startIndex)
        
        
        
        //Remove last two characters
        
        let endIndex = headString.index(headString.endIndex, offsetBy: -1)
        
        let trailString = headString.substring(to: endIndex)
        
        
        let decryptData = try! trailString.aesDecrypt(SalesforceConfig.key, iv: SalesforceConfig.iv)
        
        
        
        // returnjsonData = decryptData.data(using: .utf8)
        
        
        
        
        return decryptData
        
    }
    
    class func encryptedParams(dictParameters:AnyObject)-> String{
        let convertedString = Utilities.jsonToString(json: dictParameters as AnyObject)
        
        
        
        let encryptSaveUnitStr = try! convertedString?.aesEncrypt(SalesforceConfig.key, iv: SalesforceConfig.iv)
        
        return encryptSaveUnitStr!
    }
    
    class func showErrorMessage(toastView:UIView,message:String,delay:TimeInterval,toastPosition:ToastPosition){
        
        toastView.makeToast(message, duration: delay, position: toastPosition)
    }
    
    
    class func createUnitDicData(unitName:String,apartmentNumber:String,locationId:String,assignmentLocId:String,notes:String,iosLocUnitId:String,iosAssignLocUnitId:String)->[String:String]{
        
        var newUnitDic:[String:String] = [:]
        
        newUnitDic["unitName"] =  unitName//"Apt " + apartmentNumberVal
        
        newUnitDic["apartmentNumber"] = apartmentNumber
        
        newUnitDic["locationId"] = locationId//SalesforceConnection.locationId
        
        newUnitDic["assignLocId"] = assignmentLocId//SalesforceConnection.assignmentLocationId
        
        newUnitDic["notes"] = notes//notesVal
        
        //................
        newUnitDic["iOSLocUnitId"] = iosLocUnitId //UUID().uuidString
        
        newUnitDic["iOSAssignmentLocUnitId"] = iosAssignLocUnitId//UUID().uuidString
        
        return newUnitDic
    }
    
    class func editUnitTenantAndSurveyDicData(intake:String?=nil,notes:String?=nil,attempt:String?=nil,contact:String?=nil,reKnockNeeded:String?=nil,reason:String?=nil,assignmentLocationUnitId:String?=nil,selectedSurveyId:String?=nil,selectedTenantId:String?=nil,lastCanvassedBy:String?=nil)->[String:String]{
        
        var editUnitDict:[String:String] = [:]
        
        editUnitDict["assignmentLocationUnitId"] = assignmentLocationUnitId
        
        
        editUnitDict["intake"] = intake
        editUnitDict["reason"] = reason
        editUnitDict["notes"] = notes
        editUnitDict["attempt"] = attempt
        editUnitDict["contact"] = contact
        editUnitDict["reKnockNeeded"] = reKnockNeeded
        
        
        editUnitDict["surveyId"] = selectedSurveyId
        editUnitDict["tenantId"] = selectedTenantId
        
        editUnitDict["lastCanvassedBy"] = lastCanvassedBy
        
        
        
        
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
        
    
        editIssueDict["iOSTenantId"] = iOSIssueId as AnyObject?
        
        editIssueDict["Case__c"] = caseId as AnyObject?
        
        editIssueDict["Issuetype__c"] = issueType as AnyObject?
        
        editIssueDict["Issue_Notes__c"] = issueNotes as AnyObject?
        
       
        
        return editIssueDict
        
    }
    

    
    class func createAndEditTenantData(firstName:String,lastName:String,email:String,phone:String,dob:String,locationUnitId:String,currentTenantId:String,iOSTenantId:String,type:String)->[String:String]{
        
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
        
        if(dob != ""){
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy"
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
    
    
    
    class func parseAddNewUnitResponse(jsonObject: Dictionary<String, AnyObject>)->Bool {
        
        
        guard let isError = jsonObject["hasError"] as? Bool,
            
            let unitDataDict = jsonObject["unitData"] as? [String: AnyObject] else { return true}
        
        
        
        
        if(isError == false){
            
            //update unitId and assignmentLocUnitId
            updateUnitDetail(unitDataDict: unitDataDict)
            updateEditUnitDetail(unitDataDict: unitDataDict)
            updateTenantDetail(unitDataDict: unitDataDict)
            updateSurveyResponseDetail(unitDataDict: unitDataDict)
            
            // updateSurveyUnitDetail(unitDataDict: unitDataDict)
            // updateTenantAssignDetail(unitDataDict: unitDataDict)
            // updateAssignmentUnitCount()
            
            
            
        }
        
        
        return isError
        
        
        
    }
    
    
    class func parseTenantResponse(jsonObject: Dictionary<String, AnyObject>)->Bool{
        
        guard let isError = jsonObject["hasError"] as? Bool,
            
            let tenantDataDictonary = jsonObject["tenantData"] as? [String: AnyObject] else { return true }
        
        
        
        
        if(isError == false){
            
            
            updateTenantIdInCoreData(tenantDataDict: tenantDataDictonary)
            
            updateTenantIdInTenantAssign(tenantDataDict: tenantDataDictonary)
            
        }
        
        return isError
        
        
    }
    
    
    class func parseIssueResponse(jsonObject: Dictionary<String, AnyObject>)->Bool{
        
        guard let isError = jsonObject["hasError"] as? Bool,
            
            let issueDataDictonary = jsonObject["issueData"] as? [String: AnyObject] else { return true }
        
        
        
        
        if(isError == false){
       
            updateIssueIdInCoreData(issueDataDict: issueDataDictonary)

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
        
        let surveyResResults = ManageCoreData.fetchData(salesforceEntityName: "SurveyResponse",predicateFormat: "actionStatus == %@ AND assignmentLocUnitId == %@" ,predicateValue: "edit",predicateValue2: assignmentLocUnitId,isPredicate:true) as! [SurveyResponse]
        
        if(surveyResResults.count > 0){
            
            var updateObjectDic:[String:String] = [:]
            
            updateObjectDic["actionStatus"] = ""
            
            ManageCoreData.updateRecord(salesforceEntityName: "SurveyResponse", updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocUnitId == %@", predicateValue: assignmentLocUnitId,isPredicate: true)
            
            print("update survey response: \(assignmentLocUnitId)")
        }
        
        
    }
    
 
    
    class func updateIssueIdInCoreData(issueDataDict:[String:AnyObject]){
        
        let iOSIssueId = issueDataDict["iOSIssueId"] as! String?
        let issueId = issueDataDict["issueId"] as! String?
        
        if(SalesforceConnection.currentIssueId == iOSIssueId){
            SalesforceConnection.currentIssueId =  issueId!
            print("issueId updated")
        }
        
        let issueResults = ManageCoreData.fetchData(salesforceEntityName: "Issues",predicateFormat: "actionStatus == %@ OR actionStatus == %@ AND issueId == %@" ,predicateValue: "create",predicateValue2: "edit", predicateValue3: iOSIssueId, isPredicate:true) as! [Issues]
        
        
        
        if(issueResults.count > 0){
            
            var updateObjectDic:[String:String] = [:]
            updateObjectDic["issueId"] = issueId
            updateObjectDic["actionStatus"] = ""
            
            ManageCoreData.updateRecord(salesforceEntityName: "Issues", updateKeyValue: updateObjectDic, predicateFormat: "issueId == %@", predicateValue: iOSIssueId,isPredicate: true)
            
          
            
        }
        
        
    }
    
    
    class func updateTenantIdInCoreData(tenantDataDict:[String:AnyObject]){
        
        let iosTenantId = tenantDataDict["iOSTenantId"] as! String?
        let tenantId = tenantDataDict["tenantId"] as! String?
        
        if(SalesforceConnection.currentTenantId == iosTenantId){
            SalesforceConnection.currentTenantId =  tenantId!
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
    
    
    class func fetchAllDataFromSalesforce(loginViewController:LoginViewController?=nil){
        
        var emailParams : [String:String] = [:]
        var userParams : [String:String] = [:]
        
        
        SVProgressHUD.show(withStatus: "Syncing data..", maskType: SVProgressHUDMaskType.gradient)
        
        SalesforceConnection.loginToSalesforce() { response in
            
            let encryptUserIdStr = try! SalesforceConnection.salesforceUserId.aesEncrypt(SalesforceConfig.key, iv: SalesforceConfig.iv)
            
            userParams["userId"] = encryptUserIdStr
            
            
            SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.userDetail, params: userParams){ userInfoJsonData in
                
                Utilities.parseUserInfoData(jsonObject: userInfoJsonData.1)
                
                emailParams["email"] = try! SalesforceConfig.currentUserEmail.aesEncrypt(SalesforceConfig.key, iv: SalesforceConfig.iv)
                
                
                SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.getAllEventAssignmentData, params: emailParams){ assignmentJsonData in
                    
                    
                    SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.assignmentdetailchart, params: emailParams){ chartJsonData in
                        
                        SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.picklistValue, methodType:"GET"){ picklistData in
                            
                            
                            SalesforceConnection.SalesforceCaseData(restApiUrl: SalesforceRestApiUrl.caseConfiguration, methodType:"GET"){ caseData in
                                
                                
                                
                                updateDashBoard(assignmentJsonData: assignmentJsonData.1, chartJsonData: chartJsonData.1,pickListJsonData: picklistData.1,caseJsonData:caseData.1)
                                
                                if(loginViewController != nil){
                                    
                                    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                                    
                                    let fullPath = "\(path)/NewYorkLayers.geodatabase"
                                    
                                    
                                    if (Utilities.isGeoDatabseExist()==false) {
                                        
                                        DownloadESRILayers.DownloadData(loginViewController: loginViewController,downloadPath:fullPath)
                                        
                                        
                                    }
                                        
                                    else if(SalesforceConfig.isBaseMapNeedToDownload == true){
                                        
                                        SVProgressHUD.dismiss()
                                        
                                        //Delete Basemap first and then download
                                        Utilities.deleteBasemap()
                                        
                                        DownloadBaseMap.downloadNewYorkCityBaseMap(loginViewController: loginViewController)
                                        
                                    }
                                        
                                        
                                    else{
                                        
                                        SVProgressHUD.dismiss()
                                        DispatchQueue.main.async {
                                            loginViewController?.performSegue(withIdentifier: "loginIdentifier", sender: nil)
                                        }
                                        
                                        
                                    }
                                    
                                    
                                    
                                }
                                else{
                                    
                                    
                                    
                                    
                                    if(SalesforceConfig.isBaseMapNeedToDownload == true){
                                        
                                        
                                        //Delete Basemap first and then download
                                        Utilities.deleteBasemap()
                                        
                                        SVProgressHUD.show(withStatus: "Updating Basemap..", maskType: .gradient)
                                        
                                        DownloadBaseMap.downloadNewYorkCityBaseMap(loginViewController: nil)
                                        
                                    }
                                    else{
                                        DownloadESRILayers.RefreshData()
                                    }
                                    
                                    
                                }
                            }
                            
                        }
                    }
                }
                
            }
            
        }
        
    }//end of class
    
    
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
        
        let fullPath = "\(path)/NewYorkLayers.geodatabase"
        
        
        let filemanager = FileManager.default
        
        if filemanager.fileExists(atPath: fullPath) {
            return true
        }
        else{
            return false
        }
    }
    
    
    
    class func updateDashBoard(assignmentJsonData:[String:AnyObject],chartJsonData:[String:AnyObject],pickListJsonData:[String:AnyObject],caseJsonData:[String:AnyObject]){
        
        
        
        ManageCoreData.DeleteAllDataFromEntities()
        
        
        Utilities.parseEventAssignmentData(jsonObject: assignmentJsonData)
        
        Utilities.parseChartData(jsonObject: chartJsonData)
        
        Utilities.parsePickListData(jsonObject: pickListJsonData)
        
        Utilities.parseCaseConfigData(jsonObject: caseJsonData)
        
        
    }
    
    
    class func parseCaseConfigData(jsonObject: Dictionary<String, AnyObject>){
        //save case config
        let caseConfig = CaseConfig(context: context)
        
        caseConfig.caseConfigData = jsonObject as NSObject?
        
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
        
        
        Utilities.isRefreshBtnClick = false
        
    }
    
    
    class func parseUserData(jsonObject: Dictionary<String, AnyObject>){
        
        SalesforceConfig.currentUserContactId  = (jsonObject["contactId"] as? String)!
        SalesforceConfig.currentUserEmail = (jsonObject["Email"] as? String)!
        SalesforceConfig.currentUserExternalId = (jsonObject["ExternalId"] as? String)!
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
        
        let today = NSDate()
        let dateAfterThreeDays = today.addDays(daysToAdd: 3)
        
        //let dateAfterThreeDays = Calendar.current.date(byAdding: .day, value: 3, to: today)
        
        
        
        SalesforceConfig.currentUserContactId = jsonObject["contactId"] as? String  ?? ""
        SalesforceConfig.currentUserExternalId = jsonObject["externalId"] as? String  ?? ""
        SalesforceConfig.currentUserEmail = jsonObject["email"] as? String  ?? ""
        
        
        SalesforceConfig.currentBaseMapUrl = jsonObject["esriBaseMapLink"] as? String  ?? ""
        SalesforceConfig.currentFeatureLayerUrl = jsonObject["esriLayerLink"] as? String  ?? ""
        
        let basemapDate = jsonObject["esriBaseMapModifiedDate"] as? String  ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: basemapDate)
        
        SalesforceConfig.currentBaseMapDate = date as NSDate?
        
        
        //SalesforceConfig.isBaseMapNeedToDownload
        
        let userInfoData =  ManageCoreData.fetchData(salesforceEntityName: "UserInfo", predicateFormat:"userName == %@",predicateValue:  SalesforceConfig.userName, isPredicate:true) as! [UserInfo]
        
        let userSettingData = ManageCoreData.fetchData(salesforceEntityName: "Setting", predicateFormat:"settingsId == %@",predicateValue:"1", isPredicate:true) as! [Setting]
        
        
        if(userInfoData.count == 0){
            
            //save userInfo
            let objUserInfo = UserInfo(context: context)
            
            objUserInfo.contactId = SalesforceConfig.currentUserContactId
            objUserInfo.externalId = SalesforceConfig.currentUserExternalId
            objUserInfo.contactEmail = SalesforceConfig.currentUserEmail
            objUserInfo.userName = SalesforceConfig.userName
            objUserInfo.password = try! SalesforceConfig.password.aesEncrypt(Utilities.encryptDecryptKey, iv: Utilities.encryptDecryptIV)
            
            objUserInfo.passwordExpDate = dateAfterThreeDays
            
            appDelegate.saveContext()
            
            
        }
        else{
            
            //update password expiration date
            var updateObjectDic:[String:AnyObject] = [:]
            
            updateObjectDic["passwordExpDate"] = dateAfterThreeDays
            
            ManageCoreData.updateDate(salesforceEntityName: "UserInfo", updateKeyValue: updateObjectDic, predicateFormat: "userName == %@", predicateValue: SalesforceConfig.userName,isPredicate: true)
            
            SalesforceConfig.currentUserEmail = userInfoData[0].contactEmail!
            SalesforceConfig.currentUserContactId = userInfoData[0].contactId!
            SalesforceConfig.currentUserExternalId = userInfoData[0].externalId!
            
            
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
            
            
            //update password expiration date
            var updateObjectDic:[String:AnyObject] = [:]
            
            updateObjectDic["basemapUrl"] = SalesforceConfig.currentBaseMapUrl as AnyObject?
            updateObjectDic["featureLayerUrl"] = SalesforceConfig.currentFeatureLayerUrl as AnyObject?
            updateObjectDic["basemapDate"] = SalesforceConfig.currentBaseMapDate as AnyObject?
            
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
    
    
    
    class func parseEventAssignmentData(jsonObject: Dictionary<String, AnyObject>){
        
        
        
        guard let _ = jsonObject["errorMessage"] as? String,
            let eventResults = jsonObject["Event"] as? [[String: AnyObject]] else { return }
        
        //need to check location id and unit id
        
        for eventData in eventResults {
            
            let eventObject = Event(context: context)
            eventObject.id = eventData["eventId"] as? String  ?? ""
            eventObject.name = eventData["Name"] as? String  ?? ""
            eventObject.startDate = eventData["startDate"] as? String  ?? ""
            eventObject.endDate = eventData["endDate"] as? String  ?? ""
            
            
            
            appDelegate.saveContext()
            
            guard let assignmentResults = eventData["Assignment"] as? [[String: AnyObject]]  else { break }
            
            for assignmentData in assignmentResults {
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
                    
                    let convertedJsonString = Utilities.jsonToString(json: surveyData as AnyObject)
                    
                    
                    
                    let surveyObject = SurveyQuestion(context: context)
                    surveyObject.assignmentId = assignmentId
                    surveyObject.surveyId = surveyId
                    surveyObject.surveyName = surveyName
                    surveyObject.surveyQuestionData = convertedJsonString
                    
                    
                    
                    appDelegate.saveContext()
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
                    locationObject.street = locationData["street"] as? String  ?? ""
                    
                    locationObject.assignmentLocId = locationData["AssignLocId"] as? String  ?? ""
                    locationObject.totalUnits = locationData["totalUnits"] as? String  ?? "0"
                    locationObject.syncDate = locationData["locationSyncDate"] as? String  ?? ""
                    
                    locationObject.assignmentId = assignmentObject.id!
                    locationObject.locStatus = locationData["status"] as? String  ?? ""
                    
                    
                    
                    locationObject.noOfClients = String(locationData["numberOfClients"] as! Int)
                    locationObject.noOfUnitsAttempt  = String(locationData["numberOfUnitsAttempted"] as! Int)
                    
                    
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
                    
                    appDelegate.saveContext()
                    
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
                        
                        
                        unitObject.unitSyncDate = unitData["unitSyncDate"] as? String  ?? ""
                        
                        let surveySyncDate = unitData["surveySyncDate"] as? String  ?? ""
                        
                        
                        if(surveySyncDate != ""){
                            unitObject.surveyStatus = "Completed"
                        }
                        else{
                            unitObject.surveyStatus = ""
                        }
                        
                        
                        
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
                        // editUnitObject.inTakeStatus = unitData["intakeStatus"] as? String  ?? ""
                        editUnitObject.reKnockNeeded = unitData["reKnockNeeded"] as? String  ?? ""
                        // editUnitObject.tenantStatus = unitData["tenantStatus"] as? String  ?? ""
                        editUnitObject.unitNotes = unitData["notes"] as? String  ?? ""
                        editUnitObject.isContact = unitData["isContact"] as? String  ?? ""
                        editUnitObject.actionStatus = ""
                        editUnitObject.tenantId = unitData["tenant"] as? String  ?? ""
                        editUnitObject.surveyId = unitData["survey"] as? String  ?? ""
                        
                        appDelegate.saveContext()
                        
                        
                        
                        //...........Remove below codes
                        
                        //TenantStatus
                        
                        //                        let tenantAssignObject = TenantAssign(context: context)
                        //
                        //
                        //                        tenantAssignObject.locationId = locationObject.id!
                        //                        tenantAssignObject.assignmentId = assignmentObject.id!
                        //                        tenantAssignObject.assignmentLocId = locationObject.assignmentLocId!
                        //                        tenantAssignObject.unitId = unitObject.id!
                        //                        tenantAssignObject.assignmentLocUnitId = unitObject.assignmentLocUnitId!
                        //                        tenantAssignObject.tenantId = unitData["tenant"] as? String  ?? ""
                        //                        tenantAssignObject.actionStatus = ""
                        //
                        //
                        //                        appDelegate.saveContext()
                        //
                        //
                        //                        //AssignSurvey
                        //
                        //
                        //                        //save the record
                        //                        let surveyUnitObject = SurveyUnit(context: context)
                        //                        surveyUnitObject.locationId = locationObject.id!
                        //                        surveyUnitObject.assignmentId = assignmentObject.id!
                        //                        surveyUnitObject.assignmentLocId = locationObject.assignmentLocId!
                        //                        surveyUnitObject.unitId = unitObject.id!
                        //                        surveyUnitObject.assignmentLocUnitId = unitObject.assignmentLocUnitId!
                        //                        surveyUnitObject.surveyId = unitData["survey"] as? String  ?? ""
                        //                        surveyUnitObject.actionStatus = ""
                        //
                        //
                        //                        appDelegate.saveContext()
                        
                        //.....................
                        
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
                            
                            tenantObject.assignmentId = assignmentObject.id!
                            tenantObject.locationId = locationObject.id!
                            tenantObject.unitId = unitObject.id!
                            tenantObject.actionStatus = ""
                            tenantObject.assignmentLocUnitId = unitObject.assignmentLocUnitId!
                            
                            
                            appDelegate.saveContext()
                            
                        }
                        
                        guard let casesInfoResults = unitData["caseInfo"] as? [[String: AnyObject]]  else { break }
                        
                        for casesInfo in casesInfoResults {
                            
                        
                            let caseObject = Cases(context: context)
                            caseObject.caseId = casesInfo["caseId"] as? String  ?? ""
                            caseObject.contactId = casesInfo["contactId"] as? String  ?? ""
                            caseObject.contactName = casesInfo["contactName"] as? String  ?? ""
                            caseObject.caseNo = casesInfo["caseNumber"] as? String  ?? ""
                            caseObject.unitId = unitObject.id
                            caseObject.assignmentLocUnitId = unitObject.assignmentLocUnitId
                            
                            appDelegate.saveContext()
                            
                             guard let issueResults = casesInfo["issueList"] as? [[String: AnyObject]]  else { break }
                            
                            for issueInfo in issueResults {
                                
                                let issueObject = Issues(context: context)
                                issueObject.caseId = caseObject.caseId
                                issueObject.actionStatus = ""
                                issueObject.issueNo = issueInfo["issueNumber"] as? String  ?? ""
                                issueObject.issueId = issueInfo["issueId"] as? String  ?? ""
                                 issueObject.issueType = issueInfo["issueType"] as? String  ?? ""
                                issueObject.notes = issueInfo["issueNotes"] as? String  ?? ""
                                appDelegate.saveContext()
                                
                            }
                            
                        }
                        
                    }
                    
                }
            }
            
            
            
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
    
    
    
    
    
}

