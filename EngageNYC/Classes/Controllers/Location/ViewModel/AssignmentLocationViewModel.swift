//
//  AssignmentLocationViewModel.swift
//  EngageNYC
//
//  Created by Kamal on 15/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation

class AssignmentLocationViewModel{
    
    static func getViewModel() -> AssignmentLocationViewModel {
        return AssignmentLocationViewModel()
    }
    
    
    func getAssignmentLocation(assignmentLocId:String)-> AssignmentLocationInfoDO?{
        
        var assignmentLocationInfoObj:AssignmentLocationInfoDO?
        
        if let assignmentLoc = AssignmentLocationAPI.shared.getAssignmentLocation(assignmentLocId: assignmentLocId){
            
            assignmentLocationInfoObj =  AssignmentLocationInfoDO(assignmentLocUnitId: assignmentLoc.assignmentLocId!, attempted: assignmentLoc.attempt!, locStatus:  assignmentLoc.locStatus!, totalUnits: assignmentLoc.totalUnits!, notes: assignmentLoc.notes!)
            
//            assignmentLocationInfoObj.assignmentLocationId = assignmentLoc.assignmentLocId
//
//            assignmentLocationInfoObj.attempted = assignmentLoc.attempt
//            assignmentLocationInfoObj.locStatus = assignmentLoc.locStatus
//            assignmentLocationInfoObj.notes = assignmentLoc.notes
//
//            assignmentLocationInfoObj.totalUnits = assignmentLoc.totalUnits
            
        }
        
        return assignmentLocationInfoObj
    }
    
    func getLocationStatusPicklist(objectType:String,fieldName:String)->[DropDownDO]{
        
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
    
    
    func getAssignmentLocationNotes(assignmentLocId:String)->[AssignmentLocationNotesDO]{
    
        
        var arrAssignmentLocNotes = [AssignmentLocationNotesDO]()
   
        if let assignmentLocNotes = AssignmentNotesAPI.shared.getAssignmentLocationNotes(assignmentLocId: assignmentLocId){
            
             for assignmentLocNote:AssignmentNotes in assignmentLocNotes{
              let objAssignmentLocationNote = AssignmentLocationNotesDO()
                objAssignmentLocationNote.assignmentLocId = assignmentLocNote.assignmentLocId
                objAssignmentLocationNote.locStatus = assignmentLocNote.locStatus
                objAssignmentLocationNote.notes = assignmentLocNote.notes
                objAssignmentLocationNote.createdDate = assignmentLocNote.createdDate
                objAssignmentLocationNote.canvasserName = assignmentLocNote.canvasserName
                objAssignmentLocationNote.canvasserId = assignmentLocNote.canvasserId
                
                arrAssignmentLocNotes.append(objAssignmentLocationNote)
                
            }
        }
        return arrAssignmentLocNotes
        
        
    }
    
    
    func updateAssignmentLocation(assignmentLocationInfoObj:AssignmentLocationInfoDO){
        AssignmentLocationAPI.shared.updateAssignmentLocation(assignmentLocInfoObj: assignmentLocationInfoObj)
    }
    
}
