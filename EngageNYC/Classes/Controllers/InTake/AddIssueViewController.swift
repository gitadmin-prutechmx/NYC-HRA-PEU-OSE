//
//  AddIssueViewController.swift
//  EngageNYC
//
//  Created by MTX on 1/23/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

enum enumIssueActionStatus:String{
    case Add = "Add"
    case Edit = "Edit"
    case View = "View"
}

class AddIssueViewController: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var tblAddIssue: UITableView!
 
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var saveBtn:UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var btnNotes: UIButton!
    @IBOutlet weak var imgNote: UIImageView!
    @IBOutlet weak var lblNote: UILabel!
    
    
    
    var objIssue:IssueDO!
    var viewModel:IssueViewModel!
    var inTakeVC:IntakeViewController!
    
    var issueTypePicklist:[DropDownDO]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.bindView()
        self.reloadView()
        
        Utility.makeButtonBorder(btn: saveBtn)
        Utility.makeButtonBorder(btn: cancelBtn)
    }
    
    func reloadView(){
         self.issueTypePicklist = self.viewModel.getIssueTypePicklist(objectType: "Issue__c", fieldName: "Issuetype__c")
        tblAddIssue.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar for current view controller
        self.navigationController?.isNavigationBarHidden = true;
        
    }

    @IBAction func btnNotesPressed(_ sender: Any) {
        
        if let issueNotesVC = IssueNotesStoryboard().instantiateViewController(withIdentifier: "IssueNotesViewController") as? IssueNotesViewController{
            
            issueNotesVC.selectedIssueObj = objIssue
            
            let navigationController = UINavigationController(rootViewController: issueNotesVC)
            navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
            self.navigationController?.pushViewController(issueNotesVC, animated: true)
        }
        
        
    }
    
    func setUpUI(){
        txtNotes.layer.cornerRadius = 5
        txtNotes.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        txtNotes.layer.borderWidth = 1.5
        txtNotes.clipsToBounds = true
        txtNotes.textColor = UIColor.black
        self.tblAddIssue?.tableFooterView = UIView()
        
    
        imgNote.isHidden = false
        lblNote.isHidden = false
        btnNotes.isHidden = false
        
        
        if(objIssue.issueActionStatus ==  enumIssueActionStatus.View.rawValue){
            saveBtn.isHidden = true
            txtNotes.isEditable = false
           
            if(objIssue.issueNo.isEmpty){
                headerTitle.text = "View Case"
            }
            else{
                headerTitle.text = objIssue.issueNo
            }
            
            
        }
        else if(objIssue.issueActionStatus ==  enumIssueActionStatus.Add.rawValue){
            saveBtn.isHidden = false
            headerTitle.text = "Add Issue"
            
            imgNote.isHidden = true
            lblNote.isHidden = true
            btnNotes.isHidden = true
        }
        else{
            saveBtn.isHidden = false
           
            if(objIssue.issueNo.isEmpty){
                headerTitle.text = "Edit Issue"
            }
            else{
                headerTitle.text = objIssue.issueNo
            }
            
        }
        
         txtNotes.text = objIssue.notes
        
//        if(objIssue.issueNo.isEmpty){
//            txtNotes.text = objIssue.notes
//        }
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        objIssue.notes = textView.text
    }
    
    
    @IBAction func btnBackAction(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSaveAction(_ sender: Any) {
        
        saveBtn.isEnabled = false
        
        var msg:String = ""
        
        if(objIssue.issueType.isEmpty){
            
            self.view.makeToast("Please select Issue Type", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                self.saveBtn.isEnabled = true
                
            }
        }
        else{
            if(objIssue.issueId.isEmpty){
                viewModel.SaveIssueInCoreData(objIssue:objIssue)
                msg = "Issue has been created successfully."
                
//                if(self.objIssue.caseId.isEmpty){
//                    self.inTakeVC.saveBtn.isHidden = false
//                }
            }
            else{
                viewModel.UpdateIssueInCoreData(objIssue:objIssue)
                msg = "Issue has been updated successfully."
            }
            
            
            self.view.makeToast(msg, duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                 CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.INTAKEISSUELISTING_SYNC.rawValue, sender: nil, userInfo: nil)
                
                self.navigationController?.popViewController(animated: true);

            }
        }
        
        
    }
    
}
extension AddIssueViewController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dynamicPicklistVC = DynamicPicklistStoryboard().instantiateViewController(withIdentifier: "DynamicPicklistViewController") as? DynamicPicklistViewController
        
        let dynamicPicklistObj = DynamicPicklistDO()
        
       
       
        dynamicPicklistObj.selectedDynamicPickListValue = objIssue.issueType
        
        
        dynamicPicklistObj.dynamicPickListArray = self.issueTypePicklist
        
        dynamicPicklistObj.dynamicPicklistName = "Issue Type"
        
        dynamicPicklistVC?.dynamicPicklistObj = dynamicPicklistObj
        dynamicPicklistVC?.delegate = self
        
        self.navigationController?.pushViewController(dynamicPicklistVC!, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell:AddIssueTableViewCell = tableView.dequeueReusableCell(withIdentifier: "addIssueCell") as! AddIssueTableViewCell
            cell.backgroundColor = UIColor.clear
            
            cell.accessoryType = .disclosureIndicator
        
            if let obj = objIssue{
                if(obj.issueType.isEmpty){
                     cell.issueType.text = "Select Issue Type"
                }
                else{
                    cell.issueType.text = obj.issueType
                }
            }
        
            
            return cell
        
      
    }
    
}

extension AddIssueViewController{
    func bindView(){
        self.viewModel = IssueViewModel.getViewModel()
    }
}

extension AddIssueViewController:DynamicPicklistDelegate{
    func getPickListValue(pickListValue: DropDownDO) {
        objIssue.issueType = pickListValue.name
        tblAddIssue.reloadData()
    }
    
}


