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
        
        
        
        if(SalesforceConnection.currentIssueId != ""){
            fillIssueInfo()
        }
        
    }
    
    func fillIssueInfo(){
        
        
        let issueResults = ManageCoreData.fetchData(salesforceEntityName: "Issues",predicateFormat: "issueId == %@" ,predicateValue: SalesforceConnection.currentIssueId,isPredicate:true) as! [Issues]
        
        if(issueResults.count > 0){
            
            txtIssueNotes.text = issueResults[0].notes!
            issueType = issueResults[0].issueType!
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
        return 1
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddIssueCell")!
        cell.backgroundColor = UIColor.clear
        
        cell.accessoryType = .disclosureIndicator
        
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
    
    var issueTypeStr:String = ""
    
    func populateIssueTypes(){
        
        let issueTypeData =  ManageCoreData.fetchData(salesforceEntityName: "DropDown", predicateFormat:"object == %@ AND fieldName == %@",predicateValue:  "Issue__c",predicateValue2:  "Issuetype__c", isPredicate:true) as! [DropDown]
        
        
        if(issueTypeData.count>0){
            
            issueTypeStr =  String(issueTypeData[0].value!.characters.dropLast())
            //  statusArray = statusStr.components(separatedBy: ";")
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let pickListVC = self.storyboard!.instantiateViewController(withIdentifier: "picklistIdentifier") as? PickListViewController
        
        pickListVC?.picklistStr = issueTypeStr
        
        pickListVC?.pickListProtocol = self
        pickListVC?.selectedPickListValue = issueType
        
        self.navigationController?.pushViewController(pickListVC!, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        let msgtitle = "Message"
        
        let alertController = UIAlertController(title: "Message", message: "Are you sure you want to cancel without saving?", preferredStyle: .alert)
        
        alertController.setValue(NSAttributedString(string: msgtitle, attributes: [NSFontAttributeName :  UIFont(name: "Arial", size: 17.0)!, NSForegroundColorAttributeName : UIColor.black]), forKey: "attributedTitle")
        
        
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Do some stuff
        }
        alertController.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
            
            
            self.navigationController?.popViewController(animated: true);
            //Do some other stuff
        }
        alertController.addAction(okAction)
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    var notes:String = ""
    
    @IBAction func save(_ sender: Any) {
        
        if let issueNotes = txtIssueNotes.text{
            
            notes = issueNotes
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
