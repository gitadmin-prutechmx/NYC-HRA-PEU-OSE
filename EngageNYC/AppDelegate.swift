//
//  AppDelegate.swift
//  EncryptDecryptSurvey
//
//  Created by Kamal on 07/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics
import SalesforceSDKCore
import SmartStore
import UserNotifications

// Fill these in when creating a new Connected Application on Force.com
let RemoteAccessConsumerKey = "3MVG9ic.6IFhNpPr8GIEr8R0j25Wf7FJvQXGFDGTgWUsgBwOUUKxTOeyCltrF0fWu9kYbv3OQyqiQDdGdO6OA";
let OAuthRedirectURI        = "testsfdc:///mobilesdk/detect/oauth/done";

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    override
    init()
    {
        super.init()
        showSalesForceLoginView()
    }
    
    func showSalesForceLoginView(){
      
        
        SalesforceSDKManager.setInstanceClass(SalesforceSDKManagerWithSmartStore.self)
        
        SalesforceSDKManager.shared().connectedAppId = RemoteAccessConsumerKey
        SalesforceSDKManager.shared().connectedAppCallbackUri = OAuthRedirectURI
        SalesforceSDKManager.shared().authScopes = ["web", "api"];
        
        
        
        
        //Uncomment the following line inorder to enable/force the use of advanced authentication flow.
        // SFAuthenticationManager.shared().advancedAuthConfiguration = SFOAuthAdvancedAuthConfiguration.require;
        // OR
        // To  retrieve advanced auth configuration from the org, to determine whether to initiate advanced authentication.
        // SFAuthenticationManager.shared().advancedAuthConfiguration = SFOAuthAdvancedAuthConfiguration.allow;
        
        // NOTE: If advanced authentication is configured or forced,  it will launch Safari to handle authentication
        // instead of a webview. You must implement application:openURL:options  to handle the callback.
        
        SalesforceSDKManager.shared().postLaunchAction = {
            [unowned self] (launchActionList: SFSDKLaunchAction) in
            let launchActionString = SalesforceSDKManager.launchActionsStringRepresentation(launchActionList)
            SFSDKLogger.sharedDefaultInstance().log(type(of:self), level:.info, message:"Post-launch: launch actions taken: \(launchActionString)");
            
            self.registerForNotification()
            
            self.saveUserSetting()
            self.setupRootViewController();
        }
        SalesforceSDKManager.shared().launchErrorAction = {
            [unowned self] (error: Error, launchActionList: SFSDKLaunchAction) in
            SFSDKLogger.sharedDefaultInstance().log(type(of:self), level:.error, message:"Error during SDK launch: \(error.localizedDescription)")
            self.initializeAppViewState()
            SalesforceSDKManager.shared().launch()
        }
        SalesforceSDKManager.shared().postLogoutAction = {
            [unowned self] in
            self.handleSdkManagerLogout()
        }
        SalesforceSDKManager.shared().switchUserAction = {
            [unowned self] (fromUser: SFUserAccount?, toUser: SFUserAccount?) -> () in
            self.handleUserSwitch(fromUser, toUser: toUser)
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
    
    func backAction(){
        showSalesForceLoginView()
    }
    

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // If you're using advanced authentication:
        // --Configure your app to handle incoming requests to your
        //   OAuth Redirect URI custom URL scheme.
        // --Uncomment the following line and delete the original return statement:
        
        // return  SFAuthenticationManager.shared().handleAdvancedAuthenticationResponse(url)
        return false;
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
        
        self.window!.rootViewController = InitialViewController(nibName: nil, bundle: nil)
        self.window!.makeKeyAndVisible()
    }
    
    func setupRootViewController()
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let rootVC = storyboard.instantiateViewController(withIdentifier: "loginIdentfier") as! LoginViewController
        
        
        
       // let rootVC = LoginViewController(nibName: nil, bundle: nil)
        let navVC = UINavigationController(rootViewController: rootVC)
        self.window!.rootViewController = navVC
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
               
                SalesforceSDKManager.shared().launch()
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
 
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        //
        // Uncomment the code below to register your device token with the push notification manager
        //
        //
        
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
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        
        
        UNUserNotificationCenter.current().delegate = self
        
        //change status bar color
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .lightContent
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor = UIColor.clear
        
        
        
        // Override point for customization after application launch.
        do {
            Network.reachability = try Reachability(hostname: "www.google.com")
            do {
                try Network.reachability?.start()
            } catch let error as Network.Error {
                print(error)
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.initializeAppViewState();
        
       // Appearance.configure(UIColor(named: .themeBackgroundPrimary))
        
       
        
        //
        //Uncomment the code below to see how you can customize the color, textcolor, font and fontsize of the navigation bar
        //
        let loginViewController = SFLoginViewController.sharedInstance();
       
       
//        let leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.backAction))
//        loginViewController.navigationController?.navigationItem.leftBarButtonItem  = nil
//         loginViewController.navigationController?.navigationItem.leftBarButtonItem  = leftBarButtonItem
//        
        //Set showNavBar to NO if you want to hide the top bar
        // loginViewController.showNavbar = true;
        //Set showSettingsIcon to NO if you want to hide the settings icon on the nav bar
        loginViewController.showSettingsIcon = false;
        // Set primary color to different color to style the navigation header
        // loginViewController.navBarColor = UIColor(red: 0.051, green: 0.765, blue: 0.733, alpha: 1.0);
        // loginViewController.navBarFont = UIFont (name: "Helvetica Neue", size: 16);
        // loginViewController.navBarTextColor = UIColor.black;
        //
        SalesforceSDKManager.shared().launch()
    
     
        
       /* SFAuthenticationManager.shared().login(completion: {
            com in
            print(com)
        }, failure: {
            error in
            print(error)
        })
*/
        
        return true
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
    
  
    
    
    
    //MARK:- Initalize app
    func saveUserSetting(){
        
        
        let userSettingData = ManageCoreData.fetchData(salesforceEntityName: "Setting", isPredicate:false) as! [Setting]
        
        if(userSettingData.count == 0){
            
            let settingData = Setting(context: context)
            
            settingData.settingsId = "1"
            
            settingData.forgotPasswordUrl = ""
            
            settingData.offlineSyncTime = "2"
            
            settingData.basemapUrl = ""
            settingData.featureLayerUrl = ""
            
            
            appDelegate.saveContext()
            
        }
        
        
    }
    
    func getUserSetting(){
        
        let userSettingData = ManageCoreData.fetchData(salesforceEntityName: "Setting", isPredicate:false) as! [Setting]
        
        if(userSettingData.count > 0){
            
            SalesforceConfig.currentBaseMapUrl = userSettingData[0].basemapUrl!
            SalesforceConfig.currentFeatureLayerUrl = userSettingData[0].featureLayerUrl!
            SalesforceConfig.currentGeodatabaseUrl = userSettingData[0].geodatabaseUrl!
            
        }
        
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




