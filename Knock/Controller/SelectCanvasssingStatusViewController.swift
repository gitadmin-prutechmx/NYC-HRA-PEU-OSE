//
//  SelectStatusViewController.swift
//  Knock
//
//  Created by Cloudzeg Laptop on 7/9/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class SelectCanvasssingStatusViewController: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    
    var canvassingStatusProtocol:canvassingStatusProtocol?
    var selectedCanvassingStatus:String = ""
    
    @IBOutlet weak var tblSelectStatus: UITableView!

    var statusArray: [String]!
    
   
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        //self.navigationController?.isNavigationBarHidden = false
    }
    

    override func viewDidLoad()
    {
        super.viewDidLoad()

          statusArray = ["Blocked","Planned","In Progress","Completed"]
    }
    
    
    
   
    // MARK: - table view methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
          return self.statusArray.count
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
        
        
           cell.textLabel?.text = statusArray[indexPath.row]
        
            if(selectedCanvassingStatus ==  cell.textLabel?.text){
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
       
        
        canvassingStatusProtocol?.getCanvasssingStatus(strCanvassingStatus: statusArray[indexPath.row])
        
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
