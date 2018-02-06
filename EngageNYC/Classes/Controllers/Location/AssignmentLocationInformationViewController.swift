//
//  LocationInformationViewController.swift
//  EngageNYC
//
//  Created by Kamal on 13/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit


class AssignmentLocationInfoDO{
    
    var isObjectChanged:Bool!
    var assignmentLocVC:AssignmentLocationViewController!
    
    var assignmentLocationId:String!
    
    var oldAttempted:String!
    var oldLocStatus:String!
    var oldNotes:String!
    
    var attempted:String!{
        didSet{
            EnableDisableSaveBtn()
        }
    }
    var locStatus:String!{
        didSet{
            EnableDisableSaveBtn()
        }
    }
    var totalUnits:String!
    
    var notes:String!{
        didSet{
            EnableDisableSaveBtn()
        }
    }
    
    init(assignmentLocUnitId:String,attempted:String,locStatus:String,totalUnits:String,notes:String){
        self.assignmentLocationId = assignmentLocUnitId
        self.attempted = attempted
        self.locStatus = locStatus
        self.notes = notes
        
        self.oldAttempted = attempted
        self.oldLocStatus = locStatus
        self.oldNotes = notes
        
        self.totalUnits = totalUnits
        
        self.isObjectChanged = false
        
        
    }
    
    func EnableDisableSaveBtn(){
        if(self.attempted == self.oldAttempted && self.locStatus == self.oldLocStatus && self.notes == self.oldNotes){
            assignmentLocVC.rightBarButton.isEnabled = false
            isObjectChanged = false
            print("Object not changed")
            //disable save button
        }
        else{
             assignmentLocVC.rightBarButton.isEnabled = true
            isObjectChanged = true
            print("Object changed")
        }
    }
}



class AssignmentLocationInformationViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate
{
    
    @IBOutlet weak var NotesTextArea: UITextView!
    @IBOutlet weak var tblAssignmentLocation: UITableView!
    
    var viewModel:AssignmentLocationViewModel!
    var assignmentLocInfoObj:AssignmentLocationInfoDO!
    
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    var locationStatusPicklist:[DropDownDO]!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.reloadView()
        
    }
    
    func setUpUI(){
        NotesTextArea.layer.cornerRadius = 5
        NotesTextArea.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        NotesTextArea.layer.borderWidth = 0.5
        NotesTextArea.clipsToBounds = true
        NotesTextArea.textColor = UIColor.black
        
        self.tblAssignmentLocation?.tableFooterView = UIView()
        NotesTextArea.delegate = self
    }
    
  
    func textViewDidChange(_ textView: UITextView) {
        assignmentLocInfoObj.notes = textView.text
    }


    
    func reloadView(){
        DispatchQueue.main.async {
            self.locationStatusPicklist = self.viewModel.getLocationStatusPicklist(objectType: "Assignment_Location__c", fieldName: "Status__c")
            
            self.NotesTextArea.text = self.assignmentLocInfoObj.notes
            
            self.tblAssignmentLocation.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true;
    }
    
    func attemptChanged(_ sender: UISwitch)
    {
        
        //let index = sender.tag
        //let indexRow = (sender as AnyObject).tag
        if(sender.isOn){
            assignmentLocInfoObj.attempted = boolVal.yes.rawValue
        }
        else{
            assignmentLocInfoObj.attempted = boolVal.no.rawValue
        }
        
        
        
    }
    
    
}

extension AssignmentLocationInformationViewController:DynamicPicklistDelegate{
    func getPickListValue(pickListValue: DropDownDO) {
        self.assignmentLocInfoObj.locStatus = pickListValue.name
        self.tblAssignmentLocation.reloadData()
    }
}

extension AssignmentLocationInformationViewController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 3
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        NotesTextArea.resignFirstResponder()
        
        if indexPath.section == 1{
            
            
            let dynamicPicklistVC = DynamicPicklistStoryboard().instantiateViewController(withIdentifier: "DynamicPicklistViewController") as? DynamicPicklistViewController
            
            let dynamicPicklistObj = DynamicPicklistDO()
            dynamicPicklistObj.selectedDynamicPickListValue = assignmentLocInfoObj.locStatus
            dynamicPicklistObj.dynamicPickListArray = self.locationStatusPicklist
            dynamicPicklistObj.dynamicPicklistName = "Status"
            
            dynamicPicklistVC?.dynamicPicklistObj = dynamicPicklistObj
            dynamicPicklistVC?.delegate = self
            
            self.navigationController?.pushViewController(dynamicPicklistVC!, animated: true)
            
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "attemptCell")!
            cell.backgroundColor = UIColor.clear
            
            
            cell.textLabel?.text = "Attempt"
            cell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            cell.selectionStyle = .none
            
            //accessory switch
            let attemptSwitch = UISwitch(frame: CGRect.zero)
            
            if assignmentLocInfoObj != nil {
                if(assignmentLocInfoObj.attempted == boolVal.yes.rawValue){
                    attemptSwitch.isOn = true
                }
                else if (assignmentLocInfoObj.attempted == boolVal.no.rawValue){
                    attemptSwitch.isOn = false
                }
                else{
                    attemptSwitch.isOn = false
                }
            }
            
            attemptSwitch.addTarget(self, action: #selector(AssignmentLocationInformationViewController.attemptChanged(_:)), for: UIControlEvents.valueChanged)
            
            cell.accessoryView = attemptSwitch
            return cell
        }
        else if(indexPath.section == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "statusCell")!
            cell.backgroundColor = UIColor.clear
            
            cell.accessoryType = .disclosureIndicator
            
            cell.textLabel?.text = "Canvassing Status"
            
            cell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            
            cell.detailTextLabel?.text = "Select Status"
            cell.detailTextLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            
             if assignmentLocInfoObj != nil {
                if(assignmentLocInfoObj.locStatus.isEmpty){
                    cell.detailTextLabel?.text = "Select Status"
                    cell.detailTextLabel?.font = UIFont.init(name: "Arial", size: 18.0)
                    
                }
                else{
                    cell.detailTextLabel?.text = assignmentLocInfoObj.locStatus
                    cell.detailTextLabel?.font = UIFont.init(name: "Arial", size: 18.0)
                }
            }
            cell.detailTextLabel?.textColor = UIColor.lightGray
            
            
            return cell
            
        }
            
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noOfUnitsCell", for: indexPath)
            
            cell.selectionStyle = .none
            
            cell.textLabel?.text = "# of Units"
            cell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            if assignmentLocInfoObj != nil {
                cell.detailTextLabel?.text = assignmentLocInfoObj.totalUnits
            }
            cell.detailTextLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            cell.detailTextLabel?.textColor = UIColor.lightGray
            
            return cell
        }
        
        
        
    }
    
    
    
    
}


