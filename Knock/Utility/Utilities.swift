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
    
    static var isSyncing:Bool = false
    
    
   
    
    static var basemapMobileMapPackage:AGSMobileMapPackage!
    
    static var basemapLocator:AGSLocatorTask?
    
    static var currentSegmentedControl:String = ""
    
    // for skiplogic survey
    static var skipLogicParentChildDict : [String:[SkipLogic]] = [:]
    
    static var prevSkipLogicParentChildDict : [String:[SkipLogic]] = [:]
    
    static var isSubmitSurvey:Bool = false

    static var answerSurvey:String = ""
   
    static var SurveyOutput:[String:SurveyResult]=[:]
    
    static var surveyQuestionArray = [structSurveyQuestion]()
 
    static var surveyQuestionArrayIndex = -1

    static var currentSurveyPage = 0
    
    static var totalSurveyQuestions = 0
    

    
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
    
    class func editUnitTenantAndSurveyDicData(tenantStatus:String?=nil,notes:String?=nil,attempt:String?=nil,contact:String?=nil,reKnockNeeded:String?=nil,inTakeStatus:String?=nil,assignmentLocationUnitId:String?=nil,selectedSurveyId:String?=nil,selectedTenantId:String?=nil,lastCanvassedBy:String?=nil)->[String:String]{
        
        var editUnitDict:[String:String] = [:]
        
           editUnitDict["assignmentLocationUnitId"] = assignmentLocationUnitId
        
        
            editUnitDict["tenantStatus"] = tenantStatus
            editUnitDict["notes"] = notes
            editUnitDict["attempt"] = attempt
            editUnitDict["contact"] = contact
            editUnitDict["reKnockNeeded"] = reKnockNeeded
            editUnitDict["intakeStatus"] = inTakeStatus
        
            editUnitDict["surveyId"] = selectedSurveyId
            editUnitDict["tenantId"] = selectedTenantId
        
            editUnitDict["lastCanvassedBy"] = lastCanvassedBy
        
        
        

        return editUnitDict
    }
    
    class func editLocData(canvassingStatus:String,assignmentLocationId:String,notes:String,attempt:String,numberOfUnits:String)->[String:String]{
        
        var editLocDict:[String:String] = [:]
        
        editLocDict["status"] = canvassingStatus
        editLocDict["assignmentLocationId"] = assignmentLocationId
        editLocDict["Notes"] = notes
        editLocDict["attempt"] = attempt
        editLocDict["numberOfUnits"] = numberOfUnits
        
        return editLocDict

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
    
    editTenantDict["birthdate"] = dob
        
    
    
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
        
        
    }
    
    class func parseSurveyResponse(jsonObject: Dictionary<String, AnyObject>){
        
        let assignmentLocUnitId = jsonObject["assignmentLocationUnitId"] as? String
        
        let surveyResResults = ManageCoreData.fetchData(salesforceEntityName: "SurveyResponse",predicateFormat: "actionStatus == %@ AND assignmentLocUnitId == %@" ,predicateValue: "edit",predicateValue2: assignmentLocUnitId,isPredicate:true) as! [SurveyResponse]
        
        if(surveyResResults.count > 0){
            
            var updateObjectDic:[String:String] = [:]
            
            updateObjectDic["actionStatus"] = ""
            
            ManageCoreData.updateRecord(salesforceEntityName: "SurveyResponse", updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocUnitId == %@", predicateValue: assignmentLocUnitId,isPredicate: true)
            
            
        }
        
        
    }

    
//    class func parseSurveyUnit(jsonObject: Dictionary<String, AnyObject>){
//        
//        let assignmentLocUnitId = jsonObject["assignmentLocationUnitId"] as? String
//        
//        let surveyUnitResults = ManageCoreData.fetchData(salesforceEntityName: "SurveyUnit",predicateFormat: "actionStatus == %@ OR actionStatus == %@ AND assignmentLocUnitId == %@" ,predicateValue: "edit",predicateValue2: "create",predicateValue3: assignmentLocUnitId,isPredicate:true) as! [SurveyUnit]
//        
//        if(surveyUnitResults.count > 0){
//            
//            var updateObjectDic:[String:String] = [:]
//            
//            updateObjectDic["actionStatus"] = ""
//            
//            ManageCoreData.updateRecord(salesforceEntityName: "SurveyUnit", updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocUnitId == %@", predicateValue: assignmentLocUnitId,isPredicate: true)
//            
//            
//        }
//        
//        
//    }
//    
//    
//    
//    
//    
//    
//    class func parseAssignTenant(jsonObject: Dictionary<String, AnyObject>){
//        
//        let assignmentLocUnitId = jsonObject["assignmentLocationUnitId"] as? String
//        
//        let tenantAssignResults = ManageCoreData.fetchData(salesforceEntityName: "TenantAssign",predicateFormat: "actionStatus == %@ OR actionStatus == %@ AND assignmentLocUnitId == %@" ,predicateValue: "edit",predicateValue2: "create",predicateValue3: assignmentLocUnitId,isPredicate:true) as! [TenantAssign]
//        
//        if(tenantAssignResults.count > 0){
//            
//            var updateObjectDic:[String:String] = [:]
//            
//            updateObjectDic["actionStatus"] = ""
//            
//            ManageCoreData.updateRecord(salesforceEntityName: "TenantAssign", updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocUnitId == %@", predicateValue: assignmentLocUnitId,isPredicate: true)
//            
//            
//        }
//        
//        
//    }
//    
    
    

    
    //Tested
//    class func resetAllActionStatusFromEditLocation(){
//        
//       
//            let editLocResults = ManageCoreData.fetchData(salesforceEntityName: "EditLocation",predicateFormat: "actionStatus == %@" ,predicateValue: "edit",isPredicate:true) as! [EditLocation]
//            
//            if(editLocResults.count > 0){
//                
//                for editLocData in editLocResults{
//                    
//                    var updateObjectDic:[String:String] = [:]
//                    
//                    updateObjectDic["actionStatus"] = ""
//                    
//                    ManageCoreData.updateRecord(salesforceEntityName: "EditLocation", updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocId == %@", predicateValue: editLocData.assignmentLocId,isPredicate: true)
//                    
//                    
//                }
//                
//                
//            }
//
//        
//    }
//    
//   
//
//    
//    class func resetAllActionStatusFromEditUnit(){
//        
//        
//        let editUnitResults = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "actionStatus == %@ OR actionStatus == %@" ,predicateValue: "edit",predicateValue2: "create",isPredicate:true) as! [EditUnit]
//        
//        if(editUnitResults.count > 0){
//            
//            for editUnitData in editUnitResults{
//                
//                var updateObjectDic:[String:String] = [:]
//                
//                updateObjectDic["actionStatus"] = ""
//                
//                ManageCoreData.updateRecord(salesforceEntityName: "EditUnit", updateKeyValue: updateObjectDic, predicateFormat: "unitId == %@", predicateValue: editUnitData.unitId!, isPredicate: true)
//                
//                
//            }
//            
//            
//        }
//        
//        
//    }
//    
//    class func resetAllActionStatusFromSurveyUnit(){
//        
//        
//        let surveyUnitResults = ManageCoreData.fetchData(salesforceEntityName: "SurveyUnit",predicateFormat: "actionStatus == %@ OR actionStatus == %@" ,predicateValue: "edit",predicateValue2: "create",isPredicate:true) as! [SurveyUnit]
//        
//        if(surveyUnitResults.count > 0){
//            
//            for surveyUnitData in surveyUnitResults{
//                
//                var updateObjectDic:[String:String] = [:]
//                
//                updateObjectDic["actionStatus"] = ""
//                
//                ManageCoreData.updateRecord(salesforceEntityName: "SurveyUnit", updateKeyValue: updateObjectDic, predicateFormat: "unitId == %@", predicateValue: surveyUnitData.unitId!, isPredicate: true)
//                
//                
//            }
//            
//            
//        }
//        
//        
//    }
//
//    
//    
//    
//    class func resetAllActionStatusFromTenantAssign(){
//        
//        
//        let tenantAsignResults = ManageCoreData.fetchData(salesforceEntityName: "TenantAssign",predicateFormat: "actionStatus == %@ OR actionStatus == %@" ,predicateValue: "edit",predicateValue2: "create",isPredicate:true) as! [TenantAssign]
//        
//        if(tenantAsignResults.count > 0){
//            
//            for tenantAssignData in tenantAsignResults{
//                
//                var updateObjectDic:[String:String] = [:]
//                
//                updateObjectDic["actionStatus"] = ""
//                
//                ManageCoreData.updateRecord(salesforceEntityName: "TenantAssign", updateKeyValue: updateObjectDic, predicateFormat: "unitId == %@", predicateValue: tenantAssignData.unitId!, isPredicate: true)
//                
//                
//            }
//            
//            
//        }
//        
//        
//    }
    
    
    
    
   
    class func updateTenantIdInCoreData(tenantDataDict:[String:AnyObject]){
        
        let iosTenantId = tenantDataDict["iOSTenantId"] as! String?
        let tenantId = tenantDataDict["tenantId"] as! String?
        
        if(SalesforceConnection.currentTenantId == tenantId){
            SalesforceConnection.currentTenantId =  tenantId!
        }
        
        let tenantCreateResults = ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "actionStatus == %@ OR actionStatus == %@ AND id == %@" ,predicateValue: "create",predicateValue2: "edit", predicateValue3: iosTenantId, isPredicate:true) as! [Tenant]
        

      
        if(tenantCreateResults.count > 0){
            
            var updateObjectDic:[String:String] = [:]
            updateObjectDic["id"] = tenantId
            updateObjectDic["actionStatus"] = ""
            
            ManageCoreData.updateRecord(salesforceEntityName: "Tenant", updateKeyValue: updateObjectDic, predicateFormat: "id == %@", predicateValue: iosTenantId,isPredicate: true)
            
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

    
    
    //Tested
    class func updateUnitDetail(unitDataDict:[String:AnyObject]){
        
        
        let locUnitId = unitDataDict["unitId"] as! String?
        let locAssignmentUnitId = unitDataDict["assignmentLocUnitId"] as! String?
        let iosLocUnitId = unitDataDict["iOSLocUnitId"] as! String?
        let iosAssignmentLocUnitId = unitDataDict["iOSAssignmentLocUnitId"] as! String?
        
        
        if(SalesforceConnection.unitId == locUnitId){
            SalesforceConnection.unitId =  locUnitId!
        }
        
        if(SalesforceConnection.assignmentLocationUnitId == locAssignmentUnitId){
            SalesforceConnection.assignmentLocationUnitId =  locAssignmentUnitId!
        }
        
        
        
        var updateObjectDic:[String:String] = [:]
        updateObjectDic["id"] = locUnitId
        updateObjectDic["assignmentLocUnitId"] = locAssignmentUnitId
        updateObjectDic["actionStatus"] = ""
        
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
        
    }
    

    
    
//    class func updateSurveyUnitDetail(unitDataDict:[String:AnyObject]){
//        
//        
//        let locUnitId = unitDataDict["unitId"] as! String?
//        let locAssignmentUnitId = unitDataDict["assignmentLocUnitId"] as! String?
//        let iosLocUnitId = unitDataDict["iOSLocUnitId"] as! String?
//        let iosAssignmentLocUnitId = unitDataDict["iOSAssignmentLocUnitId"] as! String?
//        
//        let editUnitResults = ManageCoreData.fetchData(salesforceEntityName: "SurveyUnit",predicateFormat: "unitId == %@ AND assignmentLocUnitId == %@" ,predicateValue: iosLocUnitId,predicateValue2: iosAssignmentLocUnitId,isPredicate:true) as! [SurveyUnit]
//        
//        
//        
//        
//        
//        if(editUnitResults.count > 0){
//            
//            
//            var updateObjectDic:[String:String] = [:]
//            updateObjectDic["unitId"] = locUnitId
//            updateObjectDic["assignmentLocUnitId"] = locAssignmentUnitId
//            //updateObjectDic["actionStatus"] = ""
//            
//            ManageCoreData.updateRecord(salesforceEntityName: "SurveyUnit", updateKeyValue: updateObjectDic, predicateFormat: "unitId == %@ AND assignmentLocUnitId ==%@", predicateValue: iosLocUnitId, predicateValue2: iosAssignmentLocUnitId,isPredicate: true)
//            
//            print("SurveyUnitDetail updated")
//        }
//        
//    }
//    
//    
//    class func updateTenantAssignDetail(unitDataDict:[String:AnyObject]){
//        
//        
//        let locUnitId = unitDataDict["unitId"] as! String?
//        let locAssignmentUnitId = unitDataDict["assignmentLocUnitId"] as! String?
//        let iosLocUnitId = unitDataDict["iOSLocUnitId"] as! String?
//        let iosAssignmentLocUnitId = unitDataDict["iOSAssignmentLocUnitId"] as! String?
//        
//        
//        let tenantAssignResults = ManageCoreData.fetchData(salesforceEntityName: "TenantAssign",predicateFormat: "unitId == %@ AND assignmentLocUnitId ==%@",predicateValue: iosLocUnitId,predicateValue2: iosAssignmentLocUnitId,isPredicate:true) as! [TenantAssign]
//        
//        
//        
//        if(tenantAssignResults.count > 0){
//            
//           
//                var updateObjectDic:[String:String] = [:]
//                updateObjectDic["unitId"] = locUnitId
//                updateObjectDic["assignmentLocUnitId"] = locAssignmentUnitId
//                //updateObjectDic["actionStatus"] = ""
//                
//                ManageCoreData.updateRecord(salesforceEntityName: "TenantAssign", updateKeyValue: updateObjectDic, predicateFormat: "unitId == %@ AND assignmentLocUnitId ==%@", predicateValue: iosLocUnitId,predicateValue2: iosAssignmentLocUnitId,isPredicate: true)
//           
//            print("tenantAssignResults updated")
//        }
//        
//    }
    
    

    
    class func updateAssignmentUnitCount(){
        
        let assignementResults = ManageCoreData.fetchData(salesforceEntityName: "Assignment",predicateFormat: "id == %@" ,predicateValue: SalesforceConnection.assignmentId,isPredicate:true) as! [Assignment]
        
        if(assignementResults.count > 0){
            
            let totalUnits = String(Int(assignementResults[0].totalUnits!)! + 1)
            
            
            ManageCoreData.updateData(salesforceEntityName: "Assignment", valueToBeUpdate: totalUnits,updatekey:"totalUnits", predicateFormat: "id == %@", predicateValue: SalesforceConnection.assignmentId, isPredicate: true)
        }
    }
    
    
    
    
    //for assignmentDetail api
    
    
    class func fetchAllDataFromSalesforce(){
        
         var emailParams : [String:String] = [:]
        
        
        emailParams["email"] = try! SalesforceConnection.currentUserEmail.aesEncrypt(SalesforceConfig.key, iv: SalesforceConfig.iv)
        
        SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.getAllEventAssignmentData, params: emailParams){ jsonData in
            
//            SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.chartapi, params: emailParams){ jsonData in
//            
//                                ManageCoreData.DeleteAllDataFromEntities()
//            
//                                Utilities.parseChartData(jsonObject: jsonData.1)
//                                Utilities.parseEventAssignmentData(jsonObject: jsonData.1)
//            }
            
            ManageCoreData.DeleteAllDataFromEntities() //need to be rethink
            
            Utilities.parseEventAssignmentData(jsonObject: jsonData.1)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateAssignmentView"), object: nil)

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateLocationView"), object: nil)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateTenantView"), object: nil)
            
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateSurveyView"), object: nil)

            

            
            
            //Notification : assignment
            //Notification : location
            //Notification  :unit
            //Notification  :tenant
        }
     
    }
    
    
    class func parseUserData(jsonObject: Dictionary<String, AnyObject>){
        
        SalesforceConnection.currentUserContactId  = (jsonObject["contactId"] as? String)!
        SalesforceConnection.currentUserEmail = (jsonObject["Email"] as? String)!
        SalesforceConnection.currentUserExternalId = (jsonObject["ExternalId"] as? String)!
    }
    
    
    class func parseChartData(jsonObject: Dictionary<String, AnyObject>){
    
      
        let chart1 = jsonObject["Chart1"] as? [String: AnyObject]
        let chart2 = jsonObject["Chart2"] as? [String: AnyObject]
        let chart3 = jsonObject["Chart3"] as? [String: AnyObject]
        let chart4 = jsonObject["Chart4"] as? [String: AnyObject]
        
        let chart1Obj = chart1?["TotalAssignmentsByStatus"] as? [String: AnyObject]
       
        let chart1CompObj = Chart(context: context)
        chart1CompObj.chartType = "Chart1"
        chart1CompObj.chartField = "Completed"
        chart1CompObj.chartLabel = "Total AssignmentsByStatus"
        chart1CompObj.chartValue = String(chart1Obj?["Completed"] as! Int)
        
        appDelegate.saveContext()
        
        let chart1InProgObj = Chart(context: context)
        chart1InProgObj.chartType = "Chart1"
        chart1InProgObj.chartField = "In Progress"
        chart1InProgObj.chartLabel = "Total AssignmentsByStatus"
        chart1InProgObj.chartValue = String(chart1Obj?["In Progress"] as! Int)
        
        appDelegate.saveContext()
        
        let chart1AssignedObj = Chart(context: context)
        chart1AssignedObj.chartType = "Chart1"
        chart1AssignedObj.chartField = "Assigned"
        chart1AssignedObj.chartLabel = "Total AssignmentsByStatus"
        chart1AssignedObj.chartValue = String(chart1Obj?["Assigned"] as! Int)
        
        appDelegate.saveContext()
        
      
        
        
        let chart2Object = Chart(context: context)
        chart2Object.chartType = "Chart2"
        chart2Object.chartField = "UnitsCompleted"
        chart2Object.chartLabel = "Units Completed"
        chart2Object.chartValue = String(chart2?["UnitsCompleted"] as! Int)
        
        appDelegate.saveContext()
        
        let chart3Object = Chart(context: context)
        chart3Object.chartType = "Chart3"
        chart3Object.chartField = "NoResponse"
        chart3Object.chartLabel = "No Response"
        chart3Object.chartValue = String(chart3?["NoResponse"] as! Int)
        
        appDelegate.saveContext()
        
        let chart4Object = Chart(context: context)
        chart4Object.chartType = "Chart4"
        chart4Object.chartField = "FollowUpNeeded"
        chart4Object.chartLabel = "FollowUp Needed"
        chart4Object.chartValue = String(chart4?["FollowUpNeeded"] as! Int)
        
        appDelegate.saveContext()
        
        //need to check location id and unit id
    
       print(String(chart4?["FollowUpNeeded"] as! Int))
       print(String(chart3?["NoResponse"] as! Int))
       print(String(chart2?["UnitsCompleted"] as! Int))
       
        
       

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
                    
                    locationObject.assignmentId = assignmentObject.id!
                    
                    
                    appDelegate.saveContext()
                    
                    //EditLocation
                    
                    let editlocationObject = EditLocation(context: context)
                    editlocationObject.locationId = locationObject.id!
                    editlocationObject.assignmentId = assignmentObject.id!
                    editlocationObject.assignmentLocId = locationObject.assignmentLocId!
                    
                    editlocationObject.canvassingStatus = locationData["status"] as? String  ?? ""
                    editlocationObject.attempt = locationData["attempt"] as? String  ?? ""
                    editlocationObject.noOfUnits = locationData["numberOfUnits"] as? String  ?? ""
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
                        
                        unitObject.surveyStatus = ""
                        unitObject.syncDate = ""
                        
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
                        editUnitObject.inTakeStatus = unitData["intakeStatus"] as? String  ?? ""
                        editUnitObject.reKnockNeeded = unitData["reKnockNeeded"] as? String  ?? ""
                        editUnitObject.tenantStatus = unitData["tenantStatus"] as? String  ?? ""
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
                            
                            
                            appDelegate.saveContext()
                            
                        }
                    }
                    
                }
            }
            
            
            
        }
        
        
        
    }

    
    
    

}

