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
        
        if(generatedGeodatabase != nil){
            loadSyncTask()
        }
        else{
            SVProgressHUD.dismiss()
            Utilities.showSwiftErrorMessage(error: "DownloadESRILayers:- RefreshData:- Generated Geodatabase is nil ")
        }
        
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
            
//            self.syncTask.registerSyncEnabledGeodatabase(<#T##geodatabase: AGSGeodatabase##AGSGeodatabase#>, completion: <#T##((Error?) -> Void)?##((Error?) -> Void)?##(Error?) -> Void#>)
//            
            
            if(syncTask != nil){
                
                self.syncTask.load { [] (error) -> Void in
                    if let error = error {
                        SVProgressHUD.dismiss()
                        Utilities.showSwiftErrorMessage(error: "DownloadESRILayers:- loadSyncTask:- Could not load feature service  \(error.localizedDescription)")
                        
                        
                        print("Could not load feature service \(error)")
                        
                    } else {
                        
                        if syncTask.featureServiceInfo != nil {
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
            else{
                SVProgressHUD.dismiss()
                 Utilities.showSwiftErrorMessage(error: "DownloadESRILayers:- loadSyncTask:- Sync Task error :  \(userSettingData[0].featureLayerUrl!)")
                
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
                
                SVProgressHUD.dismiss()
                 Utilities.showSwiftErrorMessage(error: "DownloadESRILayers:- fetchUpdatedData:- Refreshing Data issue:  \(error.localizedDescription)")
                
                print(error.localizedDescription)
                
               
            }
            else {
                
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
            
            if(loginVC != nil){
                loginVC.loadingSpinner.startAnimating()
                loginVC.message.text = "Fetching layers data.."
            }
            else{
                SVProgressHUD.show(withStatus: "Fetching layers data:- " + status.statusString(), maskType: SVProgressHUDMaskType.gradient)
            }
            
            //print(generateJob.messages)
            
        }) { [] (object: AnyObject?, error: Error?) -> Void in
            
            if let error = error {
                
                print(error)
                
                if(loginVC != nil){
                    loginVC.loadingSpinner.stopAnimating()
                    loginVC.loadingSpinner.hidesWhenStopped = true
                    loginVC.message.text = ""
                }

                
                SVProgressHUD.dismiss()
                Utilities.showSwiftErrorMessage(error: "DownloadESRILayers:- DownloadLayersData:- Error while generating geodatabase:  \(error.localizedDescription)")
                
                //Utilities.showSwiftErrorMessage(error: "Error while fetching location data from ESRI server.")
                
                //SVProgressHUD.showError(withStatus: error.localizedDescription)
                
            }
            else {
                
                SVProgressHUD.dismiss()
                
                
                if(loginVC != nil){
                    
                    loginVC.loadingSpinner.stopAnimating()
                    loginVC.loadingSpinner.hidesWhenStopped = true
                    loginVC.message.text = ""
                    
                    // && Utilities.isBaseMapExist()==false
                    if(SalesforceConfig.isBaseMapNeedToDownload == true || Utilities.isBaseMapExist()==false){
                        
                        //Delete Basemap first and then download
                        Utilities.deleteBasemap()
                        
                        
                        Download.downloadNewYorkCityData(loginViewController: loginVC)
                        
                        
                    }
                        
                    else{
                        
                        DispatchQueue.main.async {
                            loginVC?.performSegue(withIdentifier: "loginIdentifier", sender: nil)
                        }
                    }
                    
                    
                    
                    
                    
                    
                }//end of loginVC
                    //If refresh icon click
                else{
                    if(SalesforceConfig.isBaseMapNeedToDownload == true || Utilities.isBaseMapExist() == false){
                        
                        //Delete Basemap first and then download
                        Utilities.deleteBasemap()
                        
                        SVProgressHUD.show(withStatus: "Updating Basemap..", maskType: .gradient)
                        
                        Download.downloadNewYorkCityData(loginViewController: nil)
                        
                    }
                }
                
                
                
                
            }
        }
        
        
        
        
    }
    
    
}
