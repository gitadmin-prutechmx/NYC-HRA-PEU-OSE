//
//  UnitListingViewModel.swift
//  EngageNYC
//
//  Created by Kamal on 14/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation

class UnitListingViewModel{
    
    static func getViewModel() -> UnitListingViewModel {
        return UnitListingViewModel()
    }
    
    func getUnitListingHeader() -> [SortingHeaderCell]? {
        
        var header = [SortingHeaderCell]()
        
        header.append(SortingHeaderCell(withTitle: "Unit", headerSubTitle: "", headerArrowPostion: .up, allignment: .left))
        header.append(SortingHeaderCell(withTitle: "Attempt", headerSubTitle: "", headerArrowPostion: .none, allignment: .left))
        header.append(SortingHeaderCell(withTitle: "Contact", headerSubTitle: "", headerArrowPostion: .none, allignment: .left))
        header.append(SortingHeaderCell(withTitle: "Survey", headerSubTitle: "", headerArrowPostion: .none, allignment: .center))
        header.append(SortingHeaderCell(withTitle: "# of Clients", headerSubTitle: "", headerArrowPostion: .none, allignment: .center))
        header.append(SortingHeaderCell(withTitle: "Sync", headerSubTitle: "", headerArrowPostion: .none, allignment: .center))
        header.append(SortingHeaderCell(withTitle: "Sync Date", headerSubTitle: "", headerArrowPostion: .none, allignment: .center))
        return header
    }
    
    
    
    func loadUnits(assignmentId:String,assignmentLocId:String) -> [LocationUnitDO]{
        
        var arrLocationUnits = [LocationUnitDO]()
        
        let assignmentLocUnitsDict = AssignmentLocationUnitAPI.shared.getAllAssignmentLocationUnits(assignmentId: assignmentId)
        
        
        let surveyResDict = SurveyAPI.shared.getAllSurveyResponses(assignmentId: assignmentId)
        
       
        var contactDict:[String:String] = [:]
        
        if let contacts = ContactAPI.shared.getAllContacts(assignmentId: assignmentId,assignmentLocId: assignmentLocId){

                var countContacts = 1
                for contactData in contacts{
                    
                    if contactDict[contactData.locationUnitId!] == nil{
                        countContacts = 1
                        contactDict[contactData.locationUnitId!] = String(countContacts)
                    }
                    else{
                        let count = contactDict[contactData.locationUnitId!]
                        contactDict[contactData.locationUnitId!] = String(Int(count!)! + 1)
                    }
                }
            
        }
        
        
        
        
        
        if let locationUnits = LocationUnitAPI.shared.getAllLocationUnits(assignmentId: assignmentId,assignmentLocId: assignmentLocId){
            for locationUnit:LocationUnit in locationUnits{
                
                let objLocationUnit = LocationUnitDO()
                objLocationUnit.unitName = locationUnit.unitName
                objLocationUnit.locationUnitId = locationUnit.locationUnitId
                objLocationUnit.assignmentLocUnitId = locationUnit.iOSAssignmentLocUnitId
                objLocationUnit.syncDate = locationUnit.syncDate!
                
                
                if assignmentLocUnitsDict[locationUnit.assignmentLocUnitId!] != nil{
                    
                    let assignmentLocUnitObj = assignmentLocUnitsDict[locationUnit.assignmentLocUnitId!]
                    
                    objLocationUnit.attempted = (assignmentLocUnitObj?.attempted)!
                    objLocationUnit.contacted = (assignmentLocUnitObj?.contacted)!
                    objLocationUnit.surveySyncDate = (assignmentLocUnitObj?.surveySyncDate)!
                    
                }
                
                if contactDict[locationUnit.locationUnitId!] != nil{
                    
                    let contactCount = contactDict[locationUnit.locationUnitId!]
                    objLocationUnit.totalContacts = contactCount!
                }
                
                if surveyResDict[locationUnit.assignmentLocUnitId!] != nil{
                    
                    objLocationUnit.surveyStatus = surveyResDict[locationUnit.assignmentLocUnitId!]!
                }
                
                
                arrLocationUnits.append(objLocationUnit)
                
            }
        }
        return arrLocationUnits
        
    }
    
}

