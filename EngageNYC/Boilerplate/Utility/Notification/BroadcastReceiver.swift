//
//  BroadcastReceiver.swift
//
//
//  Created by MTX on 01/06/2018
//

import UIKit

/**
* Receiver delegate protocol
*
* - author: MTX
* - version: 1.0
*/
protocol BroadcastReceiverDelegate: NSObjectProtocol {
    
    /**
    on receive method
    
    - parameter notification: notification data
    */
    func onReceive(notification: NSNotification)
    
}


/**
* Broadcast receiver
*
* :author: MTX
* :version: 1.0
*/
class BroadcastReceiver: NSObject {
    
    /// observers
    var observers: [SF_NOTIFICATION: AnyObject] = [:]
    
    /// target
    weak var target: BroadcastReceiverDelegate?
    
    /**
    designated initializer
    
    - parameter targetClass: target for receiver
    */
    init(targetClass: BroadcastReceiverDelegate) {
        target = targetClass
    }
    
    /// is registered or not
    var isRegistered: Bool {
        return !observers.isEmpty
    }
    
}
