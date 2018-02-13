//
//  AddCasesViewController.swift
//  EngageNYC
//
//  Created by MTX on 1/23/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

enum enumCaseActionStatus:String{
    case Add = "Add"
    case Edit = "Edit"
    case View = "View"
}

class AddCasesViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate
{
    @IBOutlet weak var lblAdditionInfo: UILabel!
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var tblCases: UITableView!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var btnNotes: UIButton!
    @IBOutlet weak var lblNotes: UILabel!
    @IBOutlet weak var imgNote: UIImageView!
    
    
    var objCase:CaseDO!
    var viewModel:CaseViewModel!
    var metadataConfigArray = [MetadataConfigObjects]()
    
    var switchDict:[Int:String] = [:]
    var textAreaDict:[Int:String] = [:]
    var textFieldDict:[Int:String] = [:]
    var phoneTextFieldDict:[Int:String] = [:]      //handle tag + apiname
    
    var selectedIndexPath:IndexPath?
    var dateApiName:String = ""
    var pickListApiName:String  = ""
    var multiPickListApiName:String  = ""
    var inTakeVC:IntakeViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.setupView()
        self.reloadView()
        
        Utility.makeButtonBorder(btn: saveBtn)
        
         Utility.makeButtonBorder(btn: cancelBtn)
        
    }
    
    
    func setUpUI(){
        
        txtNotes.layer.cornerRadius = 5
        txtNotes.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        txtNotes.layer.borderWidth = 0.5
        txtNotes.clipsToBounds = true
        txtNotes.textColor = UIColor.black
        self.tblCases?.tableFooterView = UIView()
        
        btnNotes.isHidden = false
        lblNotes.isHidden = false
        imgNote.isHidden = false
        
        
        if(objCase.caseActionStatus ==  enumCaseActionStatus.View.rawValue){
            saveBtn.isHidden = true
            txtNotes.isEditable = false
            lblAdditionInfo.text = objCase.dateOfIntake
            if(objCase.caseNo.isEmpty){
                 headerTitle.text = "View Case"
            }
            else{
                headerTitle.text = objCase.caseNo
            }
            
        }
        else if(objCase.caseActionStatus ==  enumCaseActionStatus.Add.rawValue){
            saveBtn.isHidden = false
            lblAdditionInfo.text = ""
            headerTitle.text = "Add Case"
            
            
            btnNotes.isHidden = true
            lblNotes.isHidden = true
            imgNote.isHidden = true
        }
        else{
            saveBtn.isHidden = false
            lblAdditionInfo.text = objCase.dateOfIntake
            if(objCase.caseNo.isEmpty){
                headerTitle.text = "Edit Case"
            }
            else{
                headerTitle.text = objCase.caseNo
            }
            
            
        }
        
        txtNotes.text = objCase.caseNotes
        
//        if(objCase.caseNo.isEmpty){
//            txtNotes.text = objCase.caseNotes
//        }
       
        
       
        
    }
    
    
    
    
    func setupView() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.bindView()
        }
    }
    
    func reloadView(){
        
        DispatchQueue.main.async {
            self.metadataConfigArray = self.viewModel.loadCaseDetail(objCase:self.objCase)
            print(self.metadataConfigArray)
            self.tblCases.reloadData()
        }
    }
   
    
    @IBAction func btnNotesPressed(_ sender: Any) {
        
        if let caseNotesVC = CaseNotesStoryboard().instantiateViewController(withIdentifier: "CaseNotesViewController") as? CaseNotesViewController{
            
            caseNotesVC.selectedCaseObj = objCase
            
            let navigationController = UINavigationController(rootViewController: caseNotesVC)
            navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
            self.navigationController?.pushViewController(caseNotesVC, animated: true)
        }
        
    }
    
    @IBAction func btnBackAction(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSavepressed(_ sender: Any) {
        
        saveBtn.isEnabled = false
        
        var msg:String = ""
     
        if(objCase.caseId.isEmpty){
            viewModel.SaveCaseInCoreData(objCase:objCase)
             msg = "Case has been created successfully."
            
            if(self.objCase.clientId.isEmpty){
                self.inTakeVC.saveBtn.isHidden = false
            }
        }
        else{
            viewModel.UpdateCaseInCoreData(objCase:objCase)
            msg = "Case has been updated successfully."
        }
    
        
        self.view.makeToast(msg, duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
            
           
            
            CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.INTAKECASELISTING_SYNC.rawValue, sender: nil, userInfo: nil)
            
  
            self.navigationController?.popViewController(animated: true);
            
            
        }
        
        
    }
    
    
    
}

extension AddCasesViewController{
    
    func switchChanged(_ sender: UISwitch)
    {
        let index = sender.tag
        
        objCase.caseResponseDynamicDict[switchDict[index]!] = sender.isOn as AnyObject?
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if(textView == txtNotes){
              objCase.caseNotes = textView.text
        }
      
    }
    
    
    @nonobjc func textViewDidEndEditing(_ textView: UITextView) -> Bool {
        
        objCase.caseResponseDynamicDict[textAreaDict[textView.tag]!] =  textView.text! as AnyObject?
        
        textView.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(phoneTextFieldDict[textField.tag] != nil){
            let aSet =  NSCharacterSet(charactersIn:"0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            
            let currentCharacterCount = textField.text?.count ?? 0
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            let newLength = currentCharacterCount + string.count - range.length
            if(newLength > 10){
                return false
            }
            
            
            objCase.caseResponseDynamicDict[phoneTextFieldDict[textField.tag]!] = Int64(textField.text! + string)
                as AnyObject
            
            return string == numberFiltered
        }
        else{
            objCase.caseResponseDynamicDict[textFieldDict[textField.tag]!] =  (textField.text! + string) as AnyObject?
            return true
        }
        
    }
    
    
    
}

extension AddCasesViewController{
    func bindView(){
        self.viewModel = CaseViewModel.getViewModel()
    }
}

extension AddCasesViewController:DateTableViewCellDelegate{
    func selectDate(forDate date: Date){
        
        objCase.caseResponseDynamicDict[dateApiName] = date as AnyObject?
        
    }
}
extension AddCasesViewController {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.metadataConfigArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return metadataConfigArray[section].sectionName
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return metadataConfigArray[section].sectionObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let metadataConfigObject:MetadataConfigDO = metadataConfigArray[indexPath.section].sectionObjects[indexPath.row]
        
        
        
        if(metadataConfigObject.dataType == "BOOLEAN")
        {
            
            let switchCell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            
            
            switchCell.textLabel?.text = metadataConfigObject.fieldName
            switchCell.textLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            switchCell.backgroundColor = UIColor.white
            
            
            switchCell.selectionStyle = .none
            
            
            switchDict[indexPath.row] = metadataConfigObject.apiName
            
            //accessory switch
            let uiSwitch = UISwitch(frame: CGRect.zero)
            
            uiSwitch.tag = indexPath.row
            
            uiSwitch.backgroundColor = UIColor.white
            
            
            if let switchValue = objCase.caseResponseDynamicDict[metadataConfigObject.apiName]{
                uiSwitch.isOn = switchValue as! Bool
            }
            else
            {
                uiSwitch.isOn = false
            }
            
            
            if(objCase.caseActionStatus != enumCaseActionStatus.View.rawValue){
                
                uiSwitch.addTarget(self, action: #selector(AddCasesViewController.switchChanged(_:)), for: UIControlEvents.valueChanged)
                
            }
            else{
                uiSwitch.isEnabled = false
            }
            
            
            switchCell.accessoryView = uiSwitch
            
            return switchCell
            
            
        }
            
        else if(metadataConfigObject.dataType == "TEXTAREA")
        {
            
            let textAreaCell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            
            textAreaCell.textLabel?.text = metadataConfigObject.fieldName
            textAreaCell.textLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            textAreaCell.textLabel?.numberOfLines = 2
            
            
            textAreaCell.selectionStyle = .none
            
            textAreaDict[indexPath.row] = metadataConfigObject.apiName
            
            //UITextView
            let textArea = UITextView(frame: CGRect(x: 0, y: 0, width: 200, height: 99))
            textArea.font = UIFont.init(name: "Arial", size: 16.0)
            textArea.textAlignment = .right
            textArea.tag = indexPath.row
            textArea.delegate = self
            
            if let textAreaValue = objCase.caseResponseDynamicDict[metadataConfigObject.apiName] as! String! {
                textArea.text  = textAreaValue
            }
            else{
                textArea.text  = ""
            }
            
            
            
            let grayColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
            
            textArea.layer.backgroundColor = grayColor.cgColor
            
            if(objCase.caseActionStatus == enumCaseActionStatus.View.rawValue){
                textArea.isEditable = false
            }
            
            textArea.textColor = UIColor.gray
            
            textAreaCell.accessoryView = textArea
            
            
            
            return textAreaCell
        }
        else if(metadataConfigObject.dataType == "PICKLIST"){
            
            
            let pickListCell = tableView.dequeueReusableCell(withIdentifier: "rightDetailCell", for: indexPath)
            
            
            pickListCell.textLabel?.text = metadataConfigObject.fieldName
            pickListCell.textLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            
            
            if(objCase.caseActionStatus == enumCaseActionStatus.View.rawValue){
                pickListCell.accessoryType = .none
                pickListCell.selectionStyle = .none
                
            }
            else{
                pickListCell.accessoryType = .disclosureIndicator
                pickListCell.selectionStyle = .default
            }
            
            
            
            if let pickListValue = objCase.caseResponseDynamicDict[metadataConfigObject.apiName] as! String! {
                pickListCell.detailTextLabel?.text = pickListValue
            }
            else{
                pickListCell.detailTextLabel?.text = ""
            }
            
            pickListCell.detailTextLabel?.textColor = UIColor.gray
            pickListCell.detailTextLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            return pickListCell
            
        }
        else if(metadataConfigObject.dataType == "MULTIPICKLIST"){
            
            
            let multiPickListCell = tableView.dequeueReusableCell(withIdentifier: "rightDetailCell", for: indexPath)
            
            
            multiPickListCell.textLabel?.text = metadataConfigObject.fieldName
            multiPickListCell.textLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            if(objCase.caseActionStatus == enumCaseActionStatus.View.rawValue){
                multiPickListCell.accessoryType = .none
                
            }
            else{
                multiPickListCell.accessoryType = .disclosureIndicator
            }
            
            
            
            
            
            if let multiPickListValue = objCase.caseResponseDynamicDict[metadataConfigObject.apiName] as! String! {
                
                multiPickListCell.detailTextLabel?.text = multiPickListValue
            }
            else{
                multiPickListCell.detailTextLabel?.text = ""
            }
            
            
            
            multiPickListCell.detailTextLabel?.numberOfLines = 2
            
            multiPickListCell.detailTextLabel?.textColor = UIColor.gray
            multiPickListCell.detailTextLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            
            
            return multiPickListCell
            
        }
            
        else if(metadataConfigObject.dataType == "DATE")
        {
            
            let dateTimeCell = tableView.dequeueReusableCell(withIdentifier: "dateTimeCell", for: indexPath) as! DateTableViewCell
            
            dateTimeCell.title.text = metadataConfigObject.fieldName
            
            dateTimeCell.title.font = UIFont.init(name: "Arial", size: 16.0)
            
            
            dateTimeCell.selectionStyle = .none
            
            dateTimeCell.datePicker.datePickerMode = UIDatePickerMode.date
            
            if let val = objCase.caseResponseDynamicDict[metadataConfigObject.apiName]{
                let dateVal = val as! Date
                dateTimeCell.datePicker.date = dateVal
                let dateFormatter = DateFormatter()
                //dateFormatter.dateFormat = "MM-dd-yyyy"
                dateFormatter.dateFormat = "MM/dd/yyyy"
                dateTimeCell.detail.text = dateFormatter.string(from: dateVal)
                
            }
                
            else
            {
                dateTimeCell.datePicker.date = Date()
                dateTimeCell.detail.text = ""
            }
            
            
            if(objCase.caseActionStatus == enumCaseActionStatus.View.rawValue){
                dateTimeCell.accessoryType = .none
            }
            else{
                dateTimeCell.accessoryType = .disclosureIndicator
            }
            
            
            
            dateTimeCell.detail.textColor = UIColor.gray
            dateTimeCell.detail.font = UIFont.init(name: "Arial", size: 16.0)
            
            dateTimeCell.delegate = self
            
            
            return dateTimeCell
        }
        else if(metadataConfigObject.dataType == "PHONE"){
            
            let phoneCell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            
            phoneCell.textLabel?.text = metadataConfigObject.fieldName
            phoneCell.textLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            
            phoneCell.selectionStyle = .none
            
            phoneTextFieldDict[indexPath.row] = metadataConfigObject.apiName
            
            //UIPhoneTextField
            let phoneTextfield = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
            
            
            phoneTextfield.textAlignment = .right
            phoneTextfield.tag = indexPath.row
            phoneTextfield.delegate = self
            
            if let phoneVal = objCase.caseResponseDynamicDict[metadataConfigObject.apiName]{
                phoneTextfield.text = String(describing: phoneVal)
            }
            else{
                phoneTextfield.text = ""
            }
            
            
            
            
            let whiteColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
            
            
            phoneTextfield.layer.backgroundColor = whiteColor.cgColor
            
            if(objCase.caseActionStatus == enumCaseActionStatus.View.rawValue){
                phoneTextfield.isEnabled = false
            }
            
            phoneCell.accessoryView = phoneTextfield
            
            phoneTextfield.textColor = UIColor.gray
            
            phoneTextfield.autocorrectionType = UITextAutocorrectionType.no
            
            phoneTextfield.spellCheckingType = UITextSpellCheckingType.no
            
            
            return phoneCell
        }
        else
        {
            
            let textCell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            
            textCell.textLabel?.text = metadataConfigObject.fieldName
            textCell.textLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            textCell.selectionStyle = .none
            
            textFieldDict[indexPath.row] = metadataConfigObject.apiName
            
            //UITextField
            let textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
            
            
            textfield.textAlignment = .right
            textfield.tag = indexPath.row
            textfield.delegate = self
            
            if let textFieldValue = objCase.caseResponseDynamicDict[metadataConfigObject.apiName] as! String! {
                textfield.text  = textFieldValue
                
            }
            else{
                textfield.text  = ""
            }
            
            
            
            let grayColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
            
            textfield.layer.backgroundColor = grayColor.cgColor
            
            if(objCase.caseActionStatus == enumCaseActionStatus.View.rawValue){
                textfield.isEnabled = false
            }
            
            textfield.textColor = UIColor.gray
            
            textfield.autocorrectionType = UITextAutocorrectionType.no
            
            textfield.spellCheckingType = UITextSpellCheckingType.no
            
            textCell.accessoryView = textfield
            
            return textCell
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let metadataConfigObject:MetadataConfigDO = metadataConfigArray[indexPath.section].sectionObjects[indexPath.row]
        
        if(metadataConfigObject.dataType == "DATE"){
            (cell as! DateTableViewCell).watchFrameChanges()
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let metadataConfigObject:MetadataConfigDO = metadataConfigArray[indexPath.section].sectionObjects[indexPath.row]
        
        
        if(metadataConfigObject.dataType == "DATE"){
            (cell as! DateTableViewCell).ignoreFrameChanges()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        let metadataConfigObject:MetadataConfigDO = metadataConfigArray[indexPath.section].sectionObjects[indexPath.row]
        
        
        if(metadataConfigObject.dataType == "TEXTAREA"){
            return 100.0
        }
            
        else if(metadataConfigObject.dataType == "DATE"){
            if indexPath == selectedIndexPath {
                return DateTableViewCell.expandHeight
            } else {
                return DateTableViewCell.defaultHeight
            }
        }
        else{
            return UITableViewAutomaticDimension
        }
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let metadataConfigObject:MetadataConfigDO = metadataConfigArray[indexPath.section].sectionObjects[indexPath.row]
        
        if(metadataConfigObject.dataType == "PICKLIST" && objCase.caseActionStatus != enumCaseActionStatus.View.rawValue){
            
            pickListApiName = metadataConfigObject.apiName
            
            let dynamicPicklistVC = DynamicPicklistStoryboard().instantiateViewController(withIdentifier: "DynamicPicklistViewController") as? DynamicPicklistViewController
            
            let dynamicPicklistObj = DynamicPicklistDO()
            
            if let selectedVal = objCase.caseResponseDynamicDict[pickListApiName]{
                dynamicPicklistObj.selectedDynamicPickListValue = selectedVal as! String
            }
            else{
                dynamicPicklistObj.selectedDynamicPickListValue = ""
            }
            
            dynamicPicklistObj.dynamicPickListArray = self.viewModel.loadPickList(pickListStr: metadataConfigObject.pickListValue)
            
            dynamicPicklistObj.dynamicPicklistName = metadataConfigObject.fieldName
            
            dynamicPicklistVC?.dynamicPicklistObj = dynamicPicklistObj
            dynamicPicklistVC?.delegate = self
            
            self.navigationController?.pushViewController(dynamicPicklistVC!, animated: true)
            
        }
            
        else if(metadataConfigObject.dataType == "MULTIPICKLIST" && objCase.caseActionStatus != enumCaseActionStatus.View.rawValue){
            
            multiPickListApiName = metadataConfigObject.apiName
            
            let dynamicMultiPicklistVC = DynamicMultiPicklistStoryboard().instantiateViewController(withIdentifier: "DynamicMultiPicklistViewController") as? DynamicMultiPicklistViewController
            
            let dynamicMultiPicklistObj = DynamicMultiPicklistDO()
            
            if let selectedVal = objCase.caseResponseDynamicDict[multiPickListApiName]{
                dynamicMultiPicklistObj.selectedDynamicMultiPickListValue = selectedVal as! String
            }
            else{
                dynamicMultiPicklistObj.selectedDynamicMultiPickListValue = ""
            }
            
            dynamicMultiPicklistObj.dynamicMultiPickListArray = self.viewModel.loadPickList(pickListStr: metadataConfigObject.pickListValue)
            
            dynamicMultiPicklistObj.dynamicMultiPicklistName = metadataConfigObject.fieldName
            
            dynamicMultiPicklistVC?.dynamicMultiPicklistObj = dynamicMultiPicklistObj
            dynamicMultiPicklistVC?.delegate = self
            
            self.navigationController?.pushViewController(dynamicMultiPicklistVC!, animated: true)
            
        }
        else if(metadataConfigObject.dataType == "DATE" && objCase.caseActionStatus != enumCaseActionStatus.View.rawValue){
            
            dateApiName = metadataConfigObject.apiName
            
            let previousIndexPath =   selectedIndexPath
            if(indexPath == selectedIndexPath){
                selectedIndexPath = nil
            }
            else{
                selectedIndexPath = indexPath
            }
            
            var indexPaths:Array<IndexPath> = []
            if let previous = previousIndexPath{
                indexPaths += [previous]
            }
            if let current = selectedIndexPath{
                indexPaths += [current]
            }
            
            if indexPaths.count > 0 {
                tableView.reloadRows(at: indexPaths, with: UITableViewRowAnimation.automatic)
            }
            
            
        }
            
            
        else if(metadataConfigObject.dataType == "TEXTAREA" && objCase.caseActionStatus != enumCaseActionStatus.View.rawValue)
        {
            
            let currentCell: UITableViewCell? = tblCases.cellForRow(at: indexPath)
            let textView = currentCell?.viewWithTag(indexPath.row) as? UITextView
            textView?.delegate = self
            textView?.becomeFirstResponder()
            
        }
    }
    
    
}

extension AddCasesViewController:DynamicPicklistDelegate{
    func getPickListValue(pickListValue: DropDownDO) {
        objCase.caseResponseDynamicDict[pickListApiName] = pickListValue.name as AnyObject?
        self.tblCases.reloadData()
    }
}

extension AddCasesViewController:DynamicMultiPicklistDelegate{
    func getMultiPickListValue(multiPickListValue: String) {
        objCase.caseResponseDynamicDict[multiPickListApiName] = multiPickListValue as AnyObject?
        self.tblCases.reloadData()
    }
}
