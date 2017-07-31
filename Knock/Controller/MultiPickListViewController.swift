//
//  MultiPickListViewController.swift
//  TestApplication
//
//  Created by Kamal on 30/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class MultiPickListViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate
{
    
    var multiPickListProtocol:MultiPickListProtocol?
    
    var selectedMultiPickListValue:String = ""
    
    var multiPicklistStr:String = ""
    
    
    
    var multiPickListArray: [String]!
    var selectedMultiPickListArray: [String]!
    
    
    
    @IBOutlet weak var multiPickListTblView: UITableView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        multiPickListTblView.allowsMultipleSelection = true
        
        populatePickList()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        multiPickListProtocol?.getMultiPickListValue(multiPickListValue: selectedMultiPickListArray.joined(separator: ","))
        
       
        
    }
    
    func populatePickList(){
        
        multiPickListArray = []
        selectedMultiPickListArray = []
        
        if(multiPicklistStr != ""){
            multiPickListArray = String(multiPicklistStr.characters.dropLast()).components(separatedBy: ";")
        }
        
       
        
        if(selectedMultiPickListValue != ""){
            selectedMultiPickListArray = String(selectedMultiPickListValue).components(separatedBy: ",")
            
        }
       
        
        self.multiPickListTblView.reloadData()
        
    }
    
    
    // MARK: - table view methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.multiPickListArray.count
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
        
        
        
        cell.textLabel?.text = multiPickListArray[indexPath.row]
        
        //  cell.accessoryType = cell.isSelected ? .checkmark : .none
        
        if(selectedMultiPickListArray.contains((cell.textLabel?.text)!)){
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
        
        if(!selectedMultiPickListArray.contains(selectString)){
            selectedMultiPickListArray.append(selectString)
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }

      
        
    }
    
     func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselectedRow = tableView.cellForRow(at: indexPath)
        
        let deselectString:String = (deselectedRow?.textLabel?.text!)!
        
        if(selectedMultiPickListArray.contains(deselectString)){
            let indx = selectedMultiPickListArray.index(of: deselectString)
            selectedMultiPickListArray.remove(at: indx!)
        }
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}

