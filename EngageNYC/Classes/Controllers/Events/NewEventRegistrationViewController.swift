//
//  NewEventRegistrationViewController.swift
//  EngageNYC
//
//  Created by MTX on 1/15/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

enum newEventRegScreen:Int{
    case contact = 0
    case attendeeStatus
  
}

class NewEventRegDO{
    var clientId:String!{
        didSet{
            EnableDisableSaveBtn()
        }
    }
    var clientName:String!
    var attendeeStatusName:String!
    var attendeeStatusId:String!{
        didSet{
            EnableDisableSaveBtn()
        }
    }
    
    var objEvent:EventDO!
    var newEventRegVC:NewEventRegistrationViewController!
 
    
    init(){
        self.clientId = ""
        self.clientName = ""
        self.attendeeStatusName = ""
        self.attendeeStatusId = ""
    }
    
    
    func EnableDisableSaveBtn(){
        
        if(self.clientId.isEmpty || self.attendeeStatusId.isEmpty){
            newEventRegVC.btnSave.isEnabled = false
        }
        else{
            newEventRegVC.btnSave.isEnabled = true
        }
        
    }
}

class NewEventRegistrationViewController: UIViewController,UITableViewDelegate,UITableViewDataSource
{
    
    @IBOutlet weak var tblRegistration: UITableView!
    var viewModel:NewEventRegViewModel!
    
    var clientsPicklist:[DropDownDO]!
    var attendeeStatus:[DropDownDO]!
    
    var newEventRegObj:NewEventRegDO!
    
    @IBOutlet weak var lblEventName: UILabel!
    
    @IBOutlet weak var btnSave: UIButton!
    var isSelectContactSelect:Bool = false
    var isSelectAttendeeStatus:Bool = false
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblRegistration?.tableFooterView = UIView()
       
        btnSave.isEnabled = false
        
        self.setupView()
        self.reloadView()
        
        Utility.makeButtonBorder(btn: btnSave)
    }
    
    
    
    func setupView() {
      
        DispatchQueue.global(qos: .userInitiated).async {
            self.bindView()
        }
    }
    
    
    func updateContactPicklist(){
        
        self.clientsPicklist = self.viewModel.getContactsOnEvents(assignmentLocUnitId: self.canvasserTaskDataObject.locationUnitObj.assignmentLocUnitId)
        
    }
    
    func reloadView(){
        DispatchQueue.main.async {
            
            
            self.updateContactPicklist()
            self.attendeeStatus = self.viewModel.getAttendeeStatus(objectType: "Event_Registration__c", fieldName: "Attendee_Status__c")
            
            self.lblEventName.text = self.newEventRegObj.objEvent.name
            
            self.tblRegistration.reloadData()
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isSelectContactSelect = false
        isSelectAttendeeStatus = false
        
        // Hide the navigation bar for current view controller
        self.navigationController?.isNavigationBarHidden = true;
    }
    
    
    
    @IBAction func btnSaveAction(_ sender: Any) {
        
        if(viewModel.saveEventReg(newEventRegObj: newEventRegObj)){
        
             self.view.makeToast("Event has been registered successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.EVENTREGLISTING_SYNC.rawValue, sender: nil, userInfo: nil)
                self.navigationController?.popViewController(animated: true)
            }
        }
        else{
            self.view.makeToast("Client already exist for that event.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
            }
        }
        
    }
    
    @IBAction func btnBackAction(_ sender: Any)
    {
        let alertCtrl = Alert.showUIAlert(title: "Message", message: Static.exitMessage, vc: self)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel)
        { action -> Void in
            
        }
        
        alertCtrl.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            self.navigationController?.popViewController(animated: true)
        }
        alertCtrl.addAction(okAction)
        
       
    }
    
}
extension NewEventRegistrationViewController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if(indexPath.section == newEventRegScreen.contact.rawValue)
        {
            let cell:EventSelectContactTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! EventSelectContactTableViewCell
            
            cell.setupView(forCellObject: newEventRegObj, index: indexPath)

            return cell
        }
        else
        {
            let cell:EventAttendeeStatusTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AttendeeStatusCell") as! EventAttendeeStatusTableViewCell
            
            cell.setupView(forCellObject: newEventRegObj, index: indexPath)
            
            return cell
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.section == newEventRegScreen.contact.rawValue{
            
            
            let dynamicPicklistVC = DynamicPicklistStoryboard().instantiateViewController(withIdentifier: "DynamicPicklistViewController") as? DynamicPicklistViewController
            
            
          
           
            
            let dynamicPicklistObj = DynamicPicklistDO()
            dynamicPicklistObj.selectedDynamicPickListValue = newEventRegObj.clientName
            dynamicPicklistObj.dynamicPickListArray = self.clientsPicklist
            dynamicPicklistObj.canvasserTaskDataObject = self.canvasserTaskDataObject
            
            
            
            dynamicPicklistObj.dynamicPicklistName = "Contact"
            dynamicPicklistObj.isAddClient = true
            
            dynamicPicklistVC?.dynamicPicklistObj = dynamicPicklistObj
            dynamicPicklistVC?.delegate = self
            
            isSelectContactSelect = true
            
            self.navigationController?.pushViewController(dynamicPicklistVC!, animated: true)
            
        }
        else{
            
            
            let dynamicPicklistVC = DynamicPicklistStoryboard().instantiateViewController(withIdentifier: "DynamicPicklistViewController") as? DynamicPicklistViewController
            
            let dynamicPicklistObj = DynamicPicklistDO()
            dynamicPicklistObj.selectedDynamicPickListValue = newEventRegObj.attendeeStatusName
            dynamicPicklistObj.dynamicPickListArray = self.attendeeStatus
            
            
            dynamicPicklistObj.dynamicPicklistName = "Attendee Status"
            
            dynamicPicklistVC?.dynamicPicklistObj = dynamicPicklistObj
            dynamicPicklistVC?.delegate = self
            
            isSelectAttendeeStatus = true
            
            self.navigationController?.pushViewController(dynamicPicklistVC!, animated: true)
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}

extension NewEventRegistrationViewController:DynamicPicklistDelegate{
    func getPickListValue(pickListValue: DropDownDO) {

        if(isSelectContactSelect){
            newEventRegObj.clientName = pickListValue.name
            newEventRegObj.clientId = pickListValue.id
            
            self.updateContactPicklist()
        }
        if(isSelectAttendeeStatus){
            newEventRegObj.attendeeStatusName = pickListValue.name
            newEventRegObj.attendeeStatusId = pickListValue.id
        }
        
       
        tblRegistration.reloadData()
    }
}

extension NewEventRegistrationViewController{
    func bindView(){
        self.viewModel = NewEventRegViewModel.getViewModel()
    }
}
