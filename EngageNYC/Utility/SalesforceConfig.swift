//
//  SalesforceConfig.swift
//  Knock
//
//  Created by Kamal on 12/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import Foundation

class SalesforceConfig{
    
    static let key = "hdsfjksdhf548954"
    static let iv = "1234567890123456"
    
    static var clientId:String = ""
    static var clientSecret:String = ""
    static var hostUrl:String = ""
    static var userName:String = ""
    static var password:String = ""
    static var isSavedUserName:String = ""
    
    static var currentUserEmail:String = ""
    static var currentUserContactId:String = ""
    static var currentUserExternalId:String = ""
    static var currentContactName:String = ""
    
    static var currentBaseMapUrl:String = ""
    static var currentFeatureLayerUrl:String = ""
    static var currentOfflineSyncTime:Int = 2
    static var currentBaseMapDate:NSDate!
    static var currentBackgroundDate:Date!
    static var currentGeodatabaseUrl:String = ""
    
    static var isBaseMapNeedToDownload:Bool!
    
}
