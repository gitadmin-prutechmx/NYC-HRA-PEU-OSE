//
//  EventsAPI.swift
//  EngageNYCDev
//
//  Created by Kamal on 09/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation
import SalesforceSDKCore

enum MetadataConfigEnum:String{
    case cases = "cases"
    case events = "events"
}

enum coreDataEntity:String{
    
    case events = "Events"
    case eventsReg = "EventsReg"
   
    case assignment = "Assignment"
    case location = "Location"
    case assignmentLocation = "AssignmentLocation"
    case locationUnit = "LocationUnit"
    case assignmentLocationUnit = "AssignmentLocationUnit"
    case contact = "Contact"
    
    case cases = "Cases"
    case issues = "Issues"
    case issueNotes = "IssueNotes"
    case caseNotes = "CaseNotes"
    
    case surveyQuestion = "SurveyQuestion"
    case surveyResponse = "SurveyResponse"

    case chart = "Chart"
 
    case metadataConfig = "MetadataConfig"
    
    case userInfo = "UserInfo"
    
    case settings = "Setting"
    
    case dropDown = "DropDown"
    
    case assignmentnotes = "AssignmentNotes"
    
}

final class EventsAPI : SFCommonAPI
{
    
    private static var sharedInstance: EventsAPI = {
        let instance = EventsAPI()
        return instance
    }()
    
    class var shared:EventsAPI!{
        get{
            return sharedInstance
        }
    }
    
    /// Get All Events from rest api. We are saving these Events to core data for offline use.
    ///
    /// - Parameters:
    ///   - callback: callback block.
    ///   - failure: failure block.
    //func syncDownWithCompletion(completion: @escaping (()->()), failure: @escaping ((String)->()))
    func syncDownWithCompletion(completion: @escaping (()->()))
    {
        
        let req = SFRestRequest(method: .GET, path: SalesforceRestApiUrl.events, queryParams: nil)
        req.endpoint = ""
        self.sendRequest(request: req, callback: { (response) in
            self.EventsFromJSONList(jsonResponse: response)
            completion()
        }) { (error) in
            Logger.shared.log(level: .error, msg: error)
            Utility.displayErrorMessage(errorMsg: error)
            print(error)
            //failure(error)
        }
    }
    
    func getAllUpdatedEventsReg() -> [EventsReg]?{
        
        let eventsRegRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.eventsReg.rawValue ,predicateFormat: "actionStatus == %@",predicateValue:actionStatus.create.rawValue, isPredicate:true) as? [EventsReg]
        
        return eventsRegRes
    }
    
    func updateClientId(salesforceClientId:String,iOSClientId:String){
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["clientId"] = salesforceClientId as AnyObject
        
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.eventsReg.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "clientId == %@", predicateValue:  iOSClientId,isPredicate: true)
        
    }
    
        
    
    func syncUpCompletion(completion: @escaping (()->()))
    {
        if let arrEventsReg = getAllUpdatedEventsReg(){
            
            let eventRegGroup = DispatchGroup()
            
            for eventReg in arrEventsReg{
                
                var eventRegDict:[String:String] = [:]
                var eventRegParams:[String:String] = [:]
                
                var sfdcClientId = eventReg.clientId
                
                    let isiOSClientId = Utility.isiOSGeneratedId(generatedId: sfdcClientId!)
                    
                    //if isiOSClientId is a UUID string then get salesforce clientid from contact object
                    if(isiOSClientId != nil){
                        let clientId = ContactAPI.shared.getSalesforceClientId(iOSClientId: sfdcClientId!)
                        
                         sfdcClientId = clientId //update contact id here
                        
                        if(Utility.isiOSGeneratedId(generatedId: clientId) != nil){
                            print("Error:- iOS clientId")
                            return
                        }
                        else{
                            //update ClientId here
                            
                            //updateClientId(salesforceClientId: clientId, iOSClientId: eventReg.clientId!)
                        }
                    }
                
                if(eventReg.actionStatus == actionStatus.edit.rawValue){
                     eventRegDict["EventRegId"] = eventReg.eventRegId
                     eventRegDict["iOSEventRegId"] = eventReg.iOSEventRegId
                    
                }
                else{
                     eventRegDict["iOSEventRegId"] = eventReg.iOSEventRegId
                }
                
            
            
                eventRegDict["AttendeeStatus"] = eventReg.attendeeStatus
                eventRegDict["contactId"] = sfdcClientId
                eventRegDict["eventId"] = eventReg.eventId
            
                eventRegParams["eventReg"] = Utility.jsonToString(json: eventRegDict as AnyObject)!
                
                let req = SFRestRequest(method: .POST, path: SalesforceRestApiUrl.createNewEventReg, queryParams: nil)
                
                do {
                    
                    let bodyData = try JSONSerialization.data(withJSONObject: eventRegParams, options: [])
                    req.setCustomRequestBodyData(bodyData, contentType: "application/json")
                }
                catch{
                    
                    
                }
                
                req.endpoint = ""
                
                eventRegGroup.enter()
                
                self.sendRequest(request: req, callback: { (response) in
                    
                    DispatchQueue.main.async {
                        
                        self.parseEventRegResponse(jsonObject: response as! Dictionary<String, AnyObject>)
                        
                        eventRegGroup.leave()
                        
                        print("EventRegGroup: \(eventReg.attendeeStatus!)")
                    }
                    
                    
                    
                }) { (error) in
                    Logger.shared.log(level: .error, msg: error)
                    Utility.displayErrorMessage(errorMsg: error)
                    //failure(error)
                }
                
            }
            
            eventRegGroup.notify(queue: .main) {
                completion()
            }
        }
        
        else{
            completion()
        }
        
        
    }
    
    
    func parseEventRegResponse(jsonObject: Dictionary<String, AnyObject>){
        
        guard let isError = jsonObject["hasError"] as? Bool,
            
            let message = jsonObject["message"] as? String,
            
            let eventRegDataDictonary = jsonObject["EventRegDataInfo"] as? [String: AnyObject] else { return }
        
        
        
        
        if(isError == false){
            
            updateEventRegId(eventRegDataDict: eventRegDataDictonary)
        }
        else{
            let errorMsg = "Error while adding new event reg to salesforce.\(message)"
            
            Logger.shared.log(level: .error, msg: errorMsg)
            Utility.displayErrorMessage(errorMsg: errorMsg)
        
        }
        
        
        
     
        
        
    }
    
    func updateEventRegId(eventRegDataDict:[String:AnyObject]){
        
        let eventRegId = eventRegDataDict["EventRegId"] as? String
        let iOSEventRegId = eventRegDataDict["iOSEventRegId"] as? String
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["actionStatus"] = "" as AnyObject
        updateObjectDic["eventRegId"] = eventRegId as AnyObject
        
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.eventsReg.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "iOSEventRegId == %@", predicateValue:  iOSEventRegId,isPredicate: true)
        
        
    }
    
    
    
    
    
    func saveEventReg(newEventRegObj:NewEventRegDO){
    
        let newEventReg = EventsReg(context:context)
        newEventReg.eventId = newEventRegObj.objEvent.id
        newEventReg.clientId = newEventRegObj.clientId
        newEventReg.clientName = newEventRegObj.clientName
        newEventReg.attendeeStatus = newEventRegObj.attendeeStatusName
        newEventReg.iOSEventRegId = UUID().uuidString
        newEventReg.eventRegId = UUID().uuidString
        
        newEventReg.regDate  = Utility.currentDateAndTime()
        newEventReg.actionStatus = actionStatus.create.rawValue
        
        appDelegate.saveContext()
    
    }
    
    func IsClientExistForthatEvent(clientId:String,eventId:String)->Bool{
        let eventRegResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.eventsReg.rawValue ,predicateFormat: "clientId == %@ && eventId == %@",predicateValue: clientId,predicateValue2: eventId, isPredicate:true) as! [EventsReg]
        
        if(eventRegResults.count > 0){
            return true
        }
        
        return false
    }
    
    /// Get all the events from core data.
    ///
    /// - Returns: array of events.
    func getAllEvents()->[Events]? {
        
        let eventResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.events.rawValue ,isPredicate:false) as? [Events]
        
        return eventResults
    }
    
    /// Get all the events registration from core data.
    ///
    /// - Returns: array of events registration.
    func getAllEventsReg(eventId:String)->[EventsReg]? {
        
        let eventRegResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.eventsReg.rawValue ,predicateFormat: "eventId == %@",predicateValue: eventId, isPredicate:true) as? [EventsReg]
        
        return eventRegResults
    }
    
    /// Convert the provided JSON into array of Events objects.
    ///
    /// - Parameter jsonResponse: json fetched from api.
    /// - Returns: nothing.
    private func EventsFromJSONList(jsonResponse:Any){
        
        //First Delete all event records from Core data then insert
        
        ManageCoreData.DeleteAllRecords(salesforceEntityName: coreDataEntity.events.rawValue,completion: { isSuccess in
            
            ManageCoreData.DeleteAllRecords(salesforceEntityName: coreDataEntity.eventsReg.rawValue,completion: { isSuccess in
                
                if(isSuccess){
                    
                    guard let jsonArray = (jsonResponse as? NSDictionary)?.value(forKey: "eventInfo") as? NSArray else { return }
                    
                    for responseObject in jsonArray{
                        if let json = responseObject as? NSDictionary{
                            EventsAPI.fromJSONObject(jsonObject: json)
                        }
                    }
                }
            })
            
        })
    }
    
    
}

extension EventsAPI{
    
    /// Convert JSON into a Events object.
    ///
    /// - Parameter jsonObject: fetched JSON from api.
    /// - Returns: Nothing.
    class func fromJSONObject(jsonObject:NSDictionary){
        
        if let events = jsonObject.value(forKey: "event") as? NSDictionary{
            let eventObject = Events(context: context)
            
            eventObject.id = events.value(forKey: "Id") as? String
            eventObject.name = events.value(forKey: "Event_Name__c") as? String
            eventObject.date = events.value(forKey: "Event_Date__c") as? String
            eventObject.endTime = events.value(forKey: "End_Time__c") as? String
            eventObject.startTime = events.value(forKey: "Start_Time__c") as? String
            eventObject.state = events.value(forKey: "Event_State__c") as? String
            eventObject.streetName = events.value(forKey: "Event_Street__c") as? String
            eventObject.streetNum = events.value(forKey: "Street_Number__c") as? String
            eventObject.zip = events.value(forKey: "Event_Zip__c") as? String
            eventObject.type = events.value(forKey: "Event_Type__c") as? String
            eventObject.borough = events.value(forKey: "Event_Borough__c") as? String
            eventObject.city = events.value(forKey: "Event_City__c") as? String
            eventObject.eventsDynamic = events as NSObject
            
            if let eventStaffLeadResult = (events as AnyObject).value(forKey: "Event_Staff_Lead__r") as? NSDictionary {
                eventObject.eventStaffLeadId = eventStaffLeadResult.value(forKey: "Id") as? String ?? ""
                eventObject.eventStaffLeadName = eventStaffLeadResult.value(forKey: "Name") as? String ?? ""
            }
            
            appDelegate.saveContext()
        }
        
        
        guard let eventsRegistraionArray = jsonObject.value(forKey: "eventRegister") as? NSArray else { return }
        
        for eventRegResponseObject in eventsRegistraionArray{
            let eventRegObject = EventsReg(context:context)
            eventRegObject.eventRegId = (eventRegResponseObject as AnyObject).value(forKey: "eventRegId") as? String
            eventRegObject.eventId = (eventRegResponseObject as AnyObject).value(forKey: "eventId") as? String
            eventRegObject.clientId = (eventRegResponseObject as AnyObject).value(forKey: "clientId") as? String
            eventRegObject.clientName = (eventRegResponseObject as AnyObject).value(forKey: "clientName") as? String
            eventRegObject.regDate = (eventRegResponseObject as AnyObject).value(forKey: "createdDate") as? String
            eventRegObject.attendeeStatus = (eventRegResponseObject as AnyObject).value(forKey: "attendeeStatus") as? String

            appDelegate.saveContext()
        }
        
        
        
        
        
    }
    
    
}


