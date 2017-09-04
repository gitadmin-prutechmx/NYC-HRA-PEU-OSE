//
//  LoginViewController.swift
//  MTXGIS
//
//  Created by Kamal on 22/02/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,DownloadProgressViewDelegate {
    
    var noOfAttempts  = 0
    
    var salesforceConfigData = [SalesforceOrgConfig]()
    var userSettingData = [Setting]()
    
    var userInfoData = [UserInfo]()
    
    
    @IBOutlet weak var signInLbl: UILabel!
    @IBOutlet weak var forgotPasswordLbl: UIButton!
    @IBOutlet weak var dontAccountLbl: UILabel!
    @IBOutlet weak var createAccountLbl: UIButton!
    
    @IBOutlet weak var vwEmail: UIView!
    @IBOutlet var loginView: UIView!
    @IBOutlet weak var emailTextField: DesignableTextField!
    @IBOutlet weak var passwordTextField: DesignableTextField!
    
    
    @IBOutlet weak var vwPassword: UIView!
    @IBOutlet weak var loginBtn: UIButton!
    
    var assignmentIdArray = [String]()
    
    var downloadProgressView:DownloadProgressView!
    
    
    func downloadProgressViewDidCancel(downloadProgressView: DownloadProgressView) {
        self.downloadProgressView.dismiss()
        print("Cancel")
    }
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        //self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //initialize download progress view
        self.downloadProgressView = DownloadProgressView()
        self.downloadProgressView.delegate = self
        
        
        saveUserSettings()
        saveSalesforceOrgCredentials()
        
        
        
        //temporaryFunc()
        
        /*
         
         if UserDefaults.standard.object(forKey: "Language") == nil {
         
         if let preferredLanguage = NSLocale.preferredLanguages[0] as String? {
         Utility.LocalizedString = preferredLanguage
         }
         else{
         Utility.LocalizedString = "es-MX"
         }
         
         
         
         Utility.saveLanguageCode(languageCode: Utility.LocalizedString, key: "Language")
         }
         else{
         
         Utility.LocalizedString = Utility.loadLanguageCode(key: "Language")
         
         }
         
         UpdateLocale()
         
         
         
         NotificationCenter.defaultCenter.addObserver(self, selector:#selector(LoginViewController.UpdateLocale), name: "UpdateLocale", object:nil
         )
         
         */
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    /*func UpdateLocale(){
     
     //self.title = "keyLogin".localized(Utility.LocalizedString)
     
     signInLbl.text = "keySignIn".localized(Utility.LocalizedString)
     emailTextField.placeholder = "keyUsername".localized(Utility.LocalizedString)
     passwordTextField.placeholder = "keyPassword".localized(Utility.LocalizedString)
     loginBtn.setTitle("keyLogIn".localized(Utility.LocalizedString), forState: .Normal)
     forgotPasswordLbl.setTitle("keyForgotPassword".localized(Utility.LocalizedString), forState: .Normal)
     dontAccountLbl.text = "keyDontAccount".localized(Utility.LocalizedString)
     createAccountLbl.setTitle("keyCreateAccount".localized(Utility.LocalizedString), forState: .Normal)
     
     
     // self.title = "login".localized(lang: Utility.LocalizedString)
     }
     */
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        emailTextField.text = ""
        passwordTextField.text = ""
        noOfAttempts = 0
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getUserSetting(){
        
        userSettingData = ManageCoreData.fetchData(salesforceEntityName: "Setting", isPredicate:false) as! [Setting]
        
        if(userSettingData.count > 0){
            
            SalesforceConfig.currentBaseMapUrl = userSettingData[0].basemapUrl!
            SalesforceConfig.currentFeatureLayerUrl = userSettingData[0].featureLayerUrl!
            
            // SalesforceConfig.currentOfflineSyncTime = Int(userSettingData[0].offlineSyncTime!)!
            
            
            //background sync time
            
        }
        
    }
    
    
    func saveUserSettings(){
        
        
        userSettingData = ManageCoreData.fetchData(salesforceEntityName: "Setting", isPredicate:false) as! [Setting]
        
        if(userSettingData.count == 0){
            
            let settingData = Setting(context: context)
            
            settingData.settingsId = "1"
            
            settingData.forgotPasswordUrl = "https://dev-providers.cs33.force.com/Core_Forgot_Password_Page"
            
            settingData.offlineSyncTime = "2"
            
            settingData.basemapUrl = ""
            settingData.featureLayerUrl = ""
            //settingData.basemapDate = Date() as NSDate?
            
            //background sync time
            
            
            appDelegate.saveContext()
            
        }
        
        
    }
    
    
    func saveSalesforceOrgCredentials(){
        
        
        salesforceConfigData = ManageCoreData.fetchData(salesforceEntityName: "SalesforceOrgConfig", isPredicate:false) as! [SalesforceOrgConfig]
        
        if(salesforceConfigData.count == 0){
            
            let companyName = "PEU"
            let endPointUrl = "https://nyc-mayorpeu--dev.cs33.my.salesforce.com"
            let clientId = "3MVG9Zdl7Yn6QDKMCsJWeIlvKopZ7msQYyL8QxLvD3E8Yd49Gt1N2HApGbrEtOMMU6x9yWuvY20_l5D7Tt0uN"
            let clientSecret = "5050630969965231251"
            
//            let companyName = "PEU"
//            let endPointUrl = "https://nyc-mayorpeu--uat.cs32.my.salesforce.com"
//            let clientId = "3MVG9ic.6IFhNpPr8GIEr8R0j25Wf7FJvQXGFDGTgWUsgBwOUUKxTOeyCltrF0fWu9kYbv3OQyqiQDdGdO6OA"
//            let clientSecret = "6143163716371648599"
//            
            
            
            let configData = SalesforceOrgConfig(context: context)
            
            configData.companyName = try! companyName.aesEncrypt(Utilities.encryptDecryptKey, iv: Utilities.encryptDecryptIV)
            configData.endPointUrl = try! endPointUrl.aesEncrypt(Utilities.encryptDecryptKey, iv: Utilities.encryptDecryptIV)
            configData.clientId = try! clientId.aesEncrypt(Utilities.encryptDecryptKey, iv: Utilities.encryptDecryptIV)
            configData.clientSecret = try! clientSecret.aesEncrypt(Utilities.encryptDecryptKey, iv: Utilities.encryptDecryptIV)
            
            
            appDelegate.saveContext()
            
        }
        
        
        
        
        
        
    }
    
    
    
    
    @IBAction func tapAtLoginBtn(_ sender: AnyObject) {
        
        
        
        DispatchQueue.main.async {
            self.loginView.endEditing(true)
        }
        
        
       // if validation()
       // {
            if(Network.reachability?.isReachable)!{
                
                onlineEnterToDashBoard()
            }
            else{
                
                
                
                let users =  ManageCoreData.fetchData(salesforceEntityName: "UserInfo", isPredicate:false) as! [UserInfo]
                
                if(users.count == 0){
                    
                    self.view.makeToast("No internet connection", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                        
                        
                    }
                    
                }
                else if(noOfAttempts <= 4){
                    offlineEnterToDashBoard()
                }
                else{
                    
                    self.view.makeToast("No internet connection. Please relogin when newtwork gain access.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                        
                        
                    }
                    
                }
            }
            
            
        //}
        
        
    }
    
    
    @IBAction func btnForgotPasswordPressa(_ sender: Any)
    {
        self.performSegue(withIdentifier: "ForgetPasswordIdentifer", sender: nil)
    }
    
    
    
    func validation() -> Bool
    {
        if (emailTextField.text?.isEmpty)!
        {
            vwEmail.shake()
            self.view.makeToast("Please insert username.",duration: 2.0, position: .center , title: nil, image: nil, style:nil){ (didTap: Bool) -> Void in
                if didTap {
                    
                }
                else
                {
                    
                }
                
            }
            return false
        }
        
        if  validate(YourEMailAddress: emailTextField.text!) == true
        {
            
        }
        else
        {
            self.view.makeToast("Please insert vaild username", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                if didTap {
                    
                } else
                {
                    
                }
            }
            
            return false
        }
        
        if (passwordTextField.text?.isEmpty)!
        {
            vwPassword.shake()
            self.view.makeToast("Please insert password.",duration: 2.0, position: .center , title: nil, image: nil, style:nil){ (didTap: Bool) -> Void in
                if didTap {
                    
                }
                else
                {
                    
                }
                
            }
            return false
        }
        
        
        return true
    }
    
    
    func validate(YourEMailAddress: String) -> Bool {
        let REGEX: String
        REGEX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", REGEX).evaluate(with: YourEMailAddress)
    }
    
    
    //MARK: - offlineEnterToDashBoard
    
    func offlineEnterToDashBoard(){
        
         SalesforceConfig.userName = "nik+peu@mtxb2b.com.dev".addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        
         SalesforceConfig.password = "peuprutech1234"
        
       // SalesforceConfig.userName = emailTextField.text!.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        
        userInfoData =  ManageCoreData.fetchData(salesforceEntityName: "UserInfo", predicateFormat:"userName == %@",predicateValue:  SalesforceConfig.userName, isPredicate:true) as! [UserInfo]
        
        if(userInfoData.count > 0){
            
            if(userInfoData[0].passwordExpDate?.isGreaterThanDate(dateToCompare: NSDate()))!
            {
                
                let password = try! userInfoData[0].password!.aesDecrypt(Utilities.encryptDecryptKey, iv: Utilities.encryptDecryptIV)
                
                if(password == SalesforceConfig.password){
                //if(password == passwordTextField.text!){
                    
                    getSalesforceOrgCredentials()
                    getUserSetting()
                    
                    //SalesforceConfig.password = passwordTextField.text!
                    SalesforceConfig.currentUserEmail = userInfoData[0].contactEmail!
                    SalesforceConfig.currentUserContactId = userInfoData[0].contactId!
                    SalesforceConfig.currentUserExternalId = userInfoData[0].externalId!
                    if let contactName = userInfoData[0].contactName{
                        SalesforceConfig.currentContactName = contactName
                    }
                    
                    
                    self.performSegue(withIdentifier: "loginIdentifier", sender: nil)
                }
                else{
                    
                    noOfAttempts = noOfAttempts + 1
                    
                    if(noOfAttempts > 3){
                        
                        //Delete cache? and userInfo table ? and show error message
                    }
                    else{
                        
                        //Show error with number of attempts
                        self.view.makeToast("Please enter valid passsword. Only \(5-noOfAttempts) has been left.After that you have to relogin again when you gain network connectivity.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                            
                            
                        }
                        
                        
                        
                        
                    }
                    
                    
                }
                
            }//password expiration date condition
            else{
                
                self.view.makeToast("Your password has been expired. Please relogin when you gain network connectivity.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    
                    
                }
            }
            
        }
        else{
            
            self.view.makeToast("Please enter valid username.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                
            }
            
        }
        
        
        
        
        
    }
    
    
    
    func onlineEnterToDashBoard(){
        
        //  var emailParams : [String:String] = [:]
        var userParams : [String:String] = [:]
        
        
        getSalesforceOrgCredentials()
        
        getUserSetting()
        
        
        SVProgressHUD.show(withStatus: "Signing..", maskType: SVProgressHUDMaskType.gradient)
        
        
        
        //Need to be handle refresh token as well
        
       // SalesforceConfig.userName = emailTextField.text!.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        
       // SalesforceConfig.password = passwordTextField.text!
        
        
        SalesforceConfig.userName = "nik+peu@mtxb2b.com.dev".addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        
        SalesforceConfig.password = "peuprutech1234"
        
        SyncUtility.syncDataWithSalesforce(isPullDataFromSFDC: true,controller: self)
        
        
    }
    
    
    
    
    func getSalesforceOrgCredentials(){
        
        salesforceConfigData = ManageCoreData.fetchData(salesforceEntityName: "SalesforceOrgConfig", isPredicate:false) as! [SalesforceOrgConfig]
        
        
        if(salesforceConfigData.count > 0){
            
            let clientId = salesforceConfigData[0].clientId!
            
            SalesforceConfig.clientId = try! clientId.aesDecrypt(Utilities.encryptDecryptKey, iv: Utilities.encryptDecryptIV)
            
            SalesforceConfig.clientSecret = try! salesforceConfigData[0].clientSecret!.aesDecrypt(Utilities.encryptDecryptKey, iv: Utilities.encryptDecryptIV)
            
            SalesforceConfig.hostUrl = try! salesforceConfigData[0].endPointUrl!.aesDecrypt(Utilities.encryptDecryptKey, iv: Utilities.encryptDecryptIV)
            
            
        }
        
    }
    
    
    
    
    @IBAction func UnwindBackFromLogout(segue:UIStoryboardSegue) {
        
        // ManageCoreData.DeleteAllDataFromEntities()
        Utilities.timer?.invalidate()
        print("UnwindBackFromLogout")
        
    }
    
    @IBAction func UnwindBackFromForgotPassword(segue:UIStoryboardSegue) {
        
       
        print("UnwindBackFromForgotPassword")
        
        
    }
    
    
    
    
    
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
