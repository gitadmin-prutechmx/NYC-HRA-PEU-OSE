//
//  Alert.swift
//  EngageNYC
//
//  Created by Kamal on 12/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation
import UIKit

class Alert{
    
    class func showUIAlert(title:String,message:String,vc:UIViewController)->UIAlertController{
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.setValue(NSAttributedString(string: title, attributes: [NSFontAttributeName :  UIFont(name: "Arial", size: 17.0)!, NSForegroundColorAttributeName : UIColor.black]), forKey: "attributedTitle")
        
        vc.present(alertController, animated: true, completion: nil)
        
        return alertController
    }
}
