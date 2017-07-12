//
//  SelectReasonStatusViewController.swift
//  Knock
//
//  Created by Kamal on 11/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class SelectReasonStatusViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var reasonStatusProtocol:ReasonStatusProtocol?
    var selectedReasonStatus:String = ""
    
    
    
    var reasonStatusArray: [String]!
    
 
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        reasonStatusArray =  ["No Issues","Refused","Not Primary Tenant","Superintendent Door","Landlords Door","Privacy Concern","Left Contact Info","Laguage Barrier"]
    }
    
    
    
    
    // MARK: - table view methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.reasonStatusArray.count
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        
        cell.textLabel?.text = reasonStatusArray[indexPath.row]
        
        if(selectedReasonStatus ==  cell.textLabel?.text){
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
        
        
        reasonStatusProtocol?.getReasonStatus(strReasonStatus: reasonStatusArray[indexPath.row])
        
        self.navigationController?.popViewController(animated: true);
        
        //         let viewController = self.storyboard!.instantiateViewController(withIdentifier: "editLocationIdentifier") as? EditLocationViewController
        //
        //        var selectedItem = indexPath
        //        viewController?.strStatus = statusArray[selectedItem.row]
        //
        //        self.navigationController?.pushViewController(viewController!, animated: true)
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
}



}
