//
//  MapLocationViewModel.swift
//  EngageNYCDev
//
//  Created by Kamal on 11/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation

class MapLocationViewModel{
    
    var filterfeaturesExpression:String = ""
    var locationAddressDict:[String:MapLocationDO] = [:]
    
    static func getViewModel() -> MapLocationViewModel {
        return MapLocationViewModel()
    }
   
    
    
    func updateLocationStatus(assignmentLocId:String,locStatus:String){
        LocationAPI.shared.updateLocationStatus(assignmentLocId: assignmentLocId,locStatus: locStatus)
    }
    

    func loadLocations(assignmentId:String) -> [MapLocationDO]{
        
        var arrMapLocations = [MapLocationDO]()
        
//        let objMapLocation = MapLocationDO()
//        objMapLocation.locId = "1"
//        objMapLocation.locName = "137 CHRYSTIE STREET,NEW YORK,NY,10076"
//        objMapLocation.street = "137 CHRYSTIE STREET"
//        objMapLocation.state = "NY"
//        objMapLocation.zip = "10076"
//        objMapLocation.city = "NEW YORK"
//        objMapLocation.totalUnits = "2"
//        objMapLocation.totalClients = "3"
//        objMapLocation.noOfUnitsAttempt = "5"
//        objMapLocation.lastModifiedName = "Kamal"
//
//        objMapLocation.assignmentLocId = "2"
//        objMapLocation.locStatus = "Planned"
//        objMapLocation.additionalAddress = "NEW YORK" + ", " + "NY" + ", " + "10076"
//
//        if(locationAddressDict["137 CHRYSTIE STREET,NEW YORK,NY,10076"] == nil){
//            locationAddressDict["137 CHRYSTIE STREET,NEW YORK,NY,10076"] = objMapLocation
//        }
//
//        filterfeaturesExpression = filterfeaturesExpression + "Name = 137 CHRYSTIE STREET,NEW YORK,NY,10076'OR "
//
//        arrMapLocations.append(objMapLocation)
        
        if let locations = LocationAPI.shared.getAllLocations(assignmentId: assignmentId){
            for location:Location in locations{
                let objMapLocation = MapLocationDO()
                objMapLocation.locId = location.locationId
                objMapLocation.locName = location.locationName
                objMapLocation.streetNum = location.streetNumber
                objMapLocation.streetName = location.streetName
                objMapLocation.borough = location.borough
                objMapLocation.street = location.street
                objMapLocation.state = location.state
                objMapLocation.zip = location.zip
                objMapLocation.city = location.city
                objMapLocation.totalUnits = location.totalUnits
                objMapLocation.totalClients = location.totalClients
                objMapLocation.noOfUnitsAttempt = location.noOfUnitsAttempt
                objMapLocation.lastModifiedName = location.lastModifiedName

                objMapLocation.assignmentLocId = location.assignmentLocId
                objMapLocation.locStatus = location.locStatus
                objMapLocation.additionalAddress = location.city! + ", " + location.state! + ", " + location.zip!

                if(locationAddressDict[location.locationName!] == nil){
                    locationAddressDict[location.locationName!] = objMapLocation
                }

        filterfeaturesExpression = filterfeaturesExpression + "Name = '\(location.locationName!)'OR "

                arrMapLocations.append(objMapLocation)
            }
        }
        return arrMapLocations
        
    }
    
}
