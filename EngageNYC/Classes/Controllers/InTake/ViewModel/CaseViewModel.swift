//
//  CaseViewModel.swift
//  EngageNYC
//
//  Created by Kamal on 24/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation

class CaseViewModel{
    
    
    
    var metadataDynamicDict:[String:AnyObject] = [:]
    
    var sectionFieldDict : [String:[MetadataConfigDO]] = [:]
    var orderedSectionFieldDict: [Int: [String:[MetadataConfigDO]]] = [:]
    
    var tempArray = [MetadataConfigDO]()
    
    
    
    static func getViewModel()->CaseViewModel{
        return CaseViewModel()
    }
    
    func loadCaseNotes(caseId:String,assignmentLocUnitId:String)->[CaseNoteDO]{
        
        var arrCaseNotes = [CaseNoteDO]()
        
        if let caseNotesRes = CaseAPI.shared.getAllCaseNotesOnCase(caseId: caseId, assignmentLocUnitId: assignmentLocUnitId){
            
            for caseNote in caseNotesRes{
                let caseNoteObj = CaseNoteDO()
                caseNoteObj.caseId = caseNote.caseId
                caseNoteObj.caseNotes = caseNote.notes
                caseNoteObj.createdDate = caseNote.createdDate
                
                arrCaseNotes.append(caseNoteObj)
            }
        }
        return arrCaseNotes
    }
    
    
    
    
    func loadCaseDetail(objCase:CaseDO)->[MetadataConfigObjects]{
        
        if let caseConfig = CaseAPI.shared.getCaseConfig(){
            parseJson(jsonObject:caseConfig.configData as! Dictionary<String, AnyObject>,objCase:objCase)
        }
        
        return Utility.convertDictToArray(orderedSectionFieldDict: orderedSectionFieldDict)
        
    }
    
    
    private func parseJson(jsonObject: Dictionary<String, AnyObject>,objCase:CaseDO){
        
        guard let sectionResults = jsonObject["Section"] as? [[String: AnyObject]] else { return }
        
        var sequence = 0
        
        for sectionData in sectionResults {
            
            guard let fieldListResults = sectionData["fieldList"] as? [[String: AnyObject]]  else { break }
            
            let sectionName = sectionData["sectionName"] as? String  ?? ""
            
            sequence = sequence + 1
            
            sectionFieldDict = [:]
            
            tempArray = []
            
            for fieldListData in fieldListResults {
                
                let apiName = fieldListData["apiName"] as? String  ?? ""
                let dataType = fieldListData["dataType"] as? String  ?? ""
                
                if sectionFieldDict[sectionName] != nil {
                    
                    var arrayValue:[MetadataConfigDO] =  sectionFieldDict[sectionName]!
                    arrayValue.append(MetadataConfigDO(sequence: fieldListData["sequence"] as? String  ?? "", pickListValue: fieldListData["picklistValue"] as? String  ?? "", fieldName: fieldListData["fieldName"] as? String  ?? "", dataType: dataType, apiName: apiName,sectionName:sectionName))
                    
                    sectionFieldDict[sectionName] = arrayValue
                    
                    orderedSectionFieldDict[sequence] = sectionFieldDict
                    
                    if(dataType == "DATE"){
                        
                        if let dateVal = objCase.caseDynamicDict[apiName]{
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let date = dateFormatter.date(from: dateVal as! String)!
                            objCase.caseResponseDynamicDict[apiName] = date as AnyObject?
                            
                        }
                        else{
                            objCase.caseResponseDynamicDict[apiName] = nil
                        }
                        
                        
                    }
                        
                    else{
                        
                        if(apiName == "Origin" && objCase.caseActionStatus == enumCaseActionStatus.Add.rawValue){
                            
                            objCase.caseResponseDynamicDict[apiName] = "Door Knock" as AnyObject
                        }
                            
                        else{
                            objCase.caseResponseDynamicDict[apiName] = objCase.caseDynamicDict[apiName]
                        }
                    }
                    
                    
                }
                    
                    
                else{
                    
                    tempArray.append(MetadataConfigDO(sequence: fieldListData["sequence"] as? String  ?? "", pickListValue: fieldListData["picklistValue"] as? String  ?? "", fieldName: fieldListData["fieldName"] as? String  ?? "", dataType: dataType, apiName: apiName,sectionName:sectionName))
                    
                    
                    
                    sectionFieldDict[sectionName] = tempArray
                    
                    orderedSectionFieldDict[sequence] = sectionFieldDict
                    
                    if(dataType == "DATE"){
                        
                        if let dateVal = objCase.caseDynamicDict[apiName]{
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let date = dateFormatter.date(from: dateVal as! String)!
                            objCase.caseResponseDynamicDict[apiName] = date as AnyObject?
                            
                        }
                        else{
                            objCase.caseResponseDynamicDict[apiName] = nil
                        }
                        
                        
                    }
                        
                    else{
                         if(apiName == "Origin" && objCase.caseActionStatus == enumCaseActionStatus.Add.rawValue){
                            
                            objCase.caseResponseDynamicDict[apiName] = "Door Knock" as AnyObject
                        }
                            
                        else{
                             objCase.caseResponseDynamicDict[apiName] = objCase.caseDynamicDict[apiName]
                        }
                    }
                    
                }
            }
        }
    }
    
    func loadPickList(pickListStr:String)->[DropDownDO]{
        
        var pickListArr:[DropDownDO] = []
        
        let arr = String(pickListStr.dropLast()).components(separatedBy: ";")
        for val in arr{
            
            let objDropDown = DropDownDO()
            objDropDown.id = val
            objDropDown.name = val
            
            pickListArr.append(objDropDown)
            
        }
        
        
        return pickListArr
        
    }
    
    func loadCases(clientId:String,assignmentLocUnitId:String)->[CaseDO]{
        
        var arrCases = [CaseDO]()
        
        if let cases = CaseAPI.shared.getAllCasesOnClient(clientId: clientId, assignmentLocUnitId: assignmentLocUnitId){
            for caseData:Cases in cases{
                
                let objCase = CaseDO()
                objCase.caseId = caseData.caseId
                objCase.caseNo = caseData.caseNo
                objCase.caseStatus = caseData.caseStatus
                objCase.ownerName = caseData.caseOwner
                objCase.ownerId = caseData.caseOwnerId
                objCase.clientId = caseData.clientId
                objCase.dateOfIntake = caseData.createdDate
                objCase.caseDynamicDict = caseData.caseDynamic as! [String : AnyObject]
                objCase.dbActionStatus = caseData.actionStatus
                objCase.caseNotes = caseData.caseNotes
                objCase.assignmentId = caseData.assignmentId
                objCase.assignmentLocId = caseData.assignmentLocId
                objCase.assignmentLocUnitId = caseData.assignmentLocUnitId
                
        
                
                arrCases.append(objCase)
                
            }
        }
        
        
        arrCases = loadTempCases(assignmentLocUnitId: assignmentLocUnitId,arrCases:arrCases)
        
        return arrCases
        
    }
    
    func loadTempCases(assignmentLocUnitId:String,arrCases:[CaseDO])->[CaseDO]{
        
        var arrTempCases = arrCases
        if let tempCases = CaseAPI.shared.getAllTempCasesOnAssigmentLocationUnit(assignmentLocUnitId: assignmentLocUnitId){
            
            for tempCaseData:Cases in tempCases{
                
                let objTempCase = CaseDO()
                objTempCase.caseId = tempCaseData.caseId
                objTempCase.caseNo = tempCaseData.caseNo
                objTempCase.caseStatus = tempCaseData.caseStatus
                objTempCase.ownerName = tempCaseData.caseOwner
                objTempCase.ownerId = tempCaseData.caseOwnerId
                objTempCase.clientId = tempCaseData.clientId
                objTempCase.dateOfIntake = tempCaseData.createdDate
                objTempCase.caseDynamicDict = tempCaseData.caseDynamic as! [String : AnyObject]
                objTempCase.dbActionStatus = tempCaseData.actionStatus
                objTempCase.caseNotes = tempCaseData.caseNotes
                objTempCase.assignmentId = tempCaseData.assignmentId
                objTempCase.assignmentLocId = tempCaseData.assignmentLocId
                objTempCase.assignmentLocUnitId = tempCaseData.assignmentLocUnitId
                
                
                arrTempCases.append(objTempCase)
                
            }
            
        }
        
        return arrTempCases
    }
    
    func SaveCaseInCoreData(objCase:CaseDO){
        let objResCase = prepareCaseResponse(objCase:objCase)
        CaseAPI.shared.saveCase(objCase: objResCase)
    }
    
    func UpdateCaseInCoreData(objCase:CaseDO){
         let objResCase = prepareCaseResponse(objCase:objCase)
         CaseAPI.shared.updateCase(objCase: objResCase)
    }
    
    
    
    func prepareCaseResponse(objCase:CaseDO)->CaseDO{

        
        if(objCase.caseNo != ""){
             objCase.caseApiResponseDict["Id"] = objCase.caseId as AnyObject?
        }
        
        
        let dateOfIntakeFormat = DateFormatter()
        
        dateOfIntakeFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        objCase.caseApiResponseDict["Date_of_Intake__c"] =  dateOfIntakeFormat.string(from: Date()) as AnyObject?
        objCase.caseApiResponseDict["Description"] = objCase.caseNotes as AnyObject
        
        objCase.dateOfIntake = Utility.currentDateAndTime()
        
       
        
        //Public_and_or_Rental_Assistance__c
        
        
        for (key, value) in objCase.caseResponseDynamicDict {
            
            if let str = value as? String {
                
                if(key == "Public_and_or_Rental_Assistance__c" && str.contains("OTHER")){
                    objCase.caseApiResponseDict["Other_public_rental_assistance__c"] = value as AnyObject
                }
                
                objCase.caseApiResponseDict[key] = str.replacingOccurrences(of: ",", with: ";") as AnyObject?
            }
            else{
                
                if let dateVal = value as? Date {
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    objCase.caseApiResponseDict[key] = dateFormatter.string(from: dateVal) as AnyObject?
                    
                }
                else{
                    objCase.caseApiResponseDict[key] = value
                }
            }
            
        }
        
        print(objCase.caseApiResponseDict)
        
        return objCase
        
        
        
        
        
        
    }
    

    
    
    
}
