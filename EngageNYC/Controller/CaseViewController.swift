//
//  CaseViewController.swift
//  Knock
//
//  Created by Kamal on 10/08/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

struct CaseDataStruct
{
    var caseId : String = ""
    var caseNo : String = ""
    var contactId:String = ""
    var contacName : String = ""
    var caseStatus:String = ""
    var caseOwnerId:String = ""
    var caseOwner:String = ""
    var dateOfIntake:String = ""
    var actionStatus:String = ""
    
}

class CaseViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tblCaseView: UITableView!
    
    @IBOutlet weak var fullAddressTxt: UILabel!
    
    @IBOutlet weak var addCaseOutlet: UIButton!
    
    
    var caseDataArray = [CaseDataStruct]()
    
    
    var selectedCaseId:String = ""
    var selectedCaseNo:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCaseOutlet.layer.cornerRadius = 5
        
        // fullAddressTxt.text = "Unit: " + SalesforceConnection.unitName + "  |  " + SalesforceConnection.fullAddress
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        
        
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.navigationItem.title =  GlobalClient.currentTenantName
        
        NotificationCenter.default.addObserver(self, selector:#selector(CaseViewController.UpdateCaseView), name: NSNotification.Name(rawValue: "UpdateCaseView"), object:nil
        )
        
        
        // Do any additional setup after loading the view.
    }
    
    func UpdateCaseView(){
        print("UpdateCaseView")
        
        populateCaseData()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver("UpdateCaseView")
    }
    
    
    
    @IBAction func addCase(_ sender: Any) {
        
        
        let tempCaseResults = ManageCoreData.fetchData(salesforceEntityName: "Cases",predicateFormat: "actionStatus == %@" ,predicateValue: "temp",isPredicate:true) as! [Cases]
        
        if(tempCaseResults.count < 1){
            GlobalCase.caseId =  ""
            
            GlobalCase.caseNumber = ""
            
            GlobalCase.caseActionStatus = "New"
            
            
            self.performSegue(withIdentifier: "caseConfigIdentifier", sender: nil)
            
        }
        else{
            self.view.makeToast("You can create only one open case.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                if didTap {
                    print("Completion with tap")
                    
                } else {
                    print("Completion without tap")
                }
                
                
            }
        }
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedCaseId = ""
        selectedCaseNo = ""
        
        showCaseView()
        
    }
    
    func populateCaseData(){
        
        caseDataArray = [CaseDataStruct]()
        
        
        let caseResults = ManageCoreData.fetchData(salesforceEntityName: "Cases",predicateFormat: "contactId == %@ && assignmentLocUnitId == %@" ,predicateValue: GlobalClient.currentTenantId,predicateValue2: SalesforceConnection.assignmentLocationUnitId, isPredicate:true) as! [Cases]
        
        if(caseResults.count > 0){
            
            for caseData in caseResults{
                
                let objectCaseStruct:CaseDataStruct = CaseDataStruct(caseId: caseData.caseId!, caseNo: caseData.caseNo!, contactId: caseData.contactId!, contacName: caseData.contactName!,caseStatus:caseData.caseStatus!,caseOwnerId:caseData.caseOwnerId!,caseOwner:caseData.caseOwner!,dateOfIntake:caseData.createdDate!,actionStatus:caseData.actionStatus!)
                
                caseDataArray.append(objectCaseStruct)
                
            }
        }
        
        addTempCases()
        
        self.tblCaseView.reloadData()
        
    }
    
    
    func addTempCases(){
        
        let tempCaseResults = ManageCoreData.fetchData(salesforceEntityName: "Cases",predicateFormat: "actionStatus == %@" ,predicateValue: "temp",isPredicate:true) as! [Cases]
        
        if(tempCaseResults.count > 0){
            
            for tempCaseData in tempCaseResults{
                
                
                let tempObjectCaseStruct:CaseDataStruct = CaseDataStruct(caseId: tempCaseData.caseId!, caseNo: tempCaseData.caseNo!, contactId: tempCaseData.contactId!, contacName: tempCaseData.contactName!,caseStatus:tempCaseData.caseStatus!,caseOwnerId:tempCaseData.caseOwnerId!,caseOwner:tempCaseData.caseOwner!,dateOfIntake:tempCaseData.createdDate!,actionStatus:tempCaseData.actionStatus!)
                
                caseDataArray.append(tempObjectCaseStruct)
                
            }
        }
    }
    
    @IBAction func caseEdit(_ sender: Any)
    {
         let indexRow = (sender as AnyObject).tag
        GlobalCase.caseId =  caseDataArray[indexRow!].caseId
        GlobalCase.caseNumber = caseDataArray[indexRow!].caseNo
        GlobalCase.dateOfIntake = caseDataArray[indexRow!].dateOfIntake
        
        GlobalCase.caseStatus = caseDataArray[indexRow!].caseStatus
        GlobalCase.caseOwnerId = caseDataArray[indexRow!].caseOwnerId
        
        
        if(caseDataArray[indexRow!].caseStatus == "Closed" || SalesforceConnection.salesforceUserId != caseDataArray[indexRow!].caseOwnerId)
                {
                    GlobalCase.caseActionStatus = "View"
                }
                else
                    {
                    GlobalCase.caseActionStatus = "Edit"
                }
        
                if(GlobalClient.currentTenantId.isEmpty)
                {
                    GlobalCase.caseActionStatus = "Edit"
                }
        
        
                self.performSegue(withIdentifier: "caseConfigIdentifier", sender: nil)
    }
    
    
    
   
    // MARK: UITenantTableView and UIEditTableView
  
    func numberOfSections(in tableView: UITableView) -> Int
    {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return caseDataArray.count
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "caseCell", for: indexPath) as! CaseTableViewCell
        
        
        
        cell.caseNo.text = caseDataArray[indexPath.row].caseNo
        cell.ownerName.text = caseDataArray[indexPath.row].caseOwner
        cell.caseId.text = caseDataArray[indexPath.row].caseId
        cell.dateOfIntake.text = caseDataArray[indexPath.row].dateOfIntake
        
        cell.caseStatus.text = caseDataArray[indexPath.row].caseStatus
        cell.editBtn.tag = indexPath.row
        if(caseDataArray[indexPath.row].actionStatus == "temp"){
            cell.caseView.backgroundColor = UIColor.yellow
        }
        else{
            cell.caseView.backgroundColor = UIColor.white
        }
        cell.contentView.backgroundColor = UIColor.clear
        
        //        cell.caseView.backgroundColor = UIColor.white
        //        cell.contentView.backgroundColor = UIColor.clear
        
        return cell
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPathArray = tblCaseView.indexPathsForVisibleRows
        
        for indexPath in indexPathArray!{
            
            let cell = tblCaseView.cellForRow(at: indexPath) as! CaseTableViewCell
            
            if tblCaseView.indexPathForSelectedRow != indexPath {
                
                cell.caseView.backgroundColor = UIColor.white
                cell.contentView.backgroundColor = UIColor.clear
                
            }
            else{
                
                cell.caseView.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) //green
                
               // cell.contentView.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) //green
                
                
            }
        }
        
        GlobalCase.caseId =  caseDataArray[indexPath.row].caseId
        GlobalCase.caseNumber = caseDataArray[indexPath.row].caseNo
        GlobalCase.dateOfIntake = caseDataArray[indexPath.row].dateOfIntake
        GlobalCase.caseStatus = caseDataArray[indexPath.row].caseStatus
        GlobalCase.caseOwnerId = caseDataArray[indexPath.row].caseOwnerId
        
        
//        GlobalCase.caseId =  caseDataArray[indexPath.row].caseId
//        GlobalCase.caseNumber = caseDataArray[indexPath.row].caseNo
//        GlobalCase.dateOfIntake = caseDataArray[indexPath.row].dateOfIntake
//
//        GlobalCase.caseStatus = caseDataArray[indexPath.row].caseStatus
//        GlobalCase.caseOwnerId = caseDataArray[indexPath.row].caseOwnerId
//
//
//        if(caseDataArray[indexPath.row].caseStatus == "Closed" || SalesforceConnection.salesforceUserId != caseDataArray[indexPath.row].caseOwnerId){
//            GlobalCase.caseActionStatus = "View"
//        }
//        else{
//            GlobalCase.caseActionStatus = "Edit"
//        }
//
//        if(GlobalClient.currentTenantId.isEmpty){
//            GlobalCase.caseActionStatus = "Edit"
//        }
//
//
//        self.performSegue(withIdentifier: "caseConfigIdentifier", sender: nil)
        
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let identifier = "caseHeaderCell"
        var cell: InCaseHeaderTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? InCaseHeaderTableViewCell
        
        if cell == nil {
            tableView.register(UINib(nibName: "InCaseHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? InCaseHeaderTableViewCell
        }
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44.0
    }
    
    
    
    
    func showCaseView(){
        populateCaseData()
    }
    
    
    
    //    func issueAction(){
    //
    //        if(selectedCaseId == ""){
    //            viewCase.shake()
    //            self.view.makeToast("Please select case. ", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
    //
    //
    //            }
    //
    //        }
    //        else{
    //
    //            SalesforceConnection.caseId = selectedCaseId
    //            SalesforceConnection.caseNumber = selectedCaseNo
    //
    //
    //            SalesforceConnection.currentTenantName =  selectedClientName
    //            
    //            
    //            self.performSegue(withIdentifier: "showIssueIdentifier", sender: nil)
    //        }
    //    }
    
}
