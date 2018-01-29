//
//  IssueViewModel.swift
//  EngageNYC
//
//  Created by Kamal on 24/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation

class IssueViewModel{
    
    static func getViewModel()->IssueViewModel{
        return IssueViewModel()
    }
    
    func loadIssueNotes(issueId:String,assignmentId:String)->[IssueNoteDO]{
        
        var arrIssueNotes = [IssueNoteDO]()
        
        if let issueNotesRes = IssueAPI.shared.getAllIssuesNotesOnIssue(issueId: issueId, assignmentId: assignmentId){
            
            for issueNote in issueNotesRes{
                let issueNoteObj = IssueNoteDO()
                issueNoteObj.issueId = issueNote.issueId
                issueNoteObj.issueNotes = issueNote.notes
                issueNoteObj.createdDate = issueNote.createdDate
                
                arrIssueNotes.append(issueNoteObj)
            }
        }
        return arrIssueNotes
    }
    
    
    
    
    func loadIssues(caseId: String, assignmentId: String,contactName:String)->[IssueDO]{
        
        var arrIssues = [IssueDO]()
        
        if let issuesVal = IssueAPI.shared.getAllIssuesOnCase(caseId: caseId, assignmentId: assignmentId){
            for issueData:Issues in issuesVal{
                
                let objIssue = IssueDO()
                objIssue.issueId = issueData.issueId
                objIssue.issueNo = issueData.issueNo
                objIssue.issueType = issueData.issueType
                objIssue.contactName = contactName
                objIssue.notes = issueData.notes
                objIssue.dbActionStatus = issueData.actionStatus
                objIssue.assignmentId = issueData.assignmentId
                //objIssue
                
                arrIssues.append(objIssue)
                
            }
        }
        
        
        arrIssues = loadTempIssues(assignmentId: assignmentId,arrIssues:arrIssues)
        
        
        return arrIssues
        
    }
    
   
    
    func loadTempIssues(assignmentId:String,arrIssues:[IssueDO])->[IssueDO]{
        
        var arrTempIssues = arrIssues
        
        if let tempIssues = IssueAPI.shared.getAllTempIssuesOnAssignment(assignmentId: assignmentId){
            
            for tempIssueData:Issues in tempIssues{
                
                let objTempIssue = IssueDO()
                
                objTempIssue.issueId = tempIssueData.issueId
                objTempIssue.issueNo = tempIssueData.issueNo
                objTempIssue.issueType = tempIssueData.issueType
                objTempIssue.contactName = ""
                objTempIssue.notes = tempIssueData.notes
                objTempIssue.dbActionStatus = tempIssueData.actionStatus
                
                arrTempIssues.append(objTempIssue)
                
            }
            
        }
        
        return arrTempIssues
    }
    
    
    
    
    func getIssueTypePicklist(objectType:String,fieldName:String)->[DropDownDO]{
        
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
    
    func SaveIssueInCoreData(objIssue:IssueDO){     
        IssueAPI.shared.saveIssue(objIssue: objIssue)
        
    }
    
    func UpdateIssueInCoreData(objIssue:IssueDO){
         IssueAPI.shared.updateIssue(objIssue: objIssue)
    }
    
    
    
}
