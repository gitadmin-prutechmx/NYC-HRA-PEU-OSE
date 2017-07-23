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
        
        resetButtonImage()
        
        if(Utilities.currentShowHideAssignments){
            assignmentsRdb.isOn = true
        }
        else{
            assignmentsRdb.isOn = false
        }
        
        if(Utilities.currentSortingFieldName == "Assignment"){
            setSelectedSortingBtn(btn: assignmentsBtn)
            
            resetSortingBtn(btn: eventBtn)
            resetSortingBtn(btn: dateBtn)
            
            setSortingType(btn: assignmentsBtn,type:Utilities.currentSortingTypeAscending)
            
        }
        else if(Utilities.currentSortingFieldName == "Event"){
            setSelectedSortingBtn(btn: eventBtn)
            
            resetSortingBtn(btn: assignmentsBtn)
            resetSortingBtn(btn: dateBtn)
            
            setSortingType(btn: eventBtn,type:Utilities.currentSortingTypeAscending)
            
        }
        else {
            setSelectedSortingBtn(btn: dateBtn)
            
            resetSortingBtn(btn: assignmentsBtn)
            resetSortingBtn(btn: eventBtn)
            
            setSortingType(btn: dateBtn,type:Utilities.currentSortingTypeAscending)
            
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
        
        btn.setImage(nil, for: .normal)
    }
    
    func resetButtonImage(){
        eventBtn.setImage(nil, for: .normal)
        assignmentsBtn.setImage(nil, for: .normal)
        dateBtn.setImage(nil, for: .normal)
        
    }
    
    
    
    func getSortingType(btn:UIButton)->Bool{
        
        if let currentBtnImg =  btn.currentImage{
            
            if(currentBtnImg == UIImage(named: "SortingUp.png")){
                
                return true
            }
            else{
                return false
            }
        }
        else{
            return false
        }
        
    }
    
    
    
    //assignments arrow set
    //selected radio button and assignments when show popup show
    // sorting baseed on assignments
    //insets set reset of title and image
    
    func setSortingType(btn:UIButton,type:Bool? = true){
        
        if let currentBtnImg =  btn.currentImage{
            
            if(currentBtnImg == UIImage(named: "SortingUp.png")){
                
                if let image = UIImage(named: "SortingDown.png") {
                    btn.setImage(image, for: .normal)
                    btn.tintColor = UIColor.white
                    
                }
            }
            else{
                if let image = UIImage(named: "SortingUp.png") {
                    btn.setImage(image, for: .normal)
                    btn.tintColor = UIColor.white
                }
            }
        }
        else{
            if(type == true){
                if let image = UIImage(named: "SortingUp.png") {
                    btn.setImage(image, for: .normal)
                    btn.tintColor = UIColor.white
                }
            }
            else{
                if let image = UIImage(named: "SortingDown.png") {
                    btn.setImage(image, for: .normal)
                    btn.tintColor = UIColor.white
                }
            }
        }
        
        
        
        
    }
    
    @IBAction func sortingEvent(_ sender: Any) {
        
        setSelectedSortingBtn(btn: eventBtn)
        
        resetSortingBtn(btn: assignmentsBtn)
        resetSortingBtn(btn: dateBtn)
        
        setSortingType(btn:eventBtn)
        
        //execute the closure if it exists
        if self.sortingEventAssignments != nil {
            self.sortingEventAssignments("Event",getSortingType(btn: eventBtn))
        }
        
        
    }
    @IBAction func sortingDate(_ sender: Any) {
        setSelectedSortingBtn(btn: dateBtn)
        
        resetSortingBtn(btn: eventBtn)
        resetSortingBtn(btn: assignmentsBtn)
        
        setSortingType(btn:dateBtn)
        
        //execute the closure if it exists
        if self.sortingEventAssignments != nil {
            self.sortingEventAssignments("Date",getSortingType(btn: dateBtn))
        }
    }
    
    @IBAction func sortingAssignment(_ sender: Any) {
        setSelectedSortingBtn(btn: assignmentsBtn)
        
        resetSortingBtn(btn: eventBtn)
        resetSortingBtn(btn: dateBtn)
        
        setSortingType(btn:assignmentsBtn)
        
        //execute the closure if it exists
        if self.sortingEventAssignments != nil {
            self.sortingEventAssignments("Assignment",getSortingType(btn: assignmentsBtn))
        }
    }
}
