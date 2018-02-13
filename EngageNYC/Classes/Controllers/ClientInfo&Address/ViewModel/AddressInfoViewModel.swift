//
//  AddressInfoViewModel.swift
//  EngageNYC
//
//  Created by Kamal on 15/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation

class AddressInfoViewModel{
    
    static func getViewModel() -> AddressInfoViewModel {
        return AddressInfoViewModel()
    }
    
    func getAllLocationUnitsWithoutVirtualUnit(assignmentId:String,assignmentLocId:String) -> [ListingPopOverDO]{
        var arrLocationUnits = [ListingPopOverDO]()
       
        
        if let locationUnits = LocationUnitAPI.shared.getAllLocationUnitsWithoutVirtualUnit(assignmentId: assignmentId, assignmentLocId: assignmentLocId){
            
            for locationUnitData in locationUnits{
                let listingPopOverObj = ListingPopOverDO()
                listingPopOverObj.id = locationUnitData.locationUnitId
                listingPopOverObj.iOSId = locationUnitData.iOSLoctionUnitId
                listingPopOverObj.name = locationUnitData.unitName
                listingPopOverObj.additionalId = locationUnitData.assignmentLocUnitId
               
                
                arrLocationUnits.append(listingPopOverObj)
            }
            
        }
        
        let unknownListingPopOverObj = ListingPopOverDO()
        unknownListingPopOverObj.id = virtualUnitName.unknown.rawValue
        unknownListingPopOverObj.name = virtualUnitName.unknown.rawValue
        unknownListingPopOverObj.additionalId = virtualUnitName.unknown.rawValue
        
        arrLocationUnits.insert(unknownListingPopOverObj, at: 0)
        
        return arrLocationUnits
        
    }
    
    func getBoroughPicklist(objectType:String,fieldName:String)->[String]{
        
        var arrBorough = [String]()
        if let picklist =  PicklistAPI.shared.getPicklist(objectType: objectType, fieldName: fieldName){
            let boroughStr = picklist.value!
            arrBorough = String(boroughStr.dropLast()).components(separatedBy: ";")
        }
        
        return arrBorough
        
    }
    
    func saveNewUnit(objNewUnitDO:NewUnitDO){
        LocationUnitAPI.shared.saveNewUnit(objNewUnit: objNewUnitDO)
    }
    
    func saveNewContact(objNewContactDO:NewContactDO,isSameUnit:Bool){
        ContactAPI.shared.saveNewContact(objNewContact:objNewContactDO,isSameUnit:isSameUnit)
    }
    
    func updateContact(objContactDO:ContactDO){
        ContactAPI.shared.updateContact(objContact:objContactDO)
    }
    
    
    func createVirtualUnit(unitName:String,canvasserTaskDataObject:CanvasserTaskDataObject)->(locUnitId: String, assignmentLocUnitId: String){
        
        let genLocUnitId = UUID().uuidString
        let genAssignmentLocUnitId = UUID().uuidString
        
        let objNewUnit = NewUnitDO()
        objNewUnit.assignmentId = canvasserTaskDataObject.assignmentObj.assignmentId
        objNewUnit.locationId = canvasserTaskDataObject.locationObj.objMapLocation.locId
        objNewUnit.assignmentLocId = canvasserTaskDataObject.locationObj.objMapLocation.assignmentLocId
        
        objNewUnit.unitName = unitName
        objNewUnit.unitNotes = ""
        objNewUnit.isVirtualUnit = virtualUnitEnum.VUTrue.rawValue
        objNewUnit.isPrivateHome = privateHomeEnum.no.rawValue
        objNewUnit.actionStatus = actionStatus.create.rawValue
        
        objNewUnit.syncDate = ""
        
        objNewUnit.iOSLocUnitId = genLocUnitId
        objNewUnit.iOSAssignmentLocUnitId = genAssignmentLocUnitId
        
        saveNewUnit(objNewUnitDO: objNewUnit)
        
        return (genLocUnitId, genAssignmentLocUnitId)
       // return genLocUnitId
        
    }
    
}
