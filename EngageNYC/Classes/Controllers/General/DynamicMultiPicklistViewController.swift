//
//  DynamicMultiPicklistViewController.swift
//  EngageNYC
//
//  Created by Kamal on 28/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class DynamicMultiPicklistDO{
    var dynamicMultiPickListArray:[DropDownDO] = []
    var selectedDynamicMultiPickListValue:String!
    var dynamicMultiPicklistName:String!
    var selectedMultiPickListArray:[String] = []
   
}

protocol DynamicMultiPicklistDelegate {
    func getMultiPickListValue(multiPickListValue:String)
}


class DynamicMultiPicklistViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var dynamicMultiPicklistObj:DynamicMultiPicklistDO!
    
    var delegate:DynamicMultiPicklistDelegate!
    
    @IBOutlet weak var tblDynamicMultPicklist: UITableView!
    @IBOutlet weak var lblDynamicMultiPicklist: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        
    }
    
    func setUpView(){
        
        tblDynamicMultPicklist.allowsMultipleSelection = true
        
        lblDynamicMultiPicklist.text = dynamicMultiPicklistObj.dynamicMultiPicklistName
        
        if(!dynamicMultiPicklistObj.selectedDynamicMultiPickListValue.isEmpty){
            dynamicMultiPicklistObj.selectedMultiPickListArray = String(dynamicMultiPicklistObj.selectedDynamicMultiPickListValue).components(separatedBy: ";")
        }
       
        
        
        
        self.tblDynamicMultPicklist.reloadData()
    }
    
    @IBAction func btnLeftPressed(_ sender: Any) {
        
        if(delegate != nil){
            delegate?.getMultiPickListValue(multiPickListValue: dynamicMultiPicklistObj.selectedMultiPickListArray.joined(separator: ";"))
        }
       
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
   
    
}

extension DynamicMultiPicklistViewController{
    
    // MARK: UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dynamicMultiPicklistObj.dynamicMultiPickListArray.count
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dynamicMultiPicklistCell", for: indexPath)
        
        if(dynamicMultiPicklistObj.dynamicMultiPickListArray.count > 0){
            
            cell.textLabel?.text = dynamicMultiPicklistObj.dynamicMultiPickListArray[indexPath.row].name
            
        }
        
        if(dynamicMultiPicklistObj.selectedMultiPickListArray.contains((cell.textLabel?.text)!)){
            cell.isSelected = true
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
        }
        else{
            cell.isSelected = false
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        cell.selectionStyle = .none // to prevent cells from being "highlighted"
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedRow = tableView.cellForRow(at: indexPath)
        
        let selectString:String = (selectedRow?.textLabel?.text!)!
        
        if(!dynamicMultiPicklistObj.selectedMultiPickListArray.contains(selectString)){
            dynamicMultiPicklistObj.selectedMultiPickListArray.append(selectString)
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselectedRow = tableView.cellForRow(at: indexPath)
        
        let deselectString:String = (deselectedRow?.textLabel?.text!)!
        
        if(dynamicMultiPicklistObj.selectedMultiPickListArray.contains(deselectString)){
            let indx = dynamicMultiPicklistObj.selectedMultiPickListArray.index(of: deselectString)
            dynamicMultiPicklistObj.selectedMultiPickListArray.remove(at: indx!)
        }
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    
    
    
}

