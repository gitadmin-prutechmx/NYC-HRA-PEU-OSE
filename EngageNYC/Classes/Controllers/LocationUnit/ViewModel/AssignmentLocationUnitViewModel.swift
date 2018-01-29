//
//  AssignmentLocUnitInfoViewModel.swift
//  EngageNYC
//
//  Created by Kamal on 17/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation


class AssignmentLocationUnitViewModel{
    
    static func getViewModel() -> AssignmentLocationUnitViewModel {
        return AssignmentLocationUnitViewModel()
    }
    
    func getAssignmentLocationUnitNotes(assignmentLocUnitId:String)->[AssignmentLocationUnitNotesDO]{
        
        
        var arrAssignmentLocUnitNotes = [AssignmentLocationUnitNotesDO]()
        
        if let assignmentLocUnitNotes = AssignmentNotesAPI.shared.getAssignmentLocationUnitNotes(assignmentLocUnitId: assignmentLocUnitId){
            
            for assignmentLocUnitNote:AssignmentNotes in assignmentLocUnitNotes{
                let objAssignmentLocationUnitNote = AssignmentLocationUnitNotesDO()
                objAssignmentLocationUnitNote.assignmentLocUnitId = assignmentLocUnitNote.assignmentLocUnitId
                objAssignmentLocationUnitNote.unitOutcome = assignmentLocUnitNote.unitOutcome
                objAssignmentLocationUnitNote.notes = assignmentLocUnitNote.notes
                objAssignmentLocationUnitNote.createdDate = assignmentLocUnitNote.createdDate
                objAssignmentLocationUnitNote.canvasserName = assignmentLocUnitNote.canvasserName
                objAssignmentLocationUnitNote.canvasserId = assignmentLocUnitNote.canvasserId
                
                arrAssignmentLocUnitNotes.append(objAssignmentLocationUnitNote)
                
            }
        }
        return arrAssignmentLocUnitNotes
        
        
    }
    
    
    func getAssignmentLocationUnit(assignmentLocUnitId:String)-> AssignmentLocationUnitInfoDO?{
        
 
      
        if let assignmentLocUnit = AssignmentLocationUnitAPI.shared.getAssignmentLocationUnit(assignmentLocUnitId: assignmentLocUnitId){
            
            
       
           
            if(assignmentLocUnit.attempted?.isEmpty)!{
                assignmentLocUnit.attempted = boolVal.no.rawValue
            }
          
            
            if(assignmentLocUnit.contacted?.isEmpty)!{
                assignmentLocUnit.contacted = boolVal.no.rawValue
            }
            
            
            if(assignmentLocUnit.surveyed?.isEmpty)!{
                assignmentLocUnit.surveyed = boolVal.no.rawValue
            }
            
            
            let assignmentLocationUnitInfoObj =  AssignmentLocationUnitInfoDO(assignmentLocationUnitId: assignmentLocUnit.assignmentLocUnitId!, attempted: assignmentLocUnit.attempted!, contacted: assignmentLocUnit.contacted!, contactOutcome: assignmentLocUnit.contactOutcome!, surveyed: assignmentLocUnit.surveyed!, contactId: assignmentLocUnit.contactId!, followUpDate: assignmentLocUnit.followUpDate!, followUpType: assignmentLocUnit.followUpType!, notes: assignmentLocUnit.notes!)
            
            
            return assignmentLocationUnitInfoObj
        }
        
        return nil
    }
    

    
    func getAssignmentLocUnitPicklist(objectType:String,fieldName:String)->[DropDownDO]{
        
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
    
    func getContactsOnUnit(assignmentLocUnitId:String)->[DropDownDO]{
        
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
    
    func updateAssignmentLocationUnit(assignmentLocationUnitInfoObj:AssignmentLocationUnitInfoDO,assignmentId:String){
        
        if(Utility.isiOSGeneratedId(generatedId: assignmentLocationUnitInfoObj.assignmentLocationUnitId) != nil){
            AssignmentLocationUnitAPI.shared.createNewAssignmentLocationUnit(assignmentLocUnitInfo: assignmentLocationUnitInfoObj,assignmentId:assignmentId)
        }
        else{
            AssignmentLocationUnitAPI.shared.updateAssignmentLocationUnit(assignmentLocUnitInfo: assignmentLocationUnitInfoObj)
        }
        
      
    }
    
    func getContactName(contactId:String)-> String{
         return ContactAPI.shared.getContactName(contactId: contactId)
    }
    
   
    
}



