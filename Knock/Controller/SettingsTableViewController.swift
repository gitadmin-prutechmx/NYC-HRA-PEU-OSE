//
//  SettingsTableViewController.swift
//  Knock
//
//  Created by Kamal on 12/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var syncTimeView: UIView!
    @IBOutlet weak var syncTimeLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        syncTimeView.layer.cornerRadius = 5
        
       

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func syncTimeSlider(_ sender: UISlider) {
        
        let currentValue = Int(sender.value)
        syncTimeLbl.text = "\(currentValue)"
    }
  
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func save(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
