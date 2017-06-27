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
        emailTextField.text = ""
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
    
    
    
    @IBAction func tapAtLoginBtn(_ sender: AnyObject) {
        
        DispatchQueue.main.async {
              self.loginView.endEditing(true)
        }
    
        if validation()
        {
            getDataFromSalesforce()
        }
        
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
        
        let email = "nik@mtxb2b.com"
        
        var emailParams : [String:String] = [:]
        
        var assignmentIdParams : [String:String] = [:]
        
        var assignmentIdDict : [String:AnyObject] = [:]
        
        
        var emailText = emailTextField.text
        
        if emailText == nil {
            
            emailText = ""
        }
        
    let assignmentResults = ManageCoreData.fetchData(salesforceEntityName: "Assignment",isPredicate:false) as! [Assignment]
        
        
        
    if ((emailText?.lowercased() == "clear") || assignmentResults.count == 0){
            
        
        SVProgressHUD.show(withStatus: "Fetching data from salesforce..", maskType: SVProgressHUDMaskType.gradient)
        

        
        //Need to be handle refresh token as well
        
        SalesforceConnection.loginToSalesforce(companyName: SalesforceConnection.companyName) { response in
            
        if(response)
          {
            let encryptEmailStr = try! email.aesEncrypt(SalesforceConfig.key, iv: SalesforceConfig.iv)
            

            emailParams["email"] = encryptEmailStr
            
            SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.getAllEventAssignmentData, params: emailParams){ jsonData in
                
                
                
                
                ManageCoreData.DeleteAllDataFromEntities()
                
               
                self.parseEventAssignmentData(jsonObject: jsonData.1)
                
                //get survey data
                
                assignmentIdDict["assignmentIds"] = self.assignmentIdArray as AnyObject?
                
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
    
    
       
    func parseEventAssignmentData(jsonObject: Dictionary<String, AnyObject>){
        
       
        
        guard let _ = jsonObject["errorMessage"] as? String,
            let eventResults = jsonObject["Event"] as? [[String: AnyObject]] else { return }
        
        //need to check location id and unit id
        
        for eventData in eventResults {
            
            let eventObject = Event(context: context)
            eventObject.id = eventData["eventId"] as? String  ?? ""
            eventObject.name = eventData["Name"] as? String  ?? ""
            eventObject.startDate = eventData["startDate"] as? String  ?? ""
            eventObject.endDate = eventData["endDate"] as? String  ?? ""
            
            
            
            appDelegate.saveContext()
            
            guard let assignmentResults = eventData["Assignment"] as? [[String: AnyObject]]  else { break }
            
            for assignmentData in assignmentResults {
                let assignmentObject = Assignment(context: context)
                assignmentObject.id = assignmentData["assignmentId"] as? String  ?? ""
                assignmentObject.name = assignmentData["assignmentName"] as? String  ?? ""
                
              
                
                assignmentObject.status = assignmentData["status"] as? String  ?? ""
                assignmentObject.eventId = eventObject.id
                
               assignmentObject.totalLocations = String(assignmentData["totalLocation"] as! Int)
               assignmentObject.totalUnits = String(assignmentData["totalLocationUnit"] as! Int)
               assignmentObject.totalSurvey = String(assignmentData["totalSurvey"] as! Int)
               assignmentObject.totalCanvassed = String(assignmentData["totalCanvassed"] as! Int)
                
               //var totalSurveyTemp = assignmentData["totalSurvey"] as! Int
               //var totalCanvassedTemp = assignmentData["totalCanvassed"] as! Int
                
                assignmentIdArray.append(assignmentObject.id!)
                
                
                
                 guard let locationResults = assignmentData["assignmentLocation"] as? [[String: AnyObject]]  else { break }
                

             /*    var totalUnits = 0;
                
                if(locationResults.count>0){
                    
                    assignmentObject.totalLocations = String(locationResults.count)
                    
                    for locationData in locationResults {
                        
                        let unit = locationData["totalUnits"] as? String  ?? "0"
                        
                        totalUnits =  totalUnits + Int(unit)!

                        
                    }
                }
                else{
                    assignmentObject.totalLocations = "0"
                }
                
               assignmentObject.totalUnits = String(totalUnits)
                
*/
                
                
                
                appDelegate.saveContext()
                
                    for locationData in locationResults {
                     
                        let locationObject = Location(context: context)
                        locationObject.id = locationData["locId"] as? String  ?? ""
                        locationObject.name = locationData["name"] as? String  ?? ""
                        locationObject.state = locationData["state"] as? String  ?? ""
                        locationObject.city = locationData["city"] as? String  ?? ""
                        locationObject.zip = locationData["zip"] as? String  ?? ""
                        locationObject.street = locationData["street"] as? String  ?? ""
                        
                        locationObject.assignmentLocId = locationData["AssignLocId"] as? String  ?? ""
                        
                        locationObject.assignmentId = assignmentObject.id!
                        
                        appDelegate.saveContext()
                        
                        //EditLocation
                        
                        let editlocationObject = EditLocation(context: context)
                        editlocationObject.locationId = locationData["locId"] as? String  ?? ""
                        editlocationObject.assignmentId = assignmentObject.id!
                        editlocationObject.assignmentLocId = locationData["AssignLocId"] as? String  ?? ""
                        editlocationObject.canvassingStatus = locationData["status"] as? String  ?? ""
                        editlocationObject.attempt = locationData["attempt"] as? String  ?? ""
                        editlocationObject.noOfUnits = locationData["numberOfUnits"] as? String  ?? ""
                        editlocationObject.notes = locationData["notes"] as? String  ?? ""
                        
                        appDelegate.saveContext()
                        
                        guard let unitResults = locationData["assignmentLocUnit"] as? [[String: AnyObject]]  else { break }
                       
                         for unitData in unitResults {
                            
                            
                            let unitObject = Unit(context: context)
                            unitObject.id = unitData["locationUnitId"] as? String  ?? ""
                            unitObject.name = unitData["Name"] as? String  ?? ""
                            unitObject.apartment = unitData["apartmentNumber"] as? String  ?? ""
                            unitObject.floor = unitData["floorNumber"] as? String  ?? ""
                            unitObject.assignmentId = assignmentObject.id!

                            unitObject.locationId = locationObject.id!
                            
                            unitObject.surveyStatus = ""
                            unitObject.syncDate = ""
                            
                             unitObject.assignmentLocUnitId = unitData["assignmentLocUnitId"] as? String  ?? ""
                            
                            appDelegate.saveContext()
                            
                            //EditUnit
                            
                            let editUnitObject = EditUnit(context: context)
                            editUnitObject.locationId = locationObject.id!
                            editUnitObject.assignmentId = assignmentObject.id!
                            editUnitObject.assignmentLocId = locationObject.assignmentLocId!
                            editUnitObject.unitId = unitObject.id!
                            editUnitObject.assignmentLocUnitId = unitObject.assignmentLocUnitId!
                            editUnitObject.attempt = unitData["attempt"] as? String  ?? ""
                            editUnitObject.inTakeStatus = unitData["intakeStatus"] as? String  ?? ""
                            editUnitObject.reKnockNeeded = unitData["reKnockNeeded"] as? String  ?? ""
                            editUnitObject.tenantStatus = unitData["tenantStatus"] as? String  ?? ""
                            editUnitObject.unitNotes = unitData["notes"] as? String  ?? ""
                             editUnitObject.isContact = unitData["isContact"] as? String  ?? ""
                            
                            
                            appDelegate.saveContext()
                            
                            //TenantStatus
                            
                            let tenantAssignObject = TenantAssign(context: context)
                            
                           
                            tenantAssignObject.locationId = locationObject.id!
                            tenantAssignObject.assignmentId = assignmentObject.id!
                            tenantAssignObject.assignmentLocId = locationObject.assignmentLocId!
                            tenantAssignObject.unitId = unitObject.id!
                            tenantAssignObject.assignmentLocUnitId = unitObject.assignmentLocUnitId!
                            tenantAssignObject.tenantId = unitData["tenant"] as? String  ?? ""
                            
                            
                            
                            appDelegate.saveContext()

                            
                            //AssignSurvey
                            
                            
                            //save the record
                            let surveyUnitObject = SurveyUnit(context: context)
                            surveyUnitObject.locationId = locationObject.id!
                            surveyUnitObject.assignmentId = assignmentObject.id!
                            surveyUnitObject.assignmentLocId = locationObject.assignmentLocId!
                            surveyUnitObject.unitId = unitObject.id!
                            surveyUnitObject.assignmentLocUnitId = unitObject.assignmentLocUnitId!
                            surveyUnitObject.surveyId = unitData["survey"] as? String  ?? ""
                            
                            
                            appDelegate.saveContext()

                            
                            guard let tenantInfoResults = unitData["TenantInfo"] as? [[String: AnyObject]]  else { break }
                            
                            for tenantData in tenantInfoResults {
                                
                                let tenantObject = Tenant(context: context)
                                tenantObject.id = tenantData["tenantId"] as? String  ?? ""
                                tenantObject.name = tenantData["name"] as? String  ?? ""
                                tenantObject.firstName = tenantData["firstName"] as? String  ?? ""
                                tenantObject.lastName =  tenantData["lastName"] as? String  ?? ""
                               
                                 tenantObject.phone = tenantData["phone"] as? String  ?? ""
                                 tenantObject.email = tenantData["email"] as? String  ?? ""
                                 tenantObject.age = tenantData["age"] as? String  ?? ""
                                 tenantObject.dob = tenantData["dob"] as? String  ?? ""
                                
                                tenantObject.assignmentId = assignmentObject.id!
                                tenantObject.locationId = locationObject.id!
                                tenantObject.unitId = unitObject.id!
                                
                                appDelegate.saveContext()
                                
                            }
                        }
                        
                    }
                }
                
                
            
        }
        
        
        
    }

    
    @IBAction func UnwindBackFromLogout(segue:UIStoryboardSegue) {
        
        ManageCoreData.DeleteAllDataFromEntities()
        print("UnwindBackFromLogout")
        
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
