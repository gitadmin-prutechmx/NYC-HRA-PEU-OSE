//
//  MoreOptionsViewController.swift
//  Knock
//
//  Created by Kamal on 19/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit
import DLRadioButton
import DropDown

struct SurveyDataStruct
{
    var surveyId : String = ""
    var surveyName : String = ""
    
}

struct TenantDataStruct
{
    var tenantId : String = ""
    var name:String = ""
    var firstName : String = ""
    var lastName : String = ""
    var email : String = ""
    var phone : String = ""
    var age : String = ""
    var dob:String = ""
    //var teantStatus:String = ""
    //var inTakeStaus:String = ""
    
}

protocol ReasonStatusProtocol {
    func getReasonStatus(strReasonStatus:String)
}


enum unitAttemptScreen:Int{
    case attempt = 0
    case contacted
    case contactOutcome
    case inTake
    case contactPicklist
    case followUpDate
    case followUpType
   
}


class MoreOptionsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,PickListProtocol
{
    
    typealias typeCompletionHandler = () -> ()
    var completion : typeCompletionHandler = {}
    
    
    var completionHandler : ((_ childVC:MoreOptionsViewController) -> Void)?
    
    var attempt:String = "No"
    var contact:String = "No"
    var inTake:String = "No"
    // var privateHome:String = "No"
    
    var reasonStatus:String = ""
    var contactOutcome:String = ""
    var selectContact:String = ""
    var followUpType:String = ""
    var followUpDate:Date?
    var followUpDateStr:String = ""
    
    var notes:String = ""
    
    var selectedTenantId:String = ""
    
    let pickerView = UIPickerView()
    
    var reasonCell:UITableViewCell!
    var contactOutcomeCell:UITableViewCell!
    var selectContactCell:UITableViewCell!
    var followUpTypeCell:UITableViewCell!
    var followUpDateCell:FollowUpDateTableViewCell!
    
    @IBOutlet weak var saveOutlet: UIBarButtonItem!
    @IBOutlet weak var addTenantOutlet: UIButton!
    
    @IBOutlet weak var notesTextArea: UITextView!
    
    @IBOutlet weak var tblEditUnit: UITableView!
    
    @IBOutlet weak var btnNext:UIButton!
    
    @IBOutlet weak var chooseUnitInfoView: UIView!
    
    @IBOutlet weak var fullAddressText: UILabel!
    
    //var selectedSurveyId:String = ""
    
    
    
    var editUnitDict : [String:String] = [:]
    
    
  
    var isContactOutcomeSelect:Bool = false
    var isFollowUpTypeSelect:Bool = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        print(self.preferredContentSize)
        btnNext.layer.cornerRadius = 5.0
        fullAddressText.text = "Unit: " + SalesforceConnection.unitName + "  |  " + SalesforceConnection.fullAddress
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        
        
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        //self.navigationItem.title = SalesforceConnection.unitName
        
        notesTextArea.layer.cornerRadius = 5
        notesTextArea.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        notesTextArea.layer.borderWidth = 0.5
        notesTextArea.clipsToBounds = true
        
        //NotesTextArea.text = "Description"
        notesTextArea.textColor = UIColor.black
        
        
        populateEditUnit()
        populateFollowUpType()
        
        // orientationChanged()
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Utilities.isSelectContactSelect = false
        isContactOutcomeSelect = false
        isFollowUpTypeSelect = false
        
        if(SalesforceConnection.selectedTenantForSurvey.isEmpty){
            populateSelectContact()
        }
        
       // populateReason()
      //  populateContactOutcome()
        
    }
    
    func orientationChanged() -> Void
    {
        
        if UIDevice.current.orientation.isLandscape
        {
            print("Landscape")
            self.view.superview?.center = self.view.center;
            self.preferredContentSize = CGSize(width: 700, height: 667)
            print(self.preferredContentSize)
        }
        else
        {
            print("Portrait")
            self.view.superview?.center = self.view.center;
            self.preferredContentSize = CGSize(width: 700, height: 667)
            print(self.preferredContentSize)
        }
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    //    func getReasonStatus(strReasonStatus:String){
    //
    //        if(isReasonSelect){
    //            reasonStatus = strReasonStatus
    //        }
    //        tblEditUnit?.reloadData()
    //
    //    }
    
    
    
    func enableNextBtn(){
        
        btnNext.isEnabled = true
        btnNext.alpha = 1
        
    }
    
    func disableNextBtn(){
        
        btnNext.isEnabled = false
        btnNext.alpha = 0.5
        
    }
    
    
    
    func attemptChanged(_ sender: UISwitch) {
        if(sender.isOn){
            attempt = "Yes"
            
            if(attempt == "Yes" && contact == "Yes"  && inTake == "Yes"){
                enableNextBtn()
            }
        }
        else{
            attempt = "No"
            
            disableNextBtn()
        }
    }
    
    
    
    func inTakeChanged(_ sender: UISwitch) {
        
        if(sender.isOn)
        {
            inTake = "Yes"
//            reasonCell.detailTextLabel?.isEnabled = false
//            reasonCell.detailTextLabel?.text = "Select Reason"
//            
            if(attempt == "Yes" && contact == "Yes"  && inTake == "Yes"){
                enableNextBtn()
            }
            
            
        }
        else
        {
            inTake = "No"
//            reasonCell.detailTextLabel?.isEnabled = true
//            
//            if(reasonCell.detailTextLabel?.text == "Select Reason"){
//                reasonStatus = "Select Reason"
//            }
//            
//            reasonCell.detailTextLabel?.text = reasonStatus
            
            disableNextBtn()
        }
        
    }
    
    func contactChanged(_ sender: UISwitch) {
        
        if(sender.isOn){
            contact = "Yes"
           // contactOutcomeCell.detailTextLabel?.isEnabled = false
            if(reasonStatus.isEmpty){
                reasonStatus = "Select Outcome"
            }
            contactOutcomeCell.detailTextLabel?.text = reasonStatus
           
            if(attempt == "Yes" && contact == "Yes"  && inTake == "Yes"){
                enableNextBtn()
            }
            
        }
        else{
            contact = "No"
            
            //contactOutcomeCell.detailTextLabel?.isEnabled = true
            
            if(contactOutcome.isEmpty){
                contactOutcome = "Select Outcome"
            }
            contactOutcomeCell.detailTextLabel?.text = contactOutcome
          
            disableNextBtn()
        }
        
    }
    
    
    
    var selectedClientId:String = ""
    
    func getPickListValue(pickListValue:String){
        
        if( Utilities.isSelectContactSelect){
            
            if(!pickListValue.isEmpty){
                selectContact = Utilities.getClientName(tenantId: pickListValue)
            }
            else{
                selectContact = pickListValue
            }
            
            selectedClientId = pickListValue
            
        }
        
        if(isContactOutcomeSelect){
            if(contact == "No"){
                contactOutcome = pickListValue
            }
            else{
                reasonStatus = pickListValue
            }
        }
        
        if(isFollowUpTypeSelect){
            
            followUpType = pickListValue
            
        }
        
        tblEditUnit.reloadData()
    }
    
    
    
    
    
    
    var tempInTake:String = ""
    var tempAttempt:String = ""
    var tempContact:String = ""
    var tempReason:String = ""
  
    func getIntakeContactAttempt(){
        
        let editUnitResults = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId ==%@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId, predicateValue4: SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate:true) as! [EditUnit]
        
        
        if(editUnitResults.count > 0){
            
            tempInTake = editUnitResults[0].inTake!
            tempAttempt = editUnitResults[0].attempt!
            tempContact = editUnitResults[0].isContact!
            
            tempReason = editUnitResults[0].reason!
           
        }
        
        
    }
    
    
    @IBAction func btnNextAction(_ sender: Any)
    {
        
        
        if(attempt == "Yes" && contact == "Yes"  && inTake == "Yes"){
            updateUnit()
            
            self.dismiss(animated: true) {
                
                if(!self.selectedClientId.isEmpty){
                    
                    SalesforceConnection.selectedTenantForSurvey = self.selectedClientId
                    SalesforceConnection.selectedTenantNameForSurvey = Utilities.getClientName(tenantId: self.selectedClientId)
                }
                
                
                
                if(!self.isSurveyTaken()){
                    self.getDefaultSurvey()
                }
                
                self.completionHandler?(self)
                
                print("Completion");
                
            }
            
        }
            
        else{
            
            btnNext.isEnabled = false
            btnNext.alpha = 0.5
            
            chooseUnitInfoView.shake()
            //updateUnit()
            
            self.view.makeToast("You can only proceed to next step if Attempt , Contact and Intake selected. ", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                self.btnNext.isEnabled = true
                self.btnNext.alpha = 1.0
                
                print("Completion without tap")
                
                //                if didTap {
                //                    print("Completion with tap")
                //
                //                } else {
                //                    print("Completion without tap")
                //                }
                
                //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
                
                //self.dismiss(animated: true, completion: nil)
                
            }
        }
        
        
        
        
    }
    
    
    
    // MARK: UITenantTableView and UIEditTableView
    
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
            
            if(attempt == "Yes"){
                attemptSwitch.isOn = true
            }
            else if (attempt == "No"){
                attemptSwitch.isOn = false
                // attemptRdb.isOn = false
            }
            else{
                attemptSwitch.isOn = false
            }
            
            
            
            attemptSwitch.addTarget(self, action: #selector(MoreOptionsViewController.attemptChanged(_:)), for: UIControlEvents.valueChanged)
            
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
            
            if(contact == "Yes"){
                contactSwitch.isOn = true
            }
            else if (contact == "No"){
                contactSwitch.isOn = false
                // attemptRdb.isOn = false
            }
            else{
                contactSwitch.isOn = false
            }
            
            
            
            contactSwitch.addTarget(self, action: #selector(MoreOptionsViewController.contactChanged(_:)), for: UIControlEvents.valueChanged)
            
            cell.accessoryView = contactSwitch
            return cell
            
        }
        else if(indexPath.section == unitAttemptScreen.contactOutcome.rawValue){
            contactOutcomeCell = tableView.dequeueReusableCell(withIdentifier: "contactOutcomeCell", for: indexPath)
            
            contactOutcomeCell.accessoryType = .disclosureIndicator
            
            contactOutcomeCell.backgroundColor = UIColor.clear
            
            
            contactOutcomeCell.textLabel?.text = "Contact Outcome"
            contactOutcomeCell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            
            if(contactOutcome.isEmpty && reasonStatus.isEmpty){
                contactOutcomeCell.detailTextLabel?.text = "Select Outcome"
            }
            else{
                if(contact == "No"){
                    if(contactOutcome.isEmpty){
                        contactOutcomeCell.detailTextLabel?.text = "Select Outcome"
                    }
                    else{
                        contactOutcomeCell.detailTextLabel?.text = contactOutcome
                    }
                }
                else{
                    if(reasonStatus.isEmpty){
                         contactOutcomeCell.detailTextLabel?.text = "Select Outcome"
                    }
                    else{
                        contactOutcomeCell.detailTextLabel?.text = reasonStatus
                    }
                }
            }
            
            contactOutcomeCell.detailTextLabel?.textColor = UIColor.lightGray
            
            
            return contactOutcomeCell
        }
        else if(indexPath.section == unitAttemptScreen.inTake.rawValue){
            let cell = tableView.dequeueReusableCell(withIdentifier: "inTakeCell", for: indexPath)
            
            cell.backgroundColor = UIColor.clear
            
            
            cell.textLabel?.text = "Conduct Survey?"
            cell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            cell.selectionStyle = .none
            
            //accessory switch
            let inTakeSwitch = UISwitch(frame: CGRect.zero)
            
            if(inTake == "Yes"){
                inTakeSwitch.isOn = true
            }
            else if (inTake == "No"){
                inTakeSwitch.isOn = false
                // attemptRdb.isOn = false
            }
            else{
                
                inTakeSwitch.isOn = false
            }
            
            
            
            inTakeSwitch.addTarget(self, action: #selector(MoreOptionsViewController.inTakeChanged(_:)), for: UIControlEvents.valueChanged)
            
            cell.accessoryView = inTakeSwitch
            return cell
            
        }
       
        else if(indexPath.section == unitAttemptScreen.contactPicklist.rawValue){
           
            selectContactCell = tableView.dequeueReusableCell(withIdentifier: "selectContactCell", for: indexPath)
            
            if(SalesforceConnection.selectedTenantForSurvey.isEmpty){
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
            
            if(selectContact.isEmpty){
                selectContactCell.detailTextLabel?.text = "Select Contact"
            }
            else{
                selectContactCell.detailTextLabel?.text = selectContact
            }
            
            selectContactCell.detailTextLabel?.textColor = UIColor.lightGray
            
            
            return selectContactCell

        }
        else if(indexPath.section == unitAttemptScreen.followUpDate.rawValue){
            
            followUpDateCell = tableView.dequeueReusableCell(withIdentifier: "followUpDateCell", for: indexPath) as! FollowUpDateTableViewCell
            
            tblEditUnit.scrollToRow(at: indexPath, at: .top, animated: true)
           
            followUpDateCell.selectionStyle = .none
        
          
            if let val = followUpDate
            {

                followUpDateCell.datePicker.date = val
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                followUpDateStr = dateFormatter.string(from: val)
                followUpDateCell.detail.text = followUpDateStr
                
            }
                
            else
            {
            
                followUpDateCell.datePicker.date = Date()
                followUpDateCell.detail.text = "Select Date"
               
            }
            
          
            followUpDateCell.accessoryType = .disclosureIndicator
            followUpDateCell.detail.textColor = UIColor.lightGray
           // followUpDateCell.detail.font = UIFont.init(name: "Arial", size: 16.0)
            
            followUpDateCell.delegate = self
            
            return followUpDateCell
        }
        else{
            
            followUpTypeCell = tableView.dequeueReusableCell(withIdentifier: "followUpTypeCell", for: indexPath)
          
            followUpTypeCell.accessoryType = .disclosureIndicator
            
            followUpTypeCell.backgroundColor = UIColor.clear
            
            
            followUpTypeCell.textLabel?.text = "Select Follow-up"
            followUpTypeCell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            
            if(followUpType.isEmpty){
                followUpTypeCell.detailTextLabel?.text = "Select Follow-up"
            }
            else{
                followUpTypeCell.detailTextLabel?.text = followUpType
            }
            
            followUpTypeCell.detailTextLabel?.textColor = UIColor.lightGray
            
            
            return followUpTypeCell
            
        }

        
        //followUpTypeCell
        
        
        
    }
    
    var contactOutcomeStr:String = ""
    var selectContactStr:String = ""
    var followUpTypeStr:String = ""
    
    func populateContactOutcome(contact:String){
        
        var contactOutcomeData = [DropDown]()
        
        if(contact == "No"){
            contactOutcomeData =  ManageCoreData.fetchData(salesforceEntityName: "DropDown", predicateFormat:"object == %@ AND fieldName == %@",predicateValue:  "Assignment_Location_Unit__c",predicateValue2:  "Contact_Outcome__c", isPredicate:true) as! [DropDown]
        }
        else{
            contactOutcomeData =  ManageCoreData.fetchData(salesforceEntityName: "DropDown", predicateFormat:"object == %@ AND fieldName == %@",predicateValue:  "Assignment_Location_Unit__c",predicateValue2:  "reason__c", isPredicate:true) as! [DropDown]

        }
        
        if(contactOutcomeData.count>0){
            
            contactOutcomeStr =  contactOutcomeData[0].value!
            //String(contactOutcomeData[0].value!.characters.dropLast())
            
        }
        
    }
    
    func populateFollowUpType(){
        
        
        let followUpTypeData =  ManageCoreData.fetchData(salesforceEntityName: "DropDown", predicateFormat:"object == %@ AND fieldName == %@",predicateValue:  "Assignment_Location_Unit__c",predicateValue2:  "Follow_Up_Type__c", isPredicate:true) as! [DropDown]
            
        
        
        if(followUpTypeData.count>0){
            
            followUpTypeStr =  followUpTypeData[0].value!
        }
        
    }
    
    func populateSelectContact(){
        
        selectContactStr = ""
        
        
        let clientResults = ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "unitId == %@ AND assignmentId == %@ AND locationId == %@" ,predicateValue: SalesforceConnection.unitId,predicateValue2: SalesforceConnection.assignmentId,predicateValue3: SalesforceConnection.locationId,isPredicate:true) as! [Tenant]
   
        
        if(clientResults.count > 0){
            
            for client in clientResults{
                selectContactStr += client.id! + ";"
            }
            
        }
        
      
        
        
    }
    
    
    var selectedIndexPath:IndexPath?

    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        if indexPath.section == unitAttemptScreen.contactOutcome.rawValue{
            
       
                populateContactOutcome(contact: contact)
                
          
                let pickListVC = self.storyboard!.instantiateViewController(withIdentifier: "picklistIdentifier") as? PickListViewController
                
                pickListVC?.picklistStr = contactOutcomeStr
            
                pickListVC?.showContactName = false
                
                pickListVC?.pickListProtocol = self
            
            if(contact == "Yes"){
                 pickListVC?.selectedPickListValue = reasonStatus
            }
            else{
                pickListVC?.selectedPickListValue = contactOutcome
            }
            
                
                
                isContactOutcomeSelect = true
                
                self.navigationController?.pushViewController(pickListVC!, animated: true)
            
        }
        
        if indexPath.section == unitAttemptScreen.contactPicklist.rawValue && SalesforceConnection.selectedTenantForSurvey.isEmpty{
            
           
                
                let pickListVC = self.storyboard!.instantiateViewController(withIdentifier: "picklistIdentifier") as? PickListViewController
                
                pickListVC?.picklistStr = selectContactStr
            
                pickListVC?.showContactName = true
                
                pickListVC?.pickListProtocol = self
                pickListVC?.selectedPickListValue = selectContact
                
                Utilities.isSelectContactSelect = true
                
                self.navigationController?.pushViewController(pickListVC!, animated: true)
                
            
            
        }
        if indexPath.section == unitAttemptScreen.followUpDate.rawValue{
    
            
        
               // Utilities.currentApiName = caseObject.apiName
                
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
        if indexPath.section == unitAttemptScreen.followUpType.rawValue{
            
            
            
            let pickListVC = self.storyboard!.instantiateViewController(withIdentifier: "picklistIdentifier") as? PickListViewController
            
            pickListVC?.picklistStr = followUpTypeStr
            
            pickListVC?.showContactName = false
            
            pickListVC?.pickListProtocol = self
            pickListVC?.selectedPickListValue = followUpType
            
            isFollowUpTypeSelect = true
            
            self.navigationController?.pushViewController(pickListVC!, animated: true)
            
            
            
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        
        
    }
    

    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if(indexPath.section == unitAttemptScreen.followUpDate.rawValue){
            (cell as! FollowUpDateTableViewCell).watchFrameChanges()
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if(indexPath.section == unitAttemptScreen.followUpDate.rawValue){
            (cell as! FollowUpDateTableViewCell).ignoreFrameChanges()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.section == unitAttemptScreen.followUpDate.rawValue){
        
      
         //return FollowUpDateTableViewCell.defaultHeight
        
            if indexPath == selectedIndexPath {
                return FollowUpDateTableViewCell.expandHeight
            } else {
                return FollowUpDateTableViewCell.defaultHeight
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
    
    
    
    
    func populateEditUnit(){
        let editUnitResults = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId,predicateValue4:SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate:true) as! [EditUnit]
        
        if(editUnitResults.count > 0){
            
            if(editUnitResults[0].attempt == "" || editUnitResults[0].attempt == "No"){
                attempt =  "No"
            }
                
            else{
                attempt = editUnitResults[0].attempt!
            }
            
            
            if(editUnitResults[0].isContact == "" || editUnitResults[0].isContact == "No"){
                contact = "No"
            }
            else{
                contact = editUnitResults[0].isContact!
            }
            
            
            
            
            if(editUnitResults[0].inTake == "" || editUnitResults[0].inTake == "No"){
                inTake = "No"
            }
            else{
                inTake = editUnitResults[0].inTake!
            }
            
            
            if(editUnitResults[0].contactOutcome! != ""){
                
                if(contact == "Yes"){
                    reasonStatus = editUnitResults[0].contactOutcome!
                }
                else{
                    contactOutcome = editUnitResults[0].contactOutcome!
                }
                
            }
            
           
            
            notesTextArea.text = editUnitResults[0].unitNotes
            
            
            if(attempt == "Yes" && contact == "Yes"  && inTake == "Yes"){
                enableNextBtn()
            }
            else{
                disableNextBtn()
            }
            
            selectedClientId = SalesforceConnection.selectedTenantForSurvey
            
            //if tap to unitlisting screen
            if(SalesforceConnection.selectedTenantForSurvey.isEmpty){
                if let tenantId = editUnitResults[0].tenantId{
                    selectContact = Utilities.getClientName(tenantId: tenantId)
                    selectedClientId = tenantId
                }
            }
            else{
                selectContact =  Utilities.getClientName(tenantId: SalesforceConnection.selectedTenantForSurvey)
            }
            
          
            
            if let followUpTypeVal = editUnitResults[0].followUpType{
                followUpType = followUpTypeVal
            }
            
            if let followUpDateVal = editUnitResults[0].followUpDate{
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = dateFormatter.date(from: followUpDateVal)
                
                if(date != nil){
                    
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    let strDate = dateFormatter.string(from: date!)
                    followUpDate = dateFormatter.date(from: strDate)
                }
                else{
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    followUpDate = dateFormatter.date(from: followUpDateVal)

                }
               
                
            }
            
        }
        else{
            
            disableNextBtn()

        }
        
         //tblEditUnit.reloadData()
        
    }
   
    
    
    @IBAction func cancel(_ sender: Any)
    {
        let alertCtrl = Alert.showUIAlert(title: "Message", message: "Are you sure you want to close without saving?", vc: self)
        
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel) { action -> Void in
        }
        alertCtrl.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            
            
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
            
            self.dismiss(animated: true, completion: nil)
        }
        alertCtrl.addAction(okAction)
        
        
    }
    
    //if survey already taken on unit
    func isSurveyTaken()->Bool{
        
        let surveyResResultsArr = ManageCoreData.fetchData(salesforceEntityName: "SurveyResponse",predicateFormat: "assignmentLocUnitId == %@" ,predicateValue: SalesforceConnection.assignmentLocationUnitId, isPredicate:true) as! [SurveyResponse]
        
        if(surveyResResultsArr.count > 0){
            
            let surveyQuestionResults = ManageCoreData.fetchData(salesforceEntityName: "SurveyQuestion",predicateFormat: "surveyId == %@" ,predicateValue: surveyResResultsArr[0].surveyId,isPredicate:true) as! [SurveyQuestion]
            
            if(surveyQuestionResults.count > 0){
                
                SalesforceConnection.surveyId = surveyQuestionResults[0].surveyId!
                
                SalesforceConnection.surveyName = surveyQuestionResults[0].surveyName!
                
                
                // return selectedSurveyId
                
            }
            else{
                SalesforceConnection.surveyId = ""
                
                SalesforceConnection.surveyName = ""
            }
            
            return true
        }
        else{
            return false
        }
        
    }
    
    
    
    //if no survey taken on unit
    func getDefaultSurvey(){
        
        
        let surveyQuestionResults = ManageCoreData.fetchData(salesforceEntityName: "SurveyQuestion",predicateFormat: "assignmentId == %@ && isDefault == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: "true",isPredicate:true) as! [SurveyQuestion]
        
        
        if(surveyQuestionResults.count > 0){
            
            SalesforceConnection.surveyId = surveyQuestionResults[0].surveyId!
            
            SalesforceConnection.surveyName = surveyQuestionResults[0].surveyName!
            
            
            // return selectedSurveyId
            
        }
        else{
            SalesforceConnection.surveyId = ""
            
            SalesforceConnection.surveyName = ""
        }
        
        // return ""
    }
    
    @IBAction func save(_ sender: Any) {
        
        
        updateUnit()
        
        self.view.makeToast("Unit has been updated successfully. ", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
        
    }
    
    
    
    
    func updateUnit(){
        
        
        if let notesTemp = notesTextArea.text{
            notes = notesTemp
        }
        
        
        
        
        let editUnitResults = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId,predicateValue4:SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate:true) as! [EditUnit]
        
       
        var conOutcomeVal = contactOutcomeCell.detailTextLabel?.text
        
        if(conOutcomeVal == "Select Outcome"){
            conOutcomeVal = ""
        }
        

        if(editUnitResults.count > 0){
            
            updateEditUnitInDatabase(strContactOutcome:conOutcomeVal!)
        }
        else{
            saveEditUnitInDatabase(currentAttempt: attempt, currentInTake: inTake, currentReknockNeeded: "No", currentReason: "", currentNotes: notes, currentIsContact: contact,currentContactOutcome:conOutcomeVal!,currentTenantId: "", currentSurveyId: "")
            
        }
        
    
    }
    
  
    func saveEditUnitInDatabase(currentAttempt:String,currentInTake:String,currentReknockNeeded:String,currentReason:String,currentNotes:String,currentIsContact:String,currentContactOutcome:String,currentTenantId:String,currentSurveyId:String){
        
        
        let editUnitObject = EditUnit(context: context)
        
        editUnitObject.locationId = SalesforceConnection.locationId
        editUnitObject.assignmentId = SalesforceConnection.assignmentId
        editUnitObject.assignmentLocId = SalesforceConnection.assignmentLocationId
        editUnitObject.unitId = SalesforceConnection.unitId
        editUnitObject.assignmentLocUnitId = SalesforceConnection.assignmentLocationUnitId
        editUnitObject.actionStatus = "create"
        
        
        editUnitObject.attempt = currentAttempt
        
        editUnitObject.reKnockNeeded = currentReknockNeeded
        
        editUnitObject.inTake = currentInTake
        editUnitObject.reason = currentReason
        
        editUnitObject.unitNotes = currentNotes
        editUnitObject.isContact = currentIsContact
        
        editUnitObject.contactOutcome = contactOutcome
        
        //editUnitObject.privateHome = privateHome
        
        
        editUnitObject.tenantId = selectedClientId
        
        editUnitObject.surveyId = currentSurveyId
        
        editUnitObject.lastCanvassedBy = SalesforceConfig.currentUserContactId
        
        editUnitObject.followUpType = followUpType
        
        editUnitObject.followUpDate = followUpDateStr
        
        
        
        appDelegate.saveContext()
        
    }
    
    
    
    
    
    func updateEditUnitInDatabase(strContactOutcome:String){
        
        var updateObjectDic:[String:String] = [:]
        
        //updateObjectDic["id"] = tenantDataDict["tenantId"] as! String?
        
        
        
        updateObjectDic["reason"] = ""
        updateObjectDic["inTake"] = inTake
        updateObjectDic["unitNotes"] = notes
        updateObjectDic["attempt"] = attempt
        updateObjectDic["isContact"] = contact
        updateObjectDic["contactOutcome"] = strContactOutcome
        updateObjectDic["reKnockNeeded"] = "No"
        //updateObjectDic["privateHome"] = privateHome
        updateObjectDic["actionStatus"] = "edit"
        
        updateObjectDic["tenantId"] = selectedClientId
        updateObjectDic["followUpType"] = followUpType
        updateObjectDic["followUpDate"] = followUpDateStr
        
        
        
        ManageCoreData.updateRecord(salesforceEntityName: "EditUnit", updateKeyValue: updateObjectDic, predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId ==%@", predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId, predicateValue4: SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate: true)
        
        
        
    }
    
    
    func dismissVCCompletion(completionHandler: @escaping typeCompletionHandler) {
        self.completion = completionHandler
    }
    
    
}

extension MoreOptionsViewController : FollowUpDateTableViewCellDelegate{
    
    func selectFollowUpDate(forDate date: Date){
        
        followUpDate = date
    }
}


