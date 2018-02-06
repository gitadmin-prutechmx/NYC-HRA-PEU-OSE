

import UIKit

/**
 * View controller that supports broadcast receiving
 *
 * - author: MTX
 * - version: 1.0
 */
class BroadcastReceiverViewController: UIViewController {
    
    /// receiver object
    var broadcastReceiver: BroadcastReceiver!
    
    /**
    intializer
     
     - parameter coder: decoder
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupBroadcastReceiver()
    }
    
    /**
    intializer
     
     - parameter nibNameOrNil:   nib name
     - parameter nibBundleOrNil: bundle name
     */
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
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
extension BroadcastReceiverViewController: BroadcastReceiverDelegate {
    
    /**
     on receive method
     
     - parameter notification: notification data
     */
    @objc func onReceive(notification: NSNotification) {
        Logger.shared.log(level: .debug, msg: "Notification: Received: \(notification.name.rawValue)")
    }
}
