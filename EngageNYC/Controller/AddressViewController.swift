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
    
    
     //var arrNameList = NSMutableArray()
    
     var boroughPickListArray: [String]!
    
     let pickerView = UIPickerView()
    var selectedRow = 0
    
    var clientObj:ClientDO!
    
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
        
        let leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(AddressViewController.cancelAction))
        
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
        var aptNo:String = ""
        var aptFloor:String = ""
        
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
            
            self.view.makeToast("Please enter apartment number", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                if didTap {
                    print("Completion with tap")
                    
                } else {
                    print("Completion without tap")
                }
                
                
            }
            
            
            return
            
        }
        
        if(aptFloor.isEmpty){
            
            aptNoView.shake()
            
            self.view.makeToast("Please enter apartment floor", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                if didTap {
                    print("Completion with tap")
                    
                } else {
                    print("Completion without tap")
                }
                
                
            }
            
            
            return
            
        }
        
        saveClientAddress(streetNo: streetNum, streetName: streetName, borough: borough, zip: zip, aptNo: aptNo, aptFloor: aptFloor)
        
        self.view.makeToast("Contact has been saved successfully.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
            
             self.dismiss(animated: true, completion: nil)
            
            
        }
        


        
       // Utilities.clientAddressDict["StreetNum"] =
    }
    
    func saveClientAddress(streetNo:String,streetName:String,borough:String,zip:String,aptNo:String,aptFloor:String){
        
                let clientObject = Tenant(context: context)
        
        
                clientObject.id = UUID().uuidString
        
                clientObject.firstName = clientObj.firstName
                clientObject.lastName = clientObj.lastName
                clientObject.middleName = clientObj.middleName
                clientObject.suffix = clientObj.suffix
                clientObject.phone = clientObj.phone
                clientObject.email = clientObj.email
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
        
                clientObject.assignmentId = ""
        
                clientObject.locationId = ""
        
                clientObject.unitId = ""
        
                clientObject.assignmentLocUnitId = ""
                
                appDelegate.saveContext()
        

        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelAction ()
    {
        let alertCtrl = Alert.showUIAlert(title: "Message", message: "Are you sure you want to cancel without saving?", vc: self)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel)
        { action -> Void in
            
        }
        
        alertCtrl.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            
            self.boroughTxtField.resignFirstResponder()
            // self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
        alertCtrl.addAction(okAction)
        
    }
    
    
    func validate(phoneNumber: String) -> Bool
    {
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = phoneNumber.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        return  phoneNumber == filtered
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

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        let str = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField == streetNameTxtField
        {
            return (streetNameTxtField.text != nil)
            
        }
            
        else if (textField == zipTxtField)
        {
           return isValidZipcode(value: str)
        }
        else
        {
            return validate(phoneNumber: str)
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

    
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


