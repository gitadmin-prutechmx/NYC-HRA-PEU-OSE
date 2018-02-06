//
//  ClientInfoViewController.swift
//  EngageNYCDev
//
//  Created by Kamal on 10/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class NewContactDO{
    var locationUnitId:String = ""
    var assignmentLocUnitid:String = ""
    
    var contactId:String = ""
    var firstName:String = ""
    var middleName:String = ""
    var lastName:String = ""
    var contactName:String = ""
    var suffix:String = ""
    var phone:String = ""
    var email:String = ""
    var dob:String = ""
    var age:String = ""
    var syncDate:String = ""
    var sameUnitName:String = ""
    var sameLocUnitId:String = ""
    
    var streetNum:String = ""
    var streetName:String = ""
    var borough:String = ""
    var zip:String = ""
    var diffUnitName:String = ""
    var diffLocUnitId:String = ""
    var floor:String = ""
    
    
    var assignmentId:String!
    var assignmentLocId:String!
    
    var createdById:String!
    
    
}



class ClientInfoViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var leftbarbutton: UIButton!
    @IBOutlet weak var rightBarButton: UIButton!
    
    
    @IBOutlet weak var lblHeadertitle: UILabel!
    
    @IBOutlet weak var firstNameView: UIView!
    @IBOutlet weak var lastNameView: UIView!
    @IBOutlet weak var phoneView: UIView!
    
    
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtMiddleName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtSuffixName: UITextField!
    @IBOutlet weak var txtEmailName: UITextField!
    @IBOutlet weak var txtPhoneName: UITextField!
    @IBOutlet weak var txtDobName: UITextField!
    
    var objNewContact:NewContactDO = NewContactDO()
    var objContact:ContactDO!
    
    
    var picker = UIDatePicker()
    
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    var newClientInfoWithAddressVC:NewClientInfoWithAddressViewController!
    var addressInfoVC:AddressInfoViewController!
    
    var showAddressScreen:Bool = true
    
    var fromIntakeClient:Bool = false
    var fromPicklist:Bool = false
    var fromSubmitSurveyScreen:Bool = false
    
    var viewModel:ClientInfoViewModel!
    
    var completionHandler : ((_ childVC:ClientInfoViewController) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateNavigation()
        
        self.bindView()
        
        lblHeadertitle.text = "New Client Info"
        
        if(objContact != nil){
            populateContactObject()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.setUpDatePicker()
        self.navigationController?.isNavigationBarHidden = true;
    }
    
    func populateContactObject(){
        
        txtFirstName.text = objContact.firstName
        txtLastName.text = objContact.lastName
        txtMiddleName.text = objContact.middleName
        txtSuffixName.text = objContact.suffix
        txtPhoneName.text = objContact.phone.toPhoneNumber()
        txtEmailName.text = objContact.email
        
        lblHeadertitle.text = objContact.contactName
        
        if(objContact.dob != ""){
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from: objContact.dob)
            
            if(date != nil){
                
                dateFormatter.dateFormat = "MM/dd/yyyy"
                txtDobName.text = dateFormatter.string(from: date!)
            }
            else{
                txtDobName.text = objContact.dob
            }
        }
        
        
    }
    
    func updateNavigation(){
        
        //leftbarbutton.isHidden = true
       
        
        if(showAddressScreen){
            if let image = UIImage(named: "CloseBtn.png") {
                leftbarbutton.setImage(image, for: .normal)
            }
            if let image = UIImage(named: "Forward.png") {
                rightBarButton.setImage(image, for: .normal)
            }
        }
        else{
            if let image = UIImage(named: "NavigationBack.png") {
                leftbarbutton.setImage(image, for: .normal)
            }
            if let image = UIImage(named: "Save.png") {
                rightBarButton.setImage(image, for: .normal)
            }
        }
        
        
        
    }
    
    func setUpDatePicker(){
        
        picker.backgroundColor = .white
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        
        toolBar.tintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        toolBar.barTintColor = UIColor.white
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = false
        txtDobName.inputAssistantItem.leadingBarButtonGroups.removeAll()
        txtDobName.inputAssistantItem.trailingBarButtonGroups.removeAll()
        
        let cancelBtn = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ClientInfoViewController.cancelPressed))
        
        let doneBtn = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ClientInfoViewController.donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label.font = UIFont(name: "Helvetica", size: 12)
        
        label.backgroundColor = UIColor.clear
        
        label.textColor = UIColor.white
        
        label.text = "Select a DOB"
        
        label.textAlignment = NSTextAlignment.center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([cancelBtn,flexSpace,textBtn,flexSpace,doneBtn], animated: true)
        
        txtDobName.inputAccessoryView = toolBar
        
        
        txtPhoneName.delegate = self
        txtFirstName.delegate = self
        txtLastName.delegate = self
        txtMiddleName.delegate = self
        txtSuffixName.delegate = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    func resignAllResponders(){
        
        txtFirstName.resignFirstResponder()
        txtLastName.resignFirstResponder()
        txtMiddleName.resignFirstResponder()
        txtSuffixName.resignFirstResponder()
        txtEmailName.resignFirstResponder()
        txtPhoneName.resignFirstResponder()
        txtDobName.resignFirstResponder()
        
    }
    
    func addressVC(){
        
        objContact.firstName = txtFirstName.text!
        objContact.lastName = txtLastName.text!
        objContact.middleName = txtMiddleName.text!
        objContact.suffix = txtSuffixName.text!
        objContact.phone = txtPhoneName.text!
        objContact.email = txtEmailName.text!
        
        if let dob = txtDobName.text{
            
            objContact.dob = dob
            
            objContact.age = calculateAge(dob: objContact.dob)
        }
        
        objContact.iOSContactId = objContact.contactId
        
        
        
        
        objContact.contactName = objContact.firstName + " " + objContact.middleName + " " + objContact.lastName
        
        objContact.createdById = canvasserTaskDataObject.userObj.userId
        
        //        objNewContact.assignmentId = canvasserTaskDataObject.assignmentObj.assignmentId
        //        objNewContact.assignmentLocId = canvasserTaskDataObject.locationObj.objMapLocation.assignmentLocId
        //
        
        if(addressInfoVC == nil){
            if let addressInfo = AddressInfoStoryboard().instantiateViewController(withIdentifier: "AddressInfoViewController") as? AddressInfoViewController
            {
                addressInfoVC = addressInfo
                
                addressInfo.canvasserTaskDataObject = canvasserTaskDataObject
                addressInfo.contactObj = objContact
                addressInfo.isFromClientIntake = fromIntakeClient
                
                addressInfo.modalPresentationStyle = UIModalPresentationStyle.formSheet
                self.navigationController?.pushViewController(addressInfo, animated: true)
            }
        }
        else{
            
            addressInfoVC.canvasserTaskDataObject = canvasserTaskDataObject
            addressInfoVC.contactObj = objContact
            
            addressInfoVC.modalPresentationStyle = UIModalPresentationStyle.formSheet
            self.navigationController?.pushViewController(addressInfoVC, animated: true)
        }
        
        
        
        
    }
    
    func openSameDifferentAddressVC(){
        
        objNewContact.firstName = txtFirstName.text!
        objNewContact.lastName = txtLastName.text!
        objNewContact.middleName = txtMiddleName.text!
        objNewContact.suffix = txtSuffixName.text!
        objNewContact.phone = txtPhoneName.text!
        objNewContact.email = txtEmailName.text!
        
        if let dob = txtDobName.text{
            
            objNewContact.dob = dob
            
            objNewContact.age = calculateAge(dob: objNewContact.dob)
        }
        
        
        
        objNewContact.contactId = UUID().uuidString
        objNewContact.contactName = objNewContact.firstName + " " + objNewContact.middleName + " " + objNewContact.lastName
        
        objNewContact.assignmentId = canvasserTaskDataObject.assignmentObj.assignmentId
        objNewContact.assignmentLocId = canvasserTaskDataObject.locationObj.objMapLocation.assignmentLocId
        objNewContact.createdById = canvasserTaskDataObject.userObj.userId
        
        if(showAddressScreen){
            showNewAddressVC()
        }
        else{
            saveNewContact()
        }
        
        
    }
    
    func showNewAddressVC(){
        if(newClientInfoWithAddressVC == nil){
            if let newClientInfoWithAddress = NewClientInfoWithAddressStoryboard().instantiateViewController(withIdentifier: "NewClientInfoWithAddressViewController") as? NewClientInfoWithAddressViewController
            {
                newClientInfoWithAddressVC = newClientInfoWithAddress
                
                newClientInfoWithAddress.canvasserTaskDataObject = canvasserTaskDataObject
                newClientInfoWithAddress.newContactObj = objNewContact
                
                newClientInfoWithAddress.modalPresentationStyle = UIModalPresentationStyle.formSheet
                self.navigationController?.pushViewController(newClientInfoWithAddress, animated: true)
            }
        }
        else{
            
            newClientInfoWithAddressVC.canvasserTaskDataObject = canvasserTaskDataObject
            newClientInfoWithAddressVC.newContactObj = objNewContact
            
            newClientInfoWithAddressVC.modalPresentationStyle = UIModalPresentationStyle.formSheet
            self.navigationController?.pushViewController(newClientInfoWithAddressVC, animated: true)
        }
        
    }
    
    
    func saveNewContact(){
        
        self.rightBarButton.isEnabled = false
        
        objNewContact.streetNum = canvasserTaskDataObject.locationObj.objMapLocation.streetNum
        objNewContact.streetName = canvasserTaskDataObject.locationObj.objMapLocation.streetName
        objNewContact.borough = canvasserTaskDataObject.locationObj.objMapLocation.borough
        objNewContact.zip = canvasserTaskDataObject.locationObj.objMapLocation.zip
        objNewContact.floor = ""
        objNewContact.syncDate = ""
        objNewContact.sameUnitName = canvasserTaskDataObject.locationUnitObj.locationUnitName
        objNewContact.locationUnitId =  canvasserTaskDataObject.locationUnitObj.locationUnitId
        objNewContact.assignmentLocUnitid =  canvasserTaskDataObject.locationUnitObj.assignmentLocUnitId
        
        self.viewModel.saveNewContact(objNewContactDO: objNewContact)
        
        
        self.view.makeToast("New Contact has been created successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
            
            
            self.rightBarButton.isEnabled = true
            
            if(self.fromIntakeClient){
                
                //update clientIntake screen
                Static.newClientIdFromIntakeScreen = self.objNewContact.contactId
                
                CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.INTAKECLIENTLISTING_SYNC.rawValue, sender: nil, userInfo: nil)
                self.navigationController?.popViewController(animated: true)
            }
            else if (self.fromPicklist){
                
                //update picklist screen
                self.completionHandler?(self)
                self.navigationController?.popViewController(animated: true)
            }
            else if (self.fromSubmitSurveyScreen){
                
                //Notification Center:- reload clientlisting
                CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.CLIENTLISTING_SYNC.rawValue, sender: nil, userInfo: nil)
                self.dismiss(animated: true, completion: nil)
            }
            
            
        }
        
        
    }
    
    @IBAction func btnRightBarPressed(_ sender: Any) {
        
        if(validateInfo()){
            
            self.resignAllResponders()
            
            
            if(objContact != nil){
                self.addressVC()
            }
            else{
                self.openSameDifferentAddressVC()
            }
            
        }
        
    }
    
    func validateInfo()->Bool{
        
        if let firstName = txtFirstName.text{
            // objNewContact.firstName = firstName
            
            if(firstName.isEmpty){
                
                firstNameView.shake()
                
                self.view.makeToast("Please enter first name.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    
                    if didTap {
                        print("Completion with tap")
                        
                    } else {
                        print("Completion without tap")
                    }
                    
                    
                }
                
                
                return false
                
            }
        }
        
        
        
        //        if let middleName = txtMiddleName.text{
        //            objNewContact.middleName = middleName
        //        }
        //
        if let lastName = txtLastName.text{
            // objNewContact.lastName = lastName
            if(lastName.isEmpty){
                
                lastNameView.shake()
                
                self.view.makeToast("Please enter last name.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    
                    if didTap {
                        print("Completion with tap")
                        
                    } else {
                        print("Completion without tap")
                    }
                    
                    
                }
                
                
                return false
                
            }
            
        }
        
        
        
        
        //        if let suffix = txtSuffixName.text{
        //            objNewContact.suffix = suffix
        //        }
        
        if let phone = txtPhoneName.text{
            // objNewContact.phone = phone
            if(!phone.isEmpty && phone.count < 14)
            {
                phoneView.shake()
                self.view.makeToast("Phone number should be in 10 digit.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    
                    if didTap {
                        print("Completion with tap")
                        
                    } else {
                        print("Completion without tap")
                    }
                    
                    
                }
                
                
                return false
                
            }
        }
        
        
        
        
        
        
        if let email = txtEmailName.text{
            //objNewContact.email = email
            if(!email.isEmpty && !Utility.isValidEmail(str: email)){
                
                self.view.makeToast("Email should be in proper format.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    
                    if didTap {
                        print("Completion with tap")
                        
                    } else {
                        print("Completion without tap")
                    }
                    
                    
                }
                
                
                return false
                
            }
        }
        
        
        
        
        return true
        
    }
    
    
    
    func calculateAge(dob:String)->String{
        
        var age:String = ""
        
        if(dob != ""){
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            
            let birthdate = dateFormatter.date(from: dob)
            
            let now = Date()
            let calendar = Calendar.current
            
            
            let ageComponents = calendar.dateComponents([.year], from: birthdate!, to: now)
            age = String(ageComponents.year!)
        }
        
        return age
        
    }
    
    
    @IBAction func btnLeftBarPressed(_ sender: Any) {
        
        let alertCtrl = Alert.showUIAlert(title: "Message", message: Static.exitMessage, vc: self)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel)
        { action -> Void in
            
        }
        
        alertCtrl.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            
            if(self.fromIntakeClient || self.fromPicklist){
                self.navigationController?.popViewController(animated: true)
            }
            else{ //self.fromSubmitSurveyScreen OR  From client listing screen also
                self.dismiss(animated: true, completion: nil)
            }
            

        }
        alertCtrl.addAction(okAction)
    }
    
    func checkEnglishPhoneNumberFormat(string: String?, str: String?) -> Bool{
        
        if string == ""{
            
            return true
            
        }else if str!.count < 3{
            
            if str!.count == 1{
                
                txtPhoneName.text = "("
                
            }
            
            
        }else if str!.count == 5{
            
            txtPhoneName.text = txtPhoneName.text! + ") "
            
        }else if str!.count == 10{
            
            txtPhoneName.text = txtPhoneName.text! + "-"
            
        }else if str!.count > 14{
            
            return false
            
        }
        
        return true
        
    }
    
    
}

//For DatePicker
extension ClientInfoViewController{
    
    @IBAction func editingDidBegain(_ sender: UITextField)
    {
        
        picker.datePickerMode = .date
        picker.maximumDate =  Date()
        
        var components = DateComponents()
        components.year = -100
        let minDate = Calendar.current.date(byAdding: components, to: Date())
        
        picker.minimumDate = minDate
        
        if let dateStr = txtDobName.text{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            //picker.date = dateFormatter.date(from: dateStr)!
        }
        
        
        sender.inputView = picker
        
        
        
    }
    
    func datePickerValueChanged(sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        txtDobName.text = dateFormatter.string(from: picker.date)
        
    }
    
    
    func cancelPressed(sender: UIBarButtonItem)
    {
        
        txtDobName.resignFirstResponder()
    }
    
    func donePressed(sender: UIBarButtonItem) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        txtDobName.text = dateFormatter.string(from: picker.date)
        
        txtDobName.resignFirstResponder()
        
    }
    
    
    
    
}

extension ClientInfoViewController{
    
    func bindView(){
        self.viewModel = ClientInfoViewModel.getViewModel()
    }
}

//For textfield delegates
extension ClientInfoViewController{
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        
        if(textField == txtPhoneName){
            let phoneNum = txtPhoneName.text
            txtPhoneName.text = phoneNum!
        }
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if(textField == txtPhoneName){
            let phoneNum = txtPhoneName.text
            let phone = phoneNum?.toPhoneNumber()
            txtPhoneName.text = phone!
            print(phone!)
        }
        
    }
    
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        
        let str = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        
        
        if textField == txtPhoneName
        {
            
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
            
            let compSepByCharInSet = string.components(separatedBy: aSet)
            
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            
            
            if string == numberFiltered
            {
                
                return checkEnglishPhoneNumberFormat(string: string, str: str)
                
            }
            
            return false
            
        }
        else if textField == txtFirstName{
            
            guard let text = txtFirstName.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 40 // Bool
            
        }
        else if textField == txtLastName{
            
            guard let text = txtLastName.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 80 // Bool
            
        }
        else if textField == txtMiddleName{
            
            guard let text = txtMiddleName.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 40 // Bool
            
        }
        else if textField == txtSuffixName{
            
            guard let text = txtSuffixName.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 40 // Bool
            
        }
        else
        {
            return true
            
        }
        
    }
    
    
    
    
}
