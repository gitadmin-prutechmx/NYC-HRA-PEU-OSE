//
//  ViewController.swift
//  GenerateGeoDatabase
//
//  Created by Kamal on 26/02/18.
//  Copyright © 2018 MTX. All rights reserved.
//

import UIKit
import ArcGIS

class ViewController: UIViewController {
    
    var featureTable:AGSServiceFeatureTable!
    
    var syncTask:AGSGeodatabaseSyncTask!
    
    var generatedGeodatabase:AGSGeodatabase!
    
    var generateJob:AGSGenerateGeodatabaseJob!
    
    var syncJob:AGSSyncGeodatabaseJob!
    
    var generateGeodatabasePath:String!
    
    //Deva and QA feature layer URL
    let FEATURE_SERVICE_URL = URL(string: "https://services7.arcgis.com/JRY73mi2cJ1KeR7T/arcgis/rest/services/PEU_Location_Dev/FeatureServer")!
    
    //UAT feature layer URL
    //let FEATURE_SERVICE_URL = URL(string: "https://services7.arcgis.com/JRY73mi2cJ1KeR7T/arcgis/rest/services/PEU_Address_UAT/FeatureServer")!
    
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var dbPath: UILabel!
    @IBOutlet weak var lblGeodbPath: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbPath.isHidden = true
        lblGeodbPath.isHidden = true
       // message.isHidden = true
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let fullPath = "\(path)/NewYorkLayers.geodatabase"
        
        print("Geodatabase Path: \(path)")

        AGSAuthenticationManager.shared().credentialCache.removeAllCredentials()
        
        SVProgressHUD.show(withStatus: "Generating geodatabase..", maskType: SVProgressHUDMaskType.gradient)
        
        
        let portal = AGSPortal(url: URL(string: "https://mtxgis.maps.arcgis.com")!, loginRequired: false)
        portal.credential = AGSCredential(user: "dasnobel", password: "lo9(ki8*")
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
               
                self?.deleteGeodatabase()
                self?.downloadData(downloadPath:fullPath)
            }
        }
        
        
        
        
    }
    
    func deleteGeodatabase() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: path)
            for file in files {
                let remove = file.hasSuffix(".geodatabase")
                if remove {
                    try FileManager.default.removeItem(atPath: (path as NSString).appendingPathComponent(file))
                    print("deleting geodatabase: \(file)")
                }
            }
            print("deleted geodatabase")
        }
        catch {
            print(error)
        }
    }
    
   
    func downloadData(downloadPath:String){
        
        generateGeodatabasePath = downloadPath
        
        loadSyncTask()
    }
    
    func loadSyncTask(){
        //let FEATURE_SERVICE_URL = URL(string: "")!
        
        
        syncTask = AGSGeodatabaseSyncTask(url: FEATURE_SERVICE_URL)
        
        if(syncTask != nil){
            
            syncTask.load { [] (error) -> Void in
                if let error = error {
                    SVProgressHUD.dismiss()
                    
                    self.message.isHidden = false
                    
                    let msg = "Could not load feature service \(error) :("
                    
                    self.message.text = msg
                    self.message.textColor = UIColor.red
                    
                    print(msg)
                    
                } else {
                    
                    if self.syncTask.featureServiceInfo != nil {
                        for (index, layerInfo) in self.syncTask.featureServiceInfo!.layerInfos.enumerated().reversed() {
                            
                            //For each layer in the serice, add a layer to the map
                            let layerURL = self.FEATURE_SERVICE_URL.appendingPathComponent(String(index))
                            
                            let featureTable = AGSServiceFeatureTable(url:layerURL)
                            let featureLayer = AGSFeatureLayer(featureTable: featureTable)
                            featureLayer.name = layerInfo.name
                            featureLayer.opacity = 0.65
                            
                        }
                        
                        
                    }

                    
                    self.generateGeodatabase()
                    
                }
            }
        }
        else{
            SVProgressHUD.dismiss()
            self.message.isHidden = false
            
            self.message.text = "Sync Task Error :("
            self.message.textColor = UIColor.red
            
        }
        
        
        
        
    }
    
    
    func generateGeodatabase() {
        
        //create AGSGenerateLayerOption objects with selected layerIds
        
        var layerOptions = [AGSGenerateLayerOption]()
        
        
        
        
        for (layerId, _) in syncTask.featureServiceInfo!.layerInfos.enumerated().reversed(){
            
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
        
        
        
        DownloadLayersData(path: generateGeodatabasePath,geodatabaseParams:params)
        
        
        
    }
    
    
    
    func DownloadLayersData(path:String,geodatabaseParams:AGSGenerateGeodatabaseParameters){
        
        
        //create a generate job from the sync task
        
        generateJob = syncTask.generateJob(with: geodatabaseParams, downloadFileURL: NSURL(string: path)! as URL)
        
        
        //kick off the job
        generateJob.start(statusHandler: { (status: AGSJobStatus) -> Void in
            
            
            SVProgressHUD.show(withStatus: "Generating geodatabase:- " + status.statusString(), maskType: SVProgressHUDMaskType.gradient)
            
            
        }) { [] (object: AnyObject?, error: Error?) -> Void in
            
            if let error = error {
                
                SVProgressHUD.dismiss()
                
                self.message.isHidden = false
                
                let msg = "Error while generating geodatabase:  \(error.localizedDescription)"
                print(msg)
              
                self.message.text = msg
                self.message.textColor = UIColor.red
                
            }
            else {
                
                SVProgressHUD.dismiss()
                
                self.dbPath.isHidden = false
                self.lblGeodbPath.isHidden = false
                self.message.isHidden = false
                
                
                let msg = "Successfully generate geodatabase :)"
                print(msg)
                
                self.message.text = msg
                self.message.textColor = UIColor.green
                
                self.dbPath.text = path
                
                
                
            }
        }
        
    }
    
   
    
    
    
}




