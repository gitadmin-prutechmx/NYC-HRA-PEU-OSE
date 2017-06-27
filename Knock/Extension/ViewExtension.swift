//
//  ViewExtension.swift
//  Knock
//
//  Created by Kamal on 27/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import Foundation
import AudioToolbox

extension UIView {
    
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(animation, forKey: "position")
        
        // AudioServicesCreateSystemSoundID((__bridge CFURLRef)pewPewURL, &_engineSound);
        // AudioServicesPlaySystemSound(_engineSound);
        
        AudioServicesPlaySystemSound(1519)
        //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
}

