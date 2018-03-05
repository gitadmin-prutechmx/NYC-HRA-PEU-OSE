//
//  SettingsAPI.swift
//  EngageNYCDev
//
//  Created by Kamal on 11/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation

final class SettingsAPI
{
    
    private static var sharedInstance: SettingsAPI = {
        let instance = SettingsAPI()
        return instance
    }()
    
    class var shared:SettingsAPI!{
        get{
            return sharedInstance
        }
    }
    
    func getOfflineSyncTime()->String{
        
        let  settingRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.settings.rawValue, isPredicate:false) as! [Setting]
        
        return (settingRes.first?.offlineSyncTime)!
        
    }
    
    func getESRILayerLink()->String{
        
        let  settingRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.settings.rawValue, isPredicate:false) as! [Setting]
        
        return (settingRes.first?.featureLayerUrl)!
        
    }
    
    func getMapZipFilePath()->String{
        
        var mapFilepath:String = ""
        
        let  settingRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.settings.rawValue, isPredicate:false) as! [Setting]
        
        if let filePath = settingRes.first?.mapZipFilePath{
            mapFilepath = filePath
        }
        
        return mapFilepath
       
        
    }
    
    func getSettings()->[Setting]?{
        let settingRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.settings.rawValue, isPredicate:false) as? [Setting]
        
        return settingRes
        
        
    }
    
    func saveSettings(layerLink:String){
        
        let settingObject = Setting(context: context)
        settingObject.settingsId = "1"
        settingObject.offlineSyncTime = "2"
        settingObject.featureLayerUrl = layerLink
        settingObject.isSyncON = true
        settingObject.mapZipFilePath = ""
        
        appDelegate.saveContext()
    }
    
    func updateSettings(objSettings:SettingsDO){
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["offlineSyncTime"] = objSettings.offlineSyncTime as AnyObject
        updateObjectDic["isSyncON"] = objSettings.isSyncOn as AnyObject
        
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.settings.rawValue, updateKeyValue: updateObjectDic,isPredicate: false)
        
    }
    
    func updateMapZipFilePathSetting(mapZipFilePath:String){
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["mapZipFilePath"] = mapZipFilePath as AnyObject
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.settings.rawValue, updateKeyValue: updateObjectDic,isPredicate: false)
        
    }
    
    func updateESRILayerLink(layerLink:String){
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["featureLayerUrl"] = layerLink as AnyObject
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.settings.rawValue, updateKeyValue: updateObjectDic,isPredicate: false)
        
    }
    
    
   
    
   
}

