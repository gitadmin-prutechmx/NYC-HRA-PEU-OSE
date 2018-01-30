//
//  UserDetailAPI.swift
//  EngageNYCDev
//
//  Created by Kamal on 11/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation
import SalesforceSDKCore

final class UserDetailAPI: SFCommonAPI
{
 
    static var externalId:String!
    
    private static var sharedInstance: UserDetailAPI = {
        let instance = UserDetailAPI()
        return instance
    }()
    
    class var shared:UserDetailAPI!{
        get{
            return sharedInstance
        }
    }
    
    
    
    /// Get UserInfo from rest api. We are saving these to core data for offline use.
    ///
    /// - Parameters:
    ///   - callback: callback block.
    ///   - failure: failure block.
    //func syncDownWithCompletion(completion: @escaping (()->()), failure: @escaping ((String)->()))
    func syncDownWithCompletion(completion: @escaping (()->()))
    {
        
        var userParams : [String:String] = [:]
        
        let req = SFRestRequest(method: .POST, path: SalesforceRestApiUrl.userDetail, queryParams: nil)
        req.endpoint = ""
        
      
        //SFUserAccountManager.sharedInstance().currentUserIdentity?.userId
        userParams["userId"] = (SFUserAccountManager.sharedInstance().currentUser?.idData.userId)!
        
        
        do {
            
            let bodyData = try JSONSerialization.data(withJSONObject: userParams, options: [])
            req.setCustomRequestBodyData(bodyData, contentType: "application/json")
        }
        catch{
            
            
        }
        
        self.sendRequest(request: req, callback: { (response) in
            self.UserDetailFromJSONList(jsonResponse: response)
            completion()
        }) { (error) in
            Logger.shared.log(level: .error, msg: error)
            Utility.displayErrorMessage(errorMsg: error)
            print(error)
            //failure(error)
        }
    }
    
    
    
    /// Convert the provided JSON into array of Events objects.
    ///
    /// - Parameter jsonResponse: json fetched from api.
    /// - Returns: nothing.
    private func UserDetailFromJSONList(jsonResponse:Any){
        
        //First Delete all userinfo and settings records from Core data then insert
        
        ManageCoreData.DeleteAllRecords(salesforceEntityName: coreDataEntity.userInfo.rawValue,completion: { isSuccess in

                if(isSuccess){
                    
                    UserDetailAPI.fromJSONObject(jsonObject: jsonResponse as! NSDictionary)
                    
                }
        })
    }
    
    func getUserDetail()->UserInfo?{
        
        let userInfoResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.userInfo.rawValue , isPredicate:false) as! [UserInfo]
        
        if(userInfoResults.count > 0){
            return userInfoResults.first
        }
        
        return nil
        
    }
    
    
}

extension UserDetailAPI{
    
    /// Convert JSON into object.
    ///
    /// - Parameter jsonObject: fetched JSON from api.
    /// - Returns: Nothing.
    class func fromJSONObject(jsonObject:NSDictionary){
        
        
        //UserInfo
        let userInfoObject = UserInfo(context: context)
        
        externalId = jsonObject.value(forKey: "externalId") as? String ?? ""
        userInfoObject.externalId = externalId
        
        userInfoObject.contactId = jsonObject.value(forKey: "contactId") as? String ?? ""
        userInfoObject.contactEmail = jsonObject.value(forKey: "email") as? String ?? ""
        userInfoObject.contactName = jsonObject.value(forKey: "contactName") as? String ?? ""
        userInfoObject.userId = (SFUserAccountManager.sharedInstance().currentUser?.idData.userId)!
        
        appDelegate.saveContext()
        
        
        //Setting
        let basemapDate = jsonObject.value(forKey:"esriBaseMapModifiedDate") as? String  ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: basemapDate)
        
        
        if let settingRes = SettingsAPI.shared.getSettings(){
            
            if(settingRes.count == 0){
                let settingObject = Setting(context: context)
                settingObject.settingsId = "1"
                settingObject.offlineSyncTime = "2"
                settingObject.basemapUrl = jsonObject.value(forKey: "esriBaseMapLink") as? String ?? ""
                settingObject.featureLayerUrl = jsonObject.value(forKey: "esriLayerLink") as? String ?? ""
                settingObject.geodatabaseUrl = jsonObject.value(forKey: "esriGeodatabase") as? String ?? ""
                settingObject.basemapDate = date as NSDate?
                settingObject.isSyncON = true
                
                appDelegate.saveContext()
                
            }
        }
       
        //
        //    if let basemapDate = userSettingData[0].basemapDate {
        //
        //    if(SalesforceConfig.currentBaseMapDate.equalToDate(dateToCompare: basemapDate)){
        //    SalesforceConfig.isBaseMapNeedToDownload = false
        //    }
        //    else{
        //    SalesforceConfig.isBaseMapNeedToDownload = true
        //    }
        //
        //    }
        //    else{
        //    SalesforceConfig.isBaseMapNeedToDownload = true
        //    }
        //
        //
        
        
    }
    
}
