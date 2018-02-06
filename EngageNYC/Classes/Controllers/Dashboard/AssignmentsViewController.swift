//
//  AssignmentsViewController.swift
//  EngageNYC
//
//  Created by Kamal on 07/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class AssignmentDO{
    var eventName:String!
    var assignmentId : String!
    var assignmentName : String!
    var totalLocations : String!
    var totalUnits : String!
    var totalContacts:String!
    var completePercent : String!
    var assignmentStatus:String!
    
    var completedDate:NSDate?
    var assignedDate:NSDate?
}

enum AssignmentColoum : Int
{
    
    case eventName = 1
    case assignmentName
    case totalLocations
    case completePercent
    case totalUnits
    case totalContacts
    
    
    func sort(inOrder order : ArrowDirection, main : [AssignmentDO]) -> [AssignmentDO] {
        
        switch self {
            
        case .eventName:
            if order == .up
            {
                return main.sorted { $0.eventName.uppercased() > $1.eventName.uppercased() }
            }
            else
            {
                return main.sorted { $0.eventName.uppercased() < $1.eventName.uppercased() }
            }
        case .assignmentName:
            if order == .up{
                return main.sorted { $0.assignmentName.uppercased() > $1.assignmentName.uppercased() }
            }
            else{
                return main.sorted { $0.assignmentName.uppercased() < $1.assignmentName.uppercased() }
            }
            
        case .totalLocations:
            if order == .up{
                return main.sorted { $0.totalLocations.uppercased() > $1.totalLocations.uppercased() }
            }
            else{
                return main.sorted { $0.totalLocations.uppercased() < $1.totalLocations.uppercased() }
            }
        case .totalUnits:
            if order == .up{
                return main.sorted { $0.totalUnits.uppercased() > $1.totalUnits.uppercased() }
            }
            else{
                return main.sorted { $0.totalUnits.uppercased() < $1.totalUnits.uppercased() }
            }
        case .completePercent:
            if order == .up{
                return main.sorted { $0.completePercent.uppercased() > $1.completePercent.uppercased() }
            }
            else{
                return main.sorted { $0.completePercent.uppercased() < $1.completePercent.uppercased() }
            }
        case .totalContacts:
            if order == .up{
                return main.sorted { $0.totalContacts.uppercased() > $1.totalContacts.uppercased() }
            }
            else{
                return main.sorted { $0.totalContacts.uppercased() < $1.totalContacts.uppercased() }
            }
            
        }
        
    }
    
    
}

class AssignmentsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    var dashboardInfo : DashboardInfo?{
        didSet{
            self.reloadView()
        }
    }
    
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    
    @IBOutlet weak var showHideCompleteAssignmentSwitch: UISwitch!
    @IBOutlet weak var lblAssignment: UILabel!
    @IBOutlet weak var tblAssignments: UITableView!
    var viewModel: DashboardViewModel!
    
    var arrAssignmentsMain = [AssignmentDO]()
    var arrAssignmentsSorted = [AssignmentDO]()
    var arrAssignmentsOrig = [AssignmentDO]()
    var tableHeader : SortingHeaderViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindView()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let controller = segue.destination as? SortingHeaderViewController
        {
            if segue.identifier == "assignmentHeaderIdentifier"
            {
                tableHeader = controller
                tableHeader.parentVC = self
            }
        }
    }
    func reloadView(){
        
        DispatchQueue.main.async {
            guard let info = self.dashboardInfo else { return }
            self.arrAssignmentsMain = info.arrAssignments
            
            self.sortData(forHeaderIndex: AssignmentColoum.eventName.rawValue, direction: .up)
            
            if let assignmentHeader = self.viewModel.getAssignmentHeader(){
                self.tableHeader.arrSortingHeader = assignmentHeader
            }
            self.lblAssignment.text = "ASSIGNMENTS (\(self.arrAssignmentsSorted.count))"
            self.tblAssignments.reloadData()
        }
    }
    
    
    @IBAction func switchCompletedAssignmentsPressed(_ sender: Any) {
        
        if(showHideCompleteAssignmentSwitch.isOn == false){
            
            self.arrAssignmentsSorted = self.arrAssignmentsOrig.filter({ (assigmnment) -> Bool in
                return assigmnment.assignmentStatus != "Completed"
            })
            
        }
        else{
            
            self.arrAssignmentsSorted = self.arrAssignmentsOrig
            
        }
        
        self.lblAssignment.text = "ASSIGNMENTS (\(self.arrAssignmentsSorted.count))"
        tblAssignments.reloadData()
        
    }
    
    func sortData(forHeaderIndex index: Int, direction : ArrowDirection) {
        
        if let assignmentColoumn = AssignmentColoum(rawValue: index){
            self.arrAssignmentsSorted = assignmentColoumn.sort(inOrder: direction, main: self.arrAssignmentsMain)
            
            self.arrAssignmentsOrig = self.arrAssignmentsSorted
            
            if(showHideCompleteAssignmentSwitch.isOn == false){
                
                self.arrAssignmentsSorted = self.arrAssignmentsOrig.filter({ (assigmnment) -> Bool in
                    return assigmnment.assignmentStatus != "Completed"
                })
                
            }
            tblAssignments.reloadData()
        }
    }
    
    @IBAction func UnwindBackToDashboard(segue:UIStoryboardSegue) {
        print("UnwindBackToDashboard")
    }
    
}



extension AssignmentsViewController {
    
    // MARK: UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrAssignmentsSorted.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "assignmentCell", for: indexPath) as! AssignmentTableViewCell
        
        if(arrAssignmentsSorted.count > 0){
            cell.setupView(forCellObject: arrAssignmentsSorted[indexPath.row], index: indexPath)
        }
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        //  canvasserTaskDataObject = CanvasserTaskDataObject()
        canvasserTaskDataObject.assignmentObj = AssignmentDataObject(assignmentId: arrAssignmentsSorted[indexPath.row].assignmentId, assignmentName: arrAssignmentsSorted[indexPath.row].assignmentName)
        
        
        if let mapLocationVC = MapLocationStoryboard().instantiateViewController(withIdentifier: "MapLocationViewController") as? MapLocationViewController
        {
            mapLocationVC.canvasserTaskDataObject = canvasserTaskDataObject
            mapLocationVC.modalPresentationStyle = UIModalPresentationStyle.formSheet
            self.navigationController?.pushViewController(mapLocationVC, animated: true)
        }
        
    }
    
}
extension AssignmentsViewController
{
    func bindView(){
        self.viewModel = DashboardViewModel.getViewModel()
    }
}

