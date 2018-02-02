//
//  EventsViewModel.swift
//  EngageNYCDev
//
//  Created by Kamal on 09/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation

class EventsViewModel{
    
    static func getViewModel() -> EventsViewModel {
        return EventsViewModel()
    }
    
        func loadEvents() -> [EventDO]{
            var arrEvents = [EventDO]()
    
            if let events = EventsAPI.shared.getAllEvents(){
                for event:Events in events{
                    let objEvent = EventDO()
        
                    objEvent.id = event.id ?? ""
                    objEvent.name = event.name ?? ""
                    objEvent.type = event.type ?? ""
                    objEvent.date = event.date ?? ""
                    objEvent.startTime = event.startTime ?? ""
                    objEvent.endTime = event.endTime ?? ""
                    objEvent.address = Utility.getEventFormattedAddress(eventObj:event)
                    objEvent.eventsDynamic = event.eventsDynamic!
                    objEvent.eventStaffLeadId = event.eventStaffLeadId
                    objEvent.eventStaffLeadName = event.eventStaffLeadName
                    
                    
                    arrEvents.append(objEvent)
                }
            }
            return arrEvents
        }
    
    
   
    
    
    func getEventsTypeicklist(objectType:String,fieldName:String)->[ListingPopOverDO]{
        
       var arrPickList = [ListingPopOverDO]()
        
        if let picklist =  PicklistAPI.shared.getPicklist(objectType: objectType, fieldName: fieldName){
            let arr = String(picklist.value!.dropLast()).components(separatedBy: ";")
            for val in arr{
                
                let listingPopOverObj = ListingPopOverDO()
                listingPopOverObj.id = val
                listingPopOverObj.name = val
                listingPopOverObj.additionalId = val
                
                arrPickList.append(listingPopOverObj)
                
            }
        }
        
        return arrPickList
        
    }
    
}

