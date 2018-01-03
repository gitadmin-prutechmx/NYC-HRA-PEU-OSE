//
//  InTakeViewController.swift
//  EngageNYCDev
//
//  Created by Kamal on 11/12/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class InTakeViewController: UIViewController {

    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    
    var clientListVC:ClientListingViewController!
    var caseVC:CaseViewController!
    var issueVC:IssueViewController!
    
    @IBOutlet var superView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orientationChanged()
         lblAddress.text = "Unit: " + SalesforceConnection.unitName + "  |  " + SalesforceConnection.fullAddress
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        
        
        self.navigationController?.navigationBar.tintColor = UIColor.white

        
        GlobalClient.reset()
        GlobalCase.reset()
        
        
        Utilities.inTakeVC = self
        
        Utilities.isClientDoesNotReveal = false
        
        
        // Do any additional setup after loading the view.
    }
    
    func orientationChanged() -> Void
    {
        
        if UIDevice.current.orientation.isLandscape
        {
            print("Landscape")
            self.view.superview?.center = self.view.center;
            self.preferredContentSize = CGSize(width: 740, height: 667)
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
    /// Method to switch between different panels that are region specific
    func prepareIntakePanelsInfo(viewCtrlType:String){
        
//        
//        let caseVC = self.storyboard!.instantiateViewController(withIdentifier: "caseviewcontrollerSID") as? CaseViewController
//        
//        self.present(caseVC!, animated: true, completion: nil)

        
        //opportunityViewCtrl = iTeroDashboardStoryboard().instantiateViewController(withIdentifier: "ATOpportunityEMEAViewController") as! ATOpportunityEMEAViewController
        
        DispatchQueue.main.async {
            
            var panelCtrl:UIViewController!
            
            if(viewCtrlType == "Client"){
                panelCtrl = self.storyboard!.instantiateViewController(withIdentifier: "clientListViewControllerSID") as? ClientListingViewController
                
            }
            else if(viewCtrlType == "Case"){
                panelCtrl = self.storyboard!.instantiateViewController(withIdentifier: "caseviewcontrollerSID") as? CaseViewController
            }
            else if(viewCtrlType == "Issue"){
                panelCtrl = self.storyboard!.instantiateViewController(withIdentifier: "issueviewcontrollerSID") as? IssueViewController
            }
            else{
                  panelCtrl = self.storyboard!.instantiateViewController(withIdentifier: "clientListViewControllerSID") as? ClientListingViewController
            }
            
            
            // Utilities.switchBetweenViewControllers(senderVC: self, fromVC: childVC, toVC: panelCtrl)
            
            
            for childVC in self.childViewControllers{
                
                if childVC.isKind(of: ClientListingViewController.self){
                    Utilities.switchBetweenViewControllers(senderVC: self, fromVC: childVC, toVC: panelCtrl)
                }
                else if childVC.isKind(of: CaseViewController.self){
                    Utilities.switchBetweenViewControllers(senderVC: self, fromVC: childVC, toVC: panelCtrl)
                }
                else if childVC.isKind(of: IssueViewController.self){
                    Utilities.switchBetweenViewControllers(senderVC: self, fromVC: childVC, toVC: panelCtrl)
                }
            }
        }
    }
    
    
    @IBAction func close(_ sender: Any) {
        
        let alertCtrl = Alert.showUIAlert(title: "Message", message: "Are you sure you want to close without saving?", vc: self)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel) { action -> Void in
            
        }
        alertCtrl.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            
            //delete all temp cases and issue data
            
            ManageCoreData.deleteRecord(salesforceEntityName: "Cases", predicateFormat: "actionStatus == %@", predicateValue: "temp", isPredicate: true)
             ManageCoreData.deleteRecord(salesforceEntityName: "Issues", predicateFormat: "actionStatus == %@", predicateValue: "temp", isPredicate: true)
            
            self.dismiss(animated: true, completion: nil)
            
        }
        alertCtrl.addAction(okAction)
        
        
        
    }

    @IBAction func save(_ sender: Any) {
        
       
        
        //if new temp case then by default bind all new temp issues
        //if no new temp case then give warning
        
        
        //Temp issues:- no temp case
        
        var isTempCase = false
        var isTempIssue = false
        var tempCaseId:String = ""
      
        let tempCaseResults = ManageCoreData.fetchData(salesforceEntityName: "Cases",predicateFormat: "actionStatus == %@" ,predicateValue: "temp",isPredicate:true) as! [Cases]
        
        if(tempCaseResults.count == 1){
            isTempCase = true
            tempCaseId = tempCaseResults[0].caseId!
        }
        
        let tempIssueResults = ManageCoreData.fetchData(salesforceEntityName: "Issues",predicateFormat: "actionStatus == %@" ,predicateValue: "temp",isPredicate:true) as! [Issues]

   
            if(tempIssueResults.count > 0){
                isTempIssue = true
            }
        
        
        
        var isTempRecordsExist = false
        
        //no tempcase and not selected any existing case to bind issues
        if(isTempCase == false && GlobalCase.caseId.isEmpty){
            if(isTempIssue == true){
                isTempRecordsExist = true
            }
        }
        
        if(Utilities.isClientDoesNotReveal){
            
            SalesforceConnection.selectedTenantForSurvey = "empty"
            SalesforceConnection.selectedTenantNameForSurvey = ""
            
            self.view.makeToast("Saved successfully", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                self.dismiss(animated: true, completion: nil)
                
            }
            
            return
        }
       
        
let isSave = GlobalClient.currentTenantId.isEmpty == true ? false : isTempRecordsExist == true ? false : true
        
        if(isSave){
            
            //mapping here
            
            if(isTempCase == true){
                
                for tempCaseData in tempCaseResults{
                    
                    var updateObjectDic:[String:String] = [:]
                    
                    updateObjectDic["contactId"] = GlobalClient.currentTenantId
                    updateObjectDic["actionStatus"] = ""
                    
                    
                    ManageCoreData.updateRecord(salesforceEntityName: "Cases", updateKeyValue: updateObjectDic, predicateFormat: "caseId == %@ && actionStatus == %@", predicateValue: tempCaseData.caseId!,predicateValue2: "temp", isPredicate: true)
                    
                }
            }
            if(isTempIssue == true){
                
                for tempIssueData in tempIssueResults{
                    
                    var updateObjectDic:[String:String] = [:]
                    
                    if(!GlobalCase.caseId.isEmpty){
                        updateObjectDic["caseId"] = GlobalCase.caseId
                    }
                    else{
                         updateObjectDic["caseId"] = tempCaseId
                    }
                    updateObjectDic["actionStatus"] = "create"
                    updateObjectDic["contactName"] =  GlobalClient.currentTenantName
                    
                    
                    ManageCoreData.updateRecord(salesforceEntityName: "Issues", updateKeyValue: updateObjectDic, predicateFormat: "issueId == %@ && actionStatus == %@", predicateValue: tempIssueData.issueId!,predicateValue2: "temp", isPredicate: true)
                    
                
                }
            }
            
            SalesforceConnection.selectedTenantForSurvey = GlobalClient.currentTenantId
            SalesforceConnection.selectedTenantNameForSurvey = GlobalClient.currentTenantName
            
            self.view.makeToast("Saved successfully", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                self.dismiss(animated: true, completion: nil)
                
            }
            
            
            
        }
        else{
            
            var msg = ""
            if(GlobalClient.currentTenantId.isEmpty){
                msg = "Please select client."
            }
            else if(isTempCase == false){
                msg = "Please select case."
            }
            
            superView.shake()
            self.view.makeToast(msg, duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
            }
            
            
        }
        
        
    }
    
    //click to tab means toVC controller
    //Now from which tab
    
    @IBAction func segmentChanged(_ sender: Any) {

        switch segmentControl.selectedSegmentIndex
        {
        case 0:
            GlobalClient.reset()
            GlobalCase.reset()
            prepareIntakePanelsInfo(viewCtrlType: "Client")
            
        case 1:
            if(GlobalClient.currentTenantId.isEmpty){
                GlobalClient.reset()
            }
            GlobalCase.reset()
            prepareIntakePanelsInfo(viewCtrlType: "Case")
        
        case 2:
            if(GlobalCase.caseId.isEmpty){
                GlobalCase.reset()
            }
            prepareIntakePanelsInfo(viewCtrlType: "Issue")
        
        default:
            break;
        }
    }
    


}
