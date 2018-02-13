//
//  IntakeClientViewController.swift
//  EngageNYC
//
//  Created by MTX on 1/20/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class IntakeClientViewController: BroadcastReceiverViewController,UITableViewDelegate,UITableViewDataSource
{
    @IBOutlet weak var lblClients: UILabel!
    
    @IBOutlet weak var tblClients: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    var arrContactsMain = [ContactDO]()
    
    var viewModel:ClientListingViewModel!
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    var inTakeClientNavItems:[ListingPopOverDO]!
    
    var selectedClientObj:ContactDO!
    var inTakeVC:IntakeViewController!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        
        self.setUpMoreNavItems()
        
        //Bind Locations data
        self.reloadView()
        
        
        inTakeVC.lblAdd.text = "New Client"
        inTakeVC.imgAdd.image = UIImage(named:"AddClient.png")
        
        
    }
    
    override func onReceive(notification: NSNotification) {
        super.onReceive(notification: notification)
        
        if (notification.name.rawValue == SF_NOTIFICATION.INTAKECLIENTLISTING_SYNC.rawValue)
        {
            self.reloadView()
        }
    }
    
    @IBAction func btnMorePressed(_ sender: Any) {
        
        let indexRow = (sender as AnyObject).tag
        
        selectedClientObj = arrContactsMain[indexRow!]
        
        Utility.showInTakeNavItems(btn: (sender) as! UIButton, type: .inTakeClientList, navItems: inTakeClientNavItems, vctrl: self)
        
    }
    
    func setUpMoreNavItems(){
        inTakeClientNavItems = Utility.setUpNavItems(resourceFileName: "InTakeClient")
    }
    
    func setupView() {
        
        inTakeVC.headerLbl.text = InTakeHeader.inTake.rawValue
        
        // Adding notification reciever for Sync
        CustomNotificationCenter.registerReceiver(receiver: self.broadcastReceiver, notificationName: SF_NOTIFICATION.INTAKECLIENTLISTING_SYNC)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.bindView()
        }
    }
    
    func reloadView(){
        DispatchQueue.main.async {
            
            self.arrContactsMain = self.viewModel.loadInTakeClients(assignmentId: self.canvasserTaskDataObject.assignmentObj.assignmentId, assignmentLocId: self.canvasserTaskDataObject.locationObj.objMapLocation.assignmentLocId, assignmentLocUnitId: self.canvasserTaskDataObject.locationUnitObj.assignmentLocUnitId, unit: self.canvasserTaskDataObject.locationUnitObj.locationUnitName)
            
            self.lblClients.text = "CLIENTS (\(self.arrContactsMain.count))"
            
            self.tblClients.reloadData()
        }
    }
    
    
}

extension IntakeClientViewController:ListingPopoverDelegate{
    func selectedItem(withObj obj: ListingPopOverDO, selectedIndex index: Int, popOverType type: PopoverType) {
        if(obj.name == InTakeClient.client.rawValue){
            //show contact screen
            
            if self.selectedClientObj.createdById == nil{
                self.selectedClientObj.createdById = ""
            }
            
            if let noOfOpenCases = self.selectedClientObj.openCases , noOfOpenCases > 0 && canvasserTaskDataObject.userObj.userId !=  self.selectedClientObj.createdById && !self.selectedClientObj.createdById.isEmpty {
                
                self.view.makeToast("This client already have open cases so you can't edit it.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
  
                }

            }
            else{
                
                if let clientInfoVC = ClientInfoStoryboard().instantiateViewController(withIdentifier: "ClientInfoViewController") as? ClientInfoViewController{
                    
                    clientInfoVC.canvasserTaskDataObject = canvasserTaskDataObject
                    clientInfoVC.objContact = self.selectedClientObj
                    clientInfoVC.fromIntakeClient = true
                    
                    
                    clientInfoVC.modalPresentationStyle = UIModalPresentationStyle.formSheet
                    self.navigationController?.pushViewController(clientInfoVC, animated: true)
                    
                }
                
            }

        }
        else if(obj.name == InTakeClient.cases.rawValue){
            
            
            //show case screen
            
            if let caseVC = IntakeCaseStoryboard().instantiateViewController(withIdentifier: "IntakeCaseViewController") as? IntakeCaseViewController{
                
                caseVC.canvasserTaskDataObject = self.canvasserTaskDataObject
                caseVC.selectedClient = self.selectedClientObj
                
                
                inTakeVC.segmentCtrl.selectedSegmentIndex = inTakeSegment.cases.rawValue
                inTakeVC.globalSelectedClient = self.selectedClientObj //to maintain global selection of client
                
                caseVC.inTakeVC = inTakeVC
                
                Utility.enableDisableIntakeAddBtn(btn: inTakeVC.addBtn, lbl: inTakeVC.lblAdd, img: inTakeVC.imgAdd, isHidden: false)
                
            
                
                for childVC in inTakeVC.childViewControllers{
                    
                    if childVC.isKind(of: IntakeClientViewController.self){
                        Utility.switchBetweenViewControllers(senderVC: inTakeVC, fromVC: childVC, toVC: caseVC)
                        
                        
                    }
                    
                }
               
            }
            
            
        }
    }
}

extension  IntakeClientViewController{
    func bindView(){
        self.viewModel = ClientListingViewModel.getViewModel()
    }
}

extension IntakeClientViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrContactsMain.count
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell:IntakeClientTableViewCell = self.tblClients.dequeueReusableCell(withIdentifier: "clientcell") as! IntakeClientTableViewCell!
        
        if(arrContactsMain.count > 0){
            
            var isHighlight:Bool = false
            
            //for intake save button
//            if let obj = inTakeVC.globalSelectedClientForBinding{
//                
//                if(obj.contactId == arrContactsMain[indexPath.row].contactId){
//                    isHighlight = true
//                }
//            }
            
            //for maintain intake global client selection
            if(Static.newClientIdFromIntakeScreen.isEmpty){
                if let obj = inTakeVC.globalSelectedClient{
                    if(obj.contactId == arrContactsMain[indexPath.row].contactId){
                        isHighlight = true
                    }
                }
            }
            else{
                if(Static.newClientIdFromIntakeScreen == arrContactsMain[indexPath.row].contactId){
                    inTakeVC.globalSelectedClient = arrContactsMain[indexPath.row]
                    inTakeVC.globalSelectedCase = nil
                    Static.newClientIdFromIntakeScreen = ""
                    isHighlight = true
                }
            }
            
            cell.setupView(forCellObject: arrContactsMain[indexPath.row],isHighlight:isHighlight, index: indexPath)
        }
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        if(inTakeVC.saveBtn.isHidden == false){
            let indexPathArray = tblClients.indexPathsForVisibleRows
            
            for indexPath in indexPathArray!
            {
                
                let cell = tblClients.cellForRow(at: indexPath) as! IntakeClientTableViewCell
                
                if tblClients.indexPathForSelectedRow != indexPath {
                    
                    // Set Background Color
                    if indexPath.row % 2 == 0{
                        // White Row
                        cell.contentView.backgroundColor = UIColor.init(red: 240.0, green: 240.0, blue: 240.0, alpha: 1.0)
                    }
                    else{
                        // Gray Row
                        cell.contentView.backgroundColor = UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1.000)
                        
                    }
                    
                    
                }
                else{
                    
                    cell.contentView.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) //green
                    
                    
                    
                }
            }
            
             //Here set bindingGlobalClient
            //inTakeVC.globalSelectedClientForBinding = arrContactsMain[indexPath.row]
        
            inTakeVC.globalSelectedClient = arrContactsMain[indexPath.row]
            inTakeVC.globalSelectedCase = nil
            
            
        //}
        
       
        
    }
}


