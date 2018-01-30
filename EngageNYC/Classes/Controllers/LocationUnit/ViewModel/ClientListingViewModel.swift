//
//  ClientListingViewModel.swift
//  
//
//  Created by Kamal on 14/01/18.
//

import Foundation

class ClientListingViewModel{
    
    static func getViewModel() -> ClientListingViewModel {
        return ClientListingViewModel()
    }
    
    
    func getClientListingHeader() -> [SortingHeaderCell]? {
        
        var header = [SortingHeaderCell]()
        
        header.append(SortingHeaderCell(withTitle: "First Name", headerSubTitle: "", headerArrowPostion: .up, allignment: .left))
        header.append(SortingHeaderCell(withTitle: "Last Name", headerSubTitle: "", headerArrowPostion: .none, allignment: .left))
        header.append(SortingHeaderCell(withTitle: "Unit", headerSubTitle: "", headerArrowPostion: .none, allignment: .left))
        header.append(SortingHeaderCell(withTitle: "Phone", headerSubTitle: "", headerArrowPostion: .none, allignment: .center))
        header.append(SortingHeaderCell(withTitle: "# of Cases", headerSubTitle: "", headerArrowPostion: .none, allignment: .center))
        header.append(SortingHeaderCell(withTitle: "Sync", headerSubTitle: "", headerArrowPostion: .none, allignment: .center))
        header.append(SortingHeaderCell(withTitle: "Sync Date", headerSubTitle: "", headerArrowPostion: .none, allignment: .left))
        return header
    }
    
   
    
    func loadInTakeClients(assignmentId:String,assignmentLocId:String,assignmentLocUnitId:String,unit:String)-> [ContactDO]{
        
        var arrContacts = [ContactDO]()
        
        //Count Case
        var caseDict:[String:String] = [:]
        
        if let cases = CaseAPI.shared.getAllCases(assignmentId: assignmentId,assignmentLocId: assignmentLocId){
            
            var countCases = 1
            for caseData in cases{
                
                if caseDict[caseData.clientId!] == nil{
                    countCases = 1
                    caseDict[caseData.clientId!] = String(countCases)
                }
                else{
                    let count = caseDict[caseData.clientId!]
                    caseDict[caseData.clientId!] = String(Int(count!)! + 1)
                }
            }
            
        }
        
        //Count Open Case
        var openCaseDict:[String:Int] = [:]
        
        if let openCases = CaseAPI.shared.getAllOpenCases(assignmentId: assignmentId,assignmentLocId: assignmentLocId){
            
            var countOpenCases = 1
            for openCaseData in openCases{
                
                if openCaseDict[openCaseData.clientId!] == nil{
                    countOpenCases = 1
                    openCaseDict[openCaseData.clientId!] = countOpenCases
                }
                else{
                    let count = openCaseDict[openCaseData.clientId!]
                    openCaseDict[openCaseData.clientId!] = Int(count!) + 1
                }
            }
            
        }
        
        
        if let contacts = ContactAPI.shared.getIntakeContacts(assignmentLocUnitId:assignmentLocUnitId){
            
            for contact:Contact in contacts{
                
                let objContact = ContactDO()
                
                objContact.unit = unit
                
                objContact.firstName = contact.firstName!
                objContact.lastName = contact.lastName!
                objContact.phone = contact.phone!
                objContact.contactName = contact.contactName!
                objContact.middleName = contact.middleName!
                objContact.suffix = contact.suffix!
                objContact.dob = contact.dob!
                objContact.contactId = contact.contactId!
                objContact.contactName = contact.contactName!
                
                objContact.streetNum = contact.streetNum!
                objContact.streetName = contact.streetName!
                objContact.borough = contact.borough!
                objContact.zip = contact.zip!
                objContact.aptNo = contact.unitName!
                objContact.floor = contact.floor!
                
                objContact.actionStatus = contact.actionStatus!
                
                objContact.assignmentLocUnitId = contact.assignmentLocUnitId
                objContact.locationUnitId = contact.locationUnitId
                objContact.assignmentId = contact.assignmentId
                objContact.assignmentLocId = contact.assignmentLocId
                objContact.syncDate = contact.syncDate!
                
                if caseDict[contact.contactId!] != nil{
                    let caseCount = caseDict[contact.contactId!]
                    objContact.totalCases = caseCount!
                }
                
                if openCaseDict[contact.contactId!] != nil{
                    let openCaseCount = openCaseDict[contact.contactId!]
                    objContact.openCases = openCaseCount!
                }
                
                objContact.createdById = contact.createdById
                
                arrContacts.append(objContact)
                
            }
            
            
        }
        
        return arrContacts
        
        
    }
    
    func loadContacts(assignmentId:String,assignmentLocId:String) -> [ContactDO]{
        
        var arrContacts = [ContactDO]()
        
        var unitDict:[String:String] = [:]
        
        if let locationUnits = LocationUnitAPI.shared.getAllLocationUnits(assignmentId: assignmentId,assignmentLocId: assignmentLocId){
            
            for locUnitData in locationUnits{
                
                if unitDict[locUnitData.locationUnitId!] == nil{
                    unitDict[locUnitData.locationUnitId!] = locUnitData.unitName!
                }
                
            }
            
        }
        
        
        //Count Case
        var caseDict:[String:String] = [:]
        
        if let cases = CaseAPI.shared.getAllCases(assignmentId: assignmentId,assignmentLocId: assignmentLocId){
            
            var countCases = 1
            for caseData in cases{
                
                if caseDict[caseData.clientId!] == nil{
                    countCases = 1
                    caseDict[caseData.clientId!] = String(countCases)
                }
                else{
                    let count = caseDict[caseData.clientId!]
                    caseDict[caseData.clientId!] = String(Int(count!)! + 1)
                }
            }
            
        }
        
        //Count Open Case
        var openCaseDict:[String:Int] = [:]
        
        if let openCases = CaseAPI.shared.getAllOpenCases(assignmentId: assignmentId,assignmentLocId: assignmentLocId){
            
            var countOpenCases = 1
            for openCaseData in openCases{
                
                if openCaseDict[openCaseData.clientId!] == nil{
                    countOpenCases = 1
                    openCaseDict[openCaseData.clientId!] = countOpenCases
                }
                else{
                    let count = openCaseDict[openCaseData.clientId!]
                    openCaseDict[openCaseData.clientId!] = Int(count!) + 1
                }
            }
            
        }
        
        
          if let contacts = ContactAPI.shared.getAllContacts(assignmentId: assignmentId,assignmentLocId: assignmentLocId){
            
            for contact:Contact in contacts{
                
                let objContact = ContactDO()
                
                if unitDict[contact.locationUnitId!] != nil{
                    objContact.unit = unitDict[contact.locationUnitId!]!
                }
                
         
                objContact.firstName = contact.firstName!
                objContact.lastName = contact.lastName!
                objContact.phone = contact.phone!
                objContact.contactName = contact.contactName!
                objContact.middleName = contact.middleName!
                objContact.suffix = contact.suffix!
                objContact.dob = contact.dob!
                objContact.contactId = contact.contactId!
                objContact.contactName = contact.contactName!
                
                objContact.streetNum = contact.streetNum!
                objContact.streetName = contact.streetName!
                objContact.borough = contact.borough!
                objContact.zip = contact.zip!
                objContact.aptNo = contact.unitName!
                objContact.floor = contact.floor!
                
                objContact.actionStatus = contact.actionStatus!
                
                
                objContact.assignmentLocUnitId = contact.assignmentLocUnitId
                objContact.locationUnitId = contact.locationUnitId
                objContact.assignmentId = contact.assignmentId
                objContact.assignmentLocId = contact.assignmentLocId
                objContact.syncDate = contact.syncDate!
                
                objContact.createdById = contact.createdById

                if caseDict[contact.contactId!] != nil{
                    let caseCount = caseDict[contact.contactId!]
                    objContact.totalCases = caseCount!
                }
                
                if openCaseDict[contact.contactId!] != nil{
                    let openCaseCount = openCaseDict[contact.contactId!]
                    objContact.openCases = openCaseCount!
                }
                
                arrContacts.append(objContact)
                
            }
            
            
        }
        
        return arrContacts
        
    }
    
}
