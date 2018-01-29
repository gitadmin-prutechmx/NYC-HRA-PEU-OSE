//
//  SettingsViewModel.swift
//  EngageNYC
//
//  Created by Kamal on 28/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation

class SettingsViewModel{
    
    static func getViewModel() -> SettingsViewModel {
        return SettingsViewModel()
    }
    
    func getSettings()->SettingsDO{
        
        let settingObj = SettingsDO()
        
        if let settingRes = SettingsAPI.shared.getSettings(){
            
            for settingData in settingRes{
                settingObj.isSyncOn = settingData.isSyncON
                settingObj.offlineSyncTime = settingData.offlineSyncTime
            }
            
        }
        return settingObj
    }
    
    func updateSettings(objSettings:SettingsDO){
        SettingsAPI.shared.updateSettings(objSettings: objSettings)
    }
    
    
}
