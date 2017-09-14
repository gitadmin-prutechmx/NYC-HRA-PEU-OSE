//
//  DownloadBaseMap.swift
//  Knock
//
//  Created by Kamal on 14/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import Foundation

class DownloadBaseMap{
    
    class func downloadNewYorkCityBaseMap(loginViewController:LoginViewController?=nil){
        
        //show download progress view
        loginViewController?.downloadProgressView.show(withStatus: "Downloading Map Data...", progress: 0)
        
        
        
        //  https://nyc-mayorpeu--qa.cs32.my.salesforce.com/sfc/dist/version/download/?oid=00Dr00000000rkJ&ids=068r00000002mqwAAA&d=/a/r000000006iw/Q2NKEVxRrn_mYz7BzKd8QrYgQA9p3TxgnhdsovDZ3vU&operationContext=DELIVERY&viewId=05Hr000000000PHEAY&dpt=
        
        // https://nyc-mayorpeu--qa.cs32.my.salesforce.com/sfc/dist/version/download/?oid=00Dr00000000rkJ&ids=068r00000002mr6AAA&d=/a/r000000006j1/Wgvb8JJkOwGD_ye4xPlNORQIYFIv45h7NHWgTAncmyU&operationContext=DELIVERY&viewId=05Hr000000000PMEAY&dpt=
        
        
        //"https://nyc-mayorpeu--qa.cs32.my.salesforce.com/sfc/dist/version/download/?oid=00Dr00000000rkJ&ids=068r00000002mqwAAA&d=/a/r000000006iw/Q2NKEVxRrn_mYz7BzKd8QrYgQA9p3TxgnhdsovDZ3vU&operationContext=DELIVERY&viewId=05Hr000000000PHEAY&dpt="
        
        let userSettingData = ManageCoreData.fetchData(salesforceEntityName: "Setting", isPredicate:false) as! [Setting]
        
        if(userSettingData.count > 0){
            
            SalesforceConnection.downloadBaseMap(baseMapUrl: userSettingData[0].basemapUrl!){ progress, error in
                
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
}
