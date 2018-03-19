//
//  AssignmentLocationHistoryViewController.swift
//  EngageNYC
//
//  Created by Kamal on 13/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class AssignmentLocationNotesDO {
    var assignmentLocId:String!
    var notes:String!
    var locStatus:String!
    var canvasserName:String!
    var canvasserId:String!
    var createdDate:String!
}

class AssignmentLocationHistoryViewController: UIViewController,UITableViewDelegate,UITableViewDataSource
{
    @IBOutlet weak var tblAssignmentLocationHistory: UITableView!
    
    @IBOutlet weak var lblHistory: UILabel!
    var viewModel:AssignmentLocationViewModel!
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    
    var arrAssignmentLocNotesMain = [AssignmentLocationNotesDO]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.reloadView()
        // Do any additional setup after loading the view.
    }
    
    func reloadView(){
        
        DispatchQueue.main.async {
            
            self.arrAssignmentLocNotesMain = self.viewModel.getAssignmentLocationNotes(assignmentLocId: self.canvasserTaskDataObject.locationObj.objMapLocation.assignmentLocId)
           self.lblHistory.text = "HISTORY (\(self.arrAssignmentLocNotesMain.count))"
            self.tblAssignmentLocationHistory.reloadData()
        }
    }
    

   
}

extension AssignmentLocationHistoryViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrAssignmentLocNotesMain.count
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell:AssignmentLocationHistoryTableViewCell = self.tblAssignmentLocationHistory.dequeueReusableCell(withIdentifier: "AssignmentLocationHistoryCell") as! AssignmentLocationHistoryTableViewCell!
        
        if(arrAssignmentLocNotesMain.count > 0){
            cell.setupView(forCellObject: arrAssignmentLocNotesMain[indexPath.row], index: indexPath)
            
        }
       
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let alertCtrl = Alert.showUIAlert(title: "Notes", message: arrAssignmentLocNotesMain[indexPath.row].notes, vc: self)
        
        let notesAction: UIAlertAction = UIAlertAction(title: "Close", style: .cancel)
        { action -> Void in
            
        }
        
        alertCtrl.addAction(notesAction)
    }
}
