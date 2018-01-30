//
//  EventsAPI.swift
//  EngageNYCDev
//
//  Created by Kamal on 09/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation
import SalesforceSDKCore

final class CaseConfigAPI : SFCommonAPI
{
    
    private static var sharedInstance: CaseConfigAPI = {
        let instance = CaseConfigAPI()
        return instance
    }()
    
    class var shared:CaseConfigAPI!{
        get{
            return sharedInstance
        }
    }
    
    /// Get Events Config from rest api. We are saving these CaseConfig to core data for offline use.
    ///
    /// - Parameters:
    ///   - callback: callback block.
    ///   - failure: failure block.
    func syncDownWithCompletion(completion: @escaping (()->()))
    {
        let req = SFRestRequest(method: .GET, path: SalesforceRestApiUrl.caseConfiguration, queryParams: nil)
        req.endpoint = ""
        self.sendRequest(request: req, callback: { (response) in
            self.CaseConfigFromJSONList(jsonResponse: response as! Dictionary<String, AnyObject>)
            completion()
        }) { (error) in
            Logger.shared.log(level: .error, msg: error)
            Utility.displayErrorMessage(errorMsg: error)
            print(error)
            //failure(error)
        }
    }
    
    /// Get case config from core data.
    ///
    /// - Returns: metadataconfig.
    func getCaseConfig()->MetadataConfig? {
        
        let caseConfigResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.metadataConfig.rawValue ,predicateFormat: "type == %@", predicateValue: MetadataConfigEnum.cases.rawValue,isPredicate:true) as! [MetadataConfig]
        
        if(caseConfigResults.count > 0){
            return caseConfigResults.first
        }
        
        return nil
    }
    
    /// Convert the provided JSON into array of CaseConfig object.
    ///
    /// - Parameter jsonResponse: json fetched from api.
    /// - Returns: nothing.
    private func CaseConfigFromJSONList(jsonResponse:Dictionary<String, AnyObject>){
        
        ManageCoreData.DeleteAllRecords(salesforceEntityName: coreDataEntity.metadataConfig.rawValue,completion: { isSuccess in
            
            if(isSuccess){
                let metadataConfig = MetadataConfig(context: context)
                metadataConfig.configData = jsonResponse as NSObject?
                metadataConfig.type = MetadataConfigEnum.cases.rawValue
                
                appDelegate.saveContext()
            }
        })
        
    }
    
    
}






