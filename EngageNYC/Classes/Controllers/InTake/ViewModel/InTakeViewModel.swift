//
//  InTakeViewModel.swift
//  EngageNYC
//
//  Created by Kamal on 27/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation

class InTakeViewModel{
    
    static func getViewModel()->InTakeViewModel{
        return InTakeViewModel()
    }
    
    func isTempCaseExist(assignmentLocUnitId:String)->Bool{
        return CaseAPI.shared.isTempCaseExist(assignmentLocUnitId: assignmentLocUnitId)
    }
    
    
    func isTempIssuesExist(assignmentId:String)->Bool{
        return IssueAPI.shared.isTempIssueExist(assignmentId: assignmentId)
    }
    
    func deleteAllTempRecords(){
        
        CaseAPI.shared.deleteCaseTempRecord()
        IssueAPI.shared.deleteIssueTempRecord()
    }
    
    func updateInTakeBinding(clientId:String,caseId:String,assignmentLocUnitId:String,assignmentId:String)->Bool{
        
        //if new temp case then by default bind all new temp issues
        //if no new temp case then give warning
        
        
        var isTempCase = false
        var tempCaseId = ""
        var isTempIssue = false
        var isTempRecordsExist = false
        
        if let tempCaseResults = CaseAPI.shared.getAllTempCasesOnAssigmentLocationUnit(assignmentLocUnitId: assignmentLocUnitId){
            if tempCaseResults.count >= 1{
                isTempCase = true
                tempCaseId = tempCaseResults[0].caseId!
            }
        }
        
        //Temp issues:- no temp case
        
        if let tempIssueResults = IssueAPI.shared.getAllTempIssuesOnAssignment(assignmentId: assignmentId){
            if tempIssueResults.count >= 1{
                isTempIssue = true
            }
        }
        
        
        //no tempcase and not selected any existing case to bind issues
        if(isTempCase == false && caseId.isEmpty){
            if(isTempIssue == true){
                isTempRecordsExist = true
            }
        }
        
        
        let isSave = clientId.isEmpty == true ? false : isTempRecordsExist == true ? false : true
        
        
        if(isSave){
            
            //mapping here
            
            if(isTempCase == true){
                
                CaseAPI.shared.updateAllTempCases(clientId: clientId, assignmentLocUnitId: assignmentLocUnitId)
               
            }
            if(isTempIssue == true){
                
                IssueAPI.shared.updateAllTempIssues(caseId: caseId, assignmentId: assignmentId, tempCaseId: tempCaseId)
            }
            
            return true
            
            
        }
        else{
            
            return false
            
            
        }
        
        
    }
    
    
}
