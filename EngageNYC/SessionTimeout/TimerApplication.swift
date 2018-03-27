//
//  TimerApplication.swift
//  EngageNYC
//
//  Created by Kamal on 23/03/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class TimerApplication: UIApplication {
    
    override func sendEvent(_ event: UIEvent) {
        
        super.sendEvent(event)
        
        if Static.sessionTimer != nil {
            Logger.shared.log(level: .info, msg: "Restart Timer")
            Utility.resetSessionTimer()
        }
        
        if let touches = event.allTouches {
            for touch in touches where touch.phase == UITouchPhase.began {
                Utility.resetSessionTimer()
            }
        }
    }
}
