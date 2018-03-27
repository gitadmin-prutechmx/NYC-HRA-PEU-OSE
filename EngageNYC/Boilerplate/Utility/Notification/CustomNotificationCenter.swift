//
//  Created by MTX
//

import Foundation

/*
Salesforce notification name and keys
These enum values are used as notification names and as a key for the correspondning data inside a notification.
*/
public enum SF_NOTIFICATION: String {
    
    // Notification Names
    case NOTIFICATION_CONNECTION_STATUS = "notification.CONNECTION_STATUS"
    
    // HTTP ERROR Notifications
    case NOTIFICATION_HTTP_GET_ERROR = "notification.HTTP_GET_ERROR"
    case NOTIFICATION_HTTP_REQUEST_ERROR_DURING_LOGIN = "notification.HTTP_REQUEST_ERROR_DURING_LOGIN"
    case NOTIFICATION_HTTP_REQUEST_WARNING_DURING_LOGIN = "notification.HTTP_REQUEST_WARNING_DURING_LOGIN"
    
    // MMNetworkConnectivity Notifications
    case NOTIFICATION_WIFI_CONNECTIVITY = "notification.WIFI_CONNECTIVITY"
    case NOTIFICATION_WWAN_CONNECTIVITY = "notification.WWAN_CONNECTIVITY"
    case NOTIFICATION_HOST_REACHABILITY = "notification.HOST_REACHABILITY"
    case NOTIFICATION_NETWORK_REACHABILITY = "notification.NETWORK_REACHABILITY"
    
    case NOTIFICATION_NETWORK_DID_CHANGE = "notification.NETWORK_DID_CHANGE"
    
    case KEY_NETWORK_WIFI_STATE = "key.WIFI_STATE"
    case KEY_NETWORK_WWAN_STATE = "key.WWAN_STATE"
    case KEY_NETWORK_HOST_REACHABILITY = "key.HOST_REACHABILITY"
    case KEY_NETWORK_REACHABILITY = "key.NETWORK_REACHABILITY"
    
    case ALL_DATA = "all.data"
    case DASHBOARD_SYNC = "dashboard.sync"
    case LOCATIONLISTING_SYNC = "locationlisting.sync"
    case UNITLISTING_SYNC = "unitlisting.sync"
    case CLIENTLISTING_SYNC = "clientlisting.sync"
    case EVENTREGLISTING_SYNC = "eventreglisting.sync"
    case INTAKECLIENTLISTING_SYNC = "intakeclientlisting.sync"
    case INTAKECASELISTING_SYNC = "intakecaselisting.sync"
    case INTAKEISSUELISTING_SYNC = "intakeissuelisting.sync"
    
    
    case APP_TIMEOUT = "app.timeout"
}

/**
* Notification center
*
* - author: MTX
* - version: 1.0
**/
class CustomNotificationCenter {
    
    /**
    Send given notification
    
    - parameter notificationType: the type of the notification
    - parameter sender:           the senter
    - parameter userInfo:         the userInfo
    */
    class func sendNotification(notificationType: SF_NOTIFICATION, sender: AnyObject? = nil,
        userInfo: [NSObject: AnyObject]? = nil) {
        CustomNotificationCenter.sendNotification(notificationName: notificationType.rawValue, sender: sender, userInfo: userInfo)
    }
    
    /**
    Send given notification
    
    - parameter notificationName: the name of the notification
    - parameter sender:           the senter
    - parameter userInfo:         the userInfo
    */
    class func sendNotification(notificationName: String, sender: AnyObject? = nil,
        userInfo: [NSObject: AnyObject]? = nil) {
        Logger.shared.log(level: .debug, msg: "Notification: Sending \(notificationName)")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationName), object: sender, userInfo: userInfo)
    }
    
    /**
    registers receiver for notification
    
    - parameter receiver: receiver
    - parameter name:     notification type
    */
    class func registerReceiver(receiver: BroadcastReceiver, notificationName name: SF_NOTIFICATION) {
        let observer:AnyObject = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: name.rawValue), object: nil, queue: OperationQueue.main) { (notification) in
            if let target = receiver.target {
                target.onReceive(notification: notification as NSNotification)
            } else
            {
                print("Error sending notification.")
            }
        }
        receiver.observers[name] = observer
    }
    
    /**
    registers receiver for list of notifications
    
    - parameter receiver: receiver
    - parameter list:     list of notifications
    */
    class func registerReceiver(receiver: BroadcastReceiver, notificationList list: [SF_NOTIFICATION]) {
        for name in list {
            self.registerReceiver(receiver: receiver, notificationName: name)
        }
    }
    
    /**
    unregisters a receiver from all notifications
    
    - parameter receiver: receiver
    */
    class func unregisterReceiver(receiver: BroadcastReceiver?) {
        if let receiver = receiver {
            for observer: AnyObject in receiver.observers.values {
                NotificationCenter.default.removeObserver(observer)
            }
            receiver.observers.removeAll()
        }
    }
    
    /**
    unregisters a receiver from a notification
    
    - parameter notificationName: notification type
    - parameter receiver:         receiver
    */
    class func unregisterNotification(notificationName: SF_NOTIFICATION, forReceiver receiver: BroadcastReceiver?) {
        if let receiver = receiver {
            if let observer = receiver.observers[notificationName] {
                NotificationCenter.default.removeObserver(observer)
                receiver.observers.removeValue(forKey: notificationName)
            }
        }
    }
    
}
