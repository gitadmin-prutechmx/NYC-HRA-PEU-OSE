//
//  DownloadESRILayers.swift
//  Knock
//
//  Created by Kamal on 13/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import Foundation
import ArcGIS

class DownloadESRILayers{
    
    private var featureTable:AGSServiceFeatureTable!
    
    static private var syncTask:AGSGeodatabaseSyncTask!
    
    static private var generatedGeodatabase:AGSGeodatabase!
    
    static private var generateJob:AGSGenerateGeodatabaseJob!
    
    static private var syncJob:AGSSyncGeodatabaseJob!
    
    
    static private var generateGeodatabasePath:String!
    
    static private var loginVC:LoginViewController!
    
    // static private let FEATURE_SERVICE_URL = URL(string: "https://services7.arcgis.com/JRY73mi2cJ1KeR7T/arcgis/rest/services/MainPEULocationData/FeatureServer")!
    
    
    
    
    
    
    class func RefreshData(){
        
        generatedGeodatabase = AGSGeodatabase(name: "NewYorkLayers")
        
        loadSyncTask()
        
    }
    
    
    
    
    class func DownloadData(loginViewController:LoginViewController?=nil,downloadPath:String){
        
        loginVC = loginViewController
        
        generateGeodatabasePath = downloadPath
        
        
        //syncTask = AGSGeodatabaseSyncTask(url: NSURL(string: featureServiceUrl)! as URL)
        
        
        
        loadSyncTask(isGeodatabaseGenerate: true)
        
        
        
    }
    
    
    class func loadSyncTask(isGeodatabaseGenerate:Bool? = false){
        
        let userSettingData = ManageCoreData.fetchData(salesforceEntityName: "Setting", isPredicate:false) as! [Setting]
        
        if(userSettingData.count > 0){
            
            let FEATURE_SERVICE_URL = URL(string: userSettingData[0].featureLayerUrl!)!
            
            
            syncTask = AGSGeodatabaseSyncTask(url: FEATURE_SERVICE_URL)
            
            self.syncTask.load { [] (error) -> Void in
                if let error = error {
                    print("Could not load feature service \(error)")
                    
                } else {
                    
                    
                    for (index, layerInfo) in syncTask.featureServiceInfo!.layerInfos.enumerated().reversed() {
                        
                        //For each layer in the serice, add a layer to the map
                        let layerURL = FEATURE_SERVICE_URL.appendingPathComponent(String(index))
                        
                        let featureTable = AGSServiceFeatureTable(url:layerURL)
                        let featureLayer = AGSFeatureLayer(featureTable: featureTable)
                        featureLayer.name = layerInfo.name
                        featureLayer.opacity = 0.65
                        
                    }
                    
                    
                }
                
                if(isGeodatabaseGenerate!){
                    generateGeodatabase()
                }
                else{
                    fetchUpdatedData()
                }
            }
            
        }
        
        
        
        
        
    }
    
    class func fetchUpdatedData(){
        
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
                print(error.localizedDescription)
                //SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
            else {
                print(results)
                
                
                Utilities.callNotificationCenter()
            }
            
            
        })
        
        
    }
    
    
    
    
    class func generateGeodatabase() {
        
        //create AGSGenerateLayerOption objects with selected layerIds
        
        var layerOptions = [AGSGenerateLayerOption]()
        
        
        
        
        for (layerId, layerInfo) in DownloadESRILayers.syncTask.featureServiceInfo!.layerInfos.enumerated().reversed(){
            
            let layerOption = AGSGenerateLayerOption(layerID: layerId)
            
            layerOption.useGeometry = false
            
            layerOptions.append(layerOption)
            
        }
        
        
        
        let params = AGSGenerateGeodatabaseParameters()
        
        
        
        //params.extent = self.mapView.visibleArea!.extent
        
        params.extent = AGSEnvelope(xMin: 0, yMin: 0, xMax: 100, yMax: 100, spatialReference: AGSSpatialReference.webMercator())
        
        params.layerOptions = layerOptions
        
        params.returnAttachments = true
        
        params.attachmentSyncDirection = .bidirectional
        
        
        
        //        if filemanager.fileExists(atPath: fullPath) {
        //
        //            self.deleteAllGeodatabases()
        //
        //
        //
        //        }
        
        DownloadLayersData(path: generateGeodatabasePath,geodatabaseParams:params)
        
        
        
    }
    
    
    
    class func DownloadLayersData(path:String,geodatabaseParams:AGSGenerateGeodatabaseParameters){
        
        
        //create a generate job from the sync task
        
        generateJob = DownloadESRILayers.syncTask.generateJob(with: geodatabaseParams, downloadFileURL: NSURL(string: path)! as URL)
        
        
        
        
        //kick off the job
        generateJob.start(statusHandler: { (status: AGSJobStatus) -> Void in
            
            SVProgressHUD.show(withStatus: "Fetching layers data...", maskType: SVProgressHUDMaskType.gradient)
            
        }) { [] (object: AnyObject?, error: Error?) -> Void in
            
            if let error = error {
                print(error)
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
            else {
                
                SVProgressHUD.dismiss()
                
                if(loginVC != nil){
                    
                    
                    // && Utilities.isBaseMapExist()==false
                    if(SalesforceConfig.isBaseMapNeedToDownload == true){
                        
                        //Delete Basemap first and then download
                        Utilities.deleteBasemap()
                        
                        
                        DownloadBaseMap.downloadNewYorkCityBaseMap(loginViewController: loginVC)
                        
                        
                    }
                        
                    else{
                        
                        DispatchQueue.main.async {
                            loginVC?.performSegue(withIdentifier: "loginIdentifier", sender: nil)
                        }
                    }
                    
                    
                    
                    
                    
                    
                }//end of loginVC
                
                
                
                
                
            }
        }
        
        
        
        
    }
    
    
}
