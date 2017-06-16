//
//  SideMenuViewController.swift
//  MTXGIS
//
//  Created by Kamal on 24/02/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class SideMenuViewController: UITableViewController {

    @IBOutlet var sideMenuTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        
       /* let image = UIImage(named: "Welcomebg")
        
        self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)*/
        
        


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /* self.navigationController!.navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 80.0)*/
        
        /*let height: CGFloat = 45 //whatever height you want
        
        let bounds = self.navigationController!.navigationBar.bounds
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + height)*/
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   

}

// MARK: - UITableViewDataSource methods

extension SideMenuViewController {
    
   
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    
   
    
}

