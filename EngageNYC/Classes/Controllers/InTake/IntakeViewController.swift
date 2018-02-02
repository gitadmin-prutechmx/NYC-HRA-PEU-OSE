//
//  IntakeViewController.swift
//  EngageNYC
//
//  Created by MTX on 1/20/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

enum Intake: String{
    case intakeClient = "Clients"
    case intakeCase = "Cases"
    case intakeIssue = "Issues"
}

enum InTakeClient:String{
    case client = "Client"
    case cases = "Cases"
}

enum InTakeCase:String{
    case notes = "Notes"
    case cases = "Cases"
    case issues = "Issues"
}

enum InTakeIssue:String{
    case issue = "Issue"
    case notes = "Notes"
}

enum inTakeSegment:Int{
    case client = 0
    case cases
    case issues
}

enum InTakeHeader:String{
    case inTake = "Client Intake"
}

class IntakeViewController: UIViewController {
    
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var segmentCtrl: UISegmentedControl!
    
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    
    var globalSelectedClient:ContactDO!
    var globalSelectedCase:CaseDO!
    
    var viewModel:InTakeViewModel!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    
    
   // var globalSelectedClientForBinding:ContactDO!
   // var globalSelectedCaseForBinding:CaseDO!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerLbl.text = InTakeHeader.inTake.rawValue
        lblLocation.text  = canvasserTaskDataObject.locationObj.objMapLocation.locName
        saveBtn.isHidden = true
        
        self.bindView()
        // Do any additional setup after loading the view.
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar for current view controller
        self.navigationController?.isNavigationBarHidden = true;
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let controller = segue.destination as? IntakeClientViewController
        {
            // controller.locationUnitVC = self
            controller.inTakeVC = self
            controller.canvasserTaskDataObject = self.canvasserTaskDataObject
        }
    }
    
    func prepareIntakePanelsInfo(viewCtrlType:String){
        DispatchQueue.main.async {
            
            self.addBtn.isHidden = false
            
            var panelCtrl:UIViewController?
            
            if(viewCtrlType == Intake.intakeClient.rawValue)
            {
                
                if let intakeClient = IntakeClientStoryboard().instantiateViewController(withIdentifier: "IntakeClientViewController") as? IntakeClientViewController{
                    
                    intakeClient.canvasserTaskDataObject = self.canvasserTaskDataObject
                    intakeClient.inTakeVC = self
                    
                   // self.globalSelectedClient = nil
                    
                    panelCtrl = intakeClient
                }
                
            }
            else if(viewCtrlType == Intake.intakeCase.rawValue){
                
                if let intakeCase = IntakeCaseStoryboard().instantiateViewController(withIdentifier: "IntakeCaseViewController") as? IntakeCaseViewController{
                    
                    intakeCase.inTakeVC = self
                    
                    if let obj = self.globalSelectedClient{
                        intakeCase.selectedClient = obj
                    }
                    
                    intakeCase.canvasserTaskDataObject = self.canvasserTaskDataObject
                    panelCtrl = intakeCase
                }
                
            }
                
            else if(viewCtrlType == Intake.intakeIssue.rawValue){
                
                if let intakeIssue = IntakeIssueStoryboard().instantiateViewController(withIdentifier: "IntakeIssueViewController") as? IntakeIssueViewController{
                    
                    intakeIssue.inTakeVC = self
                    
                    if let obj = self.globalSelectedCase{
                        intakeIssue.selectedCaseObj = obj
                    }
                    
                    if let obj = self.globalSelectedClient{
                        intakeIssue.selectedClient = obj
                    }
                    
                    
                    
                    intakeIssue.canvasserTaskDataObject = self.canvasserTaskDataObject
                    
                    panelCtrl = intakeIssue
                }
                
            }
            
            if let containerView = panelCtrl{
                
                for childVC in self.childViewControllers{
                    
                    if childVC.isKind(of: IntakeClientViewController.self){
                        Utility.switchBetweenViewControllers(senderVC: self, fromVC: childVC, toVC: containerView)
                    }
                    else if childVC.isKind(of: IntakeCaseViewController.self){
                        Utility.switchBetweenViewControllers(senderVC: self, fromVC: childVC, toVC: containerView)
                    }
                        
                    else if childVC.isKind(of: IntakeIssueViewController.self){
                        Utility.switchBetweenViewControllers(senderVC: self, fromVC: childVC, toVC: containerView)
                    }
                }
            }
        }
        
    }
    
    
    
    @IBAction func btnSavePressed(_ sender: Any) {
        self.saveTempCaseIssueBinding()
    }
    
    
    @IBAction func btnBackAction(_ sender: Any)
    {
         if(self.viewModel.isTempCaseExist(assignmentLocUnitId: canvasserTaskDataObject.locationUnitObj.assignmentLocUnitId) || self.viewModel.isTempIssuesExist(assignmentId: canvasserTaskDataObject.assignmentObj.assignmentId)){
            
            let alertCtrl = Alert.showUIAlert(title: "Message", message: "There are some cases or issues which does not bind with client. Do you want to close whithout saving?", vc: self)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel)
            { action -> Void in
                
            }
            
            alertCtrl.addAction(cancelAction)
            
            let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
                
                //delete all temp cases and issue data
                
                self.viewModel.deleteAllTempRecords()
                self.dismiss(animated: true, completion: nil)
                
                
            }
            alertCtrl.addAction(okAction)
            
        }
         else{
             self.dismiss(animated: true, completion: nil)
        }
        
        
    }
    
    @IBAction func btnAddAction(_ sender: Any)
    {
        if segmentCtrl.selectedSegmentIndex == inTakeSegment.issues.rawValue
        {
            if let addIssueVC = AddIssueStoryboard().instantiateViewController(withIdentifier: "AddIssueViewController") as? AddIssueViewController{
                
                
                for childVC in self.childViewControllers{
                    
                    if childVC.isKind(of: IntakeIssueViewController.self){
                        
                        addIssueVC.objIssue = IssueDO()
                        
                        if let obj = (childVC as! IntakeIssueViewController).selectedCaseObj{
                            
                            addIssueVC.objIssue.caseId = obj.caseId
                        }
                        else{
                            addIssueVC.objIssue.caseId = ""
                        }
                        
                        addIssueVC.objIssue.issueActionStatus = enumIssueActionStatus.Add.rawValue
                        addIssueVC.objIssue.assignmentId = canvasserTaskDataObject.assignmentObj.assignmentId
                        addIssueVC.inTakeVC = self
                        
                        let navigationController = UINavigationController(rootViewController: addIssueVC)
                        navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
                        self.navigationController?.pushViewController(addIssueVC, animated: true)
                        
                        
                    }
                    
                }
                
                
            }
        }
            
        else  if segmentCtrl.selectedSegmentIndex == inTakeSegment.cases.rawValue
        {
            
            
            if(self.viewModel.isTempCaseExist(assignmentLocUnitId: canvasserTaskDataObject.locationUnitObj.assignmentLocUnitId)){
                
                self.view.makeToast("You can create only one open case.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    
                }
                
            }
            else{
                
                if let addCaseVC = AddCaseStoryboard().instantiateViewController(withIdentifier: "AddCasesViewController") as? AddCasesViewController{
                    
                    for childVC in self.childViewControllers{
                        
                        if childVC.isKind(of: IntakeCaseViewController.self){
                            
                            addCaseVC.objCase = CaseDO()
                            
                            if let obj = (childVC as! IntakeCaseViewController).selectedClient{
                                
                                addCaseVC.objCase.clientId = obj.contactId
                            }
                            else{
                                addCaseVC.objCase.clientId = ""
                            }
                            
                            
                            addCaseVC.objCase.caseActionStatus = enumCaseActionStatus.Add.rawValue
                            addCaseVC.objCase.ownerName = canvasserTaskDataObject.userObj.userName
                            addCaseVC.objCase.ownerId = canvasserTaskDataObject.userObj.userId
                            addCaseVC.objCase.assignmentId = canvasserTaskDataObject.assignmentObj.assignmentId
                            addCaseVC.objCase.assignmentLocId = canvasserTaskDataObject.locationObj.objMapLocation.assignmentLocId
                            addCaseVC.objCase.assignmentLocUnitId = canvasserTaskDataObject.locationUnitObj.assignmentLocUnitId
                            
                            addCaseVC.inTakeVC = self
                            
                            let navigationController = UINavigationController(rootViewController: addCaseVC)
                            navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
                            self.navigationController?.pushViewController(addCaseVC, animated: true)
                            
                            
                        }
                        
                    }
                    
                }
                
                
            }
            
            
        }
            
        else if segmentCtrl.selectedSegmentIndex == inTakeSegment.client.rawValue
        {
            if let clientInfoVC = ClientInfoStoryboard().instantiateViewController(withIdentifier: "ClientInfoViewController") as? ClientInfoViewController{
                
                clientInfoVC.showAddressScreen = false
                clientInfoVC.fromIntakeClient = true
                //clientInfoVC.delegate = self
                clientInfoVC.canvasserTaskDataObject = canvasserTaskDataObject
                
                clientInfoVC.modalPresentationStyle = UIModalPresentationStyle.formSheet
                self.navigationController?.pushViewController(clientInfoVC, animated: true)
                
                // let navigationController = UINavigationController(rootViewController: clientInfoVC)
                //                navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
                //                self.present(navigationController, animated: true)
            }
        }
        
    }
    
    
    
    
    @IBAction func segmentCtrlPressed(_ sender: Any) {
        
        switch segmentCtrl.selectedSegmentIndex
        {
        case 0:
            prepareIntakePanelsInfo(viewCtrlType: Intake.intakeClient.rawValue)
            
        case 1:
            prepareIntakePanelsInfo(viewCtrlType: Intake.intakeCase.rawValue)
            
        case 2:
            prepareIntakePanelsInfo(viewCtrlType: Intake.intakeIssue.rawValue)
        default:
            break;
        }
        
    }
    
    
}

extension IntakeViewController{
    
    func saveTempCaseIssueBinding(){
        
        var clientId:String = ""
        var caseId:String = ""
        
//        if globalSelectedClient != nil{
//            globalSelectedClientForBinding = globalSelectedClient
//        }
//        if globalSelectedCase != nil{
//            globalSelectedCaseForBinding = globalSelectedCase
//        }
        
        if let clientObj = globalSelectedClient{
            clientId = clientObj.contactId
        }
        if let caseObj = globalSelectedCase{
            caseId = caseObj.caseId
        }
        
       
        
        
        if (self.viewModel.updateInTakeBinding(clientId: clientId, caseId: caseId, assignmentLocUnitId: canvasserTaskDataObject.locationUnitObj.assignmentLocUnitId, assignmentId: canvasserTaskDataObject.assignmentObj.assignmentId)){
            
            self.view.makeToast("Saved successfully", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                self.dismiss(animated: true, completion: nil)
                
            }
            
            
        }
        else{
            
            var msg = ""
            if(clientId.isEmpty){
                msg = "Please select client."
            }
            else if(self.viewModel.isTempCaseExist(assignmentLocUnitId: canvasserTaskDataObject.locationUnitObj.assignmentLocUnitId) == false){
                msg = "Please select case."
            }
            
            
            self.view.makeToast(msg, duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
            }
            
            
        }
        
    }
}

extension IntakeViewController{
    func bindView(){
        self.viewModel = InTakeViewModel.getViewModel()
    }
}
