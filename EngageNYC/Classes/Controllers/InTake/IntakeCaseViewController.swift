//
//  IntakeCaseViewController.swift
//  EngageNYC
//
//  Created by MTX on 1/20/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class CaseDO{
    var caseId:String!
    var caseNo:String!
    var ownerId:String!
    var ownerName:String!
    var dateOfIntake:String!
    var caseStatus:String! //Open or Closed
    var clientId:String!
    var caseApiResponseDict:[String:AnyObject]!
    var caseResponseDynamicDict:[String : AnyObject]!
    var caseDynamicDict:[String : AnyObject]!
    var caseActionStatus:String!
    var assignmentId:String!
    var assignmentLocId:String!
    var assignmentLocUnitId:String!
    
    var caseNotes:String!
    
    var dbActionStatus:String!
    
    init(){
        caseId = ""
        caseNo = ""
        ownerId = ""
        ownerName = ""
        dateOfIntake = ""
        caseStatus = ""
        clientId = ""
        caseApiResponseDict = [:]
        caseResponseDynamicDict = [:]
        caseDynamicDict = [:]
        caseActionStatus = ""
        assignmentId = ""
        assignmentLocId = ""
        assignmentLocUnitId = ""
        caseNotes = ""
        dbActionStatus = ""
    }

}


class IntakeCaseViewController: BroadcastReceiverViewController,UITableViewDataSource,UITableViewDelegate
{
    @IBOutlet weak var lblCase: UILabel!
    
    @IBOutlet weak var tblCase: UITableView!
    
    var arrCaseMain = [CaseDO]()
    
    var viewModel:CaseViewModel!
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    var selectedClient:ContactDO!
    
    var inTakeVC:IntakeViewController!
    var selectedCaseObj:CaseDO!
    
     var inTakeCaseNavItems:[ListingPopOverDO]!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        
        self.setUpMoreNavItems()
        
        //Bind Locations data
        self.reloadView()
        
    }
    
    func setUpMoreNavItems(){
        inTakeCaseNavItems = Utility.setUpNavItems(resourceFileName: "InTakeCase")
    }
    
    override func onReceive(notification: NSNotification) {
        super.onReceive(notification: notification)
        
        if (notification.name.rawValue == SF_NOTIFICATION.INTAKECASELISTING_SYNC.rawValue)
        {
            self.reloadView()
        }
    }
    
    func setupView() {
        
        if let obj = selectedClient{
            inTakeVC.headerLbl.text = obj.contactName
        }
        else{
            inTakeVC.headerLbl.text = InTakeHeader.inTake.rawValue
        }
      
        // Adding notification reciever for Sync
        CustomNotificationCenter.registerReceiver(receiver: self.broadcastReceiver, notificationName: SF_NOTIFICATION.INTAKECASELISTING_SYNC)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.bindView()
        }
    }
    
    func reloadView(){
        DispatchQueue.main.async {
            
            if let contactObj = self.selectedClient{
              self.arrCaseMain = self.viewModel.loadCases(clientId: contactObj.contactId, assignmentLocUnitId: self.canvasserTaskDataObject.locationUnitObj.assignmentLocUnitId)
            }
            else{
                
                self.arrCaseMain = self.viewModel.loadTempCases(assignmentLocUnitId: self.canvasserTaskDataObject.locationUnitObj.assignmentLocUnitId,arrCases: [])
            }
            
         
            
            self.lblCase.text = "CASES (\(self.arrCaseMain.count))"
            
            self.tblCase.reloadData()
        }
    }
    
    @IBAction func btnMorePressed(_ sender: Any) {
        
        let indexRow = (sender as AnyObject).tag
        
        selectedCaseObj = arrCaseMain[indexRow!]
        
        Utility.showInTakeNavItems(btn: (sender) as! UIButton, type: .inTakeCaseList, navItems: inTakeCaseNavItems, vctrl: self)
        
    }
    
    
}

extension IntakeCaseViewController:ListingPopoverDelegate{
    func selectedItem(withObj obj: ListingPopOverDO, selectedIndex index: Int, popOverType type: PopoverType) {
        
        if(obj.name == InTakeCase.cases.rawValue){
            
            if let addCaseVC = AddCaseStoryboard().instantiateViewController(withIdentifier: "AddCasesViewController") as? AddCasesViewController{
                
                addCaseVC.objCase = selectedCaseObj
                addCaseVC.objCase.assignmentId = canvasserTaskDataObject.assignmentObj.assignmentId
                addCaseVC.objCase.assignmentLocUnitId = canvasserTaskDataObject.locationUnitObj.assignmentLocUnitId
                
                addCaseVC.inTakeVC = self.inTakeVC
                
                if(selectedCaseObj.caseStatus == enumCaseStaus.closed.rawValue || canvasserTaskDataObject.userObj.userId != selectedCaseObj.ownerId)
                {
                     addCaseVC.objCase.caseActionStatus = enumCaseActionStatus.View.rawValue
                }
                else
                {
                     addCaseVC.objCase.caseActionStatus = enumCaseActionStatus.Edit.rawValue
                }
                
                let navigationController = UINavigationController(rootViewController: addCaseVC)
                navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
                self.navigationController?.pushViewController(addCaseVC, animated: true)
            }
            
        }
 
        else if(obj.name == InTakeCase.notes.rawValue){
            
            if(!selectedCaseObj.caseNo.isEmpty){
                if let caseNotesVC = CaseNotesStoryboard().instantiateViewController(withIdentifier: "CaseNotesViewController") as? CaseNotesViewController{
                    
                    caseNotesVC.selectedCaseObj = selectedCaseObj
                    
                    let navigationController = UINavigationController(rootViewController: caseNotesVC)
                    navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
                    self.navigationController?.pushViewController(caseNotesVC, animated: true)
                }
            }
            else{
                
                self.view.makeToast("This case does not have any notes", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    
                }
                
            }
            
            print("Notes")
            
        }
        else if(obj.name == InTakeCase.issues.rawValue){
            
            //show Issue screen
            
            if let issueVC = IntakeIssueStoryboard().instantiateViewController(withIdentifier: "IntakeIssueViewController") as? IntakeIssueViewController{
                
              
               // issueVC.selectedCase = self.selectedCaseObj
                
                issueVC.selectedCaseObj = self.selectedCaseObj
                issueVC.selectedClient = self.selectedClient
                issueVC.canvasserTaskDataObject = self.canvasserTaskDataObject
                issueVC.inTakeVC = self.inTakeVC
                
                inTakeVC.segmentCtrl.selectedSegmentIndex = inTakeSegment.issues.rawValue
                
                
                for childVC in inTakeVC.childViewControllers{
                    
                    if childVC.isKind(of: IntakeCaseViewController.self){
                        Utility.switchBetweenViewControllers(senderVC: inTakeVC, fromVC: childVC, toVC: issueVC)
                        
                        
                    }
                    
                }
                
            }
            
        }
    }
}



extension  IntakeCaseViewController{
    func bindView(){
        self.viewModel = CaseViewModel.getViewModel()
    }
}

extension IntakeCaseViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCaseMain.count
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
          let cell:IntakeCaseTableViewCell = self.tblCase.dequeueReusableCell(withIdentifier: "casecell") as! IntakeCaseTableViewCell!
        
        if(arrCaseMain.count > 0){
            
            var isHighlight:Bool = false
            
            if let obj = inTakeVC.globalSelectedCaseForBinding{
                
                if(obj.caseId == arrCaseMain[indexPath.row].caseId){
                    isHighlight = true
                }
            }
            
            
            cell.setupView(forCellObject: arrCaseMain[indexPath.row],isHighlight:isHighlight, index: indexPath)
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
        if(inTakeVC.saveBtn.isHidden == false){
            
            let indexPathArray = tblCase.indexPathsForVisibleRows
            
            for indexPath in indexPathArray!
            {
                
                let cell = tblCase.cellForRow(at: indexPath) as! IntakeCaseTableViewCell
                
                if tblCase.indexPathForSelectedRow != indexPath {
                    
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
            //Here set bindingGlobalCase
            inTakeVC.globalSelectedCaseForBinding = arrCaseMain[indexPath.row]
        }
        
    }
}

