//
//  LoginViewController.swift
//  MTXGIS
//
//  Created by Kamal on 22/02/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var salesforceConfigData = [SalesforceOrgConfig]()
    
    
    @IBOutlet weak var signInLbl: UILabel!
    @IBOutlet weak var forgotPasswordLbl: UIButton!
    @IBOutlet weak var dontAccountLbl: UILabel!
    @IBOutlet weak var createAccountLbl: UIButton!
    
    @IBOutlet var loginView: UIView!
    @IBOutlet weak var emailTextField: DesignableTextField!
    @IBOutlet weak var passwordTextField: DesignableTextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    @IBAction func tapAtLoginBtn(_ sender: AnyObject) {
        
        
        getDataFromSalesforce()
        
        
    }
    
    
    
    func getDataFromSalesforce(){
        
        let companyName = "PEU"
        let email = "nik@mtxb2b.com"
        
        var emailParams : [String:String] = [:]
        
        salesforceConfigData = ManageCoreData.fetchData(salesforceEntityName: "SalesforceOrgConfig",predicateFormat: "companyName == %@" ,predicateValue: companyName, isPredicate:true) as! [SalesforceOrgConfig]
        
        if(salesforceConfigData.count > 0){
            
            for data in salesforceConfigData{
                
                SalesforceConfig.clientId = data.clientId!
                SalesforceConfig.clientSecret = data.clientSecret!
                SalesforceConfig.hostUrl = data.endPointUrl!
                SalesforceConfig.userName = data.userName!
                SalesforceConfig.password = data.password!
                
                
            }
            
            
            /*for data in results as! [NSManagedObject]
             {
             
             if let clientId = data.value(forKey: "clientId") as? String{
             
             }
             if let clientSecret = data.value(forKey: "clientSecret") as? String{
             
             }
             
             }
             */
            
            
        }
        else{
            //one time activity
            
            //Save data
            let configData = SalesforceOrgConfig(context: context)
            configData.companyName = "PEU"
            configData.endPointUrl = "https://nyc-mayorpeu--dev.cs33.my.salesforce.com"
            configData.clientId = "3MVG9Zdl7Yn6QDKMCsJWeIlvKopZ7msQYyL8QxLvD3E8Yd49Gt1N2HApGbrEtOMMU6x9yWuvY20_l5D7Tt0uN"
            configData.clientSecret = "5050630969965231251"
            configData.userName = "nik%2bpeu%40mtxb2b%2Ecom%2Edev"
            configData.password = "peuprutech1234"
            
            appDelegate.saveContext()
            
            //load data
            salesforceConfigData =  ManageCoreData.fetchData(salesforceEntityName: "SalesforceOrgConfig",predicateFormat: "companyName == %@" ,predicateValue: companyName, isPredicate:true) as! [SalesforceOrgConfig]
            
            if(salesforceConfigData.count > 0){
                
                for data in salesforceConfigData{
                    
                    SalesforceConfig.clientId = data.clientId!
                    SalesforceConfig.clientSecret = data.clientSecret!
                    SalesforceConfig.hostUrl = data.endPointUrl!
                    SalesforceConfig.userName = data.userName!
                    SalesforceConfig.password = data.password!
                    
                }
            }
            
        }
        
        SVProgressHUD.show(withStatus: "Fetching data from salesforce..", maskType: SVProgressHUDMaskType.gradient)
        

        
        //Need to be handle refresh token as well
        
        SalesforceConnection.loginToSalesforce(companyName: companyName) { response in
            
            
            let encryptEmailStr = try! email.aesEncrypt(SalesforceConfig.key, iv: SalesforceConfig.iv)
            
            
            emailParams["email"] = encryptEmailStr
            
            SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.getAllCanverssorData, params: emailParams){ jsonData in
                
                
                ManageCoreData.DeleteAllRecords(salesforceEntityName: "Event")
                ManageCoreData.DeleteAllRecords(salesforceEntityName: "Assignment")
                
                self.readJSONData(jsonObject: jsonData.1)
                
                
                let eventData =  ManageCoreData.fetchData(salesforceEntityName: "Event", isPredicate:false) as! [Event]
                
                if(eventData.count > 0){
                    print("Event \(eventData.count)")
                    
                    
                }
                
                
                let assignmentData =  ManageCoreData.fetchData(salesforceEntityName: "Assignment",isPredicate:false) as! [Assignment]
                
                if(assignmentData.count > 0){
                    print("Assignment \(assignmentData.count)")
                }
                
                
                SVProgressHUD.dismiss()
                
                
            }
            
            
        }
        
        
        
    }
    
    
    func createEventDictionary(){
        
        var eventDict: [String:EventDO] = [:]
        
        let eventResults =  ManageCoreData.fetchData(salesforceEntityName: "Event", isPredicate:false) as! [Event]
        
        if(eventResults.count > 0){
            
            for eventData in eventResults{
                
                if eventDict[eventData.id!] == nil{
                    eventDict[eventData.id!] = EventDO(eventId: eventData.id!, eventName: eventData.name!, startDate: eventData.startDate!, endDate: eventData.endDate!)
                }
                
                
            }
        }
        
    }
    
    
    func readJSONData(jsonObject: Dictionary<String, AnyObject>){
        
        guard let _ = jsonObject["errorMessage"] as? String,
            let eventResults = jsonObject["Event"] as? [[String: AnyObject]] else { return }
        
        for eventData in eventResults {
            
            let eventObject = Event(context: context)
            eventObject.id = eventData["eventId"] as? String  ?? ""
            eventObject.name = eventData["name"] as? String  ?? ""  //confusi
            eventObject.startDate = eventData["startDate"] as? String  ?? ""
            eventObject.endDate = eventData["endDate"] as? String  ?? ""
            
            
            
            appDelegate.saveContext()
            
            guard let assignmentResults = eventData["Assignment"] as? [[String: AnyObject]]  else { break }
            
            for assignmentData in assignmentResults {
                let assignmentObject = Assignment(context: context)
                assignmentObject.id = assignmentData["assignmentId"] as? String  ?? ""
                assignmentObject.name = assignmentData["assignmentName"] as? String  ?? ""  //confusi
                assignmentObject.status = assignmentData["status"] as? String  ?? ""
                assignmentObject.eventId = eventObject.id
                
                appDelegate.saveContext()
                
            }
        }
        
        
        
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
