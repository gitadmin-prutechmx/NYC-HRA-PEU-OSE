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
    
    @IBOutlet weak var vwEmail: UIView!
    @IBOutlet var loginView: UIView!
    @IBOutlet weak var emailTextField: DesignableTextField!
    @IBOutlet weak var passwordTextField: DesignableTextField!
   
    
    @IBOutlet weak var vwPassword: UIView!
    @IBOutlet weak var loginBtn: UIButton!
    
    var assignmentIdArray = [String]()
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        //self.navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveUserInfo()
        
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
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func saveUserInfo(){
        
        SalesforceConnection.companyName = "PEU"
        let userName = "nik+peu@mtxb2b.com.dev"
        
       
        
        salesforceConfigData = ManageCoreData.fetchData(salesforceEntityName: "SalesforceOrgConfig",predicateFormat: "companyName == %@" ,predicateValue: SalesforceConnection.companyName, isPredicate:true) as! [SalesforceOrgConfig]
        
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
            
            let encodedUserName = userName.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            
            let configData = SalesforceOrgConfig(context: context)
            configData.companyName = SalesforceConnection.companyName
            configData.endPointUrl = "https://nyc-mayorpeu--dev.cs33.my.salesforce.com"
            configData.clientId = "3MVG9Zdl7Yn6QDKMCsJWeIlvKopZ7msQYyL8QxLvD3E8Yd49Gt1N2HApGbrEtOMMU6x9yWuvY20_l5D7Tt0uN"
            configData.clientSecret = "5050630969965231251"
            configData.userName = encodedUserName
            configData.password = "peuprutech1234"
            
            //"nik%2Bpeu%40mtxb2b%2Ecom%2Edev"
            
            
            //nik+peu@mtxb2b.com.dev
            
            appDelegate.saveContext()
            
            //load data
            salesforceConfigData =  ManageCoreData.fetchData(salesforceEntityName: "SalesforceOrgConfig",predicateFormat: "companyName == %@" ,predicateValue: SalesforceConnection.companyName, isPredicate:true) as! [SalesforceOrgConfig]
            
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
        

    }
    
    
//    @IBAction func forgotPassword(_ sender: Any) {
//    if let requestUrl = NSURL(string: "http://dev-nyserda-dev.cs43.force.com/Core_Forgot_Password_Page1")
//                {
//                    UIApplication.shared.openURL(requestUrl as URL)
//                }
//        
//        
//    }
    
    @IBAction func tapAtLoginBtn(_ sender: AnyObject) {
        

        
        DispatchQueue.main.async {
              self.loginView.endEditing(true)
        }
    
//        if validation()
//        {
//            getDataFromSalesforce()
//        }
        
        getDataFromSalesforce()
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
            self.view.makeToast("Please insert email.",duration: 2.0, position: .center , title: nil, image: nil, style:nil){ (didTap: Bool) -> Void in
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
            self.view.makeToast("Please insert vaild email", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
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
    
    //MARK: - isBlank
    
 
    
    func getDataFromSalesforce(){
        
        SalesforceConnection.currentUserEmail = "nik@mtxb2b.com"
        
       
        
        var emailParams : [String:String] = [:]
        
//        var assignmentIdParams : [String:String] = [:]
//        
//        var assignmentIdDict : [String:AnyObject] = [:]
//        
//        
        
      //  SalesforceConfig.userName = emailTextField.text!.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!

       // SalesforceConfig.password = passwordTextField.text!
        
        var emailText = emailTextField.text
        
        if emailText == nil {
            
            emailText = ""
        }
        
    let assignmentResults = ManageCoreData.fetchData(salesforceEntityName: "Assignment",isPredicate:false) as! [Assignment]
        
        
        
    if ((emailText?.lowercased() == "clear") || assignmentResults.count == 0){
            
        
        SVProgressHUD.show(withStatus: "Loading..", maskType: SVProgressHUDMaskType.gradient)
        

        
        //Need to be handle refresh token as well
        
        SalesforceConnection.loginToSalesforce(companyName: SalesforceConnection.companyName) { response in
            
        if(response)
          {
            let encryptEmailStr = try! SalesforceConnection.currentUserEmail.aesEncrypt(SalesforceConfig.key, iv: SalesforceConfig.iv)
            

            emailParams["email"] = encryptEmailStr
            
            SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.getAllEventAssignmentData, params: emailParams){ assignmentJsonData in
                
                
//                SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.chartapi, params: emailParams){ jsonData in
//                    
//                    ManageCoreData.DeleteAllDataFromEntities()
//                    
//                    
//                    SVProgressHUD.dismiss()
                
//                    Utilities.parseChartData(jsonObject: jsonData.1)
//                    Utilities.parseEventAssignmentData(jsonObject: jsonData.1)
//                    
//                    DispatchQueue.main.async {
//                        self.performSegue(withIdentifier: "loginIdentifier", sender: nil)
//                    }
//                    
//
//                    
//                }
//                
                
                 SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.assignmentdetailchart, params: emailParams){ chartJsonData in
                    
                    
                    SVProgressHUD.dismiss()
                    

                    ManageCoreData.DeleteAllDataFromEntities()
                    
                    Utilities.parseEventAssignmentData(jsonObject: assignmentJsonData.1)
                    
                     Utilities.parseChartData(jsonObject: chartJsonData.1)
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "loginIdentifier", sender: nil)
                    }
                
                    
                }
                
                
                
                

                
                //get survey data
                
             /*   assignmentIdDict["assignmentIds"] = self.assignmentIdArray as AnyObject?
                
                let convertedString = Utilities.jsonToString(json: assignmentIdDict as AnyObject)
                
                 let encryptAssignmentIdStr = try! convertedString?.aesEncrypt(SalesforceConfig.key, iv: SalesforceConfig.iv)
                
                 assignmentIdParams["Assignment"] = encryptAssignmentIdStr
                
                
                
                 SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.getAllSurveyData, params: assignmentIdParams){ jsonData in
                    
                    SVProgressHUD.dismiss()

                     self.parseSurveyData(jsonObject: jsonData.1)
                    
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "loginIdentifier", sender: nil)
                        }
                    }
               
                */
                
                }
            
            }
                
        }

   }
    else{
        self.performSegue(withIdentifier: "loginIdentifier", sender: nil)
    }
        
        
 
 }
    /*
    
    func temporaryFunc(){
        
        let stringarr = ["a0J35000000nMJt"]
        //let surveyarr = ["a0J35000000nMJt"]
        
        var dic:[String:AnyObject]=[:]
        
        dic["assignmentIds"] = stringarr as AnyObject?
        
        var str = Utilities.jsonToString(json: dic as AnyObject)
        
       // str = str!.replacingOccurrences(of: "\n", with: "")
        
        print(str)
        
    }
    */
    
    
    func parseSurveyData(jsonObject: Dictionary<String, AnyObject>){
        
        
        guard let _ = jsonObject["errorMessage"] as? String,
            let surveyResults = jsonObject["AssignmentSurvey"] as? [[String: AnyObject]] else { return }
        
        
        for surveyData in surveyResults {
            
            let assignmentId = surveyData["assignmentId"] as? String  ?? ""
            let surveyId = surveyData["surveyId"] as? String  ?? ""
            let surveyName = surveyData["surveyName"] as? String  ?? ""
            
             let convertedJsonString = Utilities.jsonToString(json: surveyData as AnyObject)
            
            
            
            let surveyObject = SurveyQuestion(context: context)
            surveyObject.assignmentId = assignmentId
            surveyObject.surveyId = surveyId
            surveyObject.surveyName = surveyName
            surveyObject.surveyQuestionData = convertedJsonString
            
            
            
            appDelegate.saveContext()
            
            //  convertedJsonString = convertedJsonString!.replacingOccurrences(of: "\n", with: "")
            
            
            
          /*   let jsonData = Utilities.convertToJSON(text: convertedJsonString!) as!Dictionary<String, AnyObject>
            
            
            
            guard let  surveyName = jsonData["surveyName"] as? String,
                let surveyQuestionResults = jsonData["SurveyQuestion"] as? [[String: AnyObject]] else { return }
            
            //print(surveyName)
            
            for temp in surveyQuestionResults{
                
                guard let questionName = temp["questionName"] as? String else{return}
                
               
                
            }
 
 */
            
            
            
        }
    }
    
    
       
    
    
    @IBAction func UnwindBackFromLogout(segue:UIStoryboardSegue) {
        
        ManageCoreData.DeleteAllDataFromEntities()
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
