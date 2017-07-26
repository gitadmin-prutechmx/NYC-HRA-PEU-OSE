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
    @IBOutlet weak var dateBtn: UIButton!
    
    //private property to store selection action for table cell
    private var showHideCompletedAssignments:((Bool) -> Void)!
    
    //private property to store selection action for table cell
    private var sortingEventAssignments:((String,Bool) -> Void)!
    
    //executed when UISwitch on or off
    func setShowHideCompletedAssignments(_ action : @escaping ((Bool) -> Void)) {
        self.showHideCompletedAssignments = action
    }
    
    //executed when sorting
    func setSortingEventAssignments(_ action : @escaping ((String,Bool) -> Void)) {
        self.sortingEventAssignments = action
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        assignmentsView.layer.cornerRadius = 5
        sortingView.layer.cornerRadius = 5
        
        SortingButton.resetButtonImage(btn: eventBtn)
        SortingButton.resetButtonImage(btn: assignmentsBtn)
        SortingButton.resetButtonImage(btn: dateBtn)

        
        
        if(Utilities.currentShowHideAssignments){
            assignmentsRdb.isOn = true
        }
        else{
            assignmentsRdb.isOn = false
        }
        
        if(Utilities.currentSortingFieldName == "Assignment"){
            SortingButton.setSelectedSortingBtn(btn: assignmentsBtn)
            
            SortingButton.resetSortingBtn(btn: eventBtn)
            SortingButton.resetSortingBtn(btn: dateBtn)
            
            SortingButton.setSortingType(btn: assignmentsBtn,type:Utilities.currentSortingTypeAscending)
            
        }
        else if(Utilities.currentSortingFieldName == "Event"){
            SortingButton.setSelectedSortingBtn(btn: eventBtn)
            
            SortingButton.resetSortingBtn(btn: assignmentsBtn)
            SortingButton.resetSortingBtn(btn: dateBtn)
            
            SortingButton.setSortingType(btn: eventBtn,type:Utilities.currentSortingTypeAscending)
            
        }
        else {
            SortingButton.setSelectedSortingBtn(btn: dateBtn)
            
            SortingButton.resetSortingBtn(btn: assignmentsBtn)
            SortingButton.resetSortingBtn(btn: eventBtn)
            
            SortingButton.setSortingType(btn: dateBtn,type:Utilities.currentSortingTypeAscending)
            
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func completedAssignmentAction(_ sender: Any) {
        
        //execute the closure if it exists
        if self.showHideCompletedAssignments != nil {
            self.showHideCompletedAssignments(assignmentsRdb.isOn)
        }
        
        
    }
    
    @IBAction func sortingEvent(_ sender: Any) {
        
        SortingButton.setSelectedSortingBtn(btn: eventBtn)
        
        SortingButton.resetSortingBtn(btn: assignmentsBtn)
        SortingButton.resetSortingBtn(btn: dateBtn)
        
        SortingButton.setSortingType(btn:eventBtn)
        
        //execute the closure if it exists
        if self.sortingEventAssignments != nil {
            self.sortingEventAssignments("Event",SortingButton.getSortingType(btn: eventBtn))
        }
        
        
    }
    @IBAction func sortingDate(_ sender: Any) {
        SortingButton.setSelectedSortingBtn(btn: dateBtn)
        
        SortingButton.resetSortingBtn(btn: eventBtn)
        SortingButton.resetSortingBtn(btn: assignmentsBtn)
        
        SortingButton.setSortingType(btn:dateBtn)
        
        //execute the closure if it exists
        if self.sortingEventAssignments != nil {
            self.sortingEventAssignments("Date",SortingButton.getSortingType(btn: dateBtn))
        }
    }
    
    @IBAction func sortingAssignment(_ sender: Any) {
        SortingButton.setSelectedSortingBtn(btn: assignmentsBtn)
        
        SortingButton.resetSortingBtn(btn: eventBtn)
        SortingButton.resetSortingBtn(btn: dateBtn)
        
        SortingButton.setSortingType(btn:assignmentsBtn)
        
        //execute the closure if it exists
        if self.sortingEventAssignments != nil {
            self.sortingEventAssignments("Assignment",SortingButton.getSortingType(btn: assignmentsBtn))
        }
    }
}
