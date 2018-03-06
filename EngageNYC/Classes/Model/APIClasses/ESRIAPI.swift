//
//  ESRIAPI.swift
//  EngageNYC
//
//  Created by Kamal on 05/03/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation
import ArcGIS

final class ESRIAPI{
    
    var featureTable:AGSServiceFeatureTable!
    
    var syncTask:AGSGeodatabaseSyncTask!
    
    var generatedGeodatabase:AGSGeodatabase!
    
    var generateJob:AGSGenerateGeodatabaseJob!
    
    var syncJob:AGSSyncGeodatabaseJob!
    
    var generateGeodatabasePath:String!
    
    let esriApiGroup = DispatchGroup()
    
    private static var sharedInstance: ESRIAPI = {
        let instance = ESRIAPI()
        return instance
    }()
    
    class var shared:ESRIAPI!{
        get{
            return sharedInstance
        }
    }
    
    func syncUpCompletion(completion: @escaping (()->()))
    {
        generatedGeodatabase = AGSGeodatabase(name: Utility.getGeoDatabase())
        
        if(generatedGeodatabase != nil){
           
            esriApiGroup.enter()
            loadCredentials()
            
            esriApiGroup.notify(queue: .main) {
                completion()
            }
            //completion()
        }
        else{
            Logger.shared.log(level: .error, msg: "GeneratedGeodatabase Error :(")
            Utility.displayErrorMessage(errorMsg: "GeneratedGeodatabase Error :(")
            
        }
        
        
    }
}


extension ESRIAPI{
    
    
    func loadCredentials(){
        
        let esriPortalLink = (Constant.shared.getSystemConstant(withKey: .ESRI_PORTAL_LINK) as? String)!
        let esriUsername = (Constant.shared.getSystemConstant(withKey: .ESRI_USERNAME) as? String)!
        let esriPassword = (Constant.shared.getSystemConstant(withKey: .ESRI_PASSWORD) as? String)!
        
        let portal = AGSPortal(url: URL(string: esriPortalLink)!, loginRequired: false)
        portal.credential = AGSCredential(user: esriUsername, password: esriPassword)
        portal.load() {[weak self] (error) in
            if let error = error {
                print(error)
                return
            }
            // check the portal item loaded and print the modified date
            if portal.loadStatus == AGSLoadStatus.loaded {
                let fullName = portal.user?.fullName
                
                // let licenseInfo = portal.portalInfo?.licenseInfo
                
                print(fullName!)
                
                self?.loadSyncTask()
            }
        }
        
    }
    
    func loadSyncTask(){
        
        
        let FEATURE_SERVICE_URL = URL(string: SettingsAPI.shared.getESRILayerLink())!
        
        
        syncTask = AGSGeodatabaseSyncTask(url: FEATURE_SERVICE_URL)
        
        if(syncTask != nil){
            
            syncTask.load { [] (error) -> Void in
                if let error = error {
                    Logger.shared.log(level: .error, msg: error.localizedDescription)
                    Utility.displayErrorMessage(errorMsg: error.localizedDescription)
                    
                } else {
                    
                    if self.syncTask.featureServiceInfo != nil {
                        for (index, layerInfo) in self.syncTask.featureServiceInfo!.layerInfos.enumerated().reversed() {
                            
                            //For each layer in the serice, add a layer to the map
                            let layerURL = FEATURE_SERVICE_URL.appendingPathComponent(String(index))
                            
                            let featureTable = AGSServiceFeatureTable(url:layerURL)
                            let featureLayer = AGSFeatureLayer(featureTable: featureTable)
                            featureLayer.name = layerInfo.name
                            featureLayer.opacity = 0.65
                            
                        }
                        
                        
                    }
                    
                    self.fetchUpdatedData()
                    
                }
            }
        }
        else{
            
            Logger.shared.log(level: .error, msg: "Sync Task Error :(")
            Utility.displayErrorMessage(errorMsg: "Sync Task Error :(")
            
        }
    }
    
    
    func fetchUpdatedData(){
        
        var syncLayerOptions = [AGSSyncLayerOption]()
        for layerInfo in self.syncTask.featureServiceInfo!.layerInfos {
            let layerOption = AGSSyncLayerOption(layerID: layerInfo.id, syncDirection: .download)
            syncLayerOptions.append(layerOption)
        }
        
        let params = AGSSyncGeodatabaseParameters()
        params.layerOptions = syncLayerOptions
        
        syncJob = self.syncTask.syncJob(with: params, geodatabase: generatedGeodatabase)
        
        syncJob.start(statusHandler: { (status: AGSJobStatus) -> Void in
            
            print("refreshing data")
            //SVProgressHUD.show(withStatus: status.statusString(), maskType: .gradient)
            
        }, completion: { (results: [AGSSyncLayerResult]?, error: Error?) -> Void in
            if let error = error {
                
               
                Logger.shared.log(level: .error, msg: error.localizedDescription)
                Utility.displayErrorMessage(errorMsg: error.localizedDescription)
                
                
            }
            else {
                
                self.esriApiGroup.leave()
                
            }
            
            
        })
        
        
    }
    
    
    
}
