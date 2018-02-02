//
//  AssignmentLocationUnitViewController.swift
//  EngageNYC
//
//  Created by Kamal on 14/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit



protocol UpdateAssignmentLocationUnit {
    func goToSurvey()
}

class AssignmentLocationUnitViewController: UIViewController {
    
    var completionHandler : ((_ childVC:AssignmentLocationUnitViewController) -> Void)?
    
    @IBOutlet weak var rightBarButton: UIButton!
    
    @IBOutlet weak var lblLocationName: UILabel!
    @IBOutlet weak var segmentCtrl: UISegmentedControl!
    
    @IBOutlet weak var headerTitle: UILabel!
    
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    var viewModel:AssignmentLocationUnitViewModel!
    var assignmentLocUnitInfoObj:AssignmentLocationUnitInfoDO!
    var isUnitListing:Bool!
    
    var assignmentLocUnitInfoVC:AssignmentLocationUnitInformationViewController!
    var assignmentLocUnitHistoryVC:AssignmentLocationUnitHistoryViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerTitle.text = canvasserTaskDataObject.locationUnitObj.locationUnitName
        lblLocationName.text = canvasserTaskDataObject.locationObj.objMapLocation.locName
        rightBarButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        self.bindView()
        self.assignmentLocUnitInfoObj = self.viewModel.getAssignmentLocationUnit(assignmentLocUnitId: canvasserTaskDataObject.locationUnitObj.assignmentLocUnitId)
        
        self.assignmentLocUnitInfoObj.isUnitListing = self.isUnitListing
        
        
        
        if let controller = segue.destination as? AssignmentLocationUnitInformationViewController
        {
            assignmentLocUnitInfoVC = controller
            
            controller.delegate = self
            
            controller.assignmentLocUnitInfoObj = assignmentLocUnitInfoObj
            
            controller.assignmentLocUnitInfoObj.assignmentLocUnitVC = self
            
            controller.viewModel = self.viewModel
            controller.canvasserTaskDataObject = self.canvasserTaskDataObject
        }
    }
    
    
    func prepareAssignmentLocationUnitPanelsInfo(viewCtrlType:String){
        DispatchQueue.main.async {
            
            var panelCtrl:UIViewController?
            
            if(viewCtrlType == popUpSegment.information.rawValue){
                
                if(self.assignmentLocUnitInfoVC == nil){
                    if let assignmentLocUnitInfo = AssignmentLocationUnitStoryboard().instantiateViewController(withIdentifier: "AssignmentLocationUnitInformationViewController") as? AssignmentLocationUnitInformationViewController{
                        
                        assignmentLocUnitInfo.delegate = self
                        assignmentLocUnitInfo.assignmentLocUnitInfoObj = self.assignmentLocUnitInfoObj
                        
                        assignmentLocUnitInfo.assignmentLocUnitInfoObj.assignmentLocUnitVC = self
                        
                        assignmentLocUnitInfo.viewModel = self.viewModel
                        assignmentLocUnitInfo.canvasserTaskDataObject = self.canvasserTaskDataObject
                        
                        self.assignmentLocUnitInfoVC = assignmentLocUnitInfo
                        
                        panelCtrl = assignmentLocUnitInfo
                    }
                }
                else{
                    
                    self.assignmentLocUnitInfoVC.delegate = self
                    
                    self.assignmentLocUnitInfoVC.assignmentLocUnitInfoObj = self.assignmentLocUnitInfoObj
                    
                    self.assignmentLocUnitInfoVC.assignmentLocUnitInfoObj.assignmentLocUnitVC = self
                    
                    self.assignmentLocUnitInfoVC.viewModel = self.viewModel
                    self.assignmentLocUnitInfoVC.canvasserTaskDataObject = self.canvasserTaskDataObject
                    
                    panelCtrl = self.assignmentLocUnitInfoVC
                }
                
                
            }
            else if(viewCtrlType == popUpSegment.history.rawValue){
                
                if let assignmentLocUnitHistory = AssignmentLocationUnitStoryboard().instantiateViewController(withIdentifier: "AssignmentLocationUnitHistoryViewController") as? AssignmentLocationUnitHistoryViewController{
                    
                    assignmentLocUnitHistory.canvasserTaskDataObject = self.canvasserTaskDataObject
                    assignmentLocUnitHistory.viewModel = self.viewModel
                    
                    
                    self.assignmentLocUnitHistoryVC = assignmentLocUnitHistory
                    
                    panelCtrl = assignmentLocUnitHistory
                }
                else{
                    
                    
                    self.assignmentLocUnitHistoryVC.canvasserTaskDataObject = self.canvasserTaskDataObject
                    self.assignmentLocUnitHistoryVC.viewModel = self.viewModel
                    
                    
                    panelCtrl = self.assignmentLocUnitHistoryVC
                }
                
            }
            
            if let containerView = panelCtrl{
                
                for childVC in self.childViewControllers{
                    
                    if childVC.isKind(of: AssignmentLocationUnitInformationViewController.self){
                        Utility.switchBetweenViewControllers(senderVC: self, fromVC: childVC, toVC: containerView)
                    }
                    else if childVC.isKind(of: AssignmentLocationUnitHistoryViewController.self){
                        Utility.switchBetweenViewControllers(senderVC: self, fromVC: childVC, toVC: containerView)
                    }
                    
                }
            }
        }
        
    }
    
    
    @IBAction func segmentCtrlPressed(_ sender: Any) {
        
        switch segmentCtrl.selectedSegmentIndex
        {
        case 0:
            rightBarButton.isHidden = false
            prepareAssignmentLocationUnitPanelsInfo(viewCtrlType: popUpSegment.information.rawValue)
            
        case 1:
            rightBarButton.isHidden = true
            prepareAssignmentLocationUnitPanelsInfo(viewCtrlType: popUpSegment.history.rawValue)
            
        default:
            break;
        }
    }
    
    @IBAction func btnLeftPressed(_ sender: Any) {
        
        let alertCtrl = Alert.showUIAlert(title: "Message", message: Static.exitMessage, vc: self)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel)
        { action -> Void in
            
        }
        
        alertCtrl.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            
            
            self.dismiss(animated: true, completion: nil)
        }
        alertCtrl.addAction(okAction)
        
        
    }
    
    
    @IBAction func btnRightPressed(_ sender: Any) {
        
        self.viewModel.updateAssignmentLocationUnit(assignmentLocationUnitInfoObj: self.assignmentLocUnitInfoObj,assignmentId:canvasserTaskDataObject.assignmentObj.assignmentId)
        
        self.view.makeToast("Unit has been updated successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
            
            //Notification Center:- reload unitlisting
            CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.UNITLISTING_SYNC.rawValue, sender: nil, userInfo: nil)
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
        
    }
}



extension AssignmentLocationUnitViewController:UpdateAssignmentLocationUnit{
    func goToSurvey() {
        self.viewModel.updateAssignmentLocationUnit(assignmentLocationUnitInfoObj: self.assignmentLocUnitInfoObj,assignmentId: canvasserTaskDataObject.assignmentObj.assignmentId)
        
        self.dismiss(animated: true, completion: {
            self.completionHandler?(self)
        })
        
    }
    
    
}

extension AssignmentLocationUnitViewController{
    func bindView(){
        self.viewModel = AssignmentLocationUnitViewModel.getViewModel()
    }
}
