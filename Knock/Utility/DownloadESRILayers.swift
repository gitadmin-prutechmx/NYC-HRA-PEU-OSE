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
    
    private var generatedGeodatabase:AGSGeodatabase!
    
    static private var generateJob:AGSGenerateGeodatabaseJob!
    
    private var syncJob:AGSSyncGeodatabaseJob!

    
    static private var generateGeodatabasePath:String!
    
    static private var loginVC:LoginViewController!
    
    static private let FEATURE_SERVICE_URL = URL(string: "https://services7.arcgis.com/JRY73mi2cJ1KeR7T/arcgis/rest/services/MainPEULocationData/FeatureServer")!
    
    class func DownloadData(loginViewController:LoginViewController?=nil,downloadPath:String){
        
        loginVC = loginViewController
        
        generateGeodatabasePath = downloadPath
        
        
        //featureServiceUrl
        syncTask = AGSGeodatabaseSyncTask(url: self.FEATURE_SERVICE_URL)

        
        //syncTask = AGSGeodatabaseSyncTask(url: NSURL(string: featureServiceUrl)! as URL)
        
        

        
        
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
            
            generateGeodatabase()
        }

        
        
        
        

        
        
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
            
            SVProgressHUD.show(withStatus: "Getting layers data...", maskType: SVProgressHUDMaskType.gradient)
            
        }) { [] (object: AnyObject?, error: Error?) -> Void in
            
            if let error = error {
                print(error)
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
            else {
                
                SVProgressHUD.dismiss()
                
            if(loginVC != nil){
                    
                    
                if(Utilities.isBaseMapExist()==false){
                    
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
