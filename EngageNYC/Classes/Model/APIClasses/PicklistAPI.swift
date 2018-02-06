//
//  PicklistAPI.swift
//  EngageNYCDev
//
//  Created by Kamal on 11/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation
import SalesforceSDKCore

final class PicklistAPI : SFCommonAPI
{
    
    private static var sharedInstance: PicklistAPI = {
        let instance = PicklistAPI()
        return instance
    }()
    
    class var shared:PicklistAPI!{
        get{
            return sharedInstance
        }
    }
    
    /// Get All Events from rest api. We are saving these Events to core data for offline use.
    ///
    /// - Parameters:
    ///   - callback: callback block.
    ///   - failure: failure block.
    //func syncDownWithCompletion(completion: @escaping (()->()), failure: @escaping ((String)->()))
    func syncDownWithCompletion(completion: @escaping (()->()))
    {
        
        let req = SFRestRequest(method: .GET, path: SalesforceRestApiUrl.picklistValue, queryParams: nil)
        req.endpoint = ""
        self.sendRequest(request: req, callback: { (response) in
            self.PicklistFromJSONList(jsonResponse: response)
            completion()
        }) { (error) in
            Logger.shared.log(level: .error, msg: error)
            Utility.displayErrorMessage(errorMsg: error)
            print(error)
            //failure(error)
        }
    }
    
    /// Get picklist from core data.
    ///
    /// - Returns: array of picklist.
    func getPicklist(objectType:String,fieldName:String)->DropDown? {
        
        let picklistResults =  ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.dropDown.rawValue, predicateFormat:"object == %@ AND fieldName == %@",predicateValue:  objectType,predicateValue2:  fieldName, isPredicate:true) as! [DropDown]
        
        if picklistResults.count > 0 {
            return picklistResults.first
        }
        
        return nil
    }
    
    
   
    
    /// Convert the provided JSON into array of Dropdown objects.
    ///
    /// - Parameter jsonResponse: json fetched from api.
    /// - Returns: nothing.
    private func PicklistFromJSONList(jsonResponse:Any){
        
        //First Delete all event records from Core data then insert
        
        ManageCoreData.DeleteAllRecords(salesforceEntityName: coreDataEntity.dropDown.rawValue,completion: { isSuccess in
            
                if(isSuccess){
                    
                    guard let jsonArray = (jsonResponse as? NSDictionary)?.value(forKey: "objects") as? NSArray else { return }
                    
                    for responseObject in jsonArray{
                        if let json = responseObject as? NSDictionary{
                            PicklistAPI.fromJSONObject(jsonObject: json)
                        }
                    }
                }
            
        })
    }
    
    
}

extension PicklistAPI{
    
    /// Convert JSON into a DropDown object.
    ///
    /// - Parameter jsonObject: fetched JSON from api.
    /// - Returns: Nothing.
    class func fromJSONObject(jsonObject:NSDictionary){
    
        guard let dropDownArray =  jsonObject.value(forKey: "fieldList") as? NSArray else { return }
        
        for dropDown in dropDownArray{
            
            let dropDownObject = DropDown(context: context)
            
            dropDownObject.object = jsonObject["objectName"] as? String ?? ""
            dropDownObject.fieldName = (dropDown as AnyObject).value(forKey: "fieldName") as? String
            dropDownObject.value = (dropDown as AnyObject).value(forKey: "picklistValue") as? String
            
            appDelegate.saveContext()
            
        }
        
        
      
        
    }
    
    
}

