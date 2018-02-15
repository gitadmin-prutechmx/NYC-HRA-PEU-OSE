//
//  AssignmentLocationUnitInformationViewController.swift
//  EngageNYC
//
//  Created by Kamal on 14/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

enum unitAttemptScreen:Int{
    case attempt = 0
    case contacted
    case contactOutcome
    case surveyed
    case contactPicklist
    case followUpDate
    case followUpType

    
}

enum boolVal:String{
    case yes = "Yes"
    case no = "No"
}

class AssignmentLocationUnitInfoDO{
    
     var isObjectChanged:Bool!
    
    var assignmentLocationUnitId:String!
    
    
    var assignmentLocUnitVC:AssignmentLocationUnitViewController!
    
    var oldAttempted:String!
    var oldContacted:String!
    var oldContactOutcomeYes:String!
    var oldContactOutcomeNo:String!
    var oldSurveyed:String!
    var oldContactId:String!
    var oldFollowUpDate:String!
    var oldFollowUpType:String!
    var oldNotes:String!
    
    
    var contactName:String!
    
    var attempted:String!{
        didSet{
            EnableDisableSaveBtn()
        }
    }
    var contacted:String!{
        didSet{
            EnableDisableSaveBtn()
        }
    }
    
    var contactOutcome:String!
    
    var surveyed:String!{
        didSet{
            EnableDisableSaveBtn()
        }
    }
    var contactId:String!{
        didSet{
            EnableDisableSaveBtn()
        }
    }
    
    var followUpDate:String!{
        didSet{
            EnableDisableSaveBtn()
        }
    }
    var followUpType:String!{
        didSet{
            EnableDisableSaveBtn()
        }
    }
    var notes:String!{
        didSet{
            EnableDisableSaveBtn()
        }
    }
    
    var lastCanvassedBy:String!
    
   
    var isUnitListing:Bool!
    
    var contactOutcomeNo:String{
        didSet{
            EnableDisableSaveBtn()
        }
    }
    var contactOutcomeYes:String {
        didSet{
            EnableDisableSaveBtn()
        }
    }
    
    init(assignmentLocationUnitId:String,attempted:String,contacted:String,contactOutcome:String,surveyed:String,contactId:String,followUpDate:String,followUpType:String,notes:String){
        
        self.attempted = attempted
        self.contacted = contacted
        self.surveyed = surveyed
        self.contactOutcome = contactOutcome
        self.contactId = contactId
        self.followUpDate = followUpDate
        self.followUpType = followUpType
        self.notes = notes
        
        self.contactOutcomeNo = ""
        self.contactOutcomeYes = ""
        self.oldContactOutcomeNo = ""
        self.oldContactOutcomeYes = ""
        
        self.contactName = ""
        
        self.oldAttempted = attempted
        self.oldContacted = contacted
        self.oldSurveyed = surveyed
       
        self.oldContactId = contactId
        self.oldFollowUpDate = followUpDate
        self.oldFollowUpType = followUpType
        self.oldNotes = notes
        
        self.lastCanvassedBy = ""
        
        self.assignmentLocationUnitId = assignmentLocationUnitId
        
        self.isObjectChanged = false
        
        self.isUnitListing = false
        
    }
    
    func EnableDisableSaveBtn(){
        
        
        if(self.attempted == self.oldAttempted && self.contacted == self.oldContacted && self.notes == self.oldNotes && self.surveyed == self.oldSurveyed && self.contactId == self.oldContactId && self.followUpDate == self.oldFollowUpDate && self.followUpType == self.oldFollowUpType && (self.contactOutcomeYes == self.oldContactOutcomeYes  || self.contactOutcomeNo == self.oldContactOutcomeNo)){
            assignmentLocUnitVC.rightBarButton.isEnabled = false
            isObjectChanged = false
            print("Object not changed")
            //disable save button
        }
        else{
            assignmentLocUnitVC.rightBarButton.isEnabled = true
            isObjectChanged = true
            print("Object changed")
        }
    }
}



class AssignmentLocationUnitInformationViewController: UIViewController,UITableViewDelegate,UITableViewDataSource
{
    var delegate:UpdateAssignmentLocationUnit?
    
    var selectedIndexPath:IndexPath?
    
   
    var selectContact:String = ""
    
    var followUpDate:Date?
    
    var reasonCell:UITableViewCell!
    var contactOutcomeCell:UITableViewCell!
    var selectContactCell:UITableViewCell!
    var followUpTypeCell:UITableViewCell!
    var followUpDateCell:DateTableViewCell!
    
    var isContactOutcomeSelect:Bool = false
    var isFollowUpTypeSelect:Bool = false
    var isSelectContactSelect:Bool = false
    
    
    @IBOutlet weak var NotesTextArea: UITextView!
    @IBOutlet weak var tblAssignmentLocationUnit: UITableView!
    
    @IBOutlet weak var btnNext:UIButton!
    
    @IBOutlet weak var assignmentUnitInfoView: UIView!
    
    var viewModel:AssignmentLocationUnitViewModel!
    var assignmentLocUnitInfoObj:AssignmentLocationUnitInfoDO!
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    
    var contactOutcomePicklist:[DropDownDO]!
    var reasonPicklist:[DropDownDO]!
    var followUpTypePicklist:[DropDownDO]!
    var ContactsPicklist:[DropDownDO]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.reloadView()
        
    }
    
    func setUpUI(){
        
        btnNext.layer.cornerRadius = 5.0
        
        NotesTextArea.layer.cornerRadius = 5
        NotesTextArea.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        NotesTextArea.layer.borderWidth = 0.5
        NotesTextArea.clipsToBounds = true
        NotesTextArea.textColor = UIColor.black
        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        assignmentLocUnitInfoObj.notes = textView.text
    }
    
    func updateContactList(){
         self.ContactsPicklist = self.viewModel.getContactsOnUnit(assignmentLocUnitId: self.assignmentLocUnitInfoObj.assignmentLocationUnitId)
    }
    
    
    
    func reloadView(){
        DispatchQueue.main.async {

            
            self.contactOutcomePicklist = self.viewModel.getAssignmentLocUnitPicklist(objectType: "Assignment_Location_Unit__c", fieldName: "Contact_Outcome__c")
            self.reasonPicklist = self.viewModel.getAssignmentLocUnitPicklist(objectType: "Assignment_Location_Unit__c", fieldName: "reason__c")
            self.followUpTypePicklist = self.viewModel.getAssignmentLocUnitPicklist(objectType: "Assignment_Location_Unit__c", fieldName: "Follow_Up_Type__c")
           self.updateContactList()
            
            if(self.assignmentLocUnitInfoObj != nil){
                
                if(self.assignmentLocUnitInfoObj.contacted == boolVal.yes.rawValue){
                    self.assignmentLocUnitInfoObj.contactOutcomeYes = self.assignmentLocUnitInfoObj.contactOutcome
                }
                else{
                    self.assignmentLocUnitInfoObj.contactOutcomeNo = self.assignmentLocUnitInfoObj.contactOutcome
                }
                
                if(self.assignmentLocUnitInfoObj.attempted == boolVal.yes.rawValue && self.assignmentLocUnitInfoObj.contacted == boolVal.yes.rawValue  && self.assignmentLocUnitInfoObj.surveyed == boolVal.yes.rawValue){
                    
                    self.enableNextBtn()
                }
                else{
                    self.disableNextBtn()
                }
                
                //if comes from unit then no clientid
                //if comes from client then clientid
                
                //if tap to unitlisting screen
                if(self.canvasserTaskDataObject.contactObj.contactId.isEmpty){
                    if let contactId = self.assignmentLocUnitInfoObj.contactId{
                        self.assignmentLocUnitInfoObj.contactName = self.viewModel.getContactName(contactId: contactId)
                        self.assignmentLocUnitInfoObj.contactId = contactId
                    }
                }
                    //else tap to clientlisting screen
                else{
                     self.assignmentLocUnitInfoObj.contactId = self.canvasserTaskDataObject.contactObj.contactId
                    
                    self.assignmentLocUnitInfoObj.contactName = self.viewModel.getContactName(contactId: self.canvasserTaskDataObject.contactObj.contactId)
                }
                
                
                
                if let followUpDateVal =  self.assignmentLocUnitInfoObj.followUpDate{
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let date = dateFormatter.date(from: followUpDateVal)
                    
                    if(date != nil){
                        
                        dateFormatter.dateFormat = "MM/dd/yyyy"
                        let strDate = dateFormatter.string(from: date!)
                        self.followUpDate = dateFormatter.date(from: strDate)
                    }
                    else{
                        dateFormatter.dateFormat = "MM/dd/yyyy"
                        self.followUpDate = dateFormatter.date(from: followUpDateVal)
                        
                    }
                    
                    
                }
                
                
                
                
                self.NotesTextArea.text = self.assignmentLocUnitInfoObj.notes
            }
            else{
                
                //If New Unit Create then that case there is no assignmentLocationUnit that time
                //
                
//
//                self.assignmentLocUnitInfoObj.contactName = self.viewModel.getContactName(contactId: self.canvasserTaskDataObject.contactObj.contactId)
//
//                self.assignmentLocUnitInfoObj.contactId = self.canvasserTaskDataObject.contactObj.contactId
//
//                self.disableNextBtn()
                
            }
            
            
            
            self.tblAssignmentLocationUnit.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        isContactOutcomeSelect = false
        isFollowUpTypeSelect = false
        isSelectContactSelect = false
        
        self.navigationController?.isNavigationBarHidden = true;
    }
    
    
    
    
    func enableNextBtn(){
        
        btnNext.isEnabled = true
        btnNext.alpha = 1
        
    }
    
    func disableNextBtn(){
        
        btnNext.isEnabled = false
        btnNext.alpha = 0.5
        
    }
    
    func checkEnableNextButton(){
        
        if(self.assignmentLocUnitInfoObj.attempted == boolVal.yes.rawValue && self.assignmentLocUnitInfoObj.contacted == boolVal.yes.rawValue  && self.assignmentLocUnitInfoObj.surveyed == boolVal.yes.rawValue){
            
            self.enableNextBtn()
        }
    }
    
    
    func attemptChanged(_ sender: UISwitch) {
        if(sender.isOn){
            assignmentLocUnitInfoObj.attempted = boolVal.yes.rawValue
            
            checkEnableNextButton()
            
        }
        else{
            assignmentLocUnitInfoObj.attempted = boolVal.no.rawValue
            
            disableNextBtn()
        }
    }
    
    
    func surveyedChanged(_ sender: UISwitch) {
        
        if(sender.isOn)
        {
            assignmentLocUnitInfoObj.surveyed = boolVal.yes.rawValue
            
            checkEnableNextButton()
            
            
        }
        else
        {
            assignmentLocUnitInfoObj.surveyed = boolVal.no.rawValue
            
            
            disableNextBtn()
        }
        
    }
    
    func contactChanged(_ sender: UISwitch) {
        
        if(sender.isOn){
            
            assignmentLocUnitInfoObj.contacted = boolVal.yes.rawValue
            
            if(self.assignmentLocUnitInfoObj.contactOutcomeYes.isEmpty){
                self.assignmentLocUnitInfoObj.contactOutcomeYes = "Select Outcome"
            }
            contactOutcomeCell.detailTextLabel?.text = self.assignmentLocUnitInfoObj.contactOutcomeYes
            
            checkEnableNextButton()
            
        }
        else{
            assignmentLocUnitInfoObj.contacted = boolVal.no.rawValue
            
            if(self.assignmentLocUnitInfoObj.contactOutcomeNo.isEmpty){
                self.assignmentLocUnitInfoObj.contactOutcomeNo = "Select Outcome"
            }
            
            contactOutcomeCell.detailTextLabel?.text = self.assignmentLocUnitInfoObj.contactOutcomeNo
            
            disableNextBtn()
        }
        
    }
    
    
    
    @IBAction func btnSurveyAction(_ sender: Any)
    {
        if(delegate != nil){
            delegate?.goToSurvey()
        }
    }
    
    
    
}


extension AssignmentLocationUnitInformationViewController
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        
        return 7
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        
        
        if(indexPath.section == unitAttemptScreen.attempt.rawValue){
            let cell = tableView.dequeueReusableCell(withIdentifier: "attemptCell", for: indexPath)
            
            cell.backgroundColor = UIColor.clear
            
            
            cell.textLabel?.text = "Attempted?"
            cell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            cell.selectionStyle = .none
            
            //accessory switch
            let attemptSwitch = UISwitch(frame: CGRect.zero)
            
            if assignmentLocUnitInfoObj != nil {
                if(assignmentLocUnitInfoObj.attempted == boolVal.yes.rawValue){
                    attemptSwitch.isOn = true
                }
                else if (assignmentLocUnitInfoObj.attempted == boolVal.no.rawValue){
                    attemptSwitch.isOn = false
                }
                else{
                    attemptSwitch.isOn = false
                }
            }
            
            attemptSwitch.addTarget(self, action: #selector(AssignmentLocationUnitInformationViewController.attemptChanged(_:)), for: UIControlEvents.valueChanged)
            
            cell.accessoryView = attemptSwitch
            return cell
        }
            
        else if(indexPath.section == unitAttemptScreen.contacted.rawValue){
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
            
            cell.backgroundColor = UIColor.clear
            
            
            cell.textLabel?.text = "Contacted?"
            cell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            cell.selectionStyle = .none
            
            //accessory switch
            let contactSwitch = UISwitch(frame: CGRect.zero)
            
            if assignmentLocUnitInfoObj != nil {
                if(assignmentLocUnitInfoObj.contacted == boolVal.yes.rawValue){
                    contactSwitch.isOn = true
                }
                else if (assignmentLocUnitInfoObj.contacted == boolVal.no.rawValue){
                    contactSwitch.isOn = false
                }
                else{
                    contactSwitch.isOn = false
                }
            }
            
            contactSwitch.addTarget(self, action: #selector(AssignmentLocationUnitInformationViewController.contactChanged(_:)), for: UIControlEvents.valueChanged)
            
            cell.accessoryView = contactSwitch
            return cell
            
        }
        else if(indexPath.section == unitAttemptScreen.contactOutcome.rawValue){
            contactOutcomeCell = tableView.dequeueReusableCell(withIdentifier: "contactOutcomeCell", for: indexPath)
            
            contactOutcomeCell.accessoryType = .disclosureIndicator
            
            contactOutcomeCell.backgroundColor = UIColor.clear
            
            
            contactOutcomeCell.textLabel?.text = "Contact Outcome"
            contactOutcomeCell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            
            
            
            if(self.assignmentLocUnitInfoObj.contactOutcomeNo.isEmpty && self.assignmentLocUnitInfoObj.contactOutcomeYes.isEmpty){
                contactOutcomeCell.detailTextLabel?.text = "Select Outcome"
            }
            else{
                if(assignmentLocUnitInfoObj.contacted == boolVal.no.rawValue){
                    if(self.assignmentLocUnitInfoObj.contactOutcomeNo.isEmpty){
                        contactOutcomeCell.detailTextLabel?.text = "Select Outcome"
                    }
                    else{
                        contactOutcomeCell.detailTextLabel?.text = self.assignmentLocUnitInfoObj.contactOutcomeNo
                    }
                }
                else{
                    if(self.assignmentLocUnitInfoObj.contactOutcomeYes.isEmpty){
                        contactOutcomeCell.detailTextLabel?.text = "Select Outcome"
                    }
                    else{
                        contactOutcomeCell.detailTextLabel?.text = self.assignmentLocUnitInfoObj.contactOutcomeYes
                    }
                }
            }
            
            contactOutcomeCell.detailTextLabel?.textColor = UIColor.lightGray
            
            
            return contactOutcomeCell
        }
        else if(indexPath.section == unitAttemptScreen.surveyed.rawValue){
            let cell = tableView.dequeueReusableCell(withIdentifier: "surveyedCell", for: indexPath)
            
            cell.backgroundColor = UIColor.clear
            
            
            cell.textLabel?.text = "Conduct Survey?"
            cell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            cell.selectionStyle = .none
            
            //accessory switch
            let surveyedSwitch = UISwitch(frame: CGRect.zero)
            
            if assignmentLocUnitInfoObj != nil {
                if(assignmentLocUnitInfoObj.surveyed == boolVal.yes.rawValue){
                    surveyedSwitch.isOn = true
                }
                else if (assignmentLocUnitInfoObj.surveyed == boolVal.no.rawValue){
                    surveyedSwitch.isOn = false
                }
                else{
                    surveyedSwitch.isOn = false
                }
            }
            
            
            surveyedSwitch.addTarget(self, action: #selector(AssignmentLocationUnitInformationViewController.surveyedChanged(_:)), for: UIControlEvents.valueChanged)
            
            cell.accessoryView = surveyedSwitch
            return cell
            
        }
            
        else if(indexPath.section == unitAttemptScreen.contactPicklist.rawValue){
            
            selectContactCell = tableView.dequeueReusableCell(withIdentifier: "selectContactCell", for: indexPath)
            
            
            selectContactCell.accessoryType = .none
            selectContactCell.selectionStyle = .none
            
            
            if(assignmentLocUnitInfoObj.isUnitListing){
                selectContactCell.accessoryType = .disclosureIndicator
                selectContactCell.selectionStyle = .default
            }
            else{
                selectContactCell.accessoryType = .none
                selectContactCell.selectionStyle = .none
                
            }
            
          
            
            selectContactCell.backgroundColor = UIColor.clear
            
            
            selectContactCell.textLabel?.text = "Select Contact"
            selectContactCell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            
            if assignmentLocUnitInfoObj != nil {
                if(assignmentLocUnitInfoObj.contactName.isEmpty){
                    selectContactCell.detailTextLabel?.text = "Select Contact"
                }
                else{
                    selectContactCell.detailTextLabel?.text = assignmentLocUnitInfoObj.contactName
                }
            }
            
            selectContactCell.detailTextLabel?.textColor = UIColor.lightGray
            
            
            return selectContactCell
            
        }
        else if(indexPath.section == unitAttemptScreen.followUpDate.rawValue){
            
            followUpDateCell = tableView.dequeueReusableCell(withIdentifier: "followUpDateCell", for: indexPath) as! DateTableViewCell
            
            tblAssignmentLocationUnit.scrollToRow(at: indexPath, at: .top, animated: true)
            
            followUpDateCell.selectionStyle = .none
            
            
            if let val = self.followUpDate
            {
                
                followUpDateCell.datePicker.date = val
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                assignmentLocUnitInfoObj.followUpDate = dateFormatter.string(from: val)
                followUpDateCell.detail.text =  assignmentLocUnitInfoObj.followUpDate
                
            }
                
            else
            {
                
                followUpDateCell.datePicker.date = Date()
                followUpDateCell.detail.text = "Select Date"
                
            }
            
            
            followUpDateCell.accessoryType = .disclosureIndicator
            followUpDateCell.detail.textColor = UIColor.lightGray
            
            followUpDateCell.delegate = self
            
            return followUpDateCell
        }
        else{
            
            followUpTypeCell = tableView.dequeueReusableCell(withIdentifier: "followUpTypeCell", for: indexPath)
            
            followUpTypeCell.accessoryType = .disclosureIndicator
            
            followUpTypeCell.backgroundColor = UIColor.clear
            
            
            followUpTypeCell.textLabel?.text = "Select Follow-up"
            followUpTypeCell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            
            if assignmentLocUnitInfoObj != nil {
                if(assignmentLocUnitInfoObj.followUpType.isEmpty){
                    followUpTypeCell.detailTextLabel?.text = "Select Follow-up"
                }
                else{
                    followUpTypeCell.detailTextLabel?.text = assignmentLocUnitInfoObj.followUpType
                }
            }
            
            
            
            followUpTypeCell.detailTextLabel?.textColor = UIColor.lightGray
            
            
            return followUpTypeCell
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        NotesTextArea.resignFirstResponder()
        
        if indexPath.section == unitAttemptScreen.contactOutcome.rawValue{
            
            
            let dynamicPicklistVC = DynamicPicklistStoryboard().instantiateViewController(withIdentifier: "DynamicPicklistViewController") as? DynamicPicklistViewController
            
            let dynamicPicklistObj = DynamicPicklistDO()
            
            if(assignmentLocUnitInfoObj.contacted == boolVal.yes.rawValue){
                dynamicPicklistObj.selectedDynamicPickListValue = self.assignmentLocUnitInfoObj.contactOutcomeYes
                dynamicPicklistObj.dynamicPickListArray = self.reasonPicklist
            }
            else{
                dynamicPicklistObj.selectedDynamicPickListValue = self.assignmentLocUnitInfoObj.contactOutcomeNo
                dynamicPicklistObj.dynamicPickListArray = self.contactOutcomePicklist
            }
            
            
            dynamicPicklistObj.dynamicPicklistName = "Contact Outcome"
            
            dynamicPicklistVC?.dynamicPicklistObj = dynamicPicklistObj
            dynamicPicklistVC?.delegate = self
            
            isContactOutcomeSelect = true
            
            self.navigationController?.pushViewController(dynamicPicklistVC!, animated: true)
            
            
        }
        
        if indexPath.section == unitAttemptScreen.contactPicklist.rawValue
        {
            if(assignmentLocUnitInfoObj.isUnitListing){
            
                let dynamicPicklistVC = DynamicPicklistStoryboard().instantiateViewController(withIdentifier: "DynamicPicklistViewController") as? DynamicPicklistViewController
                
                let dynamicPicklistObj = DynamicPicklistDO()
                dynamicPicklistObj.selectedDynamicPickListValue = assignmentLocUnitInfoObj.contactName
                dynamicPicklistObj.dynamicPickListArray = self.ContactsPicklist
                dynamicPicklistObj.canvasserTaskDataObject = self.canvasserTaskDataObject
                dynamicPicklistObj.isAddClient = true
                
                dynamicPicklistObj.dynamicPicklistName = "Contact"
                
                dynamicPicklistVC?.dynamicPicklistObj = dynamicPicklistObj
                dynamicPicklistVC?.delegate = self
                
                isSelectContactSelect = true
                
                self.navigationController?.pushViewController(dynamicPicklistVC!, animated: true)
            }
            
        }
        if indexPath.section == unitAttemptScreen.followUpDate.rawValue{
            
            
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
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
            
            
        }
        if indexPath.section == unitAttemptScreen.followUpType.rawValue{
            
            
            
            let dynamicPicklistVC = DynamicPicklistStoryboard().instantiateViewController(withIdentifier: "DynamicPicklistViewController") as? DynamicPicklistViewController
            
            let dynamicPicklistObj = DynamicPicklistDO()
            dynamicPicklistObj.selectedDynamicPickListValue = assignmentLocUnitInfoObj.followUpType
            dynamicPicklistObj.dynamicPickListArray = self.followUpTypePicklist
            
            
            dynamicPicklistObj.dynamicPicklistName = "Follow-up Type"
            
            dynamicPicklistVC?.dynamicPicklistObj = dynamicPicklistObj
            dynamicPicklistVC?.delegate = self
            
            isFollowUpTypeSelect = true
            
            self.navigationController?.pushViewController(dynamicPicklistVC!, animated: true)
            
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if(indexPath.section == unitAttemptScreen.followUpDate.rawValue){
            (cell as! DateTableViewCell).watchFrameChanges()
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if(indexPath.section == unitAttemptScreen.followUpDate.rawValue){
            (cell as! DateTableViewCell).ignoreFrameChanges()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.section == unitAttemptScreen.followUpDate.rawValue){
            
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
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Dequeue with the reuse identifier
        
        return UIView()
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return  0.0
        
    }
}

extension AssignmentLocationUnitInformationViewController : DateTableViewCellDelegate{
    func selectDate(forDate date: Date){
        self.followUpDate = date
    }
}


extension AssignmentLocationUnitInformationViewController:DynamicPicklistDelegate{
    func getPickListValue(pickListValue: DropDownDO) {

        if(isContactOutcomeSelect){
            if(assignmentLocUnitInfoObj.contacted == boolVal.no.rawValue){
                self.assignmentLocUnitInfoObj.contactOutcomeNo = pickListValue.name
            }
            else{
                self.assignmentLocUnitInfoObj.contactOutcomeYes = pickListValue.name
            }
        }
        
        if(isFollowUpTypeSelect){
            
            assignmentLocUnitInfoObj.followUpType = pickListValue.name
            
        }
        
        if(isSelectContactSelect){
             assignmentLocUnitInfoObj.contactName = pickListValue.name
             assignmentLocUnitInfoObj.contactId = pickListValue.id
            
            self.updateContactList()
        }
//
//        isContactOutcomeSelect = false
//        isFollowUpTypeSelect = false
//        isSelectContactSelect = false
//
        self.tblAssignmentLocationUnit.reloadData()
    }
}


