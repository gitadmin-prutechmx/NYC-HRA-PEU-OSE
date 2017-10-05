//
//  AddNewIssueViewController.swift
//  Knock
//
//  Created by Cloudzeg Laptop on 8/1/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class AddNewIssueViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,PickListProtocol
{
    
    @IBOutlet weak var tblAddIssueList: UITableView!
    @IBOutlet weak var txtIssueNotes: UITextView!
    
    var issueType:String = ""
    
    @IBOutlet weak var tblViewIssueNotes: UITableView!
    
    
    var issueNotesArray = [String]()
    
    @IBOutlet var issueView: UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        self.tblAddIssueList?.tableFooterView = UIView()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        txtIssueNotes.layer.cornerRadius = 5
        txtIssueNotes.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        txtIssueNotes.layer.borderWidth = 0.5
        txtIssueNotes.clipsToBounds = true
        
        
        txtIssueNotes.textColor = UIColor.black
        
        tblViewIssueNotes.tableFooterView = UIView()
        
        
        if(Utilities.issueActionStatus == "View"){
            self.navigationItem.rightBarButtonItem = nil
            txtIssueNotes.isEditable = false
        }
        
        
        
        if(SalesforceConnection.currentIssueId != ""){
            fillIssueInfo()
        }
        else{
            tblViewIssueNotes.isHidden = true
        }
        
        
        
    }
    
    func fillIssueInfo(){
        
        
        let issueResults = ManageCoreData.fetchData(salesforceEntityName: "Issues",predicateFormat: "issueId == %@" ,predicateValue: SalesforceConnection.currentIssueId,isPredicate:true) as! [Issues]
        
        if(issueResults.count > 0){
            
            //txtIssueNotes.text = issueResults[0].notes!
            issueType = issueResults[0].issueType!
        }
        
        populateIssueNotes()
        
        if(issueNotesArray.count == 0){
             tblViewIssueNotes.isHidden = true
        }
    }
    
    
    func populateIssueNotes(){
        
        let issueNotesResults = ManageCoreData.fetchData(salesforceEntityName: "IssueNotes",predicateFormat: "issueId == %@" ,predicateValue: SalesforceConnection.currentIssueId,isPredicate:true) as! [IssueNotes]
        
        if(issueNotesResults.count > 0){
            for issueNote in issueNotesResults{
                if let note = issueNote.notes{
                    issueNotesArray.append(note)
                }
                
            }
            
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        populateIssueTypes()
        
    }
    
    
    
    
    func getPickListValue(pickListValue:String){
        
        issueType = pickListValue
        
        tblAddIssueList.reloadData()
    }
    
    //Mark: tableview delegets
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == tblViewIssueNotes){
            return issueNotesArray.count
        }
        else{
            return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
      return 1
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if(tableView ==  tblViewIssueNotes){
            let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell")!
            cell.textLabel?.text = issueNotesArray[indexPath.row]
            cell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            
            cell.selectionStyle = .none
            
            return cell
        }
            
        else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddIssueCell")!
            cell.backgroundColor = UIColor.clear
            
            if(Utilities.issueActionStatus == "View"){
                cell.accessoryType = .none
            }
            else{
                cell.accessoryType = .disclosureIndicator
            }
            
            
            
            cell.textLabel?.text = "Issue"
            cell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            
            
            if(issueType.isEmpty){
                cell.detailTextLabel?.text = "Select Issue"
                cell.detailTextLabel?.font = UIFont.init(name: "Arial", size: 18.0)
                
            }
            else{
                cell.detailTextLabel?.text = issueType
                cell.detailTextLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            }
            
            cell.detailTextLabel?.textColor = UIColor.lightGray
            
            //let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 21))
            
            return cell
        }
        
        
    }
    
    var issueTypeStr:String = ""
    
    func populateIssueTypes(){
        
        let issueTypeData =  ManageCoreData.fetchData(salesforceEntityName: "DropDown", predicateFormat:"object == %@ AND fieldName == %@",predicateValue:  "Issue__c",predicateValue2:  "Issuetype__c", isPredicate:true) as! [DropDown]
        
        
        if(issueTypeData.count>0){
            
            issueTypeStr = issueTypeData[0].value!
            //String(issueTypeData[0].value!.characters.dropLast())
            //  statusArray = statusStr.components(separatedBy: ";")
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(tableView !=  tblViewIssueNotes){
            if(Utilities.issueActionStatus != "View"){
                
                let pickListVC = self.storyboard!.instantiateViewController(withIdentifier: "picklistIdentifier") as? PickListViewController
                
                pickListVC?.picklistStr = issueTypeStr
                
                pickListVC?.pickListProtocol = self
                pickListVC?.selectedPickListValue = issueType
                
                self.navigationController?.pushViewController(pickListVC!, animated: true)
                
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0.1
//    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        let alertCtrl = Alert.showUIAlert(title: "Message", message: "Are you sure you want to cancel without saving?", vc: self)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel) { action -> Void in
        
        }
        alertCtrl.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
 
            self.navigationController?.popViewController(animated: true);
            //Do some other stuff
        }
        alertCtrl.addAction(okAction)
        
        
    }
    
    
    var notes:String = ""
    
    @IBAction func save(_ sender: Any) {
        
        if let issueNotes = txtIssueNotes.text{
            
            notes = issueNotes
        }
        
        if(issueType == "Select Issue" || issueType.isEmpty){
            
            issueView.shake()
            
            self.view.makeToast("Please select issue.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                if didTap {
                    print("Completion with tap")
                    
                } else {
                    print("Completion without tap")
                }
                
                
            }
            
            
            return
        }
        
        if(notes.isEmpty){
            
            issueView.shake()
            
            self.view.makeToast("Please enter issue notes.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                if didTap {
                    print("Completion with tap")
                    
                } else {
                    print("Completion without tap")
                }
                
                
            }
            
            
            return
            
        }
        
        
        
        var msg:String = ""
        
        if(SalesforceConnection.currentIssueId == ""){
            saveIssueInCoreData()
            //createJsonData()
            msg = "Issue information has been created successfully."
        }
        else{
            updateIssueInCoreData()
            msg = "Issue information has been updated successfully."
        }
        
        
        
        self.view.makeToast(msg, duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateIssueView"), object: nil)
            
            
            
            self.navigationController?.popViewController(animated: true);
            
            
        }
        
        
    }
    
    
    
    func saveIssueInCoreData(){
        
        let issueObject = Issues(context: context)
        
        
        issueObject.issueId = UUID().uuidString
        
        issueObject.caseId = SalesforceConnection.caseId
        
        issueObject.issueNo = ""
        
        issueObject.issueType = issueType
        
        
        issueObject.notes = notes
        
        issueObject.actionStatus = "create"
        
        issueObject.contactName = SalesforceConnection.currentTenantName
        
        
        
        
        
        appDelegate.saveContext()
        
        
        
    }
    
    // create new issue and then edit that issue
    
    //edit issue which is already exist
    
    func updateIssueInCoreData(){
        
        var updateObjectDic:[String:String] = [:]
        
        //updateObjectDic["id"] = tenantDataDict["tenantId"] as! String?
        
        updateObjectDic["issueType"] = issueType
        updateObjectDic["notes"] = notes
        
        
        let issueResults = ManageCoreData.fetchData(salesforceEntityName: "Issues",predicateFormat: "issueId == %@" ,predicateValue: SalesforceConnection.currentIssueId,isPredicate:true) as! [Issues]
        
        
        if(issueResults.count > 0){
            
            if(issueResults[0].actionStatus! == ""){
                updateObjectDic["actionStatus"] = "edit"
                
            }
        }
        
        
        
        ManageCoreData.updateRecord(salesforceEntityName: "Issues", updateKeyValue: updateObjectDic, predicateFormat: "issueId == %@", predicateValue: SalesforceConnection.currentIssueId,isPredicate: true)
        
        
    }
    
    
    
}