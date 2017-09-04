//
//  Alert.swift
//  Knock
//
//  Created by Kamal on 04/09/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class Alert{
    
    class func showUIAlert(title:String,message:String,vc:UIViewController)->UIAlertController{
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.setValue(NSAttributedString(string: title, attributes: [NSFontAttributeName :  UIFont(name: "Arial", size: 17.0)!, NSForegroundColorAttributeName : UIColor.black]), forKey: "attributedTitle")
        
        vc.present(alertController, animated: true, completion: nil)
        
        return alertController
    }
}
