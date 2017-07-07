//
//  SaveEditTenantViewController.swift
//  Knock
//
//  Created by Kamal on 22/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class SaveEditTenantViewController: UIViewController,UITextFieldDelegate
{
    @IBOutlet weak var lastNameView: UIView!
    @IBOutlet weak var firstNameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var dobView: UIView!
    
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
    
    var age:String = ""
    
     var editTenantDict : [String:String] = [:]
    
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
        
        phoneTextField.delegate = self

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        let aSet =  NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        
        let currentCharacterCount = phoneTextField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        if(newLength > 10){
            return false
        }
        
        
        return string == numberFiltered
    }
    
    func fillTenantInfo(){
        
         let tenantResults = ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "assignmentId == %@ AND locationId == %@ AND unitId == %@ AND id == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId,predicateValue3: SalesforceConnection.unitId,predicateValue4: SalesforceConnection.currentTenantId,isPredicate:true) as! [Tenant]
        
        if(tenantResults.count > 0){
            
            firstNameTxtField.text = tenantResults[0].firstName
            lastNameTxtField.text = tenantResults[0].lastName
            emailTxtField.text = tenantResults[0].email
            phoneTextField.text = tenantResults[0].phone
            txtDob.text = tenantResults[0].dob
            
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
        
        
        if let firstNameTemp = firstNameTxtField.text{
            
            firstName = firstNameTemp
            
        }
        
        if(firstName.isEmpty){
            
            firstNameView.shake()
            
            self.view.makeToast("Please fill first name.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                if didTap {
                    print("Completion with tap")
                    
                } else {
                    print("Completion without tap")
                }
                
                
            }
            
            
            return
            
        }

        
        
        
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
        
        if(phone.isEmpty){
            
            phoneView.shake()
            
            self.view.makeToast("Please fill last name.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                if didTap {
                    print("Completion with tap")
                    
                } else {
                    print("Completion without tap")
                }
                
                
            }
            
            
            return
            
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
        
        if(email.isEmpty){
            
            emailView.shake()
            
            self.view.makeToast("Please fill email.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                if didTap {
                    print("Completion with tap")
                    
                } else {
                    print("Completion without tap")
                }
                
                
            }
            
            
            return
            
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


        
        
            
        
            
            if let dobTemp = txtDob.text{
                
                dob = dobTemp
                
                if(dob != ""){
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-dd-yyyy"
                
                    let birthdate = dateFormatter.date(from: dob)
                
                    let now = Date()
                    let calendar = Calendar.current
              
              
                    let ageComponents = calendar.dateComponents([.year], from: birthdate!, to: now)
                    age = String(ageComponents.year!)
                }
  
                
            }
        
        
        var msg:String = ""
        
            
        if(SalesforceConnection.currentTenantId == ""){
            saveTenantInCoreData()
            msg = "Tenant information has been created successfully."
        }
        else{
            updateTenantInCoreData()
            msg = "Tenant information has been updated successfully."
        }
        

        
//        editTenantDict = Utilities.createAndEditTenantData(firstName: firstName, lastName: lastName, email: email, phone: phone, dob: dob, locationUnitId: SalesforceConnection.unitId, currentTenantId: SalesforceConnection.currentTenantId,iOSTenantId: UUID().uuidString)
//        
//        
//        
        self.view.makeToast(msg, duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateTenantView"), object: nil)
            
            
            
            self.navigationController?.popViewController(animated: true);
            
            
        }
        
        
//        if(Network.reachability?.isReachable)!{
//            
//            pushCreateEditTenantDataToSalesforce(message:msg)
//        }
//            
//        else{
//            self.view.makeToast(msg, duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
//                
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateTenantView"), object: nil)
//                
//                
//                
//                self.navigationController?.popViewController(animated: true);
//
//                
//            }
//        }
//        
        
        
            
    }
    
    
    func pushCreateEditTenantDataToSalesforce(message:String){
        
       
        
        var updateTenant : [String:String] = [:]
        
        
        
        updateTenant["tenant"] = Utilities.encryptedParams(dictParameters: editTenantDict as AnyObject)
        
        
        
        
       SVProgressHUD.show(withStatus: "Saving tenant...", maskType: SVProgressHUDMaskType.gradient)
        
        SalesforceConnection.loginToSalesforce(companyName: SalesforceConnection.companyName) { response in
            
            if(response)
            {
                
                
                SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.createTenant, params: updateTenant){ jsonData in
                    
                    SVProgressHUD.dismiss()
                    
                    //Utilities.parseTenantResponse(jsonObject: jsonData.1)
                    
                    
                    // .parseResponse(jsonObject: jsonData.1)
                    
                    self.view.makeToast(message, duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateTenantView"), object: nil)
                        
                        
                        
                        self.navigationController?.popViewController(animated: true);

                        
                    }
                    
                    
                    
                }
            }
            
        }

    }
    
    
    
   
    
    
    func saveTenantInCoreData(){
        
        let tenantObject = Tenant(context: context)
        
        
        tenantObject.id = UUID().uuidString
        
        tenantObject.name = firstName + " " + lastName
        
        tenantObject.firstName = firstName
        
        tenantObject.lastName = lastName
        
        tenantObject.phone = phone
        
        tenantObject.email = email
        
        tenantObject.age = age
        
        tenantObject.dob =  dob
        
        tenantObject.actionStatus = "create"
        
        
        tenantObject.assignmentId = SalesforceConnection.assignmentId
        
        tenantObject.locationId = SalesforceConnection.locationId
        
        tenantObject.unitId = SalesforceConnection.unitId
        
        tenantObject.assignmentLocUnitId = SalesforceConnection.assignmentLocationUnitId
        
        
        appDelegate.saveContext()
        
        
        
        

    }
    
    
    func updateTenantInCoreData(){
        
        var updateObjectDic:[String:String] = [:]
        
        //updateObjectDic["id"] = tenantDataDict["tenantId"] as! String?
        
        updateObjectDic["name"] = firstName + " " + lastName
        
        updateObjectDic["firstName"] = firstName
        
        updateObjectDic["lastName"] = lastName
        
        updateObjectDic["phone"] = phone
        
        updateObjectDic["email"] = email
        
        updateObjectDic["dob"] = dob
        
        updateObjectDic["age"] = age
        
        
        let tenantResults = ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "id == %@" ,predicateValue: SalesforceConnection.currentTenantId,isPredicate:true) as! [Tenant]
        
        if(tenantResults.count > 0){
            
            if(tenantResults[0].actionStatus! == ""){
                 updateObjectDic["actionStatus"] = "edit"
            }
        }
        
        
        
        ManageCoreData.updateRecord(salesforceEntityName: "Tenant", updateKeyValue: updateObjectDic, predicateFormat: "id == %@ AND assignmentId == %@ AND locationId == %@ AND unitId == %@", predicateValue: SalesforceConnection.currentTenantId,predicateValue2: SalesforceConnection.assignmentId, predicateValue3: SalesforceConnection.locationId,predicateValue4: SalesforceConnection.unitId,isPredicate: true)
        
        
    }
    
    
    
    
   
   
    @IBAction func editingDidBegain(_ sender: UITextField)
    {
       // let datePickerView: UIDatePicker = UIDatePicker()
        
        picker.datePickerMode = .date
        picker.maximumDate =  Date()
        
        var components = DateComponents()
        components.year = -100
        let minDate = Calendar.current.date(byAdding: components, to: Date())
        
        picker.minimumDate = minDate
        
        sender.inputView = picker
        
       // txtDob.inputView = picker
        
       // picker.addTarget(self, action: #selector(SaveEditTenantViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
        
        
        
    }
    
    func datePickerValueChanged(sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        txtDob.text = dateFormatter.string(from: picker.date)
        //txtDob.text = dateFormatter.string(from: sender.date)
        
    }
    
  
    func cancelPressed(sender: UIBarButtonItem)
    {
        
        txtDob.resignFirstResponder()
    }

    func donePressed(sender: UIBarButtonItem) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
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


