//
//  RefreshAll.swift
//  EngageNYC
//
//  Created by Kamal on 12/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation
import SalesforceSDKCore

/**
 Creating only one instance of RefreshViewController, so it can be resued whenever refresh is made.
 */
class RefreshAll: BroadcastReceiverNSObject
{
    
    // The Singleton
    class var sharedInstance: RefreshAll
    {
        struct Singleton { static let instance = RefreshAll()}
        return Singleton.instance
    }
    
    /**
     -This method will fire a full refresh Data from all models/api classes we have.
     */
    func refreshESRIData()
    {
        presentRefreshView() {
            self.syncUpESRILayer()
        }
    }
    
    
    
    /**
     -This method will fire a full refresh Data from all models/api classes we have.
     */
    func refreshFullData(isFromSurveyScreen:Bool?=false, isLogout:Bool? = false,isFirstTimeLoad:Bool?=false)
    {
        presentRefreshView(isFromSurveyScreen: isFromSurveyScreen) {
            self.synUpAllObjects(isLogout: isLogout,isFirstTimeLoad:isFirstTimeLoad)
        }
    }
    
    //for background syncing
    func refreshDataWithOutModel()
    {
        self.synUpAllObjects(isLogout: false,isBackgroundSync:true)
    }
    
    
    func syncUpESRILayer(){
        ESRIAPI.shared.syncUpCompletion {
            DispatchQueue.main.async {
                if let refreshView  = Static.refreshView {
                    refreshView.dismiss(animated: true, completion: nil)
                    Static.refreshView = nil
                    
                    Static.isRefreshBtnClick = false
                    
                     CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.LOCATIONLISTING_SYNC.rawValue, sender: nil, userInfo: nil)
                }
            }
        }
    }
    
    
    
    
    func synUpAllObjects(isLogout:Bool? = false,isBackgroundSync:Bool?=false,isFirstTimeLoad:Bool?=false){
        // 1. AssignmentLocation
        // 2. New Unit
        // 3. Contact
        // 4. AssignmentLocationUnit
        // 5. Survey
        // 6. Cases
        // 7. Issues
        
        AssignmentLocationAPI.shared.syncUpCompletion {
            LocationUnitAPI.shared.syncUpCompletion {
                ContactAPI.shared.syncUpCompletion {
                    AssignmentLocationUnitAPI.shared.syncUpCompletion {
                        SurveyAPI.shared.syncUpCompletion {
                            CaseAPI.shared.syncUpCompletion {
                                IssueAPI.shared.syncUpCompletion {
                                    EventsAPI.shared.syncUpCompletion {
                                        if(isLogout)!{
                                            
                                            if(Static.timer != nil){
                                                Static.timer?.invalidate()
                                            }
                                            SFAuthenticationManager.shared().logout()
                                        }
                                        else{
                                            
                                            if(isBackgroundSync == false){
                                                self.syncDownAllObjects(isFirstTimeLoad:isFirstTimeLoad)
                                            }
                                            else{
                                                
                                                Logger.shared.log(level: .info, msg: "Background syncing finish..")
                                                Static.isBackgroundSync = false
                                                //self.callNotifications()
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        }
        
    }
    
    func syncDownAllObjects(isFirstTimeLoad:Bool?=false){
        
        UserDetailAPI.shared.syncDownWithCompletion {
            
            AssignmentDetailAPI.shared.syncDownWithCompletion {
                
                ChartAPI.shared.syncDownWithCompletion {
                    
                    PicklistAPI.shared.syncDownWithCompletion{
                        
                        CaseConfigAPI.shared.syncDownWithCompletion{
                            
                            EventsConfigAPI.shared.syncDownWithCompletion{
                                
                                EventsAPI.shared.syncDownWithCompletion{
                                    
                                    if(isFirstTimeLoad)!{
                                        
                                        var mapDataZipFile = "MapDataDev"
                                        
                                        if let SFEnvironment = Constant.shared.getSystemConstant(withKey: .SF_ENVIRONMENT_KEY) as? String{
                                            if SFEnvironment == environment.dev.rawValue{
                                                mapDataZipFile = "MapDataDev"
                                            }
                                            else if SFEnvironment == environment.qa.rawValue{
                                                mapDataZipFile = "MapDataQA"
                                            }
                                            else if SFEnvironment == environment.uat.rawValue{
                                                mapDataZipFile = "MapDataUAT"
                                            }
                                            
                                        }
                                        
                                        Utility.saveUnZipFilePath(mapDataZipFile: mapDataZipFile)
                                        
                                        ESRIAPI.shared.syncUpCompletion {
                                            self.closeRefreshPopUp()
                                        }
                                    }
                                    else{
                                        self.closeRefreshPopUp()
                                    }
                                    
                                    
                                }
                            }
                            
                        }
                        
                    }
                    
                }
                
                
            }
        }
        
        
        
        
    }
    
    
    func closeRefreshPopUp(){
        DispatchQueue.main.async {
            if let refreshView  = Static.refreshView {
                refreshView.dismiss(animated: true, completion: nil)
                Static.refreshView = nil
                
                Static.isRefreshBtnClick = false
                
                self.callNotifications()
                
            }
        }
    }
    
    func callNotifications(){
        
        CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.DASHBOARD_SYNC.rawValue, sender: nil, userInfo: nil)
        
        CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.LOCATIONLISTING_SYNC.rawValue, sender: nil, userInfo: nil)
        
        CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.UNITLISTING_SYNC.rawValue, sender: nil, userInfo: nil)
        
        CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.CLIENTLISTING_SYNC.rawValue, sender: nil, userInfo: nil)
        
        CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.INTAKECLIENTLISTING_SYNC.rawValue, sender: nil, userInfo: nil)
        
        CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.INTAKECASELISTING_SYNC.rawValue, sender: nil, userInfo: nil)
        
        CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.INTAKEISSUELISTING_SYNC.rawValue, sender: nil, userInfo: nil)
        
    }
    
    
    func presentRefreshView(isFromSurveyScreen:Bool? = false , completion: (() -> Swift.Void)!){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let refreshView = (RefreshStoryboard().instantiateViewController(withIdentifier: "RefreshViewController") as? RefreshViewController)!
            
            if (isFromSurveyScreen)!
            {
                
                var topRootViewController: UIViewController = (UIApplication.shared.keyWindow?.rootViewController)!
                
                while((topRootViewController.presentedViewController) != nil){
                    topRootViewController = topRootViewController.presentedViewController!
                    if topRootViewController.isKind(of: SurveyMultiOptionViewController.self) || topRootViewController.isKind(of: SurveyRadioOptionViewController.self)||topRootViewController.isKind(of: SurveyTextViewController.self)||topRootViewController.isKind(of: SubmitSurveyViewController.self)
                    {
                        topRootViewController.present(refreshView, animated: true, completion: {
                            completion()
                        })
                    }
                }
                
            } else {
                appDelegate?.window?.rootViewController?.present(refreshView, animated: true, completion: {
                    completion()
                })
            }
            
            Static.refreshView = refreshView

    }
    
    
    
    
//    func presentRefreshView(isFromSurveyScreen:Bool? = false , completion: (() -> Swift.Void)!){
//        let appDelegate = UIApplication.shared.delegate as? AppDelegate
//
//        if Static.refreshView == nil {
//            if let refreshView = RefreshStoryboard().instantiateViewController(withIdentifier: "RefreshViewController") as? RefreshViewController
//            {
//                appDelegate?.window?.rootViewController?.present(refreshView, animated: true, completion: {
//                    completion()
//                })
//                Static.refreshView = refreshView
//            }
//        }
//        else
//        {
//            appDelegate?.window?.rootViewController?.present(Static.refreshView!, animated: true, completion: {
//                completion()
//            })
//        }
//
//
//    }
    
    
}




