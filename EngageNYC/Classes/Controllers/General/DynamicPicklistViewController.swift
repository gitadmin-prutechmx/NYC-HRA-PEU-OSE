//
//  DynamicPicklistViewController.swift
//  EngageNYC
//
//  Created by Kamal on 14/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class DropDownDO{
    var id:String!
    var name:String!
}

class DynamicPicklistDO{
    var dynamicPickListArray:[DropDownDO] = []
    var selectedDynamicPickListValue:String!
    var dynamicPicklistName:String!
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    var isAddClient:Bool!
    
    init(){
        isAddClient = false
    }
}

protocol DynamicPicklistDelegate {
    func getPickListValue(pickListValue:DropDownDO)
}

class DynamicPicklistViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    var dynamicPicklistObj:DynamicPicklistDO!
    
    var delegate:DynamicPicklistDelegate!

    @IBOutlet weak var tblDynamicPicklist: UITableView!
    @IBOutlet weak var lblDynamicPicklist: UILabel!
    @IBOutlet weak var btnAddClient: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        
        if(dynamicPicklistObj.isAddClient){
            btnAddClient.isHidden = false
        }
        else{
            btnAddClient.isHidden = true
        }
        
        
        Utility.makeButtonBorder(btn: btnAddClient)
    }
    
    func setUpView(){
        lblDynamicPicklist.text = dynamicPicklistObj.dynamicPicklistName
        self.tblDynamicPicklist.reloadData()
    }
    
    @IBAction func btnLeftPressed(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
  
    @IBAction func btnAddClientPressed(_ sender: Any){
        
        if let clientInfoVC = ClientInfoStoryboard().instantiateViewController(withIdentifier: "ClientInfoViewController") as? ClientInfoViewController{
            
            clientInfoVC.showAddressScreen = false
            clientInfoVC.fromPicklist = true
            clientInfoVC.canvasserTaskDataObject = dynamicPicklistObj.canvasserTaskDataObject
            
            let completionHandler:(ClientInfoViewController)->Void = { newClientVC in
                
                
                let objDropDown = DropDownDO()
                objDropDown.id = newClientVC.objNewContact.contactId
                objDropDown.name = newClientVC.objNewContact.contactName
                
                self.dynamicPicklistObj.dynamicPickListArray.append(objDropDown)
                self.dynamicPicklistObj.selectedDynamicPickListValue = newClientVC.objNewContact.contactName
                
                //update value
                if(self.delegate != nil){
                    self.delegate.getPickListValue(pickListValue: objDropDown)
                }
                
               self.tblDynamicPicklist.reloadData()
                
            }
            
            clientInfoVC.completionHandler = completionHandler
            
            clientInfoVC.modalPresentationStyle = UIModalPresentationStyle.formSheet
            self.navigationController?.pushViewController(clientInfoVC, animated: true)
          
        }
        
    }

}

extension DynamicPicklistViewController{
    
    // MARK: UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dynamicPicklistObj.dynamicPickListArray.count
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dynamicPicklistCell", for: indexPath)
        
        if(dynamicPicklistObj.dynamicPickListArray.count > 0){
            
            cell.textLabel?.text = dynamicPicklistObj.dynamicPickListArray[indexPath.row].name
            
        }
       
        if(dynamicPicklistObj.selectedDynamicPickListValue ==  cell.textLabel?.text){
            cell.accessoryType = UITableViewCellAccessoryType.checkmark;
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryType.none;
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
        
        if(delegate != nil){
            delegate.getPickListValue(pickListValue: dynamicPicklistObj.dynamicPickListArray[indexPath.row])
        }
        self.navigationController?.popViewController(animated: true);
       
    }
    
}
