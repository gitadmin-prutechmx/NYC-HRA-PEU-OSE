//
//  AssignmentLocationUnitAPI.swift
//  EngageNYC
//
//  Created by Kamal on 14/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation
import SalesforceSDKCore

final class ContactAPI:SFCommonAPI {
    
    
    private static var sharedInstance: ContactAPI = {
        let instance = ContactAPI()
        return instance
    }()
    
    class var shared:ContactAPI!{
        get{
            return sharedInstance
        }
    }
    
   

    
    /// Get all the contacts from core data.
    ///
    /// - Returns: array of contacts.
    func getAllContacts(assignmentId:String,assignmentLocId:String)->[Contact]? {
        
        let contactRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.contact.rawValue,predicateFormat: "assignmentId == %@ && assignmentLocId == %@",predicateValue: assignmentId,predicateValue2: assignmentLocId, isPredicate:true) as? [Contact]
        
        return contactRes
        
    }
    
  
    
    func saveNewContact(objNewContact:NewContactDO,isSameUnit:Bool){
        
        let fname = objNewContact.firstName.capitalizingFirstLetter()
        let mname = objNewContact.middleName
        let lname = objNewContact.lastName.capitalizingFirstLetter()
        
        var middleTempName = mname
        
        if(!middleTempName.isEmpty){
            middleTempName =  " " + middleTempName + " "
        }
        else{
            middleTempName = " "
        }
        
        let contactName = fname  + middleTempName  + lname
        
        
        
        let newContact = Contact(context:context)
        
        newContact.assignmentId = objNewContact.assignmentId
        newContact.assignmentLocId = objNewContact.assignmentLocId
        newContact.locationUnitId = objNewContact.locationUnitId
        newContact.assignmentLocUnitId = objNewContact.assignmentLocUnitid
      
        newContact.iOSContactId = objNewContact.contactId
        newContact.contactId = objNewContact.contactId
        newContact.actionStatus = actionStatus.create.rawValue
        newContact.contactName = contactName
        newContact.firstName = fname
        newContact.middleName = mname
        newContact.lastName = lname
        newContact.suffix = objNewContact.suffix
        newContact.phone = objNewContact.phone
        newContact.email = objNewContact.email
        newContact.age = objNewContact.age
        newContact.dob = objNewContact.dob
        
        newContact.streetName = objNewContact.streetName
        newContact.streetNum = objNewContact.streetNum
        newContact.borough = objNewContact.borough
        newContact.zip = objNewContact.zip
        newContact.floor = objNewContact.floor
  
        
        if(isSameUnit){
             newContact.unitName = objNewContact.sameUnitName
        }
        else{
             newContact.unitName = objNewContact.diffUnitName
        }
        
        newContact.syncDate = objNewContact.syncDate
        newContact.createdById = objNewContact.createdById
        
        newContact.primaryLang = objNewContact.primaryLang
        newContact.otherLang = objNewContact.otherLang
        
        appDelegate.saveContext()
        
    }
    
    
    func updateContact(objContact:ContactDO){
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        let fname = objContact.firstName.capitalizingFirstLetter()
        let mname = objContact.middleName
        let lname = objContact.lastName.capitalizingFirstLetter()
        
        
        var middleTempName = mname
        
        if(!middleTempName.isEmpty){
            middleTempName =  " " + middleTempName + " "
        }
        else{
            middleTempName = " "
        }
        
        let contactName = fname + middleTempName  + lname
        
        
        updateObjectDic["contactName"] = contactName as AnyObject
        updateObjectDic["firstName"] = fname as AnyObject
        updateObjectDic["lastName"] = lname as AnyObject
        updateObjectDic["middleName"] = mname as AnyObject
        updateObjectDic["suffix"] = objContact.suffix as AnyObject
        updateObjectDic["phone"] = objContact.phone as AnyObject
        updateObjectDic["email"] = objContact.email as AnyObject
        updateObjectDic["dob"] = objContact.dob as AnyObject
        updateObjectDic["age"] = objContact.age as AnyObject
        
        updateObjectDic["streetName"] = objContact.streetName as AnyObject
        updateObjectDic["streetNum"] = objContact.streetNum as AnyObject
        updateObjectDic["borough"] = objContact.borough as AnyObject
        updateObjectDic["zip"] = objContact.zip as AnyObject
        updateObjectDic["floor"] = objContact.floor as AnyObject
        updateObjectDic["unitName"] = objContact.aptNo as AnyObject
        
        if(objContact.actionStatus == actionStatus.no.rawValue){
            updateObjectDic["actionStatus"] = actionStatus.edit.rawValue as AnyObject
        }
        
        updateObjectDic["locationUnitId"] = objContact.locationUnitId as AnyObject
        updateObjectDic["assignmentLocUnitId"] = objContact.assignmentLocUnitId as AnyObject
        updateObjectDic["iOSContactId"] = objContact.iOSContactId as AnyObject
        updateObjectDic["createdById"] = objContact.createdById as AnyObject
        
        updateObjectDic["primaryLang"] = objContact.primaryLang as AnyObject
        updateObjectDic["otherLang"] = objContact.otherLang as AnyObject
        
        var queryString = getQueryString(contactId: objContact.contactId)
        
        queryString = queryString + "&& assignmentLocId == %@"
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.contact.rawValue, updateKeyValue: updateObjectDic, predicateFormat: queryString, predicateValue: objContact.contactId,predicateValue2:objContact.assignmentLocId,  isPredicate: true)
        
    }
    
    func updateAssignmentLocationUnitId(salesforceAssignmentLocUnitId:String,iOSAssignmentLocUnitId:String){
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["assignmentLocUnitId"] = salesforceAssignmentLocUnitId as AnyObject
        
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.contact.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocUnitId == %@", predicateValue:  iOSAssignmentLocUnitId,isPredicate: true)
        
    }
    
    
    
    func syncUpCompletion(completion: @escaping (()->()))
    {
        if let arrContacts = getAllUpdatedContacts(){
            
            let contactGroup = DispatchGroup()
            
            for contact in arrContacts{
                
                var contactDict:[String:String] = [:]
                var contactParams:[String:String] = [:]
                

                var sfdcLocUnitId = contact.locationUnitId
                var sfdcAssignmentLocUnitId = contact.assignmentLocUnitId
                
                //...........contact info
                
                let isiOSLocationUnitId = Utility.isiOSGeneratedId(generatedId: sfdcLocUnitId!)
                
                //if isiOSLocationUnitId is a UUID string then get salesforce locationUnit from unit object
                if(isiOSLocationUnitId != nil){
                    let locUnitId = LocationUnitAPI.shared.getSalesforceLocationUnitId(iOSLocUnitId: sfdcLocUnitId!)
                    
                    sfdcLocUnitId = locUnitId //update locUnitId
                    
                    if(Utility.isiOSGeneratedId(generatedId: locUnitId) != nil){
                        print("Error:- ios locationunitid")
                        return
                    }
                    else{
                        //updated locationUnitId at parse location 
                    }
                }
                
                let isiOSAssigmentLocUnitId = Utility.isiOSGeneratedId(generatedId: sfdcAssignmentLocUnitId!)
                
                //if isiOSAssigmentLocUnitId is a UUID string then get salesforce assignmentlocationUnit from unit object
                if(isiOSAssigmentLocUnitId != nil){
                    let assignmentLocUnitId = LocationUnitAPI.shared.getSalesforceAssignmentLocationUnitId(iOSAssignmentLocUnitId: sfdcAssignmentLocUnitId!,locationUnitId: sfdcLocUnitId)
                    
                    sfdcAssignmentLocUnitId = assignmentLocUnitId //update assignmentLocUnitId
                    
                    if(Utility.isiOSGeneratedId(generatedId: assignmentLocUnitId) != nil){
                        print("Error:- ios locationunitid")
                        return
                    }
                    else{
                        //update assignmentLocationUnitId here
                        
                        //updateAssignmentLocationUnitId(salesforceAssignmentLocUnitId: assignmentLocUnitId, iOSAssignmentLocUnitId: contact.assignmentLocUnitId!)
                        
                    }
                }
                
                
                contactDict["locationUnitId"] = sfdcLocUnitId
                
                contactDict["assignmentLocUnitId"] = sfdcAssignmentLocUnitId
                
                if(contact.actionStatus == actionStatus.edit.rawValue){
                    contactDict["tenantId"] = contact.contactId
                    contactDict["iOSTenantId"] = contact.iOSContactId
                    
                }
                else{
                    contactDict["iOSTenantId"] = contact.iOSContactId
                }
                
                contactDict["firstName"] = contact.firstName
                
                contactDict["lastName"] = contact.lastName
                
                contactDict["email"] = contact.email
                
                contactDict["phone"] = contact.phone
                
                contactDict["middleName"] = contact.middleName
                
                contactDict["suffix"] = contact.suffix
                
                
                
                //...........address info
                
                contactDict["streetNum"] = contact.streetNum
                
                contactDict["streetName"] = contact.streetName
                
                contactDict["borough"] = contact.borough
                
                contactDict["zip"] = contact.zip
                
                contactDict["aptNo"] = contact.unitName
                
                contactDict["aptFloor"] = contact.floor
                
                
                if(contact.dob != ""){
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    let date = dateFormatter.date(from: contact.dob!)!
                    
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    contactDict["birthdate"] = dateFormatter.string(from: date)
                }
                
                
                contactDict["primaryLang"] = contact.primaryLang
                contactDict["otherLang"] = contact.otherLang
                
                
                contactParams["tenant"] = Utility.jsonToString(json: contactDict as AnyObject)!
                
                let req = SFRestRequest(method: .POST, path: SalesforceRestApiUrl.createContact, queryParams: nil)
                
                do {
                    
                    let bodyData = try JSONSerialization.data(withJSONObject: contactParams, options: [])
                    req.setCustomRequestBodyData(bodyData, contentType: "application/json")
                }
                catch{
                    
                    
                }
                
                req.endpoint = ""
                
                contactGroup.enter()
                
                self.sendRequest(request: req, callback: { (response) in
                    
                    DispatchQueue.main.async {
                        
                        self.parseContact(jsonObject: response as! Dictionary<String, AnyObject>)
                        
                        contactGroup.leave()
                        
                        print("ContactGroup: \(contact.contactName!)")
                    }
                    
                    
                    
                }) { (error) in
                    
                    Logger.shared.log(level: .error, msg: error)
                    Utility.displayErrorMessage(errorMsg: error)
                }
                
            }
            
            contactGroup.notify(queue: .main) {
                completion()
            }
            
        }
        else{
            completion()
        }
        
        
    }
    
    func parseContact(jsonObject: Dictionary<String, AnyObject>){
        
        
        guard let isError = jsonObject["hasError"] as? Bool,
            
            let message = jsonObject["message"] as? String,
            
            let contactDataDictonary = jsonObject["tenantData"] as? [String: AnyObject] else { return }
        
        
        
        
        if(isError == false){
            
            
            updateContactId(contactDataDict: contactDataDictonary)
            

//            updateContactIdInAssignmentLocationUnit(contactDataDict: contactDataDictonary)
//            updateContactIdInCase(contactDataDict: contactDataDictonary)
//            updateContactIdInSurveyResponse(contactDataDict: contactDataDictonary)
//            updateContactIdInEventsReg(contactDataDict: contactDataDictonary)
            
        }
        else{
            
            let errorMsg = "Error while adding new contact to salesforce.\(message)"
            
            Logger.shared.log(level: .error, msg: errorMsg)
            Utility.displayErrorMessage(errorMsg: errorMsg)
            
        }
        
        
        
    }
    
    func updateContactId(contactDataDict:[String:AnyObject]){
        
        let iOSContactId = contactDataDict["iOSTenantId"] as! String?
        let contactId = contactDataDict["tenantId"] as! String?
        //let locUnitId = contactDataDict["locUnitId"] as! String?
        //let assignmentLocUnitId = contactDataDict["assignmentLocUnitId"] as! String?
    
        
        let contactResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.contact.rawValue,predicateFormat: "actionStatus == %@ OR actionStatus == %@ AND contactId == %@" ,predicateValue: actionStatus.create.rawValue,predicateValue2: actionStatus.edit.rawValue, predicateValue3: iOSContactId, isPredicate:true) as! [Contact]
        
        
        
        if(contactResults.count > 0){
            
           
          
            
            var updateObjectDic:[String:AnyObject] = [:]
            updateObjectDic["contactId"] = contactId as AnyObject
            updateObjectDic["actionStatus"] = "" as AnyObject
           // updateObjectDic["locationUnitId"] = locUnitId as AnyObject
           // updateObjectDic["assignmentLocUnitId"] = assignmentLocUnitId as AnyObject
            updateObjectDic["syncDate"]  = Utility.currentDateAndTime() as AnyObject
            
            
            ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.contact.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "contactId == %@", predicateValue: iOSContactId,isPredicate: true)
            
        }
        
        
    }
    
    func updateContactIdInCase(contactDataDict:[String:AnyObject]){
        
        let iOSContactId = contactDataDict["iOSTenantId"] as! String?
        let contactId = contactDataDict["tenantId"] as! String?
        
        
        let caseResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.cases.rawValue,predicateFormat: "clientId == %@" ,predicateValue: iOSContactId,isPredicate:true) as! [Cases]
        
        if(caseResults.count > 0){
            
            for _ in caseResults{
                
                var updateObjectDic:[String:AnyObject] = [:]
                updateObjectDic["clientId"] = contactId as AnyObject
                
                ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.cases.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "clientId == %@", predicateValue: iOSContactId,isPredicate: true)
                
                
                print("Case Results update contactId")
            }
        }
        
    }
    
    func updateContactIdInAssignmentLocationUnit(contactDataDict:[String:AnyObject]){
        
        let iOSContactId = contactDataDict["iOSTenantId"] as! String?
        let contactId = contactDataDict["tenantId"] as! String?
        
        
        let assignmentLocUnitResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.assignmentLocationUnit.rawValue,predicateFormat: "contactId == %@" ,predicateValue: iOSContactId,isPredicate:true) as! [AssignmentLocationUnit]
        
        if(assignmentLocUnitResults.count > 0){
            
            for _ in assignmentLocUnitResults{
                
                var updateObjectDic:[String:AnyObject] = [:]
                updateObjectDic["contactId"] = contactId as AnyObject
                
                ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.assignmentLocationUnit.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "contactId == %@", predicateValue: iOSContactId,isPredicate: true)
                
                
                print("AssignmentLocUnit Results update contactId")
            }
        }
        
    }
    
    
    
    func updateContactIdInSurveyResponse(contactDataDict:[String:AnyObject]){
        
        let iOSContactId = contactDataDict["iOSTenantId"] as! String?
        let contactId = contactDataDict["tenantId"] as! String?
        
      
        let surveyResResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.surveyResponse.rawValue,predicateFormat: "clientId == %@" ,predicateValue: iOSContactId,isPredicate:true) as! [SurveyResponse]
        
        if(surveyResResults.count > 0){
            
            for _ in surveyResResults{
                
                var updateObjectDic:[String:AnyObject] = [:]
                updateObjectDic["clientId"] = contactId as AnyObject
                
                ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.surveyResponse.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "clientId == %@", predicateValue: iOSContactId,isPredicate: true)
                
                
                print("SurveyResponse Results update contactId")
            }
        }
  
    }
    
    func updateContactIdInEventsReg(contactDataDict:[String:AnyObject]){
        
        let iOSContactId = contactDataDict["iOSTenantId"] as! String?
        let contactId = contactDataDict["tenantId"] as! String?
        
        
        let eventRegResResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.eventsReg.rawValue,predicateFormat: "clientId == %@" ,predicateValue: iOSContactId,isPredicate:true) as! [EventsReg]
        
        if(eventRegResResults.count > 0){
            
            for _ in eventRegResResults{
                
                var updateObjectDic:[String:AnyObject] = [:]
                updateObjectDic["clientId"] = contactId as AnyObject
                
                ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.eventsReg.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "clientId == %@", predicateValue: iOSContactId,isPredicate: true)
                
                
                print("Event Reg Results update contactId")
            }
        }
        
    }
    
    
    func getAllUpdatedContacts()->[Contact]?{
        
        let contactResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.contact.rawValue ,predicateFormat: "actionStatus == %@ || actionStatus == %@",predicateValue:actionStatus.create.rawValue,predicateValue2: actionStatus.edit.rawValue, isPredicate:true) as? [Contact]
        
        return contactResults
        
    }
    
   
    
    func getSalesforceClientId(iOSClientId:String)->String{
        
        var clientId:String = ""
        
        let contactRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.contact.rawValue,predicateFormat: "iOSContactId == %@" ,predicateValue: iOSClientId, isPredicate:true) as! [Contact]
        
        if(contactRes.count > 0){
            clientId = (contactRes.first?.contactId)!
        }
        
        return clientId
    }
    
    
}

extension ContactAPI{
    
    /// Get all the contacts of assignmentLocationUnit from core data.
    ///
    /// - Returns: array of contacts.
    
    //getIntakeContacts
    func getAllContactsOnUnit(assignmentLocUnitId:String)->[Contact]? {
        
        let contactRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.contact.rawValue,predicateFormat: "assignmentLocUnitId == %@",predicateValue:assignmentLocUnitId, isPredicate:true) as? [Contact]
        
        return contactRes
        
    }
    
//    func getIntakeContacts(assignmentLocUnitId:String)->[Contact]? {
//
//        let contactRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.contact.rawValue,predicateFormat: "assignmentLocUnitId == %@",predicateValue: assignmentLocUnitId, isPredicate:true) as? [Contact]
//
//        return contactRes
//    }
    
    
    func getContactName(contactId:String)-> String{
        
        let queryString = getQueryString(contactId: contactId)
        
        
        let contactRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.contact.rawValue,predicateFormat: queryString ,predicateValue: contactId,isPredicate:true) as! [Contact]
        
        if(contactRes.count > 0){
            return (contactRes.first?.contactName)!
        }
        else{
            return ""
            
        }
        
    }
    
    
    func getQueryString(contactId:String)->String{
        
        var queryString = ""
        let isiOSContactId = Utility.isiOSGeneratedId(generatedId: contactId)
        
        //if isiOSContactId is a UUID string
        if(isiOSContactId != nil){
            queryString = "iOSContactId == %@"
        }
        else{
            queryString = "contactId == %@"
        }
        
        return queryString
        
        
    }
    
    
    
}

