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
    @IBOutlet weak var suffixView: UIView!
    
    @IBOutlet weak var middleNameView: UIView!
    @IBOutlet weak var firstNameTxtField: UITextField!
    
    @IBOutlet weak var txtSuffix: UITextField!
    @IBOutlet weak var lastNameTxtField: UITextField!
    
    @IBOutlet weak var emailTxtField: UITextField!
    
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    
    @IBOutlet weak var txtMiddleName: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    
    var picker = UIDatePicker()
    
    
    @IBOutlet weak var txtDob: UITextField!
    
    
    var firstName:String = ""
    
    var lastName:String = ""
    
    var email:String = ""
    
    var phone:String = ""
    
    var dob:String = ""
    
    var age:String = ""
    
    var middleName:String = ""
    
    var suffix:String = ""
    
    var editTenantDict : [String:String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if(SalesforceConnection.isNewContactWithAddress){
            
            self.navigationItem.rightBarButtonItem =  nil
            
            let rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(SaveEditTenantViewController.nextAction))
            
            self.navigationItem.rightBarButtonItem  = rightBarButtonItem
        }
        else{
            self.navigationItem.rightBarButtonItem =  nil
            
            let rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(SaveEditTenantViewController.saveAction))
            
            self.navigationItem.rightBarButtonItem  = rightBarButtonItem
            
        }
        
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        
        
        
        self.navigationController?.navigationBar.tintColor = UIColor.white

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
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        let phoneNum = phoneTextField.text
        phoneTextField.text = phoneNum!
        
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
       let phoneNum = phoneTextField.text
        let phone = phoneNum?.toPhoneNumber()
        phoneTextField.text = phone!
        print(phone!)
 
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        
        let str = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        
        
        if textField == phoneTextField
        {
            
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
            
            let compSepByCharInSet = string.components(separatedBy: aSet)
            
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            
            
            if string == numberFiltered
            {
                
                return checkEnglishPhoneNumberFormat(string: string, str: str)
                
            }
            
            return false
            
        }else
        {
            return true
            
        }
        
    }
    
    
    func getStringFormPhoneString(phoneStr:String) -> String
    {
        var result = phoneStr.replace("(", withString: "")
        result = result.replace(")", withString: "")
        result = result.replace("-", withString: "")
        result = result.replace(" ", withString: "")

        return result
        
    }

    
    func checkEnglishPhoneNumberFormat(string: String?, str: String?) -> Bool{
        
        
        
        if string == ""{
            
            
            
            return true
            
            
            
        }else if str!.characters.count < 3{
            
            
            
            if str!.characters.count == 1{
                
                
                
                phoneTextField.text = "("
                
            }
            
            
            
        }else if str!.characters.count == 5{
            
            
            
            phoneTextField.text = phoneTextField.text! + ") "
            
            
            
        }else if str!.characters.count == 10{
            
            
            
            phoneTextField.text = phoneTextField.text! + "-"
            
            
            
        }else if str!.characters.count > 14{
            
            
            
            return false
            
        }
        
        
        
        return true
        
    }
    
    
    
    func fillTenantInfo(){
        
        let tenantResults = ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "assignmentId == %@ AND locationId == %@ AND unitId == %@ AND id == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId,predicateValue3: SalesforceConnection.unitId,predicateValue4: SalesforceConnection.currentTenantId,isPredicate:true) as! [Tenant]
        
        if(tenantResults.count > 0){
            
            if(tenantResults[0].dob != ""){
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = dateFormatter.date(from: tenantResults[0].dob!)
                
                if(date != nil){
                    
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    txtDob.text = dateFormatter.string(from: date!)
                }
                else{
                    txtDob.text = tenantResults[0].dob
                }
            }
            
            
            
            firstNameTxtField.text = tenantResults[0].firstName
            lastNameTxtField.text = tenantResults[0].lastName
            emailTxtField.text = tenantResults[0].email
            txtMiddleName.text = tenantResults[0].middleName
            txtSuffix.text = tenantResults[0].suffix
            
            //phoneTextField.text = tenantResults[0].phone
            
            let phoneNum = tenantResults[0].phone
            phone = (phoneNum?.toPhoneNumber())!
            phoneTextField.text = phone
            
            
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancel(_ sender: Any)
    {
     
        let alertCtrl = Alert.showUIAlert(title: "Message", message: "Are you sure you want to cancel without saving?", vc: self)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel) { action -> Void in
            //Do some stuff
        }
        alertCtrl.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            
            if(SalesforceConnection.isNewContactWithAddress){
                
                self.dismiss(animated: true, completion: nil)
            }
            else{
            
              self.navigationController?.popViewController(animated: true);
            }
            //Do some other stuff
        }
        alertCtrl.addAction(okAction)
        
     
        
        
    }
    
    func nextAction(){
         self.dismiss(animated: true, completion: nil)
    }
    
    func saveAction(){
        
        self.saveTenantInfo()
    }
    
    /*
    @IBAction func save(_ sender: Any) {
        
        
        self.saveTenantInfo()
        
    }
    */
    
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
        
        if let middleNameTemp = txtMiddleName.text{
            
            middleName = middleNameTemp
        }
        
        if let suffixTemp = txtSuffix.text{
            
            suffix = suffixTemp
        }
        
        if(firstName.isEmpty){
            
            firstNameView.shake()
            
            self.view.makeToast("Please enter first name.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
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
            
            self.view.makeToast("Please enter last name.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                if didTap {
                    print("Completion with tap")
                    
                } else {
                    print("Completion without tap")
                }
                
                
            }
            
            
            return
            
        }
        
        if let phoneTemp = phoneTextField.text
        {
            
            phone = phoneTemp
            
        }
        
        
        
//        if(phone.isEmpty){
//            
//            phoneView.shake()
//            
//            self.view.makeToast("Please enter Phone number", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
//                
//                if didTap {
//                    print("Completion with tap")
//                    
//                } else {
//                    print("Completion without tap")
//                }
//                
//                
//            }
//            
//            
//            return
//            
//        }
        
        
        
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
        
//        if(email.isEmpty){
//            
//            emailView.shake()
//            
//            self.view.makeToast("Please enter email.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
//                
//                if didTap {
//                    print("Completion with tap")
//                    
//                } else {
//                    print("Completion without tap")
//                }
//                
//                
//            }
//            
//            
//            return
//            
//        }
        
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
                dateFormatter.dateFormat = "MM/dd/yyyy"
                
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
            msg = "Client information has been created successfully."
        }
        else{
            updateTenantInCoreData()
            msg = "Client information has been updated successfully."
        }
        
        
        
        //        editTenantDict = Utilities.createAndEditTenantData(firstName: firstName, lastName: lastName, email: email, phone: phone, dob: dob, locationUnitId: SalesforceConnection.unitId, currentTenantId: SalesforceConnection.currentTenantId,iOSTenantId: UUID().uuidString)
        //
        //
        //
        self.view.makeToast(msg, duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateClientView"), object: nil)
            
            
            
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
        
        tenantObject.middleName = middleName
        
        tenantObject.suffix = suffix
        
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
        
        updateObjectDic["middleName"] = middleName
        
        updateObjectDic["suffix"] = suffix
        
        updateObjectDic["assignmentLocUnitId"] = SalesforceConnection.assignmentLocationUnitId
        
        updateObjectDic["unitId"] = SalesforceConnection.unitId
        
        
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
        
        // yyyy-MM-dd
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        txtDob.text = dateFormatter.string(from: picker.date)
        //txtDob.text = dateFormatter.string(from: sender.date)
        
    }
    
    
    func cancelPressed(sender: UIBarButtonItem)
    {
        
        txtDob.resignFirstResponder()
    }
    
    func donePressed(sender: UIBarButtonItem) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
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
     
     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
     
     
     let aSet =  NSCharacterSet(charactersIn:"0123456789").inverted
     let compSepByCharInSet = string.components(separatedBy: aSet)
     let numberFiltered = compSepByCharInSet.joined(separator: "")
     
     let currentCharacterCount = phoneTextField.text?.characters.count ?? 0
     if (range.length + range.location > currentCharacterCount){
     return false
     }
     let newLength = currentCharacterCount + string.characters.count - range.length
     if(newLength > 13)
     {
     return false
     }
     
     
     return string == numberFiltered
     }

     */
    
}


