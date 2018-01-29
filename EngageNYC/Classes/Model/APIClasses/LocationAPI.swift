//
//  LocationAPI.swift
//  EngageNYCDev
//
//  Created by Kamal on 11/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation

final class LocationAPI : SFCommonAPI
{
    
    private static var sharedInstance: LocationAPI = {
        let instance = LocationAPI()
        return instance
    }()
    
    class var shared:LocationAPI!{
        get{
            return sharedInstance
        }
    }
    
    
    
    /// Get all the locations from core data.
    ///
    /// - Returns: array of locations.
    func getAllLocations(assignmentId:String)->[Location]? {
        
        let locationResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.location.rawValue ,predicateFormat: "assignmentId == %@",predicateValue: assignmentId, isPredicate:true) as? [Location]
        
        return locationResults
    }
    
    func updateLocationStatus(assignmentLocId:String,locStatus:String) {
        
        var updateObjectDic:[String:AnyObject] = [:]
        updateObjectDic["locStatus"] = locStatus as AnyObject
       
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.location.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocId == %@", predicateValue: assignmentLocId,isPredicate: true)
    }
}
