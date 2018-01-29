//
//  NewClientInfoWithAddressViewController.swift
//  EngageNYCDev
//
//  Created by Kamal on 10/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

enum NewClientWithAddress: String{
    case sameAddress = "SameAddress"
    case differentAddress = "DifferentAddress"
}


class NewClientInfoWithAddressViewController: UIViewController {
    @IBOutlet weak var switchCtrl: UISwitch!
    
    @IBOutlet weak var leftBarButton: UIButton!
    @IBOutlet weak var rightBarButton: UIButton!
    
    @IBOutlet weak var clientName: UILabel!
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    var viewModel:AddressInfoViewModel!
    var sameAddressVC:SameAddressViewController!
    var differentAddressVC:DifferentAddressViewController!
    var newContactObj:NewContactDO!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateNavigation()
        
        clientName.text = newContactObj.contactName
        
    }
    
    func updateNavigation(){
        if let image = UIImage(named: "Save.png") {
            rightBarButton.setImage(image, for: .normal)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        self.bindView()
        
        if let controller = segue.destination as? SameAddressViewController
        {
            self.sameAddressVC = controller
            controller.canvasserTaskDataObject = self.canvasserTaskDataObject
            controller.viewModel = self.viewModel
            controller.newContactObj = self.newContactObj
        }
    }
    
    
    @IBAction func btnLeftPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //reload unitlisting
    //reload clientlisting
    @IBAction func btnRightPressed(_ sender: Any) {
        
        var isSuccessFullSave = false
        self.rightBarButton.isEnabled = false
        
        if(switchCtrl.isOn){
            if(newContactObj.sameUnitName.isEmpty){
                //apartmentView.shake()
                self.view.makeToast("Please select unit.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    
                    self.rightBarButton.isEnabled = true
                    
                    
                }
            }
            else{
                if(newContactObj.sameUnitName == virtualUnitName.unknown.rawValue){
                    
                    let locationUnitTuple =  self.viewModel.createVirtualUnit(unitName:newContactObj.sameUnitName,canvasserTaskDataObject: canvasserTaskDataObject)
                    newContactObj.locationUnitId = locationUnitTuple.locUnitId
                    newContactObj.assignmentLocUnitid = locationUnitTuple.assignmentLocUnitId
                }
                
                
                //create new contact
                newContactObj.streetNum = canvasserTaskDataObject.locationObj.objMapLocation.streetNum
                newContactObj.streetName = canvasserTaskDataObject.locationObj.objMapLocation.streetName
                newContactObj.borough = canvasserTaskDataObject.locationObj.objMapLocation.borough
                newContactObj.zip = canvasserTaskDataObject.locationObj.objMapLocation.zip
                newContactObj.floor = ""
                newContactObj.syncDate = ""
                
                self.viewModel.saveNewContact(objNewContactDO: newContactObj,isSameUnit:true)
                isSuccessFullSave = true
            }
        }
        else{
            if(newContactObj.diffUnitName.isEmpty){
                self.view.makeToast("Please select unit.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    
                    self.rightBarButton.isEnabled = true
                    
                }
            }
            else if(newContactObj.zip.characters.count < 5){
                
                // zipView.shake()
                
                self.view.makeToast("zip should be 5 digit.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    self.rightBarButton.isEnabled = true
                    
                }
                
            }
            else{
                
                if(newContactObj.diffUnitName == virtualUnitName.unknown.rawValue){
                    
                    newContactObj.syncDate = ""
                    
                    let locationUnitTuple = self.viewModel.createVirtualUnit(unitName:newContactObj.diffUnitName,canvasserTaskDataObject: canvasserTaskDataObject)
                    newContactObj.locationUnitId = locationUnitTuple.locUnitId
                    newContactObj.assignmentLocUnitid = locationUnitTuple.assignmentLocUnitId
                  
                }
                
                //create new contact
                self.viewModel.saveNewContact(objNewContactDO: newContactObj,isSameUnit:false)
                isSuccessFullSave = true
                
                
            }
            
        }
        
        if(isSuccessFullSave){
            
            self.view.makeToast("New Contact has been created successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    //Notification Center:- reload unitlisting
                    CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.UNITLISTING_SYNC.rawValue, sender: nil, userInfo: nil)
                    
                    //Notification Center:- reload unitlisting
                    CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.CLIENTLISTING_SYNC.rawValue, sender: nil, userInfo: nil)
                    
                    self.dismiss(animated: true, completion: nil)
                
            }
        }
        
        
    }
    
   
    
    @IBAction func switchPressed(_ sender: Any) {
        if((sender as AnyObject).isOn){
            prepareAddressPanelsInfo(viewCtrlType: NewClientWithAddress.sameAddress.rawValue)
        }
        else{
            prepareAddressPanelsInfo(viewCtrlType: NewClientWithAddress.differentAddress.rawValue)
        }
    }
    
    func prepareAddressPanelsInfo(viewCtrlType:String){
        DispatchQueue.main.async {
            
            var panelCtrl:UIViewController?
            
            if(viewCtrlType == NewClientWithAddress.sameAddress.rawValue){
                
                if(self.sameAddressVC == nil){
                    if let sameAddress = NewClientInfoWithAddressStoryboard().instantiateViewController(withIdentifier: "SameAddressViewController") as? SameAddressViewController{
                        
                        sameAddress.newContactObj = self.newContactObj
                        sameAddress.canvasserTaskDataObject = self.canvasserTaskDataObject
                        sameAddress.viewModel = self.viewModel
                        
                        self.sameAddressVC = sameAddress
                        panelCtrl = sameAddress
                        
                    }
                }
                else{
                    
                    self.sameAddressVC.newContactObj = self.newContactObj
                    self.sameAddressVC.canvasserTaskDataObject = self.canvasserTaskDataObject
                    self.sameAddressVC.viewModel = self.viewModel
                    
                    panelCtrl = self.sameAddressVC
                }
                
                
            }
            else if(viewCtrlType == NewClientWithAddress.differentAddress.rawValue){
                
                if(self.differentAddressVC == nil){
                    if let diffAddress = NewClientInfoWithAddressStoryboard().instantiateViewController(withIdentifier: "DifferentAddressViewController") as? DifferentAddressViewController{
                        
                        diffAddress.newContactObj = self.newContactObj
                        diffAddress.canvasserTaskDataObject = self.canvasserTaskDataObject
                        diffAddress.viewModel = self.viewModel
                        
                        self.differentAddressVC = diffAddress
                        panelCtrl = diffAddress
                    }
                }
                else{
                    
                    self.differentAddressVC.newContactObj = self.newContactObj
                    self.differentAddressVC.canvasserTaskDataObject = self.canvasserTaskDataObject
                    self.differentAddressVC.viewModel = self.viewModel
                    
                    panelCtrl = self.differentAddressVC
                }
                
                
            }
            
            if let containerView = panelCtrl{
                
                for childVC in self.childViewControllers{
                    
                    if childVC.isKind(of: SameAddressViewController.self){
                        Utility.switchBetweenViewControllers(senderVC: self, fromVC: childVC, toVC: containerView)
                    }
                    else if childVC.isKind(of: DifferentAddressViewController.self){
                        Utility.switchBetweenViewControllers(senderVC: self, fromVC: childVC, toVC: containerView)
                    }
                    
                }
            }
        }
        
    }
}

extension NewClientInfoWithAddressViewController{
    func bindView(){
        self.viewModel = AddressInfoViewModel.getViewModel()
    }
}
