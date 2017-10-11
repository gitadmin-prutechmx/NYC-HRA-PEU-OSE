//
//  UnitsViewController.swift
//  MTXGIS
//
//  Created by Kamal on 23/02/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit
import Toast_Swift

struct UnitsDataStruct
{
    var unitId : String = ""
    var unitName : String = ""
    var apartment: String = ""
    var surveyStatus: String = ""
    var syncDate: String = ""
    var assignmentLocUnitId:String = ""
    var isPrivateHome:String = ""
}


struct ClientDataStruct
{
    var tenantId : String = ""
    var name:String = ""
    var firstName : String = ""
    var lastName : String = ""
    var email : String = ""
    var phone : String = ""
    var age : String = ""
    var dob:String = ""
    var unitId:String = ""
    var assignmentLocUnitId:String = ""
    var unitName:String = ""
    var surveyStatus:String = ""
    var isVirtualUnit:String = ""
    var apartment:String = ""
}



class UnitsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate
{
    
    
    
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var viewClient: UIView!
    
    @IBOutlet weak var tblClient: UITableView!
    @IBOutlet weak var viewUnit: UIView!
    @IBOutlet weak var tblUnits: UITableView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var dataFullAddress: UILabel!
    
    @IBOutlet weak var toolBarView: UIView!
    
    @IBOutlet weak var unitclientSearchbar: UISearchBar!
    @IBOutlet weak var dataAssignment: UILabel!
    
    
    var locId:String!
    var locName:String!
    var updatedUnitId:String?
    
    var unitDictionaryArray:Dictionary<String, AnyObject> = [:]
    
    var unitNameArray = [String]()
    var unitIdArray = [String]()
    var floorArray = [String]()
    var surveyStatusArray = [String]()
    var syncDateArray = [String]()
    
    @IBOutlet weak var newUnitLbl: UILabel!
    @IBOutlet weak var newCaseLbl: UILabel!
    
    var UnitDataArray = [UnitsDataStruct]()
    var clientDataArray = [ClientDataStruct]()
    var arrfilteredTableData: NSMutableArray = []
    var arrClientfilteredTableData: NSMutableArray = []
    var isFiltered: Bool = false

    
    
    @IBOutlet weak var unitView: UIStackView!
    @IBOutlet weak var cellContentView: UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        Utilities.currentUnitClientPage = "Unit"
        
        tblClient.register(UINib(nibName: "ClientDataTableViewCell", bundle: nil), forCellReuseIdentifier: "clientCellDataId")
        
        tblUnits.register(UINib(nibName: "UnitDataTableViewCell", bundle: nil), forCellReuseIdentifier: "unitCellIdentifier")
        
        if self.revealViewController() != nil {
            
            print("RevealViewController")
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            // self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        self.toolBarView.layer.borderWidth = 2
        self.toolBarView.layer.borderColor =  UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).cgColor
        //segmentControl.selectedSegmentIndex = 0
        let newUnitTapGesture = UITapGestureRecognizer(target: self, action: Selector(("NewUnitLblTapped:")))
        
        // add it to the image view;
        //  newUnitLbl.addGestureRecognizer(newUnitTapGesture)
        // make sure imageView can be interacted with by user
        //  newUnitLbl.isUserInteractionEnabled = true
        
        let newCaseTapGesture = UITapGestureRecognizer(target: self, action: Selector(("NewCaseLblTapped:")))
        
        // add it to the image view;
        newCaseLbl.addGestureRecognizer(newCaseTapGesture)
        // make sure imageView can be interacted with by user
        newCaseLbl.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector:#selector(UnitsViewController.UpdateUnitView), name: NSNotification.Name(rawValue: "UpdateUnitView"), object:nil
        )
        
        
        
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        
        
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "NYC")
        imageView.image = image
        self.navigationItem.titleView = imageView
        
        
        
        self.tblClient.tableFooterView = UIView()
        
        self.tblUnits.tableFooterView = UIView()
        self.tblClient.separatorStyle = UITableViewCellSeparatorStyle.none
        
        self.tblUnits.separatorStyle = UITableViewCellSeparatorStyle.none
        
        dataFullAddress.text = SalesforceConnection.fullAddress
        dataAssignment.text = "Assignment: " + SalesforceConnection.assignmentName
        
        //SalesforceRestApi.currentFullAddress = locName
        
        
        
    }
    
    @IBAction func moreAction(_ sender: Any) {
        
        /*    let buttonPosition = (sender as AnyObject).convert(CGPoint(), to: tableView)
         let index = tableView.indexPathForRow(at: buttonPosition)
         */
        let indexRow = (sender as AnyObject).tag
        
        SalesforceConnection.unitId =  UnitDataArray[indexRow!].unitId
        SalesforceConnection.unitName = UnitDataArray[indexRow!].unitName
        
      //  SalesforceConnection.assignmentLocationUnitId = UnitDataArray[indexRow!].assignmentLocUnitId
        
        
        Utilities.currentSegmentedControl = "Unit"
        self.performSegue(withIdentifier: "moreOptionsModalIdentifier", sender: nil)
        
        
        //  showActionSheet()
        
        
    }
    
    
    @IBAction func backBtn(sender: AnyObject) {
        
        
        self.performSegue(withIdentifier: "GoBackToMapIdentifier", sender: nil)
        
        // _ = self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    
    func NewUnitLblTapped(gesture: UIGestureRecognizer)
    {
        // if the tapped view is a UIImageView then set it to imageview
        self.performSegue(withIdentifier: "showNewAddClientIlistdentifier", sender: nil)
    }
    
    func NewCaseLblTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        //self.performSegue(withIdentifier: "showAddNewCaseIdentifier", sender: nil)
    }
    
    
    
    
    func UpdateUnitView(){
        print("UpdateUnitView")
        
        if(Utilities.isSubmitSurvey){
            updateSurveyStatus(status:"Completed")
        }
        else if(Utilities.isExitFromSurvey){
            updateSurveyStatus(status:Utilities.inProgressSurvey)
        }
        
        
        updateTableViewData()
        populateClientData()
    }
    
    // Cleanup notifications added in viewDidLoad
    deinit {
        NotificationCenter.default.removeObserver("UpdateUnitView")
    }
    
    
    @IBAction func syncData(_ sender: Any) {
        
        Utilities.forceSyncDataWithSalesforce(vc: self)
        
    }
    
    // var unitDataArray = [UnitsDataStruct]()
    
    
    func updateSurveyStatus(status:String?){
        var updateObjectDic:[String:String] = [:]
        
        //        _ = Date()
        //        let formatter = DateFormatter()
        //
        //        formatter.dateFormat = "MM/dd/yyyy"
        //
        //
        
        
        updateObjectDic["surveyStatus"] = status
        
        // updateObjectDic["syncDate"] = "Pending.."
        //updateObjectDic["syncDate"] = formatter.string(from: date)
        
        
        
        ManageCoreData.updateRecord(salesforceEntityName: "Unit", updateKeyValue: updateObjectDic, predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND id == %@ AND assignmentLocUnitId ==%@", predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId,predicateValue3: SalesforceConnection.assignmentLocationId, predicateValue4: SalesforceConnection.unitId, predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate: true)
        
        
        Utilities.isSubmitSurvey = false
        Utilities.isExitFromSurvey = false
        
        
    }
    
    var surveyResDict:[String:String] = [:]
    
    var editUnitDict: [String:EditUnitDO] = [:]
    var tenantDict: [String:String] = [:]
    var countTenants:Int  = 1
    
    func createEditUnitDictionary(){
        
        
        
        let attemptUnitResults =  ManageCoreData.fetchData(salesforceEntityName: "EditUnit", predicateFormat: "assignmentId == %@ && locationId == %@",predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, isPredicate:true) as! [EditUnit]
        
        if(attemptUnitResults.count > 0){
            
            for editUnitData in attemptUnitResults{
                
                if editUnitDict[editUnitData.unitId!] == nil{
                    editUnitDict[editUnitData.unitId!] = EditUnitDO(attempt: editUnitData.attempt!, contact: editUnitData.isContact!)
                }
                
                
            }
        }
        
    }
    
    
    
    func createTenantDictionary(){
        
        countTenants = 1
        
        //let tenantResults =  ManageCoreData.fetchData(salesforceEntityName: "Tenant", isPredicate:false) as! [Tenant]
        
        let tenantResults =  ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "assignmentId == %@",predicateValue: SalesforceConnection.assignmentId, isPredicate:true) as! [Tenant]
        
        if(tenantResults.count > 0){
            
            for tenantData in tenantResults{
                
                if tenantDict[tenantData.unitId!] == nil{
                    
                    countTenants = 1
                    tenantDict[tenantData.unitId!] = String(countTenants)
                }
                else{
                    
                    let count = tenantDict[tenantData.unitId!]
                    countTenants = Int(count!)! + 1
                    tenantDict[tenantData.unitId!] = String(countTenants)
                }
                
                
            }
        }
        
    }
    
    func createInProgressSurveyResponseDictionary(){
        
        
        let surveyResponseResults =  ManageCoreData.fetchData(salesforceEntityName: "SurveyResponse",predicateFormat: "actionStatus == %@ ",predicateValue: Utilities.inProgressSurvey, isPredicate:true) as! [SurveyResponse]
        
        if(surveyResponseResults.count > 0){
            
            for surveyResponseData in surveyResponseResults{
                
                if surveyResDict[surveyResponseData.unitId!] == nil{
                    surveyResDict[surveyResponseData.unitId!] = surveyResponseData.actionStatus!
                }
                
                
            }
        }
        
    }
    
    
    func populateClientData()
    {
        
        clientDataArray = [ClientDataStruct]()
        
        
        Utilities.unitClientDict = [:]
        Utilities.caseDict = [:]
        
        Utilities.createUnitDictionary()
        Utilities.createCaseDictionary()
        
        let clientResults = ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "assignmentId == %@ AND locationId == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId,isPredicate:true) as! [Tenant]
        
        
        if(clientResults.count > 0){
            
            for tenantData in clientResults{
                
                let unitObject = Utilities.unitClientDict[tenantData.unitId!]
                
                if(unitObject != nil){
                    let objectTenantStruct:ClientDataStruct = ClientDataStruct(tenantId: tenantData.id!,name: tenantData.name!, firstName: tenantData.firstName!, lastName: tenantData.lastName!, email: tenantData.email!, phone: tenantData.phone!, age: tenantData.age!,dob:tenantData.dob!,unitId:tenantData.unitId!,assignmentLocUnitId:tenantData.assignmentLocUnitId!,unitName:(unitObject?.unitName)!,surveyStatus:(unitObject?.surveyStatus)!,isVirtualUnit:tenantData.virtualUnit!,apartment:tenantData.aptNo!)
                
                    clientDataArray.append(objectTenantStruct)
                }
            }
        }
        
        if(Utilities.currentClientSortingFieldName == "FirstName"){
            if(Utilities.currentClientSortingTypeAscending){
                clientDataArray = clientDataArray.sorted { $0.firstName < $1.firstName }
            }
            else{
                clientDataArray = clientDataArray.sorted { $0.firstName > $1.firstName }
            }
        }
        else if(Utilities.currentClientSortingFieldName == "LastName"){
            if(Utilities.currentClientSortingTypeAscending){
                clientDataArray = clientDataArray.sorted { $0.lastName < $1.lastName }
            }
            else{
                clientDataArray = clientDataArray.sorted { $0.lastName > $1.lastName }
            }
        }
        else{
            if(Utilities.currentClientSortingTypeAscending){
                clientDataArray = clientDataArray.sorted { $0.unitName < $1.unitName }
            }
            else{
                clientDataArray = clientDataArray.sorted { $0.unitName > $1.unitName }
            }
        }
        
        
        DispatchQueue.main.async {
            
            self.tblClient.reloadData()
            //self.viewDidLayoutSubviews()
        }
        
        
        
        
    }
    
    
    func updateTableViewData(){
        
        UnitDataArray = [UnitsDataStruct]()
        floorArray = []
        
        editUnitDict = [:]
        tenantDict = [:]
        surveyResDict = [:]
        
        createEditUnitDictionary()
        createTenantDictionary()
        createInProgressSurveyResponseDictionary()
        
        let unitResults = ManageCoreData.fetchData(salesforceEntityName: "Unit",predicateFormat: "locationId == %@ AND assignmentId == %@ AND assignmentLocId == %@ AND virtualUnit == %@" ,predicateValue: SalesforceConnection.locationId,predicateValue2:SalesforceConnection.assignmentId,predicateValue3: SalesforceConnection.assignmentLocationId,predicateValue4: "false", isPredicate:true) as! [Unit]
        
        
        if(unitResults.count > 0){
            
            for unitData in unitResults{
                
                let objectUnitStruct:UnitsDataStruct = UnitsDataStruct(unitId: unitData.id!, unitName: unitData.name!, apartment: unitData.apartment!, surveyStatus: unitData.surveyStatus!, syncDate: unitData.unitSyncDate!,assignmentLocUnitId:unitData.assignmentLocUnitId!,isPrivateHome:unitData.privateHome!)
                
                UnitDataArray.append(objectUnitStruct)
                
            }
        }
        
        if(Utilities.currentUnitSortingFieldName == "UnitName"){
            if(Utilities.currentUnitSortingTypeAscending){
                UnitDataArray = UnitDataArray.sorted { $0.unitName < $1.unitName }
            }
            else{
                UnitDataArray = UnitDataArray.sorted { $0.unitName > $1.unitName }
            }
        }
        
        
        
        //  UnitDataArray = UnitDataArray.sorted { $0.unitName < $1.unitName }
        
        
        
        // self.floorTextField.text = "All"
        // self.tableView.reloadData()
        
        DispatchQueue.main.async {
            
            self.tblUnits.reloadData()
            //self.viewDidLayoutSubviews()
        }
        
        
        /*
         DispatchQueue.global(qos: .background).async {
         print("This is run on the background queue")
         
         DispatchQueue.main.async {
         print("This is run on the main queue, after the previous code in outer block")
         }
         }
         
         */
        
        
        
        
        
    }
    
    func removeDuplicates(array: [String]) -> [String] {
        var encountered = Set<String>()
        var result: [String] = []
        for value in array {
            if encountered.contains(value) {
                // Do not add a duplicate element.
            }
            else {
                // Add value to the set.
                encountered.insert(value)
                // ... Append the value.
                result.append(value)
            }
        }
        return result
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        super.viewWillAppear(animated)
        
        updateTableViewData()
        
        populateClientData()
    }
    
    
    override func viewDidLayoutSubviews() {
        
        //self.heightConstraint.constant = tableView.contentSize.height
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UITableViewDataSource
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
        
      
        
    }
    
    
    // MARK: SearchBar Delegate
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
        
    {
        
        if searchText.isEmpty
            
        {
            
            isFiltered = false
            
        }
        else
            
        {
            
            isFiltered = true;
            
            arrfilteredTableData.removeAllObjects()
            arrClientfilteredTableData.removeAllObjects()
            switch segmentControl.selectedSegmentIndex
            {
            case 0:
             //   Utilities.currentUnitClientPage = "Unit"
                for searchitem in UnitDataArray
                    
                {
                    
                    if searchitem.unitName.lowercased().contains(searchText.lowercased())
                        
                    {
                        
                        arrfilteredTableData.add(searchitem)
                        
                        
                    }
                    
                    
                    
                }
                
                
            case 1:
               // Utilities.currentUnitClientPage = "Client"
                for searchitem in clientDataArray
                    
                {
                    
                    if searchitem.name.lowercased().contains(searchText.lowercased())
                        
                    {
                        
                        arrClientfilteredTableData.add(searchitem)
                        
                        
                    }
                    
                    
                }
               
            default:
                break;
            }

            
            
        }
        
        
        self.tblClient.reloadData()
        self.tblUnits.reloadData()
        
        
        
    }
    
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
        
    {
        
        view.endEditing(true)
        
        
        
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)

        
    {
        if !isFiltered
        
            
        {
            
            isFiltered = true
            
            
            
            tblClient.reloadData()
            
            
            
        }
        
        // searchbarExistingClients.resignFirstResponder()
    
        view.endEditing(true)
        
        
        
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if(tableView == tblUnits)
        {
            if isFiltered
            {
                return arrfilteredTableData.count
                
            } else
                
            {
                return UnitDataArray.count
                
            }
            
        }
        else
        {
            if isFiltered
            {
                return arrClientfilteredTableData.count
                
            } else
                
            {
                return clientDataArray.count
                
            }
        }
        
        
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        if(tableView == tblUnits)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "unitCellIdentifier", for: indexPath as IndexPath) as! UnitDataTableViewCell
            
            var unitData: UnitsDataStruct
            
            if isFiltered
            {
                cell.unit.text = (arrfilteredTableData[indexPath.row] as! UnitsDataStruct).unitName
                cell.syncDate.text = (arrfilteredTableData[indexPath.row] as! UnitsDataStruct).syncDate
                
                if((arrfilteredTableData[indexPath.row] as! UnitsDataStruct).syncDate != "")
                {
                    cell.sync.image = UIImage(named: "Complete")
                }
                else
                {
                    cell.sync.image = nil
                    // cell.sync.image = UIImage(named: "transperntImg")
                }
                
                if((arrfilteredTableData[indexPath.row] as! UnitsDataStruct).surveyStatus == "Completed")
                
                {
                    cell.surveyStatus.image = UIImage(named: "Complete")
                }
                
                else if((arrfilteredTableData[indexPath.row] as! UnitsDataStruct).surveyStatus == Utilities.inProgressSurvey)
                {
                    cell.surveyStatus.image = UIImage(named: "InProgress")
                }
                else
                {
                    let survetResObject = surveyResDict[(arrfilteredTableData[indexPath.row] as! UnitsDataStruct).unitId]
                    
                    if(survetResObject == Utilities.inProgressSurvey){
                        cell.surveyStatus.image = UIImage(named: "InProgress")
                    }
                    else{
                        cell.surveyStatus.image = nil
                    }
                }
                cell.unitId.text = (arrfilteredTableData[indexPath.row] as! UnitsDataStruct).unitId
                
                let editUnitObject = editUnitDict[(arrfilteredTableData[indexPath.row] as! UnitsDataStruct).unitId]
                let noOfTenants = tenantDict[(arrfilteredTableData[indexPath.row] as! UnitsDataStruct).unitId]
                
                if let tenantCount = noOfTenants
                {
                    cell.noOfTenants.text = tenantCount
                }
                else
                {
                    cell.noOfTenants.text = "0"
                }
                
                if(editUnitObject?.attempt == "Yes"){
                    cell.attempt.image = UIImage(named: "Complete")
                }
                else if(editUnitObject?.attempt == "No"){
                    cell.attempt.image = UIImage(named: "No")
                }
                else
                {
                    cell.attempt.image = nil
                    //cell.attempt.image = UIImage(named: "transperntImg")
                }
                if(editUnitObject?.contact == "Yes")
                {
                    cell.contact.image = UIImage(named: "Complete")
                }
                else if(editUnitObject?.contact == "No")
                {
                    cell.contact.image = UIImage(named: "No")
                }
                else
                {
                    cell.contact.image = nil
                    //cell.contact.image = UIImage(named: "transperntImg")
                }

                
                unitData = (arrfilteredTableData[indexPath.row] as! UnitsDataStruct)
                
            }
                
            else
            {
                cell.unit.text = UnitDataArray[indexPath.row].unitName
                
                cell.syncDate.text = UnitDataArray[indexPath.row].syncDate
                
                if(UnitDataArray[indexPath.row].syncDate != ""){
                    cell.sync.image = UIImage(named: "Complete")
                }
                else
                {
                    cell.sync.image = nil
                    // cell.sync.image = UIImage(named: "transperntImg")
                    
                    
                }
               
                let survetResObject = surveyResDict[UnitDataArray[indexPath.row].unitId]
                
                if(survetResObject == Utilities.inProgressSurvey){
                    cell.surveyStatus.image = UIImage(named: "InProgress")
                }
                else{
                    if(UnitDataArray[indexPath.row].surveyStatus == "Completed"){
                        cell.surveyStatus.image = UIImage(named: "Complete")
                    }
                    else{
                        cell.surveyStatus.image = nil
                    }
                }
                
                
                
//                
//                if(UnitDataArray[indexPath.row].surveyStatus == "Completed"){
//                    cell.surveyStatus.image = UIImage(named: "Complete")
//                }
//                else if(UnitDataArray[indexPath.row].surveyStatus == Utilities.inProgressSurvey){
//                    cell.surveyStatus.image = UIImage(named: "InProgress")
//                }
//                else
//                {
//                    //let survetResObject = surveyResDict[UnitDataArray[indexPath.row].unitId]
//                    
//                    
//                    if(survetResObject == Utilities.inProgressSurvey){
//                        cell.surveyStatus.image = UIImage(named: "InProgress")
//                    }
//                    else{
//                        cell.surveyStatus.image = nil
//                    }
//                }
//                
                
                
                cell.unitId.text = UnitDataArray[indexPath.row].unitId
                
                let editUnitObject = editUnitDict[UnitDataArray[indexPath.row].unitId]
                let noOfTenants = tenantDict[UnitDataArray[indexPath.row].unitId]
                
                if let tenantCount = noOfTenants{
                    cell.noOfTenants.text = tenantCount
                }
                else
                {
                cell.noOfTenants.text = "0"
                }
                
                if(editUnitObject?.attempt == "Yes"){
                    cell.attempt.image = UIImage(named: "Complete")
                }
                else if(editUnitObject?.attempt == "No"){
                    cell.attempt.image = UIImage(named: "No")
                }
                else
                {
                    cell.attempt.image = nil
                    //cell.attempt.image = UIImage(named: "transperntImg")
                }
                
                if(editUnitObject?.contact == "Yes"){
                    cell.contact.image = UIImage(named: "Complete")
                }
                else if(editUnitObject?.contact == "No")
                {
                    cell.contact.image = UIImage(named: "No")
                }
                else
                {
                    cell.contact.image = nil
                    //cell.contact.image = UIImage(named: "transperntImg")
                }
                unitData = UnitDataArray[indexPath.row]
            }
            
            
            return cell
        }
            
            
        else
        {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "clientCellDataId", for: indexPath) as! ClientDataTableViewCell
            var clientData: ClientDataStruct

            if isFiltered
            {
                cell.lblFirstName.text = (arrClientfilteredTableData[indexPath.row] as! ClientDataStruct).firstName
                cell.lblLastName.text = (arrClientfilteredTableData[indexPath.row] as! ClientDataStruct).lastName
                if((arrClientfilteredTableData[indexPath.row] as! ClientDataStruct).phone.isEmpty)
                {
                    cell.lblPhone.text = "                        "
                }
                else
                {
                    cell.lblPhone.text = (arrClientfilteredTableData[indexPath.row] as! ClientDataStruct).phone.toPhoneNumber()
                }
                let noOfCases = Utilities.caseDict[(arrClientfilteredTableData[indexPath.row] as! ClientDataStruct).tenantId]
                
                if let caseCount = noOfCases
                {
                    cell.lblCase.text = caseCount
                }
                else
                {
                    cell.lblCase.text = "0"
                }
    
                
                cell.lblUnitName.text = (arrClientfilteredTableData[indexPath.row] as! ClientDataStruct).unitName
                cell.lblUnitId.text = (arrClientfilteredTableData[indexPath.row] as! ClientDataStruct).unitId
               // cell.lblSyncDate.text = ""
                
                if((arrClientfilteredTableData[indexPath.row] as! ClientDataStruct).apartment.isEmpty)
                {
                    cell.lblUnverifiedunit.text = "      "
                }
                else
                {
                     cell.lblUnverifiedunit.text = (arrClientfilteredTableData[indexPath.row] as! ClientDataStruct).apartment
                }
                
               
                
                 clientData = (arrClientfilteredTableData[indexPath.row] as! ClientDataStruct)
            }
            
            else
            {
                cell.lblFirstName.text = clientDataArray[indexPath.row].firstName
                cell.lblLastName.text = clientDataArray[indexPath.row].lastName
                if(clientDataArray[indexPath.row].phone.isEmpty){
                    cell.lblPhone.text = "                        "
                }
                else{
                    cell.lblPhone.text = clientDataArray[indexPath.row].phone.toPhoneNumber()
                }
                let noOfCases = Utilities.caseDict[clientDataArray[indexPath.row].tenantId]
                
                if let caseCount = noOfCases
                {
                    cell.lblCase.text = caseCount
                }
                else
                {
                    cell.lblCase.text = "0"
                }
                
                cell.lblUnitName.text = clientDataArray[indexPath.row].unitName
                cell.lblUnitId.text = clientDataArray[indexPath.row].unitId
                //cell.lblSyncDate.text = ""
                if(clientDataArray[indexPath.row].apartment.isEmpty){
                    cell.lblUnverifiedunit.text = "      "
                }
                else
                {
                    cell.lblUnverifiedunit.text = clientDataArray[indexPath.row].apartment
                }
                
               
                

                clientData = clientDataArray[indexPath.row]
            }
            // cell.backgroundColor = UIColor.clear
            
            // cell.unitId.text = clientDataArray[indexPath.row].unitId
            
            return cell
        }
        
    }
    
    
    func getSurveyUnitResults()->Bool{
        
        // request.predicate = NSPredicate(format: "username = %@ AND password = %@", txtUserName.text!, txtPassword.text!)
        
        let surveyUnitResults = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId == %@ ",predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId,predicateValue4:SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate:true) as! [EditUnit]
        
        if(surveyUnitResults.count == 0){
            
            return false
            
        }
        else if(surveyUnitResults.count > 0 && (surveyUnitResults[0].surveyId?.isEmpty)!){
            
            return false
        }
        
        SalesforceConnection.surveyId = surveyUnitResults[0].surveyId!
        
        return true
        
    }
    
    
    func showEditUnit(){
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let moreOptionVC = storyboard.instantiateViewController(withIdentifier: "moreOptionsIdentifier") as! MoreOptionsViewController
        
        SurveyUtility.navigationController = self.navigationController!
        
        SurveyUtility.sourceViewController = self
        
        let completionHandler:(MoreOptionsViewController)->Void = { moreOptionVC in
            
            if(SalesforceConnection.surveyId.isEmpty){
                
                self.view.makeToast("There is no default survey.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    if didTap {
                        print("completion from tap")
                    } else {
                        print("completion without tap")
                    }
                }
                
            }
            else{
                SurveyUtility.showSurvey()
            }
            print("completed for \(moreOptionVC)")
        }
        moreOptionVC.completionHandler=completionHandler
        
        
        
        
        //            moreOptionVC.dismissVCCompletion(){ () in
        //                 print("kamal")
        //                 //self.showSurveyWizard()
        //            }
        
        let navigationController = UINavigationController(rootViewController: moreOptionVC)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
        
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       // var arrfilteredTableData: NSMutableArray = []
       // var arrClientfilteredTableData: NSMutableArray = []

        
        //Units
        if(tableView == tblUnits)
        {
          //  var surveyStatus:String = ""
            
//            if(isFiltered && arrfilteredTableData.count > 0){
//                surveyStatus = (arrfilteredTableData[indexPath.row] as! UnitsDataStruct).surveyStatus
//            }
//            else{
//                surveyStatus = UnitDataArray[indexPath.row].surveyStatus
//            }
//           
//            
//            if("Completed" == surveyStatus)
//            {
//                
//                let currentCell = tblUnits.cellForRow(at: tblUnits.indexPathForSelectedRow!) as! UnitDataTableViewCell
//                
//                currentCell.shake(duration: 0.3, pathLength: 15)
//                
//                
//                self.view.makeToast("Survey already has been completed.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
//                    if didTap {
//                        print("completion from tap")
//                    } else {
//                        print("completion without tap")
//                    }
//                }
//                
//            }
//                
//            else{
            
                var unitId:String = ""
                var unitName:String = ""
                var assignmentLocUnitId:String = ""
                var isPrivateHome:String = ""
                
                if(isFiltered && arrfilteredTableData.count > 0){
                    unitId = (arrfilteredTableData[indexPath.row] as! UnitsDataStruct).unitId
                    unitName = (arrfilteredTableData[indexPath.row] as! UnitsDataStruct).unitName
                    assignmentLocUnitId = (arrfilteredTableData[indexPath.row] as! UnitsDataStruct).assignmentLocUnitId
                    isPrivateHome = (arrfilteredTableData[indexPath.row] as! UnitsDataStruct).isPrivateHome
                }
                else{
                     unitId = UnitDataArray[indexPath.row].unitId
                     unitName = UnitDataArray[indexPath.row].unitName
                     assignmentLocUnitId = UnitDataArray[indexPath.row].assignmentLocUnitId
                     isPrivateHome = UnitDataArray[indexPath.row].isPrivateHome
                }
                
                
                SalesforceConnection.unitId = unitId
                
                SalesforceConnection.unitName =  unitName
                
                SalesforceConnection.assignmentLocationUnitId = assignmentLocUnitId
                
                SalesforceConnection.isPrivateHome = isPrivateHome
                
                SalesforceConnection.selectedTenantForSurvey = ""
                
                showEditUnit()

            //}
            
        }
           
        //Clients
        else
        {
            
//            let currentCell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as! ClientDataTableViewCell
//            
//            var surveyStatus:String = ""
//            
//            if(isFiltered && arrClientfilteredTableData.count > 0){
//                surveyStatus = (arrClientfilteredTableData[indexPath.row] as! ClientDataStruct).surveyStatus
//            }
//            else{
//                surveyStatus = clientDataArray[indexPath.row].surveyStatus
//            }
//            
//            
//            
//            if("Completed" == surveyStatus){
//                
//                
//                currentCell.shake(duration: 0.3, pathLength: 15)
//                
//                
//                self.view.makeToast("Survey already has been completed.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
//                    if didTap {
//                        print("completion from tap")
//                    } else {
//                        print("completion without tap")
//                    }
//                }
//                
//            }
//            else{
            
                var unitId:String = ""
                var unitName:String = ""
                var assignmentLocUnitId:String = ""
                var isVirtualUnit:String = ""
                var tenantId:String = ""
                
                if(isFiltered && arrClientfilteredTableData.count > 0){
                    
                    unitId = (arrClientfilteredTableData[indexPath.row] as! ClientDataStruct).unitId
                    unitName = (Utilities.unitClientDict[unitId]?.unitName)!
                    assignmentLocUnitId = (arrClientfilteredTableData[indexPath.row] as! ClientDataStruct).assignmentLocUnitId
                    isVirtualUnit = (arrClientfilteredTableData[indexPath.row] as! ClientDataStruct).isVirtualUnit
                    tenantId = (arrClientfilteredTableData[indexPath.row] as! ClientDataStruct).tenantId
                }
                else{
                    unitId = clientDataArray[indexPath.row].unitId
                    unitName =  (Utilities.unitClientDict[clientDataArray[indexPath.row].unitId]?.unitName)!
                    assignmentLocUnitId = clientDataArray[indexPath.row].assignmentLocUnitId

                    isVirtualUnit = clientDataArray[indexPath.row].isVirtualUnit
                    tenantId = clientDataArray[indexPath.row].tenantId

                }
                
                
                SalesforceConnection.unitId =  unitId
                
                SalesforceConnection.unitName =  unitName
                
                SalesforceConnection.assignmentLocationUnitId = assignmentLocUnitId
                
                SalesforceConnection.selectedTenantForSurvey = tenantId
                
                if(isVirtualUnit == "true"){
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    let virtualUnitClientVC = storyboard.instantiateViewController(withIdentifier: "virtualUnitClientIdentifier") as! VirtualUnitClientViewController
                    
                    let navigationController = UINavigationController(rootViewController: virtualUnitClientVC)
                    navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
                    
                    
                    self.present(navigationController, animated: true, completion: nil)
                    
                    
                    
//                    currentCell.shake(duration: 0.3, pathLength: 15)
//                    
//                    
//                    self.view.makeToast("Please create new unit first.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
//                        if didTap {
//                            print("completion from tap")
//                        } else {
//                            print("completion without tap")
//                        }
//                    }
                }
                else{
                    
                    
                    showEditUnit()
                }
           // }
            
        }
        
        
    }
    
    
    func showSurveyWizard(){
        
        
        let surveyQuestionResults = ManageCoreData.fetchData(salesforceEntityName: "SurveyQuestion",predicateFormat: "surveyId == %@ AND assignmentId = %@" ,predicateValue: SalesforceConnection.surveyId,predicateValue2:SalesforceConnection.assignmentId,isPredicate:true) as! [SurveyQuestion]
        
        if(surveyQuestionResults.count == 1){
            
            
            let jsonData =  Utilities.convertToJSON(text: surveyQuestionResults[0].surveyQuestionData!) as!Dictionary<String, AnyObject>
            
            
            readSurveyJSONObject(object: jsonData)
            
            Utilities.totalSurveyQuestions =  Utilities.surveyQuestionArray.count
            
            //Utilities.currentUnitId = ""
            //SalesforceRestApi.currentUnitName = ""
            
            if(Utilities.totalSurveyQuestions > 0){
                
                showSurveyQuestions()
                print("ShowSurveyQuestions")
            }
            
        }
        
        
    }
    
    
    
    
    var skipLogicArray : [[String:SkipLogic]] = []
    var skipLogicDict = [String: SkipLogic]()
    var skipLogicParentChildArray = [SkipLogicParentChild]()
    
    func addSurveyObject(_ questionId:String,questionType:String,questionText:String,questionNumber:String,required:Bool,choices:String,isSkipLogic:String,answer:String,questionChoiceList:[[String: AnyObject]]){
        
        skipLogicArray = []
        
        skipLogicDict = [:]
        
        
        
        var options = ""
        
        
        
        
        
        for questionChoice in questionChoiceList{
            
            let skipLogicType = questionChoice["skipLogicType"] as? String ?? ""
            let choice = questionChoice["choice"] as? String ?? ""
            let isSkipLogicPresent = questionChoice["isSkipLogicPresent"] as? Bool
            let childQuestionNumber = questionChoice["questionNumber"] as? String ?? ""
            
            let showTextValue = questionChoice["showText"] as? String ?? ""
            
            
            options = options + choice + ";"
            
            if(isSkipLogicPresent == true){
                
                let objectSkipLogic:SkipLogic = SkipLogic(skipLogicType: skipLogicType, questionNumber: childQuestionNumber,selectedAnswer: choice,showTextValue:showTextValue)
                
                skipLogicDict[choice] = objectSkipLogic
                
                skipLogicArray.append(skipLogicDict)
                
                if(skipLogicType == "Skip to Question"){
                    skipLogicParentChildArray.append(SkipLogicParentChild(childQuesionNumber: childQuestionNumber, parentQuestionNumber: questionNumber, selectedAnswer: choice, skipLogicType: skipLogicType,showTextValue:showTextValue))
                }
                
                
            }
            
            
            
        }
        
        
        //options = options.substring(to: options.characters.index(before: options.endIndex))
        
        options = String(options.characters.dropLast())
        
        
        let  objSurveyQues = SurveyQuestionDO(questionId: questionId, questionText: questionText,questionType:questionType,questionNumber:questionNumber,isRequired: required,choices: options , skipLogicArray:skipLogicArray , isSkipLogic: isSkipLogic,getDescriptionAnswer: answer)
        
        
        let objectStruct:structSurveyQuestion = structSurveyQuestion(key: questionId, objectSurveyQuestion: objSurveyQues)
        
        
        Utilities.surveyQuestionArray.append(objectStruct)
        
        
        
    }
    
    
    func readSurveyJSONObject(object:Dictionary<String, AnyObject>) {
        
        Utilities.surveyQuestionArray = []
        
        skipLogicParentChildArray = []
        
        
        Utilities.skipLogicParentChildDict = [:]
        
        Utilities.prevSkipLogicParentChildDict = [:]
        
        
        
        
        
        guard let surveyName = object["surveyName"] as? String
            , let results = object["Question"] as? [[String: AnyObject]] else { return }
        
        
        
        for data in results {
            
            print("data: \(data)")
            
            guard let questionType = data["questionType"] as? String else {break}
            
            guard let required = data["required"] as? Bool else { break }
            
            guard let questionText = data["questionText"] as? String else { break }
            guard let questionId = data["questionId"] as? String else { break }
            guard let questionNumber = data["questionNumber"] as? String else{break}
            //guard let choices = data["choices"] as? String else {break}
            
            
            //skip logic
            guard let skipLogic = data["skipLogic"] as? String else {break}
            // guard let answer = data["answer"] as? String? else {break}  //for getdescription text
            guard let questionChoiceList = data["questionChoiceList"] as? [[String: AnyObject]]  else {break}
            
            
            
            // let updatedAnswer = answer ?? ""
            
            
            
            addSurveyObject(questionId, questionType: questionType, questionText: questionText, questionNumber: questionNumber, required: required, choices: "", isSkipLogic: skipLogic, answer: "", questionChoiceList: questionChoiceList)
            
        }
        
        
        
        var tempArray = [SkipLogic]()
        
        
        for skipLogicparentChild in skipLogicParentChildArray{
            
            tempArray = []
            
            if Utilities.skipLogicParentChildDict[skipLogicparentChild.parentQuestionNumber] != nil {
                
                var arrayValue:[SkipLogic] =  Utilities.skipLogicParentChildDict[skipLogicparentChild.parentQuestionNumber]!
                
                arrayValue.append(SkipLogic(skipLogicType: skipLogicparentChild.skipLogicType, questionNumber: skipLogicparentChild.childQuesionNumber, selectedAnswer: skipLogicparentChild.selectedAnswer,showTextValue:skipLogicparentChild.showTextValue))
                
                Utilities.skipLogicParentChildDict[skipLogicparentChild.parentQuestionNumber] = arrayValue
                
            }
                
            else{
                
                tempArray.append(SkipLogic(skipLogicType: skipLogicparentChild.skipLogicType, questionNumber: skipLogicparentChild.childQuesionNumber, selectedAnswer: skipLogicparentChild.selectedAnswer,showTextValue:skipLogicparentChild.showTextValue))
                
                Utilities.skipLogicParentChildDict[skipLogicparentChild.parentQuestionNumber] = tempArray
                
            }
            
        }
        
        
        //For Previous button
        var prevTempArray = [SkipLogic]()
        
        
        for skipLogicparentChild in skipLogicParentChildArray{
            
            prevTempArray = []
            
            if Utilities.prevSkipLogicParentChildDict[skipLogicparentChild.childQuesionNumber] != nil {
                
                var arrayValue:[SkipLogic] =  Utilities.prevSkipLogicParentChildDict[skipLogicparentChild.childQuesionNumber]!
                
                arrayValue.append(SkipLogic(skipLogicType: skipLogicparentChild.skipLogicType, questionNumber: skipLogicparentChild.parentQuestionNumber, selectedAnswer: skipLogicparentChild.selectedAnswer,showTextValue:skipLogicparentChild.showTextValue))
                
                Utilities.prevSkipLogicParentChildDict[skipLogicparentChild.childQuesionNumber] = arrayValue
                
            }
                
            else{
                
                prevTempArray.append(SkipLogic(skipLogicType: skipLogicparentChild.skipLogicType, questionNumber: skipLogicparentChild.parentQuestionNumber, selectedAnswer: skipLogicparentChild.selectedAnswer,showTextValue:skipLogicparentChild.showTextValue))
                
                Utilities.prevSkipLogicParentChildDict[skipLogicparentChild.childQuesionNumber] = prevTempArray
                
            }
            
        }
        
        
        
        
        
        print(Utilities.surveyQuestionArray)
        
        
    }
    
    
    
    
    
    
    func showSurveyQuestions(){
        
        
        Utilities.SurveyOutput = [:]
        Utilities.answerSurvey = ""
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        Utilities.surveyQuestionArrayIndex = 0
        
        
        //SalesforceRestApi.surveyQuestionArrayIndex = SalesforceRestApi.surveyQuestionArrayIndex + 1
        
        Utilities.currentSurveyPage = Utilities.surveyQuestionArrayIndex + 1
        
        let objSurveyQues =  Utilities.surveyQuestionArray[Utilities.surveyQuestionArrayIndex].objectSurveyQuestion
        
        if(objSurveyQues?.questionType == "Single Select"){
            
            let surveyRadioButtonVC = storyboard.instantiateViewController(withIdentifier: "surveyRadioButtonVCIdentifier") as! SurveyRadioOptionViewController
            
            //presentDetail(surveyRadioButtonVC)
            
            self.navigationController?.pushViewController(surveyRadioButtonVC, animated: true)
            
            /*
             let surveyRadioButtonVC = storyboard.instantiateViewControllerWithIdentifier("surveyRadioButtonVCIdentifier") as! SurveyRadioButtonViewController
             
             self.navigationController?.pushViewController(surveyRadioButtonVC, animated: true)
             
             */
        }
        else if(objSurveyQues?.questionType == "Multi Select"){
            
            let surveyMultiButtonVC = storyboard.instantiateViewController(withIdentifier: "surveyMultiOptionVCIdentifier") as! SurveyMultiOptionViewController
            
            //presentDetail(surveyMultiButtonVC)
            
            self.navigationController?.pushViewController(surveyMultiButtonVC, animated: true)
            
            
        }
        else if(objSurveyQues?.questionType == "Text Area"){
            
            let surveyTextFieldVC = storyboard.instantiateViewController(withIdentifier: "surveyTextFiedVCIdentifier") as! SurveyTextViewController
            
            
            // presentDetail(surveyTextFieldVC)
            
            self.navigationController?.pushViewController(surveyTextFieldVC, animated: true)
            
            
            /*  let surveyTextFieldVC = storyboard.instantiateViewControllerWithIdentifier("surveyTextFiedVCIdentifier") as! SurveyTextFieldViewController
             
             self.navigationController?.pushViewController(surveyTextFieldVC, animated: true)
             
             */
        }
        
        
    }
    
    
    
    
    
    //canEditRowAt
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print("editingStyle")
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let more = UITableViewRowAction(style: .normal, title: "More") { action, index in
            
            
            //self.isEditing = false
            self.showActionSheet()
        }
        
        
        
        more.backgroundColor = UIColor(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1.0) // UIColor.blue
        
        
        return [more]
    }
    
    
    func showActionSheet(){
        
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .alert)
        
        // 2
        let unitAction = UIAlertAction(title: "Unit Information", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Unit Information")
            
            Utilities.currentSegmentedControl = "Unit"
            self.performSegue(withIdentifier: "moreOptionsModalIdentifier", sender: nil)
            
        })
        let tenantAction = UIAlertAction(title: "Tenant Information", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Tenant Information")
            
            Utilities.currentSegmentedControl = "Tenant"
            self.performSegue(withIdentifier: "moreOptionsModalIdentifier", sender: nil)
        })
        
        //
        let surveyAction = UIAlertAction(title: "Choose a Survey", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Choose a Survey")
            
            Utilities.currentSegmentedControl = "Survey"
            self.performSegue(withIdentifier: "moreOptionsModalIdentifier", sender: nil)
            
            /*
             let storyboard = UIStoryboard(name: "Main", bundle: nil)
             let moreOptionsVC = storyboard.instantiateViewController(withIdentifier: "moreOptionsIdentifier") as! MoreOptionsViewController
             
             self.navigationController?.modalPresentationStyle = UIModalPresentationStyle.formSheet
             
             
             //self.present(moreOptionsVC, animated: true, completion: nil)
             
             
             
             self.navigationController?.pushViewController(moreOptionsVC, animated: true)
             */
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancel")
        })
        
        
        
        // 4
        optionMenu.addAction(unitAction)
        optionMenu.addAction(tenantAction)
        optionMenu.addAction(surveyAction)
        optionMenu.addAction(cancelAction)
        
        // optionMenu.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        
        //optionMenu.popoverPresentationController?.sourceView = self.view
        //optionMenu.popoverPresentationController?.sourceRect = self.view.bounds
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if tableView == tblUnits
        {
            let identifier = "unitCellId"
            var cell: UnitsHeaderTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? UnitsHeaderTableViewCell
            if cell == nil {
                tableView.register(UINib(nibName: "UnitsHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
                cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? UnitsHeaderTableViewCell
            }
            
            return cell
            
        }
        else
        {
            
            let identifier = "clientHeaderIdentifier"
            var cell: ClientsTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? ClientsTableViewCell
            if cell == nil {
                tableView.register(UINib(nibName: "ClientsTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
                cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ClientsTableViewCell
            }
            
            return cell
            
        }
        
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        
        return  41.0
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "unitSortingPopOverIdentifier" {
            
            let unitClientSortingVC = segue.destination as! UnitSortingViewController
            unitClientSortingVC.preferredContentSize = CGSize(width: 375, height: 160)
            
            
            
            
            unitClientSortingVC.setSortingUnitClient{
                [weak self] (sortingFieldName:String,sortingType:Bool) -> Void in
                
                
                
                if(Utilities.currentUnitClientPage == "Unit"){
                    
                    Utilities.currentUnitSortingFieldName = sortingFieldName
                    Utilities.currentUnitSortingTypeAscending = sortingType
                    
                    
                    
                    self?.updateTableViewData()
                }
                else{
                    
                    Utilities.currentClientSortingFieldName = sortingFieldName
                    Utilities.currentClientSortingTypeAscending = sortingType
                    
                    
                    
                    self?.populateClientData()
                }
                //self?.populateClientData()
                
                print(sortingFieldName)
                print(sortingType)
                
                
            }
            
        }
    }
    
       
    
    @IBAction func NewUnit(_ sender: Any)
    {
        
        self.performSegue(withIdentifier: "showAddUnitIdentifier", sender: sender)
    }
    
  
    @IBAction func NewClientAction(_ sender: Any)
    {
        SalesforceConnection.isNewContactWithAddress = true
        self.performSegue(withIdentifier: "showNewAddClientIlistdentifier", sender: nil)

    }
    
    @IBAction func NewCaseBtn(sender: AnyObject) {
        
        //self.performSegue(withIdentifier: "showAddNewCaseIdentifier", sender: sender)
        
    }
    
    
    
    
    @IBAction func indexChangedAction(_ sender: UISegmentedControl)
    {
        switch segmentControl.selectedSegmentIndex
        {
        case 0:
            Utilities.currentUnitClientPage = "Unit"
            viewClient.isHidden = true
            viewUnit.isHidden = false
        case 1:
            Utilities.currentUnitClientPage = "Client"
             //unitclientSearchbar.text = ""
            viewClient.isHidden = false
            viewUnit.isHidden = true
        default:
            break;
        }
    }
    
    
    //MARK: - Delegates and data sources
    
    
    
    @IBAction func UnwindBackFromSurvey(segue:UIStoryboardSegue) {
        
        print("UnwindBackFromSurvey")
        
    }
    
}



