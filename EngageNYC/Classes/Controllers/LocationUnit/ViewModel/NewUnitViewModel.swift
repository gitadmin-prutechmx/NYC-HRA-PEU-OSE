//
//  NewUnitViewModel.swift
//  EngageNYCDev
//
//  Created by Kamal on 11/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation

class NewUnitViewModel{
    
    static func getViewModel() -> NewUnitViewModel {
        return NewUnitViewModel()
    }
    
    func getAllLocationUnits(assignmentId:String,assignmentLocId:String) -> [LocationUnit]?{
       
        if let locationUnits = LocationUnitAPI.shared.getAllLocationUnits(assignmentId: assignmentId,assignmentLocId: assignmentLocId){
            return locationUnits
        }
        return nil
       
    }
    
    func saveNewUnit(objNewUnitDO:NewUnitDO){
        LocationUnitAPI.shared.saveNewUnit(objNewUnit: objNewUnitDO)
    }
    
}
