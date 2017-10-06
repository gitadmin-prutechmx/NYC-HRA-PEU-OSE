//
//  UnitSortingViewController.swift
//  Knock
//
//  Created by Kamal on 26/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class UnitSortingViewController: UITableViewController {

    @IBOutlet weak var unitSortingView: UIView!
    
    @IBOutlet weak var unitBtn: UIButton!
    
    @IBOutlet weak var firstName: UIButton!
    
    @IBOutlet weak var lastName: UIButton!
    
    //private property to store selection action for table cell
    private var sortingUnitClient:((String,Bool) -> Void)!
    
  
    //executed when sorting
    func setSortingUnitClient(_ action : @escaping ((String,Bool) -> Void)) {
        self.sortingUnitClient = action
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        unitSortingView.layer.cornerRadius = 5
       
        SortingButton.resetButtonImage(btn: unitBtn)
        SortingButton.resetButtonImage(btn: firstName)
        SortingButton.resetButtonImage(btn: lastName)
        
        
        if(Utilities.currentUnitClientPage == "Unit"){
            
            sortDefaultUnitBtn()
            unitBtn.isHidden = false
            firstName.isHidden = true
            lastName.isHidden = true
        }
        else{
            
            unitBtn.isHidden = false
            firstName.isHidden = false
            lastName.isHidden = false

            if(Utilities.currentClientSortingFieldName == "UnitName"){
                
                sortDefaultUnitBtn()
                
            }
                
            else if(Utilities.currentClientSortingFieldName == "FirstName"){
                
                sortDefaultFirstName()
                
            }
                
            else {
                
                sortDefaultLastName()
                
            }
            

        }
     
        
        
        
    }
    
    func sortDefaultUnitBtn(){
        
        SortingButton.setSelectedSortingBtn(btn: unitBtn)
        
        SortingButton.resetSortingBtn(btn: firstName)
        SortingButton.resetSortingBtn(btn: lastName)
        
        if(Utilities.currentUnitClientPage == "Unit"){
            
           SortingButton.setSortingType(btn: unitBtn,type:Utilities.currentUnitSortingTypeAscending)
        }
        else{
            
            SortingButton.setSortingType(btn: unitBtn,type:Utilities.currentClientSortingTypeAscending)
        }
    }
    
    func sortDefaultFirstName(){
        SortingButton.setSelectedSortingBtn(btn: firstName)
        
        SortingButton.resetSortingBtn(btn: lastName)
        SortingButton.resetSortingBtn(btn: unitBtn)
        
        if(Utilities.currentUnitClientPage == "Unit"){
            
            SortingButton.setSortingType(btn: unitBtn,type:Utilities.currentUnitSortingTypeAscending)
        }
        else{
            
            SortingButton.setSortingType(btn: unitBtn,type:Utilities.currentClientSortingTypeAscending)
        }
        
        
    }
    
    func sortDefaultLastName(){
        SortingButton.setSelectedSortingBtn(btn: lastName)
        
        SortingButton.resetSortingBtn(btn: firstName)
        SortingButton.resetSortingBtn(btn: unitBtn)
        
        if(Utilities.currentUnitClientPage == "Unit"){
            
            SortingButton.setSortingType(btn: unitBtn,type:Utilities.currentUnitSortingTypeAscending)
        }
        else{
            
            SortingButton.setSortingType(btn: unitBtn,type:Utilities.currentClientSortingTypeAscending)
        }
        

    }

  
    @IBAction func unitNameAction(_ sender: Any) {
        
        SortingButton.setSelectedSortingBtn(btn: unitBtn)
        
        SortingButton.resetSortingBtn(btn: firstName)
        SortingButton.resetSortingBtn(btn: lastName)
        
        SortingButton.setSortingType(btn:unitBtn)
        
        //execute the closure if it exists
        if self.sortingUnitClient != nil {
            self.sortingUnitClient("UnitName",SortingButton.getSortingType(btn: unitBtn))
        }
    }
    
    @IBAction func firstNameAction(_ sender: Any) {
        SortingButton.setSelectedSortingBtn(btn: firstName)
        
        SortingButton.resetSortingBtn(btn: unitBtn)
        SortingButton.resetSortingBtn(btn: lastName)
        
        SortingButton.setSortingType(btn:firstName)
        
        //execute the closure if it exists
        if self.sortingUnitClient != nil {
            self.sortingUnitClient("FirstName",SortingButton.getSortingType(btn: firstName))
        }
    }
    
    @IBAction func lastNameAction(_ sender: Any) {
        SortingButton.setSelectedSortingBtn(btn: lastName)
        
        SortingButton.resetSortingBtn(btn: firstName)
        SortingButton.resetSortingBtn(btn: unitBtn)
        
        SortingButton.setSortingType(btn:lastName)
        
        //execute the closure if it exists
        if self.sortingUnitClient != nil {
            self.sortingUnitClient("LastName",SortingButton.getSortingType(btn: lastName))
        }
    }
    

}
