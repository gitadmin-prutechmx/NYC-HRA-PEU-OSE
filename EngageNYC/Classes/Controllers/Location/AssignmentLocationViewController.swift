//
//  AssignmentLocationViewController.swift
//  EngageNYCDev
//
//  Created by MTX on 1/11/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class AssignmentLocationUnitDO{
    var assignmentLocationUnitId:String!
    var attempted:String!
    var contacted:String!
    var surveySyncDate:String!
    
    init(assignmentLocationUnitId:String,attempted:String,contacted:String,surveySyncDate:String){
        self.assignmentLocationUnitId = assignmentLocationUnitId
        self.attempted = attempted
        self.contacted = contacted
        self.surveySyncDate = surveySyncDate
    }
    
}

enum popUpSegment: String{
    case information = "Information"
    case history = "History"
}

protocol AssignmentLocationDelegate{
    func updateLocationStatus(assignmentLocId:String,locStatus:String);
}

class AssignmentLocationViewController: UIViewController
{
    var delegate:AssignmentLocationDelegate?
    @IBOutlet weak var lblLocationName: UILabel!
    @IBOutlet weak var segmentCtrl: UISegmentedControl!
    
    @IBOutlet weak var leftBarButton: UIButton!
    @IBOutlet weak var rightBarButton: UIButton!
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    var viewModel:AssignmentLocationViewModel!
    var assignmentLocInfoObj:AssignmentLocationInfoDO!
    
    var assignmentLocInfoVC:AssignmentLocationInformationViewController!
    var assignmentLocHistoryVC:AssignmentLocationHistoryViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblLocationName.text = canvasserTaskDataObject.locationObj.objMapLocation.locName
        rightBarButton.isEnabled = false
        
       Utility.makeButtonBorder(btn: self.leftBarButton)
       Utility.makeButtonBorder(btn: self.rightBarButton)
      
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        self.bindView()
        self.assignmentLocInfoObj = self.viewModel.getAssignmentLocation(assignmentLocId: self.canvasserTaskDataObject.locationObj.objMapLocation.assignmentLocId)
        
        if let controller = segue.destination as? AssignmentLocationInformationViewController
        {
            assignmentLocInfoVC = controller
            
         
            controller.assignmentLocInfoObj = assignmentLocInfoObj
             controller.assignmentLocInfoObj.assignmentLocVC = self
            controller.viewModel = self.viewModel
            controller.canvasserTaskDataObject = self.canvasserTaskDataObject
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true;
    }
    
    func prepareAssignmentLoctionPanelsInfo(viewCtrlType:String){
        DispatchQueue.main.async {
            
            var panelCtrl:UIViewController?
            
            if(viewCtrlType == popUpSegment.information.rawValue){
                
                if(self.assignmentLocInfoVC == nil){
                    if let assignmentLocInfo = AssignmentLocationStoryboard().instantiateViewController(withIdentifier: "AssignmentLocationInformationViewController") as? AssignmentLocationInformationViewController{
                        
                        self.assignmentLocInfoVC = assignmentLocInfo
                        
                        assignmentLocInfo.assignmentLocInfoObj = self.assignmentLocInfoObj
                        
                        assignmentLocInfo.assignmentLocInfoObj.assignmentLocVC = self
                        
                        assignmentLocInfo.canvasserTaskDataObject = self.canvasserTaskDataObject
                        assignmentLocInfo.viewModel = self.viewModel
                        panelCtrl = assignmentLocInfo
                    }
                }
                else{
                    
                    self.assignmentLocInfoVC.assignmentLocInfoObj = self.assignmentLocInfoObj
                    self.assignmentLocInfoVC.assignmentLocInfoObj.assignmentLocVC = self
                    
                    self.assignmentLocInfoVC.canvasserTaskDataObject = self.canvasserTaskDataObject
                    self.assignmentLocInfoVC.viewModel = self.viewModel
                    
                    panelCtrl = self.assignmentLocInfoVC
                }
                
                
            }
            else if(viewCtrlType == popUpSegment.history.rawValue){
                
                if(self.assignmentLocHistoryVC == nil){
                    if let assignmentLocHistory = AssignmentLocationStoryboard().instantiateViewController(withIdentifier: "AssignmentLocationHistoryViewController") as? AssignmentLocationHistoryViewController{
                        
                      
                        assignmentLocHistory.canvasserTaskDataObject = self.canvasserTaskDataObject
                        assignmentLocHistory.viewModel = self.viewModel
                       
                        
                        self.assignmentLocHistoryVC = assignmentLocHistory
                        panelCtrl = assignmentLocHistory
                    }
                }
                else{
                    
                   
                    self.assignmentLocHistoryVC.canvasserTaskDataObject = self.canvasserTaskDataObject
                    self.assignmentLocHistoryVC.viewModel = self.viewModel
                    
                    
                    panelCtrl = self.assignmentLocHistoryVC
                }
                
                
            }
            
            if let containerView = panelCtrl{
                
                for childVC in self.childViewControllers{
                    
                    if childVC.isKind(of: AssignmentLocationInformationViewController.self){
                        Utility.switchBetweenViewControllers(senderVC: self, fromVC: childVC, toVC: containerView)
                    }
                    else if childVC.isKind(of: AssignmentLocationHistoryViewController.self){
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
            prepareAssignmentLoctionPanelsInfo(viewCtrlType: popUpSegment.information.rawValue)
            
        case 1:
            rightBarButton.isHidden = true
            prepareAssignmentLoctionPanelsInfo(viewCtrlType: popUpSegment.history.rawValue)
            
        default:
            break;
        }
    }
    
    @IBAction func btnLeftPressed(_ sender: Any) {
        
        if(assignmentLocInfoObj.isObjectChanged){
            
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
        else{
             self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func btnRightPressed(_ sender: Any) {
        
        self.rightBarButton.isEnabled = false
        
        self.viewModel.updateAssignmentLocation(assignmentLocationInfoObj: assignmentLocInfoObj)
        
        self.view.makeToast("Location has been updated successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
            
            if(self.delegate != nil){
                self.delegate?.updateLocationStatus(assignmentLocId: self.assignmentLocInfoObj.assignmentLocationId, locStatus: self.assignmentLocInfoObj.locStatus)
            }
//                //Notification Center:- reload unitlisting
//                CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.LOCATIONLISTING_SYNC.rawValue, sender: nil, userInfo: nil)
//
                self.dismiss(animated: true, completion: nil)
                
            }
        }
        
    

}

extension AssignmentLocationViewController{
    func bindView(){
        self.viewModel = AssignmentLocationViewModel.getViewModel()
    }
}

