//
//  VirtualUnitClientViewController.swift
//  Knock
//
//  Created by Kamal on 26/09/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class VirtualUnitClientViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,PickListProtocol
 {

    @IBOutlet weak var fullAddressTxt: UILabel!
    @IBOutlet weak var tblVirtualUnitClient: UITableView!
    @IBOutlet weak var notesTxtArea: UITextView!
    
    var attempt:String = "No"
    var contact:String = "No"
    
    var contactOutcome:String = ""
    
    var notes:String = ""
    
   
    var contactOutcomeCell:UITableViewCell!
    var isContactOutcomeSelect:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fullAddressTxt.text = "Unit: " + SalesforceConnection.unitName + "  |  " + SalesforceConnection.fullAddress
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        
        
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        //self.navigationItem.title = SalesforceConnection.unitName
        
        notesTxtArea.layer.cornerRadius = 5
        notesTxtArea.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        notesTxtArea.layer.borderWidth = 0.5
        notesTxtArea.clipsToBounds = true
        
        //NotesTextArea.text = "Description"
        notesTxtArea.textColor = UIColor.black
        
        
        populateVirtualUnitClient()
        
        

        
        // Do any additional setup after loading the view.
    }
    
    func populateVirtualUnitClient(){
        let virtualUnitClientResults = ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "assignmentId == %@ AND locationId == %@ AND id == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId,predicateValue3:SalesforceConnection.selectedTenantForSurvey, isPredicate:true) as! [Tenant]
        
        
        if(virtualUnitClientResults.count > 0){
            
            if(virtualUnitClientResults[0].attempt == ""){
                virtualUnitClientResults[0].attempt = "No"
            }
            
            attempt = virtualUnitClientResults[0].attempt!
            
            
            
            if(virtualUnitClientResults[0].contact == ""){
                virtualUnitClientResults[0].contact = "No"
            }
            
            
            contact = virtualUnitClientResults[0].contact!
            
            
           
            
            
            if(virtualUnitClientResults[0].contactOutcome! != ""){
                
                contactOutcome = virtualUnitClientResults[0].contactOutcome!
                
            }
            
            notesTxtArea.text = virtualUnitClientResults[0].notes!
            
            
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        isContactOutcomeSelect = false
        
        populateContactOutcome()
        
    }
    
    func attemptChanged(_ sender: UISwitch) {
        if(sender.isOn){
            attempt = "Yes"
        }
        else{
            attempt = "No"
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
    
    func getPickListValue(pickListValue:String){
        
     
        if(isContactOutcomeSelect){
            contactOutcome = pickListValue
        }
       
        tblVirtualUnitClient.reloadData()
    }
    
    
    // MARK: UITenantTableView and UIEditTableView
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        
        return 3
        
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
        else {
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
        
    }
    
    var contactOutcomeStr:String = ""
   
    
    func populateContactOutcome(){
        
        let contactOutcomeData =  ManageCoreData.fetchData(salesforceEntityName: "DropDown", predicateFormat:"object == %@ AND fieldName == %@",predicateValue:  "Assignment_Location_Unit__c",predicateValue2:  "Contact_Outcome__c", isPredicate:true) as! [DropDown]
        
        
        if(contactOutcomeData.count>0){
            
            contactOutcomeStr =  contactOutcomeData[0].value!
            //String(contactOutcomeData[0].value!.characters.dropLast())
            
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

    
    


    @IBAction func cancel(_ sender: Any) {
        
        let alertCtrl = Alert.showUIAlert(title: "Message", message: "Are you sure you want to cancel without saving?", vc: self)
        
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel) { action -> Void in
        }
        alertCtrl.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            
            
            // NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
            
            self.dismiss(animated: true, completion: nil)
        }
        alertCtrl.addAction(okAction)
        

        
    }
    
    @IBAction func save(_ sender: Any) {
        
        updateVirtualUnitClient()
        
        self.view.makeToast("Client has been updated successfully. ", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
       
    }
    
    func updateVirtualUnitClient(){
        
        
        if let notesTemp = notesTxtArea.text{
            notes = notesTemp
        }
        
        if(contact == "Yes"){
            contactOutcome = ""
        }
        
        updateVirtualUnitClientInDatabase()


        
    }
    
    
    
    
    
    
    
    
    func updateVirtualUnitClientInDatabase(){
        
        var updateObjectDic:[String:String] = [:]
       
        
        
        updateObjectDic["contact"] = contact
        updateObjectDic["contactOutcome"] = contactOutcome
        updateObjectDic["notes"] = notes
        updateObjectDic["attempt"] = attempt
        updateObjectDic["actionStatus"] = "edit"
        
        
          ManageCoreData.updateRecord(salesforceEntityName: "Tenant", updateKeyValue: updateObjectDic, predicateFormat: "id == %@ AND assignmentId == %@ AND locationId == %@ AND unitId == %@", predicateValue: SalesforceConnection.selectedTenantForSurvey,predicateValue2: SalesforceConnection.assignmentId, predicateValue3: SalesforceConnection.locationId,predicateValue4: SalesforceConnection.unitId,isPredicate: true)
        
        
//        ManageCoreData.updateRecord(salesforceEntityName: "Tenant", updateKeyValue: updateObjectDic, predicateFormat: "assignmentId == %@ AND locationId == %@ AND id == %@ AND unitId == %@ AND assignmentLocUnitId ==%@", predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.selectedTenantForSurvey, predicateValue4: SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate: true)
//        
        
        
    }
    
    
    
    

}
