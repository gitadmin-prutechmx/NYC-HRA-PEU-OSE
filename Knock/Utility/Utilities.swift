//
//  Utilities.swift
//  Knock
//
//  Created by Kamal on 12/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import Foundation
import UIKit

class Utilities {

    class func convertToJSON(text: String) ->  [String: Any]? {
        
        if let data = text.data(using: .utf8) {
            
            do {
                
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
            } catch {
                
                print(error.localizedDescription)
                
            }
            
        }
        
        return nil
        
    }
    
    class func decryptJsonData(jsonEncryptString:String) -> String{
        
        
        
          //  var returnjsonData:Data?
        
            
            //Remove first two characters
            
            let startIndex = jsonEncryptString.index(jsonEncryptString.startIndex, offsetBy: 1)
            
            let headString = jsonEncryptString.substring(from: startIndex)
            
            
        
            //Remove last two characters
            
            let endIndex = headString.index(headString.endIndex, offsetBy: -1)
            
            let trailString = headString.substring(to: endIndex)
            
            
            let decryptData = try! trailString.aesDecrypt(SalesforceConfig.key, iv: SalesforceConfig.iv)
            
            
            
           // returnjsonData = decryptData.data(using: .utf8)
            
        
        
        
        return decryptData
        
    }

}

