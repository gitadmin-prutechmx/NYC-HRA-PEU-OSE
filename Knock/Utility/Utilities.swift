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
    
    
    class func parseAddNewUnitResponse(jsonObject: Dictionary<String, AnyObject>)->Bool {
        
        
        guard let isError = jsonObject["hasError"] as? Bool,
            
            let unitDataDict = jsonObject["unitData"] as? [String: AnyObject] else { return true}
        
        
        
        
        if(isError == false){
            
            
            updateUnitDetail(unitDataDict: unitDataDict)
            
            updateAssignmentUnitCount()
            
           // updateAssignmentUnitCount()
            
        }
        
        
        return isError
        
        
        
    }
    
    class func updateUnitDetail(unitDataDict:[String:AnyObject]){
        
        
        let locUnitId = unitDataDict["unitId"] as! String?
        let locAssignmentUnitId = unitDataDict["assignmentLocUnitId"] as! String?
        let iosLocUnitId = unitDataDict["iOSLocUnitId"] as! String?
        let iosAssignmentLocUnitId = unitDataDict["iOSAssignmentLocUnitId"] as! String?
        
        
        let unitResults = ManageCoreData.fetchData(salesforceEntityName: "Unit",predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND id == %@ AND assignmentLocUnitId ==%@",predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId, predicateValue4: iosLocUnitId, predicateValue5: iosAssignmentLocUnitId,isPredicate:true) as! [Unit]
        
        
        
        if(unitResults.count > 0){
            
            
            var updateObjectDic:[String:String] = [:]
            updateObjectDic["id"] = locUnitId
            updateObjectDic["assignmentLocUnitId"] = locAssignmentUnitId
            updateObjectDic["actionStatus"] = ""
            
            ManageCoreData.updateRecord(salesforceEntityName: "Unit", updateKeyValue: updateObjectDic, predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND id == %@ AND assignmentLocUnitId ==%@", predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId, predicateValue4: iosLocUnitId, predicateValue5: iosAssignmentLocUnitId,isPredicate: true)
        }
        
    }
    
    class func updateAssignmentUnitCount(){
        
        let assignementResults = ManageCoreData.fetchData(salesforceEntityName: "Assignment",predicateFormat: "id == %@" ,predicateValue: SalesforceConnection.assignmentId,isPredicate:true) as! [Assignment]
        
        if(assignementResults.count > 0){
            
            let totalUnits = String(Int(assignementResults[0].totalUnits!)! + 1)
            
            
            ManageCoreData.updateData(salesforceEntityName: "Assignment", valueToBeUpdate: totalUnits,updatekey:"totalUnits", predicateFormat: "id == %@", predicateValue: SalesforceConnection.assignmentId, isPredicate: true)
        }
    }

}

