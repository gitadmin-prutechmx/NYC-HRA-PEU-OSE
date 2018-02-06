//
//  AssignmentLocationUnitHistoryViewController.swift
//  EngageNYC
//
//  Created by Kamal on 14/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class AssignmentLocationUnitNotesDO {
    var assignmentLocUnitId:String!
    var notes:String!
    var unitOutcome:String!
    var canvasserName:String!
    var canvasserId:String!
    var createdDate:String!
}



class AssignmentLocationUnitHistoryViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tblAssignmentLocationUnitHistory: UITableView!
    
    @IBOutlet weak var lblHistory: UILabel!
    
    var viewModel:AssignmentLocationUnitViewModel!
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    var arrAssignmentLocUnitNotesMain = [AssignmentLocationUnitNotesDO]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reloadView()
        // Do any additional setup after loading the view.
    }
    
    func reloadView(){
        
        DispatchQueue.main.async {
            
            self.arrAssignmentLocUnitNotesMain = self.viewModel.getAssignmentLocationUnitNotes(assignmentLocUnitId: self.canvasserTaskDataObject.locationUnitObj.assignmentLocUnitId)
            self.lblHistory.text = "HISTORY (\(self.arrAssignmentLocUnitNotesMain.count))"
            self.tblAssignmentLocationUnitHistory.reloadData()
        }
    }
    

}


extension AssignmentLocationUnitHistoryViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrAssignmentLocUnitNotesMain.count
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell:AssignmentLocationUnitHistoryTableViewCell = self.tblAssignmentLocationUnitHistory.dequeueReusableCell(withIdentifier: "AssignmentLocationUnitHistoryCell") as! AssignmentLocationUnitHistoryTableViewCell!
        
        if(arrAssignmentLocUnitNotesMain.count > 0){
            cell.setupView(forCellObject: arrAssignmentLocUnitNotesMain[indexPath.row], index: indexPath)
            
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
        
    }
}

