//
//  SaveEditTenantViewController.swift
//  Knock
//
//  Created by Kamal on 22/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class SaveEditTenantViewController: UIViewController
{
    @IBOutlet weak var lastNameView: UIView!
    
    @IBOutlet weak var firstNameTxtField: UITextField!
    
    @IBOutlet weak var lastNameTxtField: UITextField!
    
    @IBOutlet weak var emailTxtField: UITextField!
    
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    
    @IBOutlet weak var dobTextField: UITextField!
    
var picker = UIDatePicker()
    
    
    @IBOutlet weak var txtDob: UITextField!
    
    
    
    
    var firstName:String = ""
    
    var lastName:String = ""
    
    var email:String = ""
    
    var phone:String = ""
    
    var dob:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        
        let cancelBtn = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SaveEditTenantViewController.cancelPressed))
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(SaveEditTenantViewController.donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label.font = UIFont(name: "Helvetica", size: 12)
        
        label.backgroundColor = UIColor.clear
        
        label.textColor = UIColor.white
        
        label.text = "Select a DOB"
        
        label.textAlignment = NSTextAlignment.center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([cancelBtn,flexSpace,textBtn,flexSpace,doneBtn], animated: true)
        
        txtDob.inputAccessoryView = toolBar
        
        if(SalesforceConnection.currentTenantId != ""){
            fillTenantInfo()
        }

    }
    
    func fillTenantInfo(){
        
         let tenantResults = ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "assignmentId == %@ AND locationId == %@ AND unitId == %@ AND id == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId,predicateValue3: SalesforceConnection.unitId,predicateValue4: SalesforceConnection.currentTenantId,isPredicate:true) as! [Tenant]
        
        if(tenantResults.count > 0){
            
            firstNameTxtField.text = tenantResults[0].firstName
            lastNameTxtField.text = tenantResults[0].lastName
            emailTxtField.text = tenantResults[0].email
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true);
    }
    
    @IBAction func save(_ sender: Any) {
        
        self.saveTenantInfo()
      
    }
    
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func saveTenantInfo(){
        
        var editTenantDict : [String:String] = [:]
        
        var updateTenant : [String:String] = [:]
        
        
        
        
        
        if let lastNameTemp = lastNameTxtField.text{
            
            lastName = lastNameTemp
            
        }
        
        
        
        if(lastName.isEmpty){
            
            lastNameView.shake()
            
            self.view.makeToast("Please fill last name.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                if didTap {
                    print("Completion with tap")
                    
                } else {
                    print("Completion without tap")
                }
                
                
            }
            
            
            return
            
        }
        
        if let phoneTemp = phoneTextField.text{
            
            phone = phoneTemp
            
        }
        
        if(!phone.isEmpty && phone.characters.count < 10){
            
            self.view.makeToast("Phone number should be in 10 digit.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                if didTap {
                    print("Completion with tap")
                    
                } else {
                    print("Completion without tap")
                }
                
                
            }
            
            
            return
            
        }
        
        if let emailTemp = emailTxtField.text{
            
            email = emailTemp
            
        }
        
        if(!email.isEmpty && !isValidEmail(testStr: email)){
            
            self.view.makeToast("Email should be in proper format.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                if didTap {
                    print("Completion with tap")
                    
                } else {
                    print("Completion without tap")
                }
                
                
            }
            
            
            return
            
        }


        
        
            
            if let firstNameTemp = firstNameTxtField.text{
                
                firstName = firstNameTemp
                
            }
            
        
            
        
            
            if let dobTemp = txtDob.text{
                
                dob = dobTemp
                
            }
            
            
            
        
        
            
            
            
            editTenantDict["locationUnitId"] = SalesforceConnection.unitId
            
            editTenantDict["firstName"] = firstName
            
            editTenantDict["lastName"] = lastName
            
            editTenantDict["email"] = email
            
            editTenantDict["phone"] = phone
            
            editTenantDict["birthdate"] = dob
            
            
            
        
            
            
            let convertedString = Utilities.jsonToString(json: editTenantDict as AnyObject)
            
            
            
            let encryptEditTenantStr = try! convertedString?.aesEncrypt(SalesforceConfig.key, iv: SalesforceConfig.iv)
            
            
            
            updateTenant["tenant"] = encryptEditTenantStr
            
            
            
            SVProgressHUD.show(withStatus: "Saving tenant...", maskType: SVProgressHUDMaskType.gradient)
        
        
    SalesforceConnection.loginToSalesforce(companyName: SalesforceConnection.companyName) { response in
        
            if(response)
                
            {
                
                SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.createTenant, params: updateTenant){ jsonData in
                    
                    
                    
                   // self.saveTenantInCoreData()
                    
                    
                    
                    
                    
                    SVProgressHUD.dismiss()
                    
                    self.parseResponse(jsonObject: jsonData.1)
                    
                    
//                    self.view.makeToast("Tenant information has been created successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
//                        
//                        if didTap {
//                            
//                            self.navigationController?.popViewController(animated: true);
//                            
//                        } else {
//                            
//                            self.navigationController?.popViewController(animated: true);
//                            
//                        }
//                        
//                    }
                    
                    
                    
                    //print(jsonData.1)
                    
                    
                    
                }
                
            }
            
            
        }
        
        
        
            
    }
    
    func parseResponse(jsonObject: Dictionary<String, AnyObject>){
     
        guard let isError = jsonObject["hasError"] as? Bool,
            
            let tenantDataDict = jsonObject["tenantData"] as? [String: AnyObject] else { return }
        
        

        
        if(isError == false){
            
           
                
                let tenantObject = Tenant(context: context)
                
                
                tenantObject.id = tenantDataDict["tenantId"] as! String?
                
                 tenantObject.firstName = firstName + " " + lastName
            
                 tenantObject.lastName = ""
                 
                 tenantObject.phone = phone
                 
                 tenantObject.email = email
                
                 tenantObject.age = ""
                
                
                
                tenantObject.assignmentId = SalesforceConnection.assignmentId
                
                tenantObject.locationId = SalesforceConnection.locationId
                
                tenantObject.unitId = SalesforceConnection.unitId
                
                
                
                appDelegate.saveContext()
                
                
                
            
            
            
            
            self.view.makeToast("Tenant information has been created successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                if didTap {
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateTenantView"), object: nil)
                    
                    

                    self.navigationController?.popViewController(animated: true);
                    
                } else {
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateTenantView"), object: nil)
                    
                    

                    self.navigationController?.popViewController(animated: true);
                    
                }
                
            }
            
            
            
            
            
        }
            
        else{
            
            self.view.makeToast("Error while updating Tenant info", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                if didTap {
                    
                    print("completion from tap")
                    
                } else {
                    
                    print("completion without tap")
                    
                }
                
            }
            
            
            
        }
        
        
        
    }
    
   
    @IBAction func editingDidBegain(_ sender: UITextField)
    {
       // let datePickerView: UIDatePicker = UIDatePicker()
        
        picker.datePickerMode = .date
        sender.inputView = picker
        
       // txtDob.inputView = picker
        
       // picker.addTarget(self, action: #selector(SaveEditTenantViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
        
        
        
    }
    
    func datePickerValueChanged(sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        txtDob.text = dateFormatter.string(from: picker.date)
        //txtDob.text = dateFormatter.string(from: sender.date)
        
    }
    
  
    func cancelPressed(sender: UIBarButtonItem)
    {
        
        txtDob.resignFirstResponder()
    }

    func donePressed(sender: UIBarButtonItem) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        txtDob.text = dateFormatter.string(from: picker.date)
        
        txtDob.resignFirstResponder()
        
    }
    
    

       /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


