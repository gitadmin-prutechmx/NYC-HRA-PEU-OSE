//
//  IntakeIssueViewController.swift
//  EngageNYC
//
//  Created by MTX on 1/20/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class IssueDO{
    var caseId:String!
    var issueId:String!
    var issueNo: String!
    var issueType: String!
    var contactName: String!
    var assignmentId:String!
    var notes:String!
    var issueActionStatus:String!
    var dbActionStatus:String!

    init(){
        caseId = ""
        issueId = ""
        issueNo = ""
        issueType = ""
        contactName = ""
        assignmentId = ""
        notes = ""
        issueActionStatus = ""
        dbActionStatus = ""
    }
}

enum enumCaseStaus:String{
    case open = "Open"
    case closed = "Closed"
}

class IntakeIssueViewController: BroadcastReceiverViewController,UITableViewDataSource,UITableViewDelegate
{
    @IBOutlet weak var tblIssue: UITableView!
    @IBOutlet weak var lblIssues: UILabel!
    
    var arrIssueMain = [IssueDO]()
    
    var viewModel:IssueViewModel!
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    var selectedClient:ContactDO!
    
    var inTakeVC:IntakeViewController!
    var selectedCaseObj:CaseDO!
    var selectedIssueObj:IssueDO!
    
    var inTakeIssuesNavItems:[ListingPopOverDO]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        
        self.setUpMoreNavItems()
        
        self.reloadView()
        
    }
    
    func setUpMoreNavItems(){
        inTakeIssuesNavItems = Utility.setUpNavItems(resourceFileName: "InTakeIssue")
    }
    
    override func onReceive(notification: NSNotification) {
        super.onReceive(notification: notification)
        
        if (notification.name.rawValue == SF_NOTIFICATION.INTAKEISSUELISTING_SYNC.rawValue)
        {
            self.reloadView()
        }
    }
    
    func setupView() {
        
        if let caseObj = selectedCaseObj{
            inTakeVC.headerLbl.text = caseObj.caseNo
            
            if (caseObj.caseStatus == enumCaseStaus.closed.rawValue || canvasserTaskDataObject.userObj.userId != caseObj.ownerId) {
                //hide button
                inTakeVC.addBtn.isHidden = true
                
            }
            else{
                //show button
                inTakeVC.addBtn.isHidden = false
              
            }
            
        }
        else{
            inTakeVC.headerLbl.text = InTakeHeader.inTake.rawValue
        }
        
        
        
        
        // Adding notification reciever for Sync
        CustomNotificationCenter.registerReceiver(receiver: self.broadcastReceiver, notificationName: SF_NOTIFICATION.INTAKEISSUELISTING_SYNC)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.bindView()
        }
    }
    
    func reloadView(){
        DispatchQueue.main.async {
            
            if let caseObj = self.selectedCaseObj{
                
                var contactName:String = ""
                if let objClient = self.selectedClient{
                    contactName = objClient.contactName
                }
                
                self.arrIssueMain = self.viewModel.loadIssues(caseId: caseObj.caseId, assignmentId: self.canvasserTaskDataObject.assignmentObj.assignmentId,contactName:contactName)
            }
            
            else{
                
                self.arrIssueMain = self.viewModel.loadTempIssues(assignmentId: self.canvasserTaskDataObject.assignmentObj.assignmentId,arrIssues: [])
            }
            
            
            
            
            self.lblIssues.text = "ISSUES (\(self.arrIssueMain.count))"
            
            self.tblIssue.reloadData()
        }
    }
    
    @IBAction func btnMorePressed(_ sender: Any) {
        
        let indexRow = (sender as AnyObject).tag
        
        selectedIssueObj = arrIssueMain[indexRow!]
        
        Utility.showInTakeNavItems(btn: (sender) as! UIButton, type: .inTakeIssueList, navItems: inTakeIssuesNavItems, vctrl: self)
        
    }
    
    
}

extension IntakeIssueViewController:ListingPopoverDelegate{
    func selectedItem(withObj obj: ListingPopOverDO, selectedIndex index: Int, popOverType type: PopoverType) {
        
        
        if(obj.name == InTakeIssue.issue.rawValue){
            
             if let addIssueVC = AddIssueStoryboard().instantiateViewController(withIdentifier: "AddIssueViewController") as? AddIssueViewController{
                
                addIssueVC.objIssue = selectedIssueObj
                addIssueVC.objIssue.assignmentId = canvasserTaskDataObject.assignmentObj.assignmentId
                addIssueVC.inTakeVC = self.inTakeVC
                
                if let obj  = selectedCaseObj{
                    if(obj.caseStatus == enumCaseStaus.closed.rawValue || canvasserTaskDataObject.userObj.userId != obj.ownerId)
                    {
                        addIssueVC.objIssue.issueActionStatus = enumIssueActionStatus.View.rawValue
                    }
                    else
                    {
                        addIssueVC.objIssue.issueActionStatus = enumIssueActionStatus.Edit.rawValue
                    }
                }
                else{
                     addIssueVC.objIssue.issueActionStatus = enumIssueActionStatus.Edit.rawValue
                }
                
                
                
                let navigationController = UINavigationController(rootViewController: addIssueVC)
                navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
                self.navigationController?.pushViewController(addIssueVC, animated: true)
            }
            
            print("Edit Issue")
        }
       
        else if(obj.name == InTakeIssue.notes.rawValue){
            
            
                if let issueNotesVC = IssueNotesStoryboard().instantiateViewController(withIdentifier: "IssueNotesViewController") as? IssueNotesViewController{
                    
                    issueNotesVC.selectedIssueObj = selectedIssueObj
                    
                    let navigationController = UINavigationController(rootViewController: issueNotesVC)
                    navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
                    self.navigationController?.pushViewController(issueNotesVC, animated: true)
                }
            
        
            
            
            print("Notes")
            
        }
        
    }
}


extension  IntakeIssueViewController{
    func bindView(){
        self.viewModel = IssueViewModel.getViewModel()
    }
}

extension IntakeIssueViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrIssueMain.count
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell:IntakeIssueTableViewCell = self.tblIssue.dequeueReusableCell(withIdentifier: "issuecell") as! IntakeIssueTableViewCell!
        
        if(arrIssueMain.count > 0){
            cell.setupView(forCellObject: arrIssueMain[indexPath.row], index: indexPath)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
}

