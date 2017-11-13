//
//  DownloadBaseMap.swift
//  Knock
//
//  Created by Kamal on 14/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import Foundation

class Download{
    
    class func downloadNewYorkCityData(loginViewController:LoginViewController?=nil){
        
        //show download progress view
        loginViewController?.downloadProgressView.show(withStatus: "Downloading Map Data...", progress: 0)
        
        let userSettingData = ManageCoreData.fetchData(salesforceEntityName: "Setting", isPredicate:false) as! [Setting]
        
        if(userSettingData.count > 0){
            
            
            
            SalesforceConnection.downloadESRIStuff(url: userSettingData[0].geodatabaseUrl!,fileName: "NewYorkLayersGeodatabase.zip"){ progress, error in
                
                if(progress != nil){
                    if (progress! < 1.0) {
                        
                        if(loginViewController != nil){
                            loginViewController?.downloadProgressView?.updateProgress(progress: CGFloat(progress!), animated: true)
                        }
                    }
                    
                    if(progress! == 1.0) {
                        

                        
                        
                        if(loginViewController != nil){
                            loginViewController?.downloadProgressView.dismiss()
                            
                           
                            loginViewController?.performSegue(withIdentifier: "loginIdentifier", sender: nil)
                        }
                        else{
                            DownloadESRILayers.RefreshData()
                            
                            //Utilities.callNotificationCenter()
                        }
                        
                        //in main thread
                        //                DispatchQueue.main.sync {
                        //
                        //                    //dismiss download progress view
                        //                    loginViewController?.downloadProgressView.dismiss()
                        //
                        //                    DispatchQueue.main.async {
                        //                        loginViewController?.performSegue(withIdentifier: "loginIdentifier", sender: nil)
                        //                    }
                        //
                        //                }
                        
                    }
                }
                else{
                    if(loginViewController != nil){
                        loginViewController?.downloadProgressView.dismiss()
                    }
                    else{
                        
                        DownloadESRILayers.RefreshData()
                        
                        //Utilities.callNotificationCenter()
                        
                        
                        //SVProgressHUD.dismiss()
                    }
                }
                
            }
            
        }
        
        
    }
    
    // UnzipFile(fileName: "NewYorkLayers.geodatabase")
    
    
    
    
}
