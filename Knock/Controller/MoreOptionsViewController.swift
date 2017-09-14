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



class MoreOptionsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,PickListProtocol
{
    
    typealias typeCompletionHandler = () -> ()
    var completion : typeCompletionHandler = {}
    
    
    var completionHandler : ((_ childVC:MoreOptionsViewController) -> Void)?
    
    var attempt:String = ""
    var contact:String = ""
    var reknockNeeded:String = ""
    var inTake:String = ""
    
    var reasonStatus:String = ""
    var contactOutcome:String = ""
    
    var notes:String = ""
    
    var selectedTenantId:String = ""
    
    let pickerView = UIPickerView()
    
    var reasonCell:UITableViewCell!
    var contactOutcomeCell:UITableViewCell!
    
    @IBOutlet weak var saveOutlet: UIBarButtonItem!
    @IBOutlet weak var addTenantOutlet: UIButton!
    
    @IBOutlet weak var notesTextArea: UITextView!
    
    @IBOutlet weak var tblEditUnit: UITableView!
    
    
    @IBOutlet weak var chooseUnitInfoView: UIView!
    
    @IBOutlet weak var fullAddressText: UILabel!
    
    //var selectedSurveyId:String = ""
    
    
    
    var editUnitDict : [String:String] = [:]
    
    
    var isReasonSelect:Bool = false
    var isContactOutcomeSelect:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
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
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isReasonSelect = false
        isContactOutcomeSelect = false
        
        populateReason()
        populateContactOutcome()
        
    }
    
    
    //    func getReasonStatus(strReasonStatus:String){
    //
    //        if(isReasonSelect){
    //            reasonStatus = strReasonStatus
    //        }
    //        tblEditUnit?.reloadData()
    //
    //    }
    
    
    
    func attemptChanged(_ sender: UISwitch) {
        if(sender.isOn){
            attempt = "Yes"
        }
        else{
            attempt = "No"
        }
    }
    
    
    func inTakeChanged(_ sender: UISwitch) {
        
        if(sender.isOn)
        {
            inTake = "Yes"
            reasonCell.detailTextLabel?.isEnabled = false
            reasonCell.detailTextLabel?.text = "Select Reason"
            
            
        }
        else
        {
            inTake = "No"
            reasonCell.detailTextLabel?.isEnabled = true
            reasonCell.detailTextLabel?.text = reasonStatus
            
        }
        
    }
    
    func contactChanged(_ sender: UISwitch) {
        
        if(sender.isOn){
            contact = "Yes"
            contactOutcomeCell.detailTextLabel?.isEnabled = false
            contactOutcomeCell.detailTextLabel?.text = "Select Outcome"
        }
        else{
            contact = "No"
            contactOutcomeCell.detailTextLabel?.isEnabled = true
            contactOutcomeCell.detailTextLabel?.text = contactOutcome
        }
        
    }
    
    func reKnockChanged(_ sender: UISwitch) {
        
        if(sender.isOn){
            reknockNeeded = "Yes"
        }
        else{
            reknockNeeded = "No"
        }
    }
    
    
    func getPickListValue(pickListValue:String){
        
        if(isReasonSelect){
            reasonStatus = pickListValue
        }
        
        if(isContactOutcomeSelect){
            contactOutcome = pickListValue
        }
        
        //        isReasonSelect = false
        //        isContactOutcomeSelect = false
        //
        tblEditUnit.reloadData()
    }
    
    
    
    
    
    
    var tempInTake:String = ""
    var tempAttempt:String = ""
    var tempContact:String = ""
    var tempReason:String = ""
    var tempReKnock:String = ""
    
    
    func getIntakeContactAttempt(){
        
        let editUnitResults = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId ==%@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId, predicateValue4: SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate:true) as! [EditUnit]
        
        
        if(editUnitResults.count > 0){
            
            tempInTake = editUnitResults[0].inTake!
            tempAttempt = editUnitResults[0].attempt!
            tempContact = editUnitResults[0].isContact!
            
            tempReason = editUnitResults[0].reason!
            tempReKnock = editUnitResults[0].reKnockNeeded!
        }
        
        
    }
    
    
    
    
    
    // MARK: UITenantTableView and UIEditTableView
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        
        return 5
        
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
        
        
        
        if(indexPath.section == 0){
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
        else if(indexPath.section == 1){
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
        else if(indexPath.section == 2){
            contactOutcomeCell = tableView.dequeueReusableCell(withIdentifier: "contactOutcomeCell", for: indexPath)
            
            contactOutcomeCell.accessoryType = .disclosureIndicator
            
            contactOutcomeCell.backgroundColor = UIColor.clear
            
            
            contactOutcomeCell.textLabel?.text = "If No Contact, Outcome?"
            contactOutcomeCell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            if(contactOutcome.isEmpty){
                contactOutcomeCell.detailTextLabel?.text = "Select Outcome"
            }
            else{
                contactOutcomeCell.detailTextLabel?.text = contactOutcome
            }
            
            contactOutcomeCell.detailTextLabel?.textColor = UIColor.lightGray
            
            
            return contactOutcomeCell
        }
        else if(indexPath.section == 3){
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
        else if(indexPath.section == 4){
            reasonCell = tableView.dequeueReusableCell(withIdentifier: "reasonCell", for: indexPath)
            
            reasonCell.accessoryType = .disclosureIndicator
            
            reasonCell.backgroundColor = UIColor.clear
            
            
            reasonCell.textLabel?.text = "If No Survey, Reason?"
            reasonCell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            if(reasonStatus.isEmpty){
                reasonCell.detailTextLabel?.text = "Select Reason"
            }
            else{
                reasonCell.detailTextLabel?.text = reasonStatus
            }
            
            reasonCell.detailTextLabel?.textColor = UIColor.lightGray
            
            
            return reasonCell
            
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reKnockCell", for: indexPath)
            
            cell.backgroundColor = UIColor.clear
            
            
            cell.textLabel?.text = "Reknock Required?"
            cell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            
            cell.selectionStyle = .none
            
            //accessory switch
            let reKnockSwitch = UISwitch(frame: CGRect.zero)
            
            if(reknockNeeded == "Yes"){
                reKnockSwitch.isOn = true
            }
            else if (reknockNeeded == "No"){
                reKnockSwitch.isOn = false
                // attemptRdb.isOn = false
            }
            else{
                reKnockSwitch.isOn = false
            }
            
            
            
            reKnockSwitch.addTarget(self, action: #selector(MoreOptionsViewController.reKnockChanged(_:)), for: UIControlEvents.valueChanged)
            
            cell.accessoryView = reKnockSwitch
            return cell
            
        }
        
        
        
    }
    
    var contactOutcomeStr:String = ""
    var reasonStr:String = ""
    
    func populateContactOutcome(){
        
        let contactOutcomeData =  ManageCoreData.fetchData(salesforceEntityName: "DropDown", predicateFormat:"object == %@ AND fieldName == %@",predicateValue:  "Assignment_Location_Unit__c",predicateValue2:  "Contact_Outcome__c", isPredicate:true) as! [DropDown]
        
        
        if(contactOutcomeData.count>0){
            
            contactOutcomeStr =  String(contactOutcomeData[0].value!.characters.dropLast())
            
        }
        
    }
    
    func populateReason(){
        
        let reasonData =  ManageCoreData.fetchData(salesforceEntityName: "DropDown", predicateFormat:"object == %@ AND fieldName == %@",predicateValue:  "Assignment_Location_Unit__c",predicateValue2:  "reason__c", isPredicate:true) as! [DropDown]
        
        
        if(reasonData.count>0){
            
            reasonStr =  String(reasonData[0].value!.characters.dropLast())
            
        }
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        if indexPath.section == 2{
            
            if(contact == "No"){
                
                
                let pickListVC = self.storyboard!.instantiateViewController(withIdentifier: "picklistIdentifier") as? PickListViewController
                
                pickListVC?.picklistStr = contactOutcomeStr
                
                pickListVC?.pickListProtocol = self
                pickListVC?.selectedPickListValue = contactOutcome
                
                
                isContactOutcomeSelect = true
                
                self.navigationController?.pushViewController(pickListVC!, animated: true)
                
                
                //                    let reasonStatusVC = self.storyboard!.instantiateViewController(withIdentifier: "reasonStatusIdentifier") as? SelectReasonStatusViewController
                //
                //                    reasonStatusVC?.reasonStatusProtocol = self
                //
                //                    reasonStatusVC?.selectedReasonStatus = reasonStatus
                //
                //                    self.navigationController?.pushViewController(reasonStatusVC!, animated: true)
                
                
                
                
            }
            
        }
        
        if indexPath.section == 4{
            
            if(inTake == "No"){
                
                
                let pickListVC = self.storyboard!.instantiateViewController(withIdentifier: "picklistIdentifier") as? PickListViewController
                
                pickListVC?.picklistStr = reasonStr
                
                pickListVC?.pickListProtocol = self
                pickListVC?.selectedPickListValue = reasonStatus
                
                isReasonSelect = true
                
                self.navigationController?.pushViewController(pickListVC!, animated: true)
                
                
                
            }
            
        }
        
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Dequeue with the reuse identifier
        
        return UIView()
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return  0.0
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    
    
    
    func populateEditUnit(){
        let editUnitResults = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId,predicateValue4:SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate:true) as! [EditUnit]
        
        if(editUnitResults.count > 0){
            
            if(editUnitResults[0].attempt == ""){
                editUnitResults[0].attempt = "No"
            }
            
            attempt = editUnitResults[0].attempt!
            
            
            
            if(editUnitResults[0].isContact == ""){
                editUnitResults[0].isContact = "No"
            }
            
            
            contact = editUnitResults[0].isContact!
            
            
            
            
            if(editUnitResults[0].reKnockNeeded == ""){
                editUnitResults[0].reKnockNeeded = "No"
            }
            
            
            reknockNeeded = editUnitResults[0].reKnockNeeded!
            
            
            
            
            if(editUnitResults[0].inTake == ""){
                editUnitResults[0].inTake = "No"
            }
            
            inTake = editUnitResults[0].inTake!
            
            
            
            if(editUnitResults[0].reason! != ""){
                
                reasonStatus = editUnitResults[0].reason!
                
            }
            
            if(editUnitResults[0].contactOutcome! != ""){
                
                contactOutcome = editUnitResults[0].contactOutcome!
                
            }
            
            notesTextArea.text = editUnitResults[0].unitNotes
            
            
        }
    }
    
    
    
    @IBAction func cancel(_ sender: Any)
    {
        let alertCtrl = Alert.showUIAlert(title: "Message", message: "Are you sure you want to cancel without saving?", vc: self)
        
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel) { action -> Void in
            //Do some stuff
        }
        alertCtrl.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            
            
           // NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
            
            self.dismiss(animated: true, completion: nil)
            //Do some other stuff
        }
        alertCtrl.addAction(okAction)
        
        
    }
    
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
        
        
        if((attempt == "Yes" && contact == "Yes"  && (inTake == "No" && reknockNeeded == "Yes")) || (attempt == "Yes" && contact == "Yes"  && inTake == "Yes")){
            
            updateUnit()
            
            self.dismiss(animated: true) {
                
                self.getDefaultSurvey()
                
                self.completionHandler?(self)
                
                print("Completion");
                
            }
            
        }
            
        else{
            
            
            chooseUnitInfoView.shake()
            updateUnit()
            
            self.view.makeToast("You can only proceed to next step if Attempt , Contact and Reknock selected. ", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
                
                self.dismiss(animated: true, completion: nil)
                
            }
        }
        
        
        
        
        
        
    }
    
    
    
    
    func updateUnit(){
        
        
        if let notesTemp = notesTextArea.text{
            notes = notesTemp
        }
        
        
        
        
        let editUnitResults = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId,predicateValue4:SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate:true) as! [EditUnit]
        
        if(inTake == "Yes"){
            reasonStatus = ""
        }
        if(contact == "Yes"){
            contactOutcome = ""
        }
        
        if(editUnitResults.count > 0){
            
            updateEditUnitInDatabase()
        }
        else{
            saveEditUnitInDatabase(currentAttempt: attempt, currentInTake: inTake, currentReknockNeeded: reknockNeeded, currentReason: reasonStatus, currentNotes: notes, currentIsContact: contact,currentContactOutcome:contactOutcome, currentTenantId: "", currentSurveyId: "")
            
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
        
        
        editUnitObject.tenantId = currentTenantId
        
        editUnitObject.surveyId = currentSurveyId
        
        editUnitObject.lastCanvassedBy = SalesforceConfig.currentUserContactId
        
        
        appDelegate.saveContext()
        
    }
    
    
    
    
    
    func updateEditUnitInDatabase(){
        
        var updateObjectDic:[String:String] = [:]
        
        //updateObjectDic["id"] = tenantDataDict["tenantId"] as! String?
        
        
        
        updateObjectDic["reason"] = reasonStatus
        updateObjectDic["inTake"] = inTake
        updateObjectDic["unitNotes"] = notes
        updateObjectDic["attempt"] = attempt
        updateObjectDic["isContact"] = contact
        updateObjectDic["contactOutcome"] = contactOutcome
        updateObjectDic["reKnockNeeded"] = reknockNeeded
        updateObjectDic["actionStatus"] = "edit"
        
        
        
        ManageCoreData.updateRecord(salesforceEntityName: "EditUnit", updateKeyValue: updateObjectDic, predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId ==%@", predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId, predicateValue4: SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate: true)
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    func dismissVCCompletion(completionHandler: @escaping typeCompletionHandler) {
        self.completion = completionHandler
    }
    
    
}
