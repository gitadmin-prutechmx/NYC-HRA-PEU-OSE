//
//  BroadcastReceiverNSObject.swift
//
//

import UIKit

class BroadcastReceiverNSObject: NSObject {
    
    /// receiver object
    var broadcastReceiver: BroadcastReceiver!
    
    /**
     intializer
     
     - parameter coder: decoder
     */
    override init() {
        super.init()
        self.setupBroadcastReceiver()
    }
    
    /**
     cleanup
     */
    deinit {
        if broadcastReceiver != nil {
            CustomNotificationCenter.unregisterReceiver(receiver: broadcastReceiver)
            self.broadcastReceiver = nil
        }
    }
    
    /**
     setups receiver
     */
    func setupBroadcastReceiver() {
        self.broadcastReceiver = BroadcastReceiver(targetClass: self)
    }
    
}

// MARK: - BroadcastReceiverDelegate

extension BroadcastReceiverNSObject: BroadcastReceiverDelegate {
    
    /**
     on receive method
     
     - parameter notification: notification data
     */
    @objc func onReceive(notification: NSNotification) {
        Logger.shared.log(level: .debug, msg: "Notification: Received: \(notification.name.rawValue)")
    }
    
}
