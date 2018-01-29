//
//  AppDelegate.swift
//
//  Created by Kamal on 07/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit
import CoreData
import SalesforceSDKCore
import SmartStore
import UserNotifications
import IQKeyboardManagerSwift
import ArcGIS



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    /// broadcast receiver
    var broadcastReceiver: BroadcastReceiver!
    
    override init()
    {
        super.init()
        
        Logger.shared.log(level: .debug, msg: "testing the logger")
        
        do {
            
            let result = try AGSArcGISRuntimeEnvironment.setLicenseKey((Constant.shared.getSystemConstant(withKey: .ESRI_RUNTIME_LITE_LICENSE_KEY) as? String)!,extensions: [(Constant.shared.getSystemConstant(withKey: .ESRI_RUNTIME_SMPNA_EXTENSION_LICENSE_KEY) as? String)!])
            
            Logger.shared.log(level: .info, msg: "\(result.licenseStatus)")
            print("License Result : \(result.licenseStatus)")
        }
        catch let error as NSError {
            Logger.shared.log(level: .error, msg: "\(error)")
            print("error: \(error)")
        }
        
        
        SalesforceSDKManager.shared().connectedAppId = Constant.shared.getSystemConstant(withKey: .SF_REMOTE_ACTION_CONSUMER_KEY) as? String
        SalesforceSDKManager.shared().connectedAppCallbackUri = Constant.shared.getSystemConstant(withKey: .SF_OAUTH_REDIRECT_URI) as? String
        SalesforceSDKManager.shared().authScopes = Constant.shared.getSystemConstant(withKey: .SF_AUTH_SCOPES) as? Array
        
        
        SalesforceSDKManager.shared().postLaunchAction = {
            [unowned self] (launchActionList: SFSDKLaunchAction) in
            let launchActionString = SalesforceSDKManager.launchActionsStringRepresentation(launchActionList)
            Logger.shared.log(level: .info, msg: "Post-launch: launch action taken: \(launchActionString)")
            let session = URLSessionConfiguration.default
            SFNetwork.setSessionConfiguration(session, isBackgroundSession: true)
            
            self.registerForNotification()
            self.setupRootViewController();
        }
        
        SalesforceSDKManager.shared().launchErrorAction = {
            [unowned self] (error: Error, launchActionList: SFSDKLaunchAction) in
            Logger.shared.log(level: .error, msg: error.localizedDescription)
            self.initializeAppViewState()
            SalesforceSDKManager.shared().launch()
        }
        
        SalesforceSDKManager.shared().postLogoutAction = {
            [unowned self] in
         
            (UIApplication.shared.delegate as! AppDelegate).clean()
            self.handleSdkManagerLogout()
        }
        
        SalesforceSDKManager.shared().switchUserAction = {
            [unowned self] (fromUser: SFUserAccount?, toUser: SFUserAccount?) -> () in
            self.handleUserSwitch(fromUser, toUser: toUser)
        }
        
        SalesforceSDKManager.shared().useSnapshotView = true
        let snapshot:SFSnapshotViewControllerCreationBlock = {() in
            return brandingStoryboard().instantiateInitialViewController()!
        }
        
        SalesforceSDKManager.shared().snapshotViewControllerCreationAction = snapshot
    }
    

    

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // If you're using advanced authentication:
        // --Configure your app to handle incoming requests to your
        //   OAuth Redirect URI custom URL scheme.
        // --Uncomment the following line and delete the original return statement:
        
        // return  SFAuthenticationManager.shared().handleAdvancedAuthenticationResponse(url)
        return false;
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        SFPushNotificationManager.sharedInstance().didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
        if (SFUserAccountManager.sharedInstance().currentUser?.credentials.accessToken != nil)
        {
            SFPushNotificationManager.sharedInstance().registerForSalesforceNotifications()
            
            
        }
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error )
    {
        // Respond to any push notification registration errors here.
        print(error.localizedDescription)
    }
    
    
    // MARK: - App delegate lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        
        UNUserNotificationCenter.current().delegate = self
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.initializeAppViewState();
        IQKeyboardManager.sharedManager().enable = true
        
        NetworkUtility.shared.registerForNetworkConnectivityStatus()
        broadcastReceiver = BroadcastReceiver(targetClass: self)
        CustomNotificationCenter.registerReceiver(receiver: self.broadcastReceiver, notificationName: SF_NOTIFICATION.NOTIFICATION_NETWORK_REACHABILITY)
        
        //
        // If you wish to register for push notifications, uncomment the line below.  Note that,
        // if you want to receive push notifications from Salesforce, you will also need to
        // implement the application:didRegisterForRemoteNotificationsWithDeviceToken: method (below).
        //
        // SFPushNotificationManager.sharedInstance().registerForRemoteNotifications()
        
        //
        //Uncomment the code below to see how you can customize the color, textcolor, font and fontsize of the navigation bar
        //
        
        let loginViewController = SFLoginViewController.sharedInstance();
        //Set showNavBar to NO if you want to hide the top bar
        // loginViewController.showNavbar = true;
        //Set showSettingsIcon to NO if you want to hide the settings icon on the nav bar
        loginViewController.showSettingsIcon = false;
        // Set primary color to different color to style the navigation header
        loginViewController.navBarColor = UIColor.Charcoal
        loginViewController.navBarFont = UIFont (name: "NHaasGroteskDSPro-55Rg", size: 16);
        loginViewController.navBarTextColor = UIColor.white;
        //
        
        if SFUserAccountManager.sharedInstance().currentUser == nil && NetworkUtility.shared.isConnected() == false{
            if let brandingScreen = brandingStoryboard().instantiateInitialViewController()
            {
                self.window!.rootViewController = brandingScreen
            }
        }
        else{
            SalesforceSDKManager.shared().launch()
        }
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        return true
    }
    
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        return true
    }
    
    
   
    
    func showSalesForceLoginView(){
        
        //Uncomment the following line inorder to enable/force the use of advanced authentication flow.
        // SFAuthenticationManager.shared().advancedAuthConfiguration = SFOAuthAdvancedAuthConfiguration.require;
        // OR
        // To  retrieve advanced auth configuration from the org, to determine whether to initiate advanced authentication.
        // SFAuthenticationManager.shared().advancedAuthConfiguration = SFOAuthAdvancedAuthConfiguration.allow;
        
        // NOTE: If advanced authentication is configured or forced,  it will launch Safari to handle authentication
        // instead of a webview. You must implement application:openURL:options  to handle the callback.
        
        
    }
    
    
    
    // MARK: - Private methods
    func initializeAppViewState()
    {
        if (!Thread.isMainThread) {
            DispatchQueue.main.async {
                self.initializeAppViewState()
            }
            return
        }
        
        self.window?.rootViewController = brandingStoryboard().instantiateInitialViewController()
        self.window!.makeKeyAndVisible()
    }
    
    func setupRootViewController()
    {
        if let navigation = dashboardStoryboard().instantiateInitialViewController()
        {
            self.window!.rootViewController = navigation
        }
    }
    
    func resetViewState(_ postResetBlock: @escaping () -> ())
    {
        if let rootViewController = self.window!.rootViewController {
            if let _ = rootViewController.presentedViewController {
                rootViewController.dismiss(animated: false, completion: postResetBlock)
                return
            }
        }
        
        postResetBlock()
    }
    
    func handleSdkManagerLogout()
    {
        
        SFSDKLogger.sharedDefaultInstance().log(type(of:self), level:.debug, message: "SFAuthenticationManager logged out.  Resetting app.")
        self.resetViewState { () -> () in
            self.initializeAppViewState()
            
            // Multi-user pattern:
            // - If there are two or more existing accounts after logout, let the user choose the account
            //   to switch to.
            // - If there is one existing account, automatically switch to that account.
            // - If there are no further authenticated accounts, present the login screen.
            //
            // Alternatively, you could just go straight to re-initializing your app state, if you know
            // your app does not support multiple accounts.  The logic below will work either way.
            
            var numberOfAccounts : Int;
            let allAccounts = SFUserAccountManager.sharedInstance().allUserAccounts()
            numberOfAccounts = (allAccounts!.count);
            
            if numberOfAccounts > 1 {
                let userSwitchVc = SFDefaultUserManagementViewController(completionBlock: {
                    action in
                    self.window!.rootViewController!.dismiss(animated:true, completion: nil)
                })
                if let actualRootViewController = self.window!.rootViewController {
                    actualRootViewController.present(userSwitchVc!, animated: true, completion: nil)
                }
            } else {
                if (numberOfAccounts == 1) {
                    SFUserAccountManager.sharedInstance().currentUser = allAccounts![0]
                }
               
                if SFUserAccountManager.sharedInstance().currentUser == nil && NetworkUtility.shared.isConnected() == false{
                    if let brandingScreen = brandingStoryboard().instantiateInitialViewController()
                    {
                        self.window!.rootViewController = brandingScreen
                    }
                }
                else{
                    SalesforceSDKManager.shared().launch()
                }
                
               
            }
        }
    }
    
    func handleUserSwitch(_ fromUser: SFUserAccount?, toUser: SFUserAccount?)
    {
        let fromUserName = (fromUser != nil) ? fromUser?.userName : "<none>"
        let toUserName = (toUser != nil) ? toUser?.userName : "<none>"
        SFSDKLogger.sharedDefaultInstance().log(type(of:self), level:.debug, message:"SFUserAccountManager changed from user \(String(describing: fromUserName)) to \(String(describing: toUserName)).  Resetting app.")
        self.resetViewState { () -> () in
            self.initializeAppViewState()
            SalesforceSDKManager.shared().launch()
        }
    }
 
    
    
    
    func registerForNotification(){
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
        
        
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            SFPushNotificationManager.sharedInstance().registerForRemoteNotifications()
            
        }
    }
    
   
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
  
   
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "EngageNYC")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}


extension AppDelegate:BroadcastReceiverDelegate{
    /**
     on receive method
     
     - parameter notification: notification data
     */
    func onReceive(notification: NSNotification) {
        if (notification.name.rawValue == SF_NOTIFICATION.NOTIFICATION_NETWORK_REACHABILITY.rawValue){
            if(NetworkUtility.shared.isConnected() == true){
                if SFUserAccountManager.sharedInstance().currentUser == nil{
                    SalesforceSDKManager.shared().launch()
                }
                Logger.shared.log(level: .info, msg: "Network Connectivity Changed: Connected to internet")
            }
            else{
                Logger.shared.log(level: .info, msg: "Network Connectivity Changed: Disconnected to internet")
            }
        }
    }
}

extension AppDelegate{
    func deleteAll(entityName: String) -> Error? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        do
        {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            for managedObject in results
            {
                if let managedObjectData:NSManagedObject = managedObject as? NSManagedObject {
                    persistentContainer.viewContext.delete(managedObjectData)
                }
            }
        } catch  {
            return error
        }
        return nil
    }
    
    var objectModel: NSManagedObjectModel? {
        return persistentContainer.managedObjectModel
    }
    
    open func clean() {
        if let models = objectModel?.entities {
            for entity in models {
                if let entityName = entity.name {
                    _ = deleteAll(entityName: entityName)
                }
            }
        }
        do{
            try persistentContainer.viewContext.save()
        }catch{}
        
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
   /* func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
    }
 */
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext




