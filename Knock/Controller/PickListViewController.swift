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
    
    
    
    var pickListArray: [String]!
    
    @IBOutlet weak var pickListTblView: UITableView!
   
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        populatePickList()
        
        
    }
    
    func populatePickList(){
   
        if(picklistStr != ""){
            
            
            pickListArray = String(picklistStr.characters.dropLast()).components(separatedBy: ";")
        }
        
        self.pickListTblView.reloadData()

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
        
        
        
        cell.textLabel?.text = pickListArray[indexPath.row]
        
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
        
        
        pickListProtocol?.getPickListValue(pickListValue: pickListArray[indexPath.row])
        
        self.navigationController?.popViewController(animated: true);
        
      
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}



