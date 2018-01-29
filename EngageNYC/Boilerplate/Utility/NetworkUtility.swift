//
//  ATNetworkUtility.swift
//  aligntech-stpe
//
//  Created by Blaine Rothrock on 5/2/17.
//  Copyright © 2017 Align Technology Inc. All rights reserved.
//

import Foundation
import SystemConfiguration

/**
 wifi state
 */
enum WIFI_STATE : Int {
    case DISCONNECTED = 0
    case CONNECTED
}
/**
 wwan state
 */
enum WWAN_STATE : Int {
    case DISCONNECTED = 0
    case CONNECTED
}
/**
 reachability status
 */
enum HOST_REACHABILITY : Int {
    case HOST_NOT_REACHABLE = 0
    case HOST_REACHABLE_VIA_WIFI
    case HOST_REACHABLE_VIA_WWAN
}

/// network states descriptions
let networkState = ["Down: NotReachable", "UP: ReachableViaWifi", "UP: ReachableViaWWAN"]

/**
 * This Interface object contains network reachability information
 * Any Network Connectivity related messages should be sent to this object
 * It could be WIFI or 3G or Edge etc.
 *
 * - author: TCCODER
 * - version: 1.0
 */

final class NetworkUtility: NSObject {
    // rechability objects
    private var hostReach: Reachability!
    private var networkReach: Reachability!
    private var wifiReach: Reachability!
    
    // MARK: Singleton
    static let shared:NetworkUtility = NetworkUtility()
    
    /// returns text description
    override var description: String {
        return "[ATNetworkUtility]"
    }
    
    // MARK: - Registration API's:
    /**
     Register for Reachability Notifications whenever there is a change in
     1. Wifi and WWAN
     2. Host Name and HostAddress
     By default: Wifi status notifications are turned on: and WWAN is turned off in appDelegate
     
     - parameter enable: true to enable
     - parameter wwan:   true to enable wwan
     */
    func registerReachabliliyNotificationsForWifi(enable: Bool, AndWWAN wwan: Bool) {
        // Register for  kNetworkReachabilityChangedNotification.
        // reachanbilityChanged function is a callback fromthe NotificatoinCenter
        // Register Notification to get the internet connectivity status
        if wwan {
            self.networkReach = Reachability.forInternetConnection()
            self.networkReach.startNotifier()
        }
        // Register Notification get the Wifi Connectivity Status
        if enable {
            self.wifiReach = Reachability.forLocalWiFi()
            self.wifiReach.startNotifier()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(NetworkUtility.reachabilityChanged(note:)), name: NSNotification.Name.reachabilityChanged, object: nil)
    }
    
    /**
     registers for reachability notifications for a host name
     
     - parameter hostName: host name
     */
    func registerReachabliliyNotificationsWithHostName(hostName: String) {
        // Stop The Notifier if started
        self.hostReach.stopNotifier()
        self.hostReach = nil
        // Start the Notifier
        self.hostReach = Reachability(hostName: hostName)
        self.hostReach.startNotifier()
    }
    
    /**
     registers for reachability notifications on a host address
     
     - parameter hostAddress: host address
     */
    func registerReachabliliyNotificationsWithAddress(hostAddress: UnsafePointer<sockaddr_in>) {
        // Stop The Notifier if started
        self.hostReach.stopNotifier()
        self.hostReach = nil
        // Start the Notifier
        self.hostReach = Reachability(address: hostAddress)
        self.hostReach.startNotifier()
    }
    
    // MARK: - UnRegister the Reachability Notifications:
    
    /**
     UnRegister for kNetworkReachabilityChangedNotification
     */
    func unregisterReachabilityNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.reachabilityChanged, object: nil)
        // Stop All the Notifications registered.
        self.hostReach.stopNotifier()
        self.networkReach.stopNotifier()
        self.wifiReach.stopNotifier()
    }
    
    // MARK: - Connectivity Status Indication API whenever application requires it
    /**
     checks for any connection
     
     - returns: true if connected
     */
    func isConnected() -> Bool {
        let curStatus: NetworkStatus = networkReach.currentReachabilityStatus()
        if curStatus == .NotReachable {
            return false
        }
        else if curStatus == .ReachableViaWWAN {
            return true
        }
        else if curStatus == .ReachableViaWiFi {
            return true
        }
        
        return false
    }
    
    /**
     checks if wifi is connected
     
     - returns: true if wifi is connected
     */
    func isWifiConnected() -> Bool {
        let curStatus: NetworkStatus = networkReach.currentReachabilityStatus()
        if curStatus == .NotReachable {
            return false
        }
        else if curStatus == .ReachableViaWiFi {
            return true
        }
        
        return false
    }
    
    /**
     checks if wwan is connected
     
     - returns: true if wwan is connected
     */
    func isWwanConnected() -> Bool {
        let curStatus: NetworkStatus = networkReach.currentReachabilityStatus()
        if curStatus == .NotReachable {
            return false
        }
        else if curStatus == .ReachableViaWWAN {
            return true
        }
        
        return false
    }
    
    /**
     reachability change observer
     
     - parameter note: notification
     */
    @objc func reachabilityChanged(note: NSNotification) {
        let curReach: Reachability = note.object! as! Reachability
        var dict: [NSObject : AnyObject]
        let status: NetworkStatus = curReach.currentReachabilityStatus()
        if curReach == self.wifiReach {
            // Send the Notification to the Application
            var wifiState: WIFI_STATE
            if status == .ReachableViaWiFi {
                wifiState = .CONNECTED
            }
            else {
                wifiState = .DISCONNECTED
            }
            dict = [SF_NOTIFICATION.KEY_NETWORK_WIFI_STATE.rawValue as NSObject: wifiState.rawValue as AnyObject]
            DispatchQueue.main.async() {
                CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.NOTIFICATION_WIFI_CONNECTIVITY.rawValue, sender: self, userInfo: dict as [NSObject : AnyObject])
            }
        }
        else if curReach == self.networkReach {
            // LOGI(LOG_TAG, @" networkReachabilityChanged: %d",(integer_t)status);
            var wwanState: WWAN_STATE
            if status == .ReachableViaWWAN {
                wwanState = .CONNECTED
            }
            else {
                wwanState = .DISCONNECTED
            }
            dict = [SF_NOTIFICATION.KEY_NETWORK_WWAN_STATE.rawValue as NSObject: wwanState.rawValue as AnyObject]
            DispatchQueue.main.async() {
                CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.NOTIFICATION_WWAN_CONNECTIVITY.rawValue, sender: self, userInfo: dict as [NSObject : AnyObject])
            }
            // Send the Notification to the Application
        }
        else if curReach == self.hostReach {
            // LOGI(LOG_TAG, @" HostReachabilityChanged:");
            // HOST_REACHABILITY reachState;
            // Notify Applicatoin about the Reachability of the given host
            dict = [SF_NOTIFICATION.KEY_NETWORK_HOST_REACHABILITY.rawValue as NSObject: status.rawValue as AnyObject]
            DispatchQueue.main.async() {
                CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.NOTIFICATION_HOST_REACHABILITY.rawValue, sender: self, userInfo: dict as [NSObject : AnyObject])
            }
        }
        
    }
    
    /**
     Register to Notify for Internet connection
     It could be either through Wifi or 3G
     */
    func registerForNetworkConnectivityStatus() {
        self.networkReach = Reachability.forInternetConnection()
        self.networkReach.startNotifier()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.reachabilityChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NetworkUtility.networkConnectivityStatusChanged(note:)), name: NSNotification.Name.reachabilityChanged, object: nil)
    }
    
    /**
     notification observer
     
     - parameter note: notification
     */
    @objc func networkConnectivityStatusChanged(note: NSNotification) {
        DispatchQueue.main.async {
            let curReach: Reachability = note.object! as! Reachability
            let status: NetworkStatus = curReach.currentReachabilityStatus()
            let dict: [NSObject : AnyObject] = [SF_NOTIFICATION.KEY_NETWORK_REACHABILITY.rawValue as NSObject: status.rawValue as AnyObject]
            DispatchQueue.main.async {
                CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.NOTIFICATION_NETWORK_REACHABILITY.rawValue, sender: self, userInfo: dict as [NSObject : AnyObject])
            }
        }
    }
    
    /**
     returns current network status
     
     - returns: network status
     */
    func networkStatus() -> NetworkStatus {
        return networkReach.currentReachabilityStatus()
    }
}
