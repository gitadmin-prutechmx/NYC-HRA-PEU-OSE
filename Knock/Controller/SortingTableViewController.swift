//
//  SortingTableViewController.swift
//  Knock
//
//  Created by Kamal on 16/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class SortingTableViewController: UITableViewController {

    @IBOutlet weak var assignmentsRdb: UISwitch!
    @IBOutlet weak var assignmentsView: UIView!
    @IBOutlet weak var sortingView: UIView!
    @IBOutlet weak var eventBtn: UIButton!
    @IBOutlet weak var assignmentsBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

         assignmentsView.layer.cornerRadius = 5
         sortingView.layer.cornerRadius = 5
        
        //set selected button properties color
        setSelectedSortingBtn(btn: assignmentsBtn)
        resetSortingBtn(btn: eventBtn)
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setSelectedSortingBtn(btn:UIButton){
       
        btn.backgroundColor = UIColor(red: 0/255, green: 128/255, blue: 255/255, alpha: 1)
        btn.setTitleColor(UIColor.white, for: UIControlState.normal)
        
        btn.layer.borderColor = UIColor.clear.withAlphaComponent(0.5).cgColor
        btn.layer.borderWidth = 0

    }
    
    func resetSortingBtn(btn:UIButton){
        btn.backgroundColor = UIColor.white
        btn.setTitleColor(UIColor.black, for: UIControlState.normal)
        
        btn.layer.borderColor = UIColor.clear.withAlphaComponent(0.5).cgColor
        btn.layer.borderWidth = 0.5
    }

    @IBAction func sortingEvent(_ sender: Any) {
        setSelectedSortingBtn(btn: eventBtn)
        resetSortingBtn(btn: assignmentsBtn)
    }
   
    @IBAction func sortingAssignment(_ sender: Any) {
        setSelectedSortingBtn(btn: assignmentsBtn)
        resetSortingBtn(btn: eventBtn)
    }
}
