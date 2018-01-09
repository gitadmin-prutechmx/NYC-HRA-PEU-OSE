//
//  EventsRegViewModel.swift
//  EngageNYCDev
//
//  Created by Kamal on 09/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation

class EventsRegViewModel{
    
    static func getViewModel() -> EventsRegViewModel {
        return EventsRegViewModel()
    }
    
    func loadEventsReg(objEvent:EventDO) -> [EventRegDO]{
        var arrEventsReg = [EventRegDO]()
        
        if let eventsReg = EventsAPI.shared.getAllEventsReg(eventId:objEvent.id){
                for eventReg:EventsReg in eventsReg{
                    let objEventReg = EventRegDO()
        
                    objEventReg.id = eventReg.eventRegId ?? ""
                    objEventReg.clientName = eventReg.clientName ?? ""
                    objEventReg.regDate = eventReg.regDate ?? ""
        
                    arrEventsReg.append(objEventReg)
                }
            }
        return arrEventsReg
    }
    
}
