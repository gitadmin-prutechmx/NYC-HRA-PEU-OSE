//
//  UnitListingViewController.swift
//  EngageNYC
//
//  Created by Kamal on 12/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit



class LocationUnitDO{
    var locationUnitId:String!
    var unitName:String!
    var assignmentLocUnitId:String!
    var attempted:String = ""
    var contacted:String = ""
    var surveyStatus:String = ""
    var totalContacts:String = "0"
    var syncDate:String = ""
    var surveySyncDate:String = ""
    
    
}

enum UnitListingColoum : Int
{
    
    case unitName = 1
    case totalContacts = 5
    case syncDate = 7
    
    
    func sort(inOrder order : ArrowDirection, main : [LocationUnitDO]) -> [LocationUnitDO] {
        
        switch self {
            
       
        case .unitName:
            if order == .up{
                return main.sorted { $0.unitName.uppercased() > $1.unitName.uppercased() }
            }
            else{
                return main.sorted { $0.unitName.uppercased() < $1.unitName.uppercased() }
            }
        
        
        case .totalContacts:
            if order == .up{
                return main.sorted { $0.totalContacts.uppercased() > $1.totalContacts.uppercased() }
            }
            else{
                return main.sorted { $0.totalContacts.uppercased() < $1.totalContacts.uppercased() }
            }
        case .syncDate:
            if order == .up{
                return main.sorted { $0.syncDate.uppercased() > $1.syncDate.uppercased() }
            }
            else{
                return main.sorted { $0.syncDate.uppercased() < $1.syncDate.uppercased() }
            }
        }
    
    }
}



class UnitListingViewController:BroadcastReceiverViewController,UITableViewDelegate,UITableViewDataSource
{
    
    @IBOutlet weak var tblUnits: UITableView!
    @IBOutlet weak var unitListSearchbar: UISearchBar!
    
    @IBOutlet weak var lblUnits: UILabel!
    var arrLocationUnitsMain = [LocationUnitDO]()
    var arrLocationUnitsFiltered = [LocationUnitDO]()
    var arrLocationUnitsSorted = [LocationUnitDO]()
    var tableHeader : SortingHeaderViewController!
    var surveyVM:SurveyViewModel!
    var viewModel:UnitListingViewModel!
    var searchActive : Bool = false
    var locationUnitVC:LocationUnitViewController!
    
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        
        //Bind Locations data
        self.reloadView()
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let controller = segue.destination as? SortingHeaderViewController
        {
            if segue.identifier == "UnitsHeaderIdentifier"
            {
                tableHeader = controller
                tableHeader.parentVC = self
            }
        }
    }
    override func onReceive(notification: NSNotification) {
        super.onReceive(notification: notification)
        
        if (notification.name.rawValue == SF_NOTIFICATION.UNITLISTING_SYNC.rawValue)
        {
            self.reloadView()
        }
    }
    
    func setupView() {
        
        // Adding notification reciever for Sync
        CustomNotificationCenter.registerReceiver(receiver: self.broadcastReceiver, notificationName: SF_NOTIFICATION.UNITLISTING_SYNC)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.bindView()
        }
    }
    
    func reloadView(){
        DispatchQueue.main.async {
            self.arrLocationUnitsMain = self.viewModel.loadUnits(assignmentId: self.canvasserTaskDataObject.assignmentObj.assignmentId, assignmentLocId: self.canvasserTaskDataObject.locationObj.objMapLocation.assignmentLocId)
            self.sortData(forHeaderIndex: UnitListingColoum.unitName.rawValue, direction: .up)
            
            if let unitlistingHeader = self.viewModel.getUnitListingHeader(){
                self.tableHeader.arrSortingHeader = unitlistingHeader
            }
            self.lblUnits.text = "UNITS (\(self.arrLocationUnitsMain.count))"
           
            self.tblUnits.reloadData()
        }
    }
    
    func sortData(forHeaderIndex index: Int, direction : ArrowDirection) {
        
        if let unitlistingColoumn = UnitListingColoum(rawValue: index){
           
            if(searchActive)
            {
                 self.arrLocationUnitsSorted = unitlistingColoumn.sort(inOrder: direction, main: self.arrLocationUnitsFiltered)
                self.arrLocationUnitsFiltered = self.arrLocationUnitsSorted
            }
            else
                
            {
                 self.arrLocationUnitsSorted = unitlistingColoumn.sort(inOrder: direction, main: self.arrLocationUnitsMain)
                self.arrLocationUnitsMain = self.arrLocationUnitsSorted
                
            }
            tblUnits.reloadData()
        }
    }
}

extension UnitListingViewController{
    func bindView(){
        self.viewModel =  UnitListingViewModel.getViewModel()
    }
}

//Searching locations
extension UnitListingViewController{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        arrLocationUnitsFiltered = arrLocationUnitsSorted.filter {
            
            var isSearch = false
            
            if(searchText != ""){
                isSearch = ($0.unitName.lowercased() as NSString).contains(searchText.lowercased())
            }
            
            return isSearch
            
            
        }
        
        if(arrLocationUnitsFiltered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        
        if(self.arrLocationUnitsFiltered.count > 0){
            self.lblUnits.text = "UNITS (\(self.arrLocationUnitsFiltered.count))"
        }
        else{
            self.lblUnits.text = "UNITS (\(self.arrLocationUnitsSorted.count))"
        }
        self.tblUnits.reloadData()
        
    }
    
}



//extension UnitListingViewController:UpdateUnitListingDelegate{
//    func reloadUnitListing() {
//        self.reloadView()
//    }
//}


extension UnitListingViewController {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(searchActive) {
            return arrLocationUnitsFiltered.count
        }
        
        return self.arrLocationUnitsMain.count
        
        
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UnitsCustomTableViewCell = self.tblUnits.dequeueReusableCell(withIdentifier: "unitListingCell") as! UnitsCustomTableViewCell!
        
        if(searchActive && arrLocationUnitsFiltered.count > 0){
            cell.setupView(forCellObject:arrLocationUnitsFiltered[indexPath.row],index:indexPath)
        }
        else{
            cell.setupView(forCellObject:arrLocationUnitsMain[indexPath.row],index:indexPath)
        }
        
        
        
        return cell
        
        
    }
    
    
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedLocationUnitObj:LocationUnitDO!
        if(searchActive && arrLocationUnitsFiltered.count > 0){
            selectedLocationUnitObj = arrLocationUnitsFiltered[indexPath.row]
        }
        else{
            selectedLocationUnitObj = arrLocationUnitsMain[indexPath.row]
        }
        
        
        if let assignmentLocationUnitVC = AssignmentLocationUnitStoryboard().instantiateViewController(withIdentifier: "AssignmentLocationUnitViewController") as? AssignmentLocationUnitViewController{
            
            canvasserTaskDataObject.contactObj = ContactDataObject(contactId: "")
            canvasserTaskDataObject.locationUnitObj = LocationUnitDataObject(locationUnitId: selectedLocationUnitObj.locationUnitId, locationUnitName: selectedLocationUnitObj.unitName, assignmentLocUnitId: selectedLocationUnitObj.assignmentLocUnitId)
            
            assignmentLocationUnitVC.canvasserTaskDataObject = self.canvasserTaskDataObject
            assignmentLocationUnitVC.isUnitListing = true
            
            let completionHandler:(AssignmentLocationUnitViewController)->Void = { objassignmentLocUnitVC in
                print(objassignmentLocUnitVC)
                
                
                //ToShow Survey
                self.surveyVM = SurveyViewModel.getViewModel()
                
                Utility.initializeSurvey(surveyVM: self.surveyVM, canvasserTaskDataObject: self.canvasserTaskDataObject, vctrl: self.locationUnitVC,contactId:objassignmentLocUnitVC.assignmentLocUnitInfoObj.contactId)
                
                
                
            }
            
            assignmentLocationUnitVC.completionHandler = completionHandler
            
            
            let navigationController = UINavigationController(rootViewController: assignmentLocationUnitVC)
            navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
            self.present(navigationController, animated: true)
        }
        
        
        
    }
    
    
    
    
    
    //                cell.syncDate.text = "12/01/2018 9:00AM"//(arrfilteredTableData[indexPath.row] as! UnitsDataStruct).syncDate
    //
    //               // if((arrfilteredTableData[indexPath.row] as! UnitsDataStruct).syncDate != "")
    //                //{
    //                    cell.sync.image = UIImage(named: "Complete")
    //               // }
    //
    //
    //                //if((arrfilteredTableData[indexPath.row] as! UnitsDataStruct).surveyStatus == "Completed")
    //
    //               // {
    //                    cell.surveyStatus.image = UIImage(named: "Complete")
    //                //}
    //
    
    //
    
    //
    //
    
    //    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
}
