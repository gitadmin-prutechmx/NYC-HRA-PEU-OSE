//
//  AddressViewController.swift
//  Knock
//
//  Created by Cloudzeg Laptop on 9/23/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class AddressViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate
    
{
    
    @IBOutlet weak var streetNumView: UIView!
    @IBOutlet weak var streetNumLbl: UILabel!
    @IBOutlet weak var aptFloorTxtField: UITextField!
    @IBOutlet weak var aptFloorView: UIView!
    @IBOutlet weak var aptTextField: UITextField!
    @IBOutlet weak var aptNoView: UIView!
    @IBOutlet weak var zipView: UIView!
    @IBOutlet weak var zipTxtField: UITextField!
    @IBOutlet weak var boroughTxtField: UITextField!
    @IBOutlet weak var boroughView: UIView!
    @IBOutlet weak var streetNumTxtField: UITextField!
    @IBOutlet weak var streetNameView: UIView!
    @IBOutlet weak var streetNameLbl: UILabel!
    @IBOutlet weak var streetNameTxtField: UITextField!
    
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var unitNameView: UIView! //for hidden
    @IBOutlet weak var unitView: UIView!  //for shake
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var loctionSwitch: UISwitch!
    
    //var arrNameList = NSMutableArray()
    
    var boroughPickListArray: [String]!
    
    let pickerView = UIPickerView()
    var selectedRow = 0
    
    var clientObj:ClientDO!
    
    var aptNo:String = ""
    var unitName:String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        pickerView.delegate = self
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        // boroughPickListArray = [ "Bronx", "Broonklyn", "Manhattan", "Queens", "Staten Island"]
        pickerView.backgroundColor = .white
        pickerView.showsSelectionIndicator = true
        
        let rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(AddressViewController.saveAction))
        
        self.navigationItem.rightBarButtonItem  = rightBarButtonItem
        
        let leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(AddressViewController.cancelAction))
        
        self.navigationItem.leftBarButtonItem  = leftBarButtonItem
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = false
        toolBar.tintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        toolBar.barTintColor = UIColor.white
        
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddressViewController.donePicker))
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style:UIBarButtonItemStyle.plain, target: self, action: #selector(AddressViewController.canclePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        self.boroughTxtField.inputView = pickerView
        boroughTxtField.inputAssistantItem.leadingBarButtonGroups.removeAll()
        boroughTxtField.inputAssistantItem.trailingBarButtonGroups.removeAll()
        boroughTxtField.inputAccessoryView = toolBar
        
        populateBorough()
        
    }
    
    func populateBorough(){
        
        let boroughData =  ManageCoreData.fetchData(salesforceEntityName: "DropDown", predicateFormat:"object == %@ AND fieldName == %@",predicateValue:  "Contact",predicateValue2:  "Borough__c", isPredicate:true) as! [DropDown]
        
        
        if(boroughData.count>0){
            
            var boroughStr = boroughData[0].value!
            
            boroughPickListArray = String(boroughStr.characters.dropLast()).components(separatedBy: ";")
            
            
        }
        
    }
    
    @IBAction func diffLocMainSwitch(_ sender: Any) {
        
        if((sender as AnyObject).isOn == true){

            aptTextField.text = "PH/Main"
            aptTextField.isEnabled = false
            
            
        }
        else{

            aptTextField.text = aptNo
            aptTextField.isEnabled = true
        }
    }
    
    @IBAction func sameLocMainSwitch(_ sender: Any) {
        
        if((sender as AnyObject).isOn == true){
            
            unitTextField.text = "PH/Main"
            unitTextField.isEnabled = false
            
            
        }
        else
        {
            
            unitTextField.text = unitName
            unitTextField.isEnabled = true
        }
    }
    
    func donePicker()
    {
        self.boroughTxtField.text = boroughPickListArray[selectedRow]as? String
        boroughTxtField.resignFirstResponder()
        
    }
    
    func canclePicker()
    {
        boroughTxtField.resignFirstResponder()
    }
    
    func saveAction()
    {
        
        
        var streetNum:String = ""
        var streetName:String = ""
        var borough:String = ""
        var zip:String = ""
        var aptFloor:String = ""
        
        aptNo = ""
        unitName = ""
        
        
        if(loctionSwitch.isOn){
            
            if let tempUnitName = unitTextField.text{
                unitName = tempUnitName
            }
            
            
            if(unitName.isEmpty){
                
                unitView.shake()
                
                self.view.makeToast("Please Enter Unit Number.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    
                    if didTap {
                        print("Completion with tap")
                        
                    } else {
                        print("Completion without tap")
                    }
                    
                    
                }
                
                
                return
                
            }
            
            unitName = unitName.trimmingCharacters(in: .whitespacesAndNewlines)
            
            
            let unitRes = ManageCoreData.fetchData(salesforceEntityName: "Unit",predicateFormat: "assignmentId == %@ && locationId == %@" ,predicateValue: SalesforceConnection.assignmentId, predicateValue2: SalesforceConnection.locationId,isPredicate:true) as! [Unit]
            
            if(unitRes.count > 0){
                
                for unitData in unitRes
                {
                    if(unitData.name?.lowercased() == unitName.lowercased()){
                        
                        unitView.shake()
                        unitName = ""
                        
                        self.view.makeToast("This Unit Number already exist.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                            
                            if didTap {
                                print("Completion with tap")
                                
                            } else {
                                print("Completion without tap")
                            }
                            
                            
                        }
                        
                        return
                    }
                }
                
                
            }

            
            
            let locationData = ManageCoreData.fetchData(salesforceEntityName: "Location",predicateFormat: "id == %@" ,predicateValue: SalesforceConnection.locationId,isPredicate:true) as! [Location]
            
            if(locationData.count > 0){
                
                streetName = locationData[0].streetName!
                streetNum = locationData[0].streetNumber!
                borough = locationData[0].borough!
                zip = locationData[0].zip!
                
            }
            
            aptNo = unitName
            
        }
        else{
            
            if let tempStreetNum = streetNumTxtField.text{
                streetNum = tempStreetNum
            }
            
            if let tempStreetName = streetNameTxtField.text{
                streetName = tempStreetName
            }
            
            if let tempBorough = boroughTxtField.text{
                borough = tempBorough
            }
            
            if let tempZip = zipTxtField.text{
                zip = tempZip
            }
            if let tempAptNo = aptTextField.text{
                aptNo = tempAptNo
            }
            if let tempAptFloor = aptFloorTxtField.text{
                aptFloor = tempAptFloor
            }
            
            
            
            if(streetNum.isEmpty){
                
                streetNumView.shake()
                
                self.view.makeToast("Please enter Street Number", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    
                    if didTap {
                        print("Completion with tap")
                        
                    } else {
                        print("Completion without tap")
                    }
                    
                    
                }
                
                
                return
                
            }
            
            if(streetName.isEmpty){
                
                streetNameView.shake()
                
                self.view.makeToast("Please enter Street Name", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    
                    if didTap {
                        print("Completion with tap")
                        
                    } else {
                        print("Completion without tap")
                    }
                    
                    
                }
                
                
                return
                
            }
            
            if(borough.isEmpty){
                
                boroughView.shake()
                
                self.view.makeToast("Please select borough", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    
                    if didTap {
                        print("Completion with tap")
                        
                    } else {
                        print("Completion without tap")
                    }
                    
                    
                }
                
                
                return
                
            }
            
            if(zip.isEmpty){
                
                zipView.shake()
                
                self.view.makeToast("Please enter zip", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    
                    if didTap {
                        print("Completion with tap")
                        
                    } else {
                        print("Completion without tap")
                    }
                    
                    
                }
                
                
                return
                
            }
            
            if(zip.characters.count < 5){
                
                zipView.shake()
                
                self.view.makeToast("zip should be 5 digit.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    
                    if didTap {
                        print("Completion with tap")
                        
                    } else {
                        print("Completion without tap")
                    }
                    
                    
                }
                
                
                return
                
            }
            
            if(aptNo.isEmpty){
                
                aptNoView.shake()
                
                self.view.makeToast("Please Enter Unit Number.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    
                    if didTap {
                        print("Completion with tap")
                        
                    } else {
                        print("Completion without tap")
                    }
                    
                    
                }
                
                
                return
                
            }
            
            unitName = ""
            
            
            
        }
        
        saveClientAddress(streetNo: streetNum, streetName: streetName, borough: borough, zip: zip, aptNo: aptNo, aptFloor: aptFloor)
        
        self.view.makeToast("Contact has been saved successfully.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
            
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateNoUnitClientView"), object: nil)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
            
            
            self.dismiss(animated: true, completion: nil)
            
            
        }
        
        
        
        
        // Utilities.clientAddressDict["StreetNum"] =
    }
    
    func saveClientAddress(streetNo:String,streetName:String,borough:String,zip:String,aptNo:String,aptFloor:String){
        
        let clientObject = Tenant(context: context)
        
        
        clientObject.id = UUID().uuidString
        clientObject.iOSTenantId = clientObject.id
        
        clientObject.name = clientObj.firstName + " " + clientObj.lastName
        clientObject.firstName = clientObj.firstName
        clientObject.lastName = clientObj.lastName
        clientObject.middleName = clientObj.middleName
        clientObject.suffix = clientObj.suffix
        clientObject.phone = clientObj.phone
        clientObject.email = clientObj.email
        clientObject.age =  clientObj.age
        clientObject.dob = clientObj.dob
        
        clientObject.streetNum = streetNo
        clientObject.streetName = streetName
        clientObject.borough = borough
        clientObject.aptNo = aptNo
        clientObject.aptFloor = aptFloor
        clientObject.zip = zip
        
        clientObject.attempt = ""
        clientObject.contact = ""
        clientObject.contactOutcome = ""
        clientObject.notes = ""
        
        clientObject.actionStatus = "create"
        
        clientObject.virtualUnit = "false"
        
        
        clientObject.assignmentId = SalesforceConnection.assignmentId
        
        clientObject.locationId = SalesforceConnection.locationId
        
        clientObject.assignmentLocId = SalesforceConnection.assignmentLocationId
        
        clientObject.sourceList = ""
        
        
        if(loctionSwitch.isOn){
            
            var iOSUnitId = UUID().uuidString
            var iOSAssignmentLocUnitId = UUID().uuidString
            
            //create new unit
            createNewUnit(aptNo: aptNo,iOSUnitId:iOSUnitId,iOSAssignmentLocUnitId: iOSAssignmentLocUnitId)
            
            clientObject.unitId = iOSUnitId
            
            clientObject.assignmentLocUnitId = iOSAssignmentLocUnitId
            
        }
        else{
            clientObject.unitId = ""
            
            clientObject.assignmentLocUnitId = ""
            
        }
        
        
        
        appDelegate.saveContext()
        
        
        
    }
    
    func createNewUnit(aptNo:String,iOSUnitId:String,iOSAssignmentLocUnitId:String){
        
        let unitObject = Unit(context: context)
        
        unitObject.id = iOSUnitId
       
        unitObject.assignmentLocUnitId = iOSAssignmentLocUnitId
        
        unitObject.iOSUnitId = iOSUnitId
        unitObject.iOSAssigLocUnitId = iOSAssignmentLocUnitId
        
        
        
        unitObject.locationId = SalesforceConnection.locationId
        
        unitObject.assignmentLocId = SalesforceConnection.assignmentLocationId
        
        
        
        unitObject.name =  aptNo
        
        unitObject.apartment = aptNo
        
        unitObject.notes = ""
        
        unitObject.assignmentId = SalesforceConnection.assignmentId
        
        if(aptNo == "PH/Main"){
            unitObject.privateHome =  "Yes"
        }
        else{
            unitObject.privateHome =  "No"
        }
        
        
        unitObject.virtualUnit = "false"
        
        
        unitObject.actionStatus = "create"
        
        unitObject.surveyStatus = ""
        unitObject.unitSyncDate = ""
        
        appDelegate.saveContext()
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelAction ()
    {
        let alertCtrl = Alert.showUIAlert(title: "Message", message: "Are you sure you want to close without saving?", vc: self)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel)
        { action -> Void in
            
        }
        
        alertCtrl.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            
            self.boroughTxtField.resignFirstResponder()
             self.unitTextField.resignFirstResponder()
            self.streetNumTxtField.resignFirstResponder()
            self.streetNameTxtField.resignFirstResponder()
            self.zipTxtField.resignFirstResponder()
            self.aptTextField.resignFirstResponder()
            self.aptFloorTxtField.resignFirstResponder()
            // self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
        alertCtrl.addAction(okAction)
        
    }
    
    
    func validate(value: String) -> Bool
    {
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = value.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        return  value == filtered
    }
    
    func isValidZipcode(value: String) -> Bool
    {
        
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = value.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        
        let currentCharacterCount = zipTxtField.text?.characters.count ?? 0
        
        let newLength = currentCharacterCount + value.characters.count
        if(newLength > 9)
        {
            return false
        }
        
        
        return value == filtered
        
        
    }
    
    func isValidFloor(value:String) -> Bool
    {
    
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = value.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        
        let currentCharacterCount = aptFloorTxtField.text?.characters.count ?? 0
        
        let newLength = currentCharacterCount + value.characters.count
        if(newLength > 3)
        {
            return false
        }
        
        
        return value == filtered

    }
    
    
    
    func isValidAptNo(value:String) -> Bool
    {
        let aSet =  NSCharacterSet(charactersIn:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789 ").inverted
        let compSepByCharInSet = value.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        
        let currentCharacterCount = aptTextField.text?.characters.count ?? 0
        
        
        let newLength = currentCharacterCount + value.characters.count
        if(newLength > 19){
            return false
        }
        
        return value == numberFiltered
        
    }
    
    func isValidUnitName(value:String) -> Bool
    {
        let aSet =  NSCharacterSet(charactersIn:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789 ").inverted
        let compSepByCharInSet = value.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        
        let currentCharacterCount = unitTextField.text?.characters.count ?? 0
        
        
        let newLength = currentCharacterCount + value.characters.count
        if(newLength > 19){
            return false
        }
        
        return value == numberFiltered
        
    }
    
    func isValidStreetNum(value:String) -> Bool
    {
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = value.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        
        let currentCharacterCount = streetNumTxtField.text?.characters.count ?? 0
        
        let newLength = currentCharacterCount + value.characters.count
        if(newLength > 23)
        {
            return false
        }
        
        
        return value == filtered
        
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        let str = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField == streetNameTxtField
        {
            guard let text = streetNameTxtField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            return newLength <= 100 // Bool
            
          //  return (streetNameTxtField.text != nil)
            
        }
            
        else if (textField == zipTxtField)
        {
            return isValidZipcode(value: str)
        }
        else if (textField == aptTextField)
        {
            aptNo = aptTextField.text!
            
            let val = isValidUnitName(value: str)
            
            if(val){
                aptNo = aptNo + string
            }
            
            return isValidAptNo(value: str)
        }
        else if (textField == unitTextField)
        {
            unitName = unitTextField.text!
            
            let val = isValidUnitName(value: str)
            
            if(val){
                unitName = unitName + string
            }
            
            return val
        }
        else if (textField == aptFloorTxtField)
        {
           return isValidFloor(value: str)
        }
        else if (textField == streetNumTxtField)
        {
            return isValidStreetNum(value: str)
        }
        else
        {
            return validate(value: str)
        }
        
    }
    //Mark Pickerview delegate methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        
        return self.boroughPickListArray.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return boroughPickListArray[row]
        
        //    return boroughPickListArray.object(at: row)as? String
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedRow = row
        //  self.boroughTxtField.text = arrAgeList.object(at: row) as? String
        
    }
    
    @IBAction func switchAction(_ sender: UISwitch)
    {
        if sender.isOn
        {
            addressView.isHidden = true
            unitView.isHidden = false
            
        }
            
        else
        {
            unitView.isHidden = true
            addressView.isHidden = false
            
        }
    }
    
}
/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */


