//
//  ClientListingViewController.swift
//  EngageNYC
//
//  Created by Kamal on 12/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class ContactDO{
    var contactId:String!
    var contactName:String = ""
    var firstName:String = ""
    var middleName:String = ""
    var lastName:String = ""
    var unit:String = ""
    var totalCases:String!
    var phone:String = ""
    var suffix:String = ""
    var email:String = ""
    var dob:String = ""
    
    var age:String = ""
    
    var syncDate:String = ""
    
    var streetNum:String = ""
    var streetName:String = ""
    var borough:String = ""
    var zip:String = ""
    var aptNo:String = ""
    var floor:String = ""
    
    var iOSContactId:String!
    
    var actionStatus:String = ""
    
    var locationUnitId:String!
    var assignmentLocUnitId:String!
    var assignmentId:String!
    var assignmentLocId:String!
    
    var createdById:String!
    var openCases:Int!
    
    init(){
        self.openCases = 0
        self.totalCases = "0"
        self.createdById = ""
    }

}

enum ClientListingColoum : Int
{
    
    case firstName = 1
    case lastName
    case unit
    case phone
    case totalCases
    case syncdate = 7
    
    
    func sort(inOrder order : ArrowDirection, main : [ContactDO]) -> [ContactDO] {
        
        switch self {
            
            
        case .firstName:
            if order == .up{
                return main.sorted { $0.firstName.uppercased() > $1.firstName.uppercased() }
            }
            else{
                return main.sorted { $0.firstName.uppercased() < $1.firstName.uppercased() }
            }
            
            
        case .lastName:
            if order == .up{
                return main.sorted { $0.lastName.uppercased() > $1.lastName.uppercased() }
            }
            else{
                return main.sorted { $0.lastName.uppercased() < $1.lastName.uppercased() }
            }
        case .unit:
            if order == .up{
                return main.sorted { $0.unit.uppercased() > $1.unit.uppercased() }
            }
            else{
                return main.sorted { $0.unit.uppercased() < $1.unit.uppercased() }
            }
        case .phone:
            if order == .up{
                return main.sorted { $0.phone.uppercased() > $1.phone.uppercased() }
            }
            else{
                return main.sorted { $0.phone.uppercased() < $1.phone.uppercased() }
            }
        case .totalCases:
            if order == .up{
                return main.sorted { $0.totalCases.uppercased() > $1.totalCases.uppercased() }
            }
            else{
                return main.sorted { $0.totalCases.uppercased() < $1.totalCases.uppercased() }
            }
        case .syncdate:
            if order == .up{
                return main.sorted { $0.syncDate.uppercased() > $1.syncDate.uppercased() }
            }
            else{
                return main.sorted { $0.syncDate.uppercased() < $1.syncDate.uppercased() }
            }
        }
        
    }
}



class ClientListingViewController: BroadcastReceiverViewController,UITableViewDelegate,UITableViewDataSource
{
    
    @IBOutlet weak var tblClients: UITableView!
    var arrContactsMain = [ContactDO]()
    var arrContactsFiltered =  [ContactDO]()
    var arrContactsSorted = [ContactDO]()
    var tableHeader : SortingHeaderViewController!
    var surveyVM:SurveyViewModel!
    var viewModel:ClientListingViewModel!
    var searchActive : Bool = false
    
    @IBOutlet weak var clientSearchBar: UISearchBar!
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    
    @IBOutlet weak var lblClients: UILabel!
    
    var locationUnitVC:LocationUnitViewController!
    
    var sortDirection: ArrowDirection!
    var isLoadingFirstTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        
        sortDirection = .up
        
        //Bind Clients data
        self.reloadView()
        
    }
    
    override func onReceive(notification: NSNotification) {
        super.onReceive(notification: notification)
        
        if (notification.name.rawValue == SF_NOTIFICATION.CLIENTLISTING_SYNC.rawValue)
        {
            self.reloadView()
        }
    }
    
    func setupView() {
        
        // Adding notification reciever for Sync
        CustomNotificationCenter.registerReceiver(receiver: self.broadcastReceiver, notificationName: SF_NOTIFICATION.CLIENTLISTING_SYNC)
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.bindView()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let controller = segue.destination as? SortingHeaderViewController
        {
            if segue.identifier == "ClientsHeaderIdentifier"
            {
                tableHeader = controller
                tableHeader.parentVC = self
            }
        }
    }
    func reloadView(){
        DispatchQueue.main.async {
            
            self.arrContactsMain = self.viewModel.loadContacts(assignmentId: self.canvasserTaskDataObject.assignmentObj.assignmentId, assignmentLocId: self.canvasserTaskDataObject.locationObj.objMapLocation.assignmentLocId)
            if self.searchActive {
                 if let clientlistingColoumn = ClientListingColoum(rawValue: ClientListingColoum.firstName.rawValue)
                 {
                    self.arrContactsSorted = clientlistingColoumn.sort(inOrder: self.sortDirection, main: self.arrContactsMain)
                    
                    self.filterContactForSearchedText(searchText: self.clientSearchBar.text!)
                    self.lblClients.text = "CLIENTS (\(self.arrContactsFiltered.count))"
                }
            } else {
                self.sortData(forHeaderIndex: ClientListingColoum.firstName.rawValue, direction: self.sortDirection)
                self.lblClients.text = "CLIENTS (\(self.arrContactsSorted.count))"
            }
            
            if  self.isLoadingFirstTime{
                self.isLoadingFirstTime = false
                if let clientlistingHeader = self.viewModel.getClientListingHeader(){
                    self.tableHeader.arrSortingHeader = clientlistingHeader
                }
            }
            
            self.tblClients.reloadData()
        }
    }
    
    func sortData(forHeaderIndex index: Int, direction : ArrowDirection) {
        
        if let clientlistingColoumn = ClientListingColoum(rawValue: index){
            
            if(searchActive)
            {
                self.arrContactsSorted = clientlistingColoumn.sort(inOrder: direction, main: self.arrContactsFiltered)
                self.arrContactsFiltered = self.arrContactsSorted
            }
            else
                
            {
                self.arrContactsSorted = clientlistingColoumn.sort(inOrder: direction, main: self.arrContactsMain)
                //self.arrContactsMain = self.arrContactsSorted
                
            }
            tblClients.reloadData()
        }
    }


    
    @IBAction func btnEditPressed(_ sender: Any) {
        
        let indexRow = (sender as AnyObject).tag
        var selectedContactObj:ContactDO  = ContactDO()
        
        if(searchActive && arrContactsFiltered.count > 0){
            selectedContactObj =  arrContactsFiltered[indexRow!]
        }
        else{
            selectedContactObj =  arrContactsSorted[indexRow!]
        }
        
        if selectedContactObj.createdById == nil{
            selectedContactObj.createdById = ""
        }
        
        if let noOfOpenCases = selectedContactObj.openCases , noOfOpenCases > 0 && canvasserTaskDataObject.userObj.userId !=  selectedContactObj.createdById && !selectedContactObj.createdById.isEmpty  {
            
            self.view.makeToast("This client already have open cases so you can't edit it.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
            }
            
        }
        else{
            
            if let clientInfoVC = ClientInfoStoryboard().instantiateViewController(withIdentifier: "ClientInfoViewController") as? ClientInfoViewController{
                
                clientInfoVC.canvasserTaskDataObject = canvasserTaskDataObject
                clientInfoVC.objContact = selectedContactObj
                let navigationController = UINavigationController(rootViewController: clientInfoVC)
                navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
                self.present(navigationController, animated: true)
            }
            
        }

      
    }
    
}

extension ClientListingViewController{
    func bindView(){
        self.viewModel =  ClientListingViewModel.getViewModel()
    }
}

//Searching locations
extension ClientListingViewController{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
       // searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
       // searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
       // searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       // searchActive = false;
    }
    
    func filterContactForSearchedText(searchText: String) {
        arrContactsFiltered = arrContactsSorted.filter {
            
            var isSearch = false
            
            if(searchText != ""){
                isSearch = ($0.contactName.lowercased() as NSString).contains(searchText.lowercased())
            }
            
            return isSearch
            
            
        }
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filterContactForSearchedText(searchText: searchText)
        
        if(arrContactsFiltered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        
        if(self.arrContactsFiltered.count > 0){
            self.lblClients.text = "CLIENTS (\(self.arrContactsFiltered.count))"
        }
        else{
            self.lblClients.text = "CLIENTS (\(self.arrContactsSorted.count))"
        }
        self.tblClients.reloadData()
        
    }
    
}



extension ClientListingViewController {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(searchActive) {
            return arrContactsFiltered.count
        }
        
        return arrContactsSorted.count
        
        
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ClientCustomTableViewCell = self.tblClients.dequeueReusableCell(withIdentifier: "clientListingCell") as! ClientCustomTableViewCell!
        
        if(searchActive && arrContactsFiltered.count > 0){
            cell.setupView(forCellObject:arrContactsFiltered[indexPath.row],index:indexPath)
        }
        else{
            cell.setupView(forCellObject:arrContactsSorted[indexPath.row],index:indexPath)
        }
        
        
        
        return cell
        
        
    }
    
    
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selected, so set textField to relevant value, hide tableView
        // endEditing can trigger some other action according to requirements
        
        let selectedContactObj:ContactDO!
        if(searchActive && arrContactsFiltered.count > 0){
            selectedContactObj = arrContactsFiltered[indexPath.row]
        }
        else{
            selectedContactObj = arrContactsSorted[indexPath.row]
        }
        
        
        if let assignmentLocationUnitVC = AssignmentLocationUnitStoryboard().instantiateViewController(withIdentifier: "AssignmentLocationUnitViewController") as? AssignmentLocationUnitViewController{
            
            canvasserTaskDataObject.contactObj = ContactDataObject(contactId: selectedContactObj.contactId)
            canvasserTaskDataObject.locationUnitObj = LocationUnitDataObject(locationUnitId: selectedContactObj.locationUnitId, locationUnitName: selectedContactObj.unit, assignmentLocUnitId: selectedContactObj.assignmentLocUnitId)
            
            assignmentLocationUnitVC.canvasserTaskDataObject = self.canvasserTaskDataObject
            assignmentLocationUnitVC.isUnitListing = false
            
            let completionHandler:(AssignmentLocationUnitViewController)->Void = { objassignmentLocUnitVC in
                print(objassignmentLocUnitVC)
                
                
                
                //ToShow Survey
                self.surveyVM = SurveyViewModel.getViewModel()
                
                Utility.initializeSurvey(surveyVM: self.surveyVM, canvasserTaskDataObject: self.canvasserTaskDataObject, vctrl: self,contactId:objassignmentLocUnitVC.assignmentLocUnitInfoObj.contactId)
                
                
                
            }
            
            assignmentLocationUnitVC.completionHandler = completionHandler
            
            let navigationController = UINavigationController(rootViewController: assignmentLocationUnitVC)
            navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
            self.present(navigationController, animated: true)
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
}

