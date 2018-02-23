//
//  LocationInformationViewController.swift
//  EngageNYC
//
//  Created by Kamal on 13/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

enum enumAssignmentLocInfo:String{
    case attempt = "Attempt"
    case canvassingStatus = "Canvassing Status"
    case totalUnits = "# of Units"
    case name = "Name"
    case phoneNo = "Phone #"
    case phoneExt = "Phone Ext."
    case propertyContactTitle = "Property Contact Title"
}

enum assignmentLocInfoSection:String{
    case locInformation = "Location Information"
    case propertyInformation = "Property Information"
    
}
class AssignmentLocationInfoDO{
    
   
    var isObjectChanged:Bool!
    var assignmentLocVC:AssignmentLocationViewController!
    
    var assignmentLocationId:String!
   
    
  
    var oldAttempted:String!
    var oldLocStatus:String!
    var oldNotes:String!
    
    var oldPropertyName:String!
    var oldPropertyContactTitle:String!
    var oldPhoneNo:String!
    var oldPhoneExt:String!
    
    var attempted:String!{
        didSet{
            EnableDisableSaveBtn()
        }
    }
    var locStatus:String!{
        didSet{
            EnableDisableSaveBtn()
        }
    }
    var totalUnits:String!
    
    var notes:String!{
        didSet{
            EnableDisableSaveBtn()
        }
    }
    
    var propertyName:String!{
        didSet{
            EnableDisableSaveBtn()
        }
    }
    
    var propertyContactTitle:String!{
        didSet{
            EnableDisableSaveBtn()
        }
    }
    
    var phoneNo:String!{
        didSet{
            EnableDisableSaveBtn()
        }
    }
    
    var phoneExt:String!{
        didSet{
            EnableDisableSaveBtn()
        }
    }
    
    init(assignmentLocUnitId:String,attempted:String,locStatus:String,totalUnits:String,notes:String,propertyName:String,propertyContactTitle:String,phoneNo:String,phoneExt:String){
        self.assignmentLocationId = assignmentLocUnitId
        
        
        self.attempted = attempted
        self.locStatus = locStatus
        self.notes = notes
        
        self.oldAttempted = attempted
        self.oldLocStatus = locStatus
        self.oldNotes = notes
        
        self.totalUnits = totalUnits
        
        self.propertyName = propertyName
        self.propertyContactTitle = propertyContactTitle
        self.phoneNo = phoneNo
        self.phoneExt = phoneExt
        
        self.oldPropertyName = propertyName
        self.oldPropertyContactTitle = propertyContactTitle
        self.oldPhoneNo = phoneNo
        self.oldPhoneExt = phoneExt
        
        
        self.isObjectChanged = false
        
        
    }
    
    func EnableDisableSaveBtn(){
        if(self.attempted == self.oldAttempted && self.locStatus == self.oldLocStatus && self.notes == self.oldNotes && self.propertyName == self.oldPropertyName && self.propertyContactTitle == self.oldPropertyContactTitle && self.phoneNo == self.oldPhoneNo && self.phoneExt == self.oldPhoneExt){
            assignmentLocVC.rightBarButton.isEnabled = false
            isObjectChanged = false
            print("Object not changed")
            //disable save button
        }
        else{
             assignmentLocVC.rightBarButton.isEnabled = true
            isObjectChanged = true
            print("Object changed")
        }
    }
}



class AssignmentLocationInformationViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UITextFieldDelegate
{
    
    @IBOutlet weak var NotesTextArea: UITextView!
    @IBOutlet weak var tblAssignmentLocation: UITableView!
    
    var metadataConfigArray = [MetadataConfigObjects]()
    
    
    var viewModel:AssignmentLocationViewModel!
    var assignmentLocInfoObj:AssignmentLocationInfoDO!
    
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    var locationStatusPicklist:[DropDownDO]!
    var propertyContactTitlePicklist:[DropDownDO]!
    
    var isLocStatusSelect:Bool = false
    var isPropertyContactTitleSelect:Bool = false
    
    
    var phoneNoTextField:UITextField!
    var phoneExtTextField:UITextField!
    var propertyNameTextField:UITextField!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.reloadView()
        
    }
    
    func setUpUI(){
        NotesTextArea.layer.cornerRadius = 5
        NotesTextArea.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        NotesTextArea.layer.borderWidth = 0.5
        NotesTextArea.clipsToBounds = true
        NotesTextArea.textColor = UIColor.black
        
        self.tblAssignmentLocation?.tableFooterView = UIView()
        NotesTextArea.delegate = self
    }
    
  
    func textViewDidChange(_ textView: UITextView) {
        assignmentLocInfoObj.notes = textView.text
    }


    
    func reloadView(){
        DispatchQueue.main.async {
            self.locationStatusPicklist = self.viewModel.getPicklistOnLocation(objectType: "Assignment_Location__c", fieldName: "Status__c")
            self.propertyContactTitlePicklist = self.viewModel.getPicklistOnLocation(objectType: "Location__c", fieldName: "Property_Contact_Title__c")
            
            self.metadataConfigArray = self.viewModel.loadAssigmentLocInfoDetail()
        
            self.NotesTextArea.text = self.assignmentLocInfoObj.notes
            
            self.tblAssignmentLocation.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.isLocStatusSelect = false;
        self.isPropertyContactTitleSelect = false;
        
        
        self.navigationController?.isNavigationBarHidden = true;
    }
    
    func attemptChanged(_ sender: UISwitch)
    {
        
        //let index = sender.tag
        //let indexRow = (sender as AnyObject).tag
        if(sender.isOn){
            assignmentLocInfoObj.attempted = boolVal.yes.rawValue
        }
        else{
            assignmentLocInfoObj.attempted = boolVal.no.rawValue
        }
        
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        let str = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if(textField == phoneNoTextField){
            
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
            
            let compSepByCharInSet = string.components(separatedBy: aSet)
            
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            
            
            if string == numberFiltered
            {
                
                return checkEnglishPhoneNumberFormat(string: string, str: str)
                
            }
            
            return false
            
        }
        else if(textField == phoneExtTextField){
           
            let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
            let inputString = str.components(separatedBy: charcterSet)
            let filtered = inputString.joined(separator: "")
            
            let currentCharacterCount = phoneExtTextField.text?.count ?? 0
            
            let newLength = currentCharacterCount + str.count
            if(newLength > 19)
            {
                self.assignmentLocInfoObj.phoneExt = phoneExtTextField.text!
                return false
            }
            
           self.assignmentLocInfoObj.phoneExt = str
            
            return str == filtered
            
            
        }
        
        else if textField == propertyNameTextField{
            
           
            
            guard let text = propertyNameTextField.text else { return true }
            let newLength = text.count + string.count - range.length
            if(newLength <= 255){
                self.assignmentLocInfoObj.propertyName = str
                return true
            }
            
            return false
            
            
        }
        
        else{
            return true
        }
        
       
        
    }
    
    
    func checkEnglishPhoneNumberFormat(string: String?, str: String?) -> Bool{
        
        assignmentLocInfoObj.phoneNo = phoneNoTextField.text
        
        if string == ""{
            
            return true
            
        }else if str!.count < 3{
            
            if str!.count == 1{
                
                phoneNoTextField.text = "("

            }
            
            
        }else if str!.count == 5{
            
            phoneNoTextField.text = phoneNoTextField.text! + ") "
            
        }else if str!.count == 10{
            
            phoneNoTextField.text = phoneNoTextField.text! + "-"
            
        }else if str!.count > 14{
            
            
            return false
            
        }
        
        return true
        
    }
    
    
}

extension AssignmentLocationInformationViewController:DynamicPicklistDelegate{
    func getPickListValue(pickListValue: DropDownDO) {
        if(isLocStatusSelect){
            self.assignmentLocInfoObj.locStatus = pickListValue.name
        }
        else if(isPropertyContactTitleSelect){
            self.assignmentLocInfoObj.propertyContactTitle = pickListValue.name
        }
        self.tblAssignmentLocation.reloadData()
    }
}

extension AssignmentLocationInformationViewController
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.metadataConfigArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return metadataConfigArray[section].sectionName
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return metadataConfigArray[section].sectionObjects.count
    }
    
  
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        NotesTextArea.resignFirstResponder()
    
        let metadataConfigObject:MetadataConfigDO = metadataConfigArray[indexPath.section].sectionObjects[indexPath.row]
        
        if(metadataConfigObject.fieldName == enumAssignmentLocInfo.canvassingStatus.rawValue){
            
            
            let dynamicPicklistVC = DynamicPicklistStoryboard().instantiateViewController(withIdentifier: "DynamicPicklistViewController") as? DynamicPicklistViewController
            
            let dynamicPicklistObj = DynamicPicklistDO()
            dynamicPicklistObj.selectedDynamicPickListValue = assignmentLocInfoObj.locStatus
            dynamicPicklistObj.dynamicPickListArray = self.locationStatusPicklist
            dynamicPicklistObj.dynamicPicklistName = "Status"
            
            dynamicPicklistVC?.dynamicPicklistObj = dynamicPicklistObj
            dynamicPicklistVC?.delegate = self
            
            self.isLocStatusSelect = true
            
            self.navigationController?.pushViewController(dynamicPicklistVC!, animated: true)
            
            
        }
        
        if(metadataConfigObject.fieldName == enumAssignmentLocInfo.propertyContactTitle.rawValue){
            
            
            let dynamicPicklistVC = DynamicPicklistStoryboard().instantiateViewController(withIdentifier: "DynamicPicklistViewController") as? DynamicPicklistViewController
            
            let dynamicPicklistObj = DynamicPicklistDO()
            dynamicPicklistObj.selectedDynamicPickListValue = assignmentLocInfoObj.propertyContactTitle
            dynamicPicklistObj.dynamicPickListArray = self.propertyContactTitlePicklist
            dynamicPicklistObj.dynamicPicklistName = "Contact Title"
            
            dynamicPicklistVC?.dynamicPicklistObj = dynamicPicklistObj
            dynamicPicklistVC?.delegate = self
            
            self.isPropertyContactTitleSelect = true
            
            self.navigationController?.pushViewController(dynamicPicklistVC!, animated: true)
            
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let metadataConfigObject:MetadataConfigDO = metadataConfigArray[indexPath.section].sectionObjects[indexPath.row]
        
        if(metadataConfigObject.fieldName == enumAssignmentLocInfo.attempt.rawValue)
        {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell")!
            cell.backgroundColor = UIColor.white
            
            cell.textLabel?.text = metadataConfigObject.fieldName
            cell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            cell.selectionStyle = .none
            
            //accessory switch
            let attemptSwitch = UISwitch(frame: CGRect.zero)
            
            if assignmentLocInfoObj != nil {
                if(assignmentLocInfoObj.attempted == boolVal.yes.rawValue){
                    attemptSwitch.isOn = true
                }
                else if (assignmentLocInfoObj.attempted == boolVal.no.rawValue){
                    attemptSwitch.isOn = false
                }
                else{
                    attemptSwitch.isOn = false
                }
            }
            
            attemptSwitch.addTarget(self, action: #selector(AssignmentLocationInformationViewController.attemptChanged(_:)), for: UIControlEvents.valueChanged)
            
            cell.accessoryView = attemptSwitch
            return cell
        }
        
        else if(metadataConfigObject.fieldName == enumAssignmentLocInfo.canvassingStatus.rawValue)
        {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "rightDetailCell")!
            cell.backgroundColor = UIColor.white
            
            cell.accessoryType = .disclosureIndicator
            
            cell.textLabel?.text = metadataConfigObject.fieldName
            
            cell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            
            cell.detailTextLabel?.text = "Select Status"
            cell.detailTextLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            
            if assignmentLocInfoObj != nil {
                if(assignmentLocInfoObj.locStatus.isEmpty){
                    cell.detailTextLabel?.text = "Select Status"
                    cell.detailTextLabel?.font = UIFont.init(name: "Arial", size: 18.0)
                    
                }
                else{
                    cell.detailTextLabel?.text = assignmentLocInfoObj.locStatus
                    cell.detailTextLabel?.font = UIFont.init(name: "Arial", size: 18.0)
                }
            }
            cell.detailTextLabel?.textColor = UIColor.lightGray
            
            
            return cell
            
        }
        else if(metadataConfigObject.fieldName == enumAssignmentLocInfo.totalUnits.rawValue)
        {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "noOfUnitsCell", for: indexPath)
            cell.backgroundColor = UIColor.white
            cell.selectionStyle = .none
            cell.textLabel?.text = "# of Units"
            cell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            if assignmentLocInfoObj != nil {
                cell.detailTextLabel?.text = assignmentLocInfoObj.totalUnits
            }
            cell.detailTextLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            cell.detailTextLabel?.textColor = UIColor.lightGray
            
            return cell
            
        }
     
        else if(metadataConfigObject.fieldName == enumAssignmentLocInfo.name.rawValue)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.backgroundColor = UIColor.white
            cell.textLabel?.text = metadataConfigObject.fieldName
            cell.textLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            cell.selectionStyle = .none
            
            //UITextField
            let textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
            
            textfield.backgroundColor = UIColor.clear
            textfield.textAlignment = .right
            textfield.tag = indexPath.row
            textfield.delegate = self
            
           
            propertyNameTextField = textfield
            
            if let textFieldValue = assignmentLocInfoObj.propertyName {
                textfield.text  = textFieldValue

            }
            else{
                textfield.text  = ""
            }
            
            
            
            let grayColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
            
            textfield.layer.backgroundColor = grayColor.cgColor
            
            
            
            textfield.textColor = UIColor.gray
            
            textfield.autocorrectionType = UITextAutocorrectionType.no
            
            textfield.spellCheckingType = UITextSpellCheckingType.no
            
            cell.accessoryView = textfield
            
            
            return cell
        }
        
        else if(metadataConfigObject.fieldName == enumAssignmentLocInfo.phoneNo.rawValue)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.backgroundColor = UIColor.white
            cell.textLabel?.text = metadataConfigObject.fieldName
            cell.textLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            cell.selectionStyle = .none
            
            //UITextField
            let textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
            
            textfield.backgroundColor = UIColor.clear
            textfield.textAlignment = .right
            textfield.tag = indexPath.row
            textfield.delegate = self
            textfield.text  = ""
            
            if let textFieldValue = assignmentLocInfoObj.phoneNo {
                textfield.text  = textFieldValue
                
            }
            else{
                textfield.text  = ""
            }
            
            phoneNoTextField = textfield
            
            let grayColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
            
            textfield.layer.backgroundColor = grayColor.cgColor

            textfield.textColor = UIColor.gray
            
            textfield.autocorrectionType = UITextAutocorrectionType.no
            
            textfield.spellCheckingType = UITextSpellCheckingType.no
            
            cell.accessoryView = textfield
            
            
            return cell
        }
        
        else if(metadataConfigObject.fieldName == enumAssignmentLocInfo.phoneExt.rawValue)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.backgroundColor = UIColor.white
            cell.textLabel?.text = metadataConfigObject.fieldName
            cell.textLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            cell.selectionStyle = .none
            
            //UITextField
            let textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
            
            textfield.backgroundColor = UIColor.clear
            textfield.textAlignment = .right
            textfield.tag = indexPath.row
            textfield.delegate = self
            
            textfield.text  = ""
            
            if let textFieldValue = assignmentLocInfoObj.phoneExt {
                textfield.text  = textFieldValue
                
            }
            else{
                textfield.text  = ""
            }
            
            
            phoneExtTextField = textfield
            
            let grayColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
            
            textfield.layer.backgroundColor = grayColor.cgColor
            
            
            
            textfield.textColor = UIColor.gray
            
            textfield.autocorrectionType = UITextAutocorrectionType.no
            
            textfield.spellCheckingType = UITextSpellCheckingType.no
            
            cell.accessoryView = textfield
            
            
            return cell
        }
        
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "rightDetailCell")!
            cell.backgroundColor = UIColor.white
            
            cell.accessoryType = .disclosureIndicator
            
            cell.textLabel?.text = metadataConfigObject.fieldName
            
            cell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            
            cell.detailTextLabel?.text = "Select Contact Title"
            cell.detailTextLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            
            if assignmentLocInfoObj != nil {
                if(assignmentLocInfoObj.propertyContactTitle.isEmpty){
                    cell.detailTextLabel?.text = "Select Contact Title"
                    cell.detailTextLabel?.font = UIFont.init(name: "Arial", size: 18.0)

                }
                else{
                    cell.detailTextLabel?.text = assignmentLocInfoObj.propertyContactTitle
                    cell.detailTextLabel?.font = UIFont.init(name: "Arial", size: 18.0)
                }
            }
            
            cell.detailTextLabel?.textColor = UIColor.lightGray
            
            
            return cell
            
        }
        
    }
    
    
    
    
}


