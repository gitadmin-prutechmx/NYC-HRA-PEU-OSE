//
//  IssueViewController.swift
//  Knock
//
//  Created by Cloudzeg Laptop on 7/31/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

struct IssueDataStruct
{
    var caseId : String = ""
    //var caseNo : String = ""
    var issueId:String = ""
    var issueNo : String = ""
    var issueType : String = ""
    var contactName:String = ""
    var issueNotes:String = ""
    var actionStatus:String = ""
    
}

class IssueViewController: UIViewController,UITableViewDelegate,UITableViewDataSource
    
{
   
    @IBOutlet weak var tblIssueList: UITableView!
    
    
    @IBOutlet weak var addIssueBtn: UIButton!
    
    var issueDataArray = [IssueDataStruct]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if(GlobalCase.caseStatus == "Closed" || SalesforceConnection.salesforceUserId != GlobalCase.caseOwnerId){
            addIssueBtn.isHidden = true
        }
        
        if(GlobalCase.caseId.isEmpty){
            addIssueBtn.isHidden = false
        }
        
        
        tblIssueList.delegate = self
        tblIssueList.dataSource = self
        self.tblIssueList.tableFooterView = UIView()
        
      
        
        self.navigationItem.title =  GlobalCase.caseNumber
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(IssueViewController.UpdateIssueView), name: NSNotification.Name(rawValue: "UpdateIssueView"), object:nil
        )
        
        addIssueBtn.layer.cornerRadius = 5
        
        // Do any additional setup after loading the view.
    }
    
    
    
    func UpdateIssueView(){
        print("UpdateIssueView")
        
        populateIssues()
    }
    
    // Cleanup notifications added in viewDidLoad
    deinit {
        NotificationCenter.default.removeObserver("UpdateIssueView")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateIssues()
    }
    @IBAction func btnEditIssue(_ sender: Any) {
        
        let indexRow = (sender as AnyObject).tag
        
        GlobalIssue.currentIssueId =  issueDataArray[indexRow!].issueId
        
        self.performSegue(withIdentifier: "showAddIssueIdentifier", sender: nil)
    }
    
    func populateIssues(){
        
        issueDataArray = [IssueDataStruct]()
        
      
        
        let issueResults = ManageCoreData.fetchData(salesforceEntityName: "Issues",predicateFormat: "caseId == %@" ,predicateValue: GlobalCase.caseId,isPredicate:true) as! [Issues]
        
        
        if(issueResults.count > 0){
            
            for issueData in issueResults{
                
                
                
                let objectIssueStruct:IssueDataStruct = IssueDataStruct(caseId: issueData.caseId!, issueId: issueData.issueId!, issueNo: issueData.issueNo!, issueType: issueData.issueType!,contactName:issueData.contactName!,issueNotes:issueData.notes!,actionStatus:issueData.actionStatus!)
                
                issueDataArray.append(objectIssueStruct)
                
            }
           
        }
        
        
        addTempIssues()
        
        issueDataArray = issueDataArray.sorted { $0.issueType < $1.issueType }
        
        
        
        
        self.tblIssueList.reloadData()
        
        
        
        
        
    }
    
    func addTempIssues(){
        
        
        let tempIssueResults = ManageCoreData.fetchData(salesforceEntityName: "Issues",predicateFormat: "actionStatus == %@" ,predicateValue: "temp",isPredicate:true) as! [Issues]
        
        if(tempIssueResults.count > 0){
            
            for tempIssueData in tempIssueResults{
                
                let objecttempIssueStruct:IssueDataStruct = IssueDataStruct(caseId: tempIssueData.caseId!, issueId: tempIssueData.issueId!, issueNo: tempIssueData.issueNo!, issueType: tempIssueData.issueType!,contactName:tempIssueData.contactName!,issueNotes:tempIssueData.notes!,actionStatus:tempIssueData.actionStatus!)
                
                issueDataArray.append(objecttempIssueStruct)
                
            }
        }
    }
    
    
    
    // MARK: UITenantTableView and UIEditTableView
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return issueDataArray.count
        
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "issueCell", for: indexPath) as! IssueTableViewCell
        
        let issueNo = issueDataArray[indexPath.row].issueNo
        let contactName = issueDataArray[indexPath.row].contactName
        
        cell.lblIssueNo.text = issueNo.isEmpty ? "-" : issueNo
        cell.lblIssueType.text = issueDataArray[indexPath.row].issueType
        cell.lblIssueId.text = issueDataArray[indexPath.row].issueId
        cell.issueBtn.tag = indexPath.row
        cell.lblContactName.text = contactName.isEmpty ? "-" : contactName
        
        if(issueDataArray[indexPath.row].actionStatus == "temp"){
            cell.issueView.backgroundColor = UIColor.yellow
        }
        else{
            cell.issueView.backgroundColor = UIColor.white
        }
         //cell.contentView.backgroundColor = UIColor.clear
        
        
        return cell
        
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Dequeue with the reuse identifier
        
        let identifier = "IssueHeaderIdentifier"
        var cell: IssueHeaderTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? IssueHeaderTableViewCell
        
        if cell == nil
        {
            tableView.register(UINib(nibName: "IssueHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? IssueHeaderTableViewCell
        }
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        GlobalIssue.currentIssueId =  issueDataArray[indexPath.row].issueId
        
       
        if(GlobalCase.caseStatus == "Closed" || SalesforceConnection.salesforceUserId != GlobalCase.caseOwnerId){
            GlobalIssue.issueActionStatus = "View"
        }
        else{
            GlobalIssue.issueActionStatus = "Edit"
        }
        
        
        if(GlobalCase.caseOwnerId.isEmpty){
             GlobalIssue.issueActionStatus = "Edit"
        }
        
        self.performSegue(withIdentifier: "showAddIssueIdentifier", sender: nil)
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return  44.0
        
    }
    
    
    
    @IBAction func addIssueAction(_ sender: Any)
    {
        GlobalIssue.currentIssueId =  ""
        
        GlobalIssue.issueActionStatus = "New"
        
        
        self.performSegue(withIdentifier: "showAddIssueIdentifier", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
