//
//  PickListViewController.swift
//  TestApplication
//
//  Created by Kamal on 30/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class PickListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    
    var pickListProtocol:PickListProtocol?
    var selectedPickListValue:String = ""
    var picklistStr:String = ""
    var isReset:Bool =  false
    var showContactName = false
    var selectedContactId:String = ""
    
    
    var pickListArray: [String]!
    
    @IBOutlet weak var pickListTblView: UITableView!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
 
        
        NotificationCenter.default.addObserver(self, selector:#selector(PickListViewController.UpdatePicklistView), name: NSNotification.Name(rawValue: "UpdatePicklistView"), object:nil)
        
        
        
        
        
                let resetButton = UIBarButtonItem(title: "Reset",  style: .plain, target: self, action: #selector(PickListViewController.didTapResetButton))
        
                if(showContactName){
                    let addClientButton   = UIBarButtonItem(title: "Add",  style: .plain, target: self, action: #selector(PickListViewController.didTapAddClientButton))
                     navigationItem.rightBarButtonItems = [addClientButton, resetButton]
                }
                else{
                    navigationItem.rightBarButtonItem = resetButton
                }
        
        
        populatePickList()
        
        
    }
    
    func didTapAddClientButton(sender: AnyObject){
        
        GlobalClient.currentTenantId =  ""
        
        SalesforceConnection.isNewContactWithAddress = false
        SalesforceConnection.isFromPickListToNewClient = true
        
        
        let saveEditTenantVC = self.storyboard!.instantiateViewController(withIdentifier: "saveEditTenantSID") as? SaveEditTenantViewController
        
    
        self.navigationController?.pushViewController(saveEditTenantVC!, animated: true)
        
        
        //self.performSegue(withIdentifier: "showSaveEditClientIdentifier", sender: nil)
        
    }
    
    func didTapResetButton(sender: AnyObject){
        
        selectedPickListValue = ""
        isReset = true
        
        self.pickListTblView.reloadData()
    }
    
   
    @IBAction func resetAction(_ sender: Any) {
        
        selectedPickListValue = ""
        isReset = true
        
        self.pickListTblView.reloadData()
        
    }
    
    
    func UpdatePicklistView(_ notification:NSNotification){
        print("UpdatePicklistView")
        
        if let contactObj = notification.userInfo?["contactKey"] as? ContactPicklist {
            
            selectedContactId = contactObj.contactId
            showContactName = contactObj.isShowContactName
            selectedPickListValue = contactObj.selectedContactName
        }
        
        picklistStr = ""
        
        let clientResults = ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "unitId == %@ AND assignmentId == %@ AND locationId == %@" ,predicateValue: SalesforceConnection.unitId,predicateValue2: SalesforceConnection.assignmentId,predicateValue3: SalesforceConnection.locationId,isPredicate:true) as! [Tenant]
        
        
        if(clientResults.count > 0){
            
            for client in clientResults{
                picklistStr += client.id! + ";"
            }
            
        }
        
        populatePickList()
    }
    
    
    // Cleanup notifications added in viewDidLoad
    deinit
    {
        NotificationCenter.default.removeObserver("UpdatePicklistView")
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if(isReset){
            pickListProtocol?.getPickListValue(pickListValue: "")
        }
        
        if(Utilities.isSelectContactSelect){
             pickListProtocol?.getPickListValue(pickListValue: selectedContactId)
        }
    }
    
    
    
    func populatePickList(){
        
        if(picklistStr != ""){
            
            pickListArray = String(picklistStr.characters.dropLast()).components(separatedBy: ";")
        }
        
        
        if(showContactName){
            createTenantDictionary()
        }
        
        self.pickListTblView.reloadData()
        
    }
    
    
    var contactDict: [String:String] = [:]
    
    
    func createTenantDictionary(){
        
        let tenantResults =  ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "unitId == %@",predicateValue: SalesforceConnection.unitId, isPredicate:true) as! [Tenant]
        
        if(tenantResults.count > 0){
            
            for tenantData in tenantResults{
                
                contactDict[tenantData.id!] = tenantData.name!
                
            }
        }
        
    }
    
    // MARK: - table view methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.pickListArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        
        if(showContactName){
            cell.textLabel?.text = contactDict[pickListArray[indexPath.row]]
        }
        else{
            cell.textLabel?.text = pickListArray[indexPath.row]
        }
        
        if(selectedPickListValue ==  cell.textLabel?.text){
            cell.accessoryType = UITableViewCellAccessoryType.checkmark;
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryType.none;
        }
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if(Utilities.isSelectContactSelect){
            selectedContactId = pickListArray[indexPath.row]
        }
        else{
            pickListProtocol?.getPickListValue(pickListValue: pickListArray[indexPath.row])
        }
        
        self.navigationController?.popViewController(animated: true);

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}



