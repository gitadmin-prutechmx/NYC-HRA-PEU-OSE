

//
//  ATConstant.swift
//  aligntech-stpe
//
//  Created by Blaine Rothrock on 5/9/17.
//  Copyright © 2017 Align Technology Inc. All rights reserved.
//

import Foundation

/**
 * Constant Keys
 *
 * - author: MTX
 * - version: 1.0
 */
enum ConstantKey: String {
    case LOG_LEVEL = "LogLevel"
    case NavigationMenu = "NavigationMenu"
}

enum SystemConstantKey: String {
    case SF_REMOTE_ACTION_CONSUMER_KEY = "SFRemoteAccessConsumerKey"
    case SF_LOGIN_HOST = "SFLoginHost"
    case SF_OAUTH_REDIRECT_URI = "SFOAuthRedirectURI"
    case SF_AUTH_SCOPES = "SFAuthScopes"
    case SF_ENVIRONMENT_KEY = "SFEnvironment"
    case ESRI_PORTAL_LINK = "ESRIPortalLink"
    case ESRI_USERNAME = "ESRIUsername"
    case ESRI_PASSWORD = "ESRIPassword"
    case ESRI_RUNTIME_LITE_LICENSE_KEY = "ESRIRuntimeLiteLicenseKey"
    case ESRI_RUNTIME_SMPNA_EXTENSION_LICENSE_KEY = "ESRIRuntimeSMPNAExtensionLicenseKey"
}

/**
 * Constant Singleton Class
 *
 * - author: MTX
 * - version: 1.0
 */


class Constant {
    
    // singleton
    static let shared = Constant()
    
    // dictionary representation of .plst file
    //private let constDict: [String: AnyObject]!
    private let systemConstDict: [String: AnyObject]!
    
    
    /*
     private init for singleton
    */
    private init() {
//        let path = Bundle.main.path(forResource: "Constant", ofType: "plist")
//        self.constDict = NSDictionary(contentsOfFile: path!) as! [String: AnyObject]
        
        let infoPath = Bundle.main.path(forResource: "Info", ofType: "plist")
        self.systemConstDict = NSDictionary(contentsOfFile: infoPath!) as! [String: AnyObject]
    }
    
    
    /*
     Retrieve constants from plist file
     
     - parameter: key: ConstantKey to retrieve
    */
//    func getConstant(withKey key:ConstantKey) -> AnyObject {
//        return constDict[key.rawValue]!
//    }
//
//    func getConstant(withKeyString keyString:String) -> AnyObject {
//        return constDict[keyString]!
//    }
//
    func getSystemConstant(withKey key:SystemConstantKey) -> AnyObject {
        return systemConstDict[key.rawValue]!
    }
}
