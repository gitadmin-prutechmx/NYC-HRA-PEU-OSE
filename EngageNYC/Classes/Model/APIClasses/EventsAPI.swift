//
//  EventsAPI.swift
//  EngageNYCDev
//
//  Created by Kamal on 09/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation
import SalesforceSDKCore

enum coreDataEntity:String{
    case events = "Events"
    case eventsReg = "EventsReg"
    case metadataConfig = "MetadataConfig"
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
            print(error)
            //failure(error)
        }
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
            
            appDelegate.saveContext()
        }
        
        
        guard let eventsRegistraionArray = jsonObject.value(forKey: "eventRegister") as? NSArray else { return }
        
        for eventRegResponseObject in eventsRegistraionArray{
            let eventRegObject = EventsReg(context:context)
            eventRegObject.eventRegId = (eventRegResponseObject as AnyObject).value(forKey: "eventRegId") as? String
            eventRegObject.eventId = (eventRegResponseObject as AnyObject).value(forKey: "eventId") as? String
            eventRegObject.clientName = (eventRegResponseObject as AnyObject).value(forKey: "clientName") as? String
            eventRegObject.regDate = (eventRegResponseObject as AnyObject).value(forKey: "createdDate") as? String

            appDelegate.saveContext()
        }
        
        
        
        
        
    }
    
    
}


