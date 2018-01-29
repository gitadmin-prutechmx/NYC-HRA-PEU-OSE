//
//  NewEventRegViewModel.swift
//  EngageNYC
//
//  Created by Kamal on 23/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation

class NewEventRegViewModel{
    
    static func getViewModel() -> NewEventRegViewModel {
        return NewEventRegViewModel()
    }
    
    func saveEventReg(newEventRegObj:NewEventRegDO)->Bool{
        if(EventsAPI.shared.IsClientExistForthatEvent(clientId: newEventRegObj.clientId, eventId: newEventRegObj.objEvent.id)){
            return false
        }
        else{
            EventsAPI.shared.saveEventReg(newEventRegObj: newEventRegObj)
            return true
        }
    }
    
    func getContactsOnEvents(assignmentLocUnitId:String)->[DropDownDO]{
        
        var pickListArr:[DropDownDO] = []
        
        if let contacts =  ContactAPI.shared.getAllContactsOnUnit(assignmentLocUnitId: assignmentLocUnitId){
            for contact in contacts{
                
                let objDropDown = DropDownDO()
                objDropDown.id = contact.contactId
                objDropDown.name = contact.contactName
                
                pickListArr.append(objDropDown)
                
            }
        }
        
        return pickListArr
        
    }
    
    func getAttendeeStatus(objectType:String,fieldName:String)->[DropDownDO]{
        
        var pickListArr:[DropDownDO] = []
        
        if let picklist =  PicklistAPI.shared.getPicklist(objectType: objectType, fieldName: fieldName){
            let arr = String(picklist.value!.dropLast()).components(separatedBy: ";")
            for val in arr{
                
                let objDropDown = DropDownDO()
                objDropDown.id = val
                objDropDown.name = val
                
                pickListArr.append(objDropDown)
                
            }
        }
        
        return pickListArr
        
    }
    
}
