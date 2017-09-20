//
//  ExistingClientsViewController.swift
//  Knock
//
//  Created by Cloudzeg Laptop on 9/15/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class ExistingClientsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate
{
    @IBOutlet weak var tblExistingClientsView: UITableView!
    @IBOutlet weak var btnShowMore:UIButton!
    @IBOutlet weak var fullAddressTxt: UILabel!
    
    
    var filteredTableData = NSMutableArray()
    var arrSelectedIndex: NSMutableArray = []
    var isFiltered: Bool = false
    var existingClientsDataArray = [ClientDataStruct]()
    var selectedExistingClientsArray = [ClientDataStruct]()
    
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        btnShowMore.layer.cornerRadius = 5
        fullAddressTxt.text = "Unit: " + SalesforceConnection.unitName + "  |  " + SalesforceConnection.fullAddress
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        // self.navigationItem.rightBarButtonItem =  nil
        
        let rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(ExistingClientsViewController.saveAction))
        let leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ExistingClientsViewController.cancelAction))
        
        self.navigationItem.rightBarButtonItem  = rightBarButtonItem
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //populateExistingClientData()
        populateVirtualUnitClientData()
    }
    
    func populateVirtualUnitClientData(){
        
        arrSelectedIndex = []
        
        existingClientsDataArray = [ClientDataStruct]()
        
        
        Utilities.unitClientDict = [:]
        Utilities.caseDict = [:]
        
        Utilities.createUnitDictionary()
        Utilities.createCaseDictionary()
        
        let clientResults = ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "assignmentId == %@ AND locationId == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId,isPredicate:true) as! [Tenant]
        
        
        if(clientResults.count > 0){
            
            for tenantData in clientResults{
                
                if(tenantData.virtualUnit! == "true"){
                    
                    let unitObject = Utilities.unitClientDict[tenantData.unitId!]
                    
                    let objectTenantStruct:ClientDataStruct = ClientDataStruct(tenantId: tenantData.id!,name: tenantData.name!, firstName: tenantData.firstName!, lastName: tenantData.lastName!, email: tenantData.email!, phone: tenantData.phone!, age: tenantData.age!,dob:tenantData.dob!,unitId:tenantData.unitId!,assignmentLocUnitId:tenantData.assignmentLocUnitId!,unitName:(unitObject?.unitName)!,surveyStatus:(unitObject?.surveyStatus)!,isVirtualUnit:tenantData.virtualUnit!)
                    
                    
                    existingClientsDataArray.append(objectTenantStruct)
                }
                
            }
        }
        
        
        
        
        DispatchQueue.main.async {
            
            self.tblExistingClientsView.reloadData()
            //self.viewDidLayoutSubviews()
        }
        
        
        
        
    }
    
    
    func populateExistingClientData(){
        
        arrSelectedIndex = []
        existingClientsDataArray = [ClientDataStruct]()
        
        
        Utilities.unitClientDict = [:]
        Utilities.caseDict = [:]
        
        Utilities.createUnitDictionary()
        Utilities.createCaseDictionary()
        
        let clientResults = ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "assignmentId == %@ AND locationId == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId,isPredicate:true) as! [Tenant]
        
        
        if(clientResults.count > 0){
            
            for tenantData in clientResults{
                
                if(SalesforceConnection.unitId != tenantData.unitId!){
                    
                    let unitObject = Utilities.unitClientDict[tenantData.unitId!]
                    
                    let objectTenantStruct:ClientDataStruct = ClientDataStruct(tenantId: tenantData.id!,name: tenantData.name!, firstName: tenantData.firstName!, lastName: tenantData.lastName!, email: tenantData.email!, phone: tenantData.phone!, age: tenantData.age!,dob:tenantData.dob!,unitId:tenantData.unitId!,assignmentLocUnitId:tenantData.assignmentLocUnitId!,unitName:(unitObject?.unitName)!,surveyStatus:(unitObject?.surveyStatus)!,isVirtualUnit:tenantData.virtualUnit!)
                    
                    
                    existingClientsDataArray.append(objectTenantStruct)
                }
                
            }
        }
        
        
        
        
        DispatchQueue.main.async {
            
            self.tblExistingClientsView.reloadData()
            //self.viewDidLayoutSubviews()
        }
        
        
        
        
    }
    
    
    @IBAction func showMoreAction(_ sender: Any) {
        populateExistingClientData()
    }
    
    func saveAction()
    {
        
        selectedExistingClientsArray = [ClientDataStruct]()
        var nonVirtualUnitCount = 0
        var clientMsg = ""
        
        
        //1 or multiple
        
        for indexPath in arrSelectedIndex
        {
            let selectedExistingClient = existingClientsDataArray[(indexPath as AnyObject).row]
            
            selectedExistingClientsArray.append(selectedExistingClient)
            
            if(selectedExistingClient.isVirtualUnit == "false"){
                nonVirtualUnitCount = nonVirtualUnitCount + 1
            }
            
            //virtual unit check
            //Some clients are already associated with the unit. Do you want to continue to reassociate with the new unit?
            
            print(selectedExistingClientsArray)
        }
        
        if(nonVirtualUnitCount == 1){
            clientMsg = "client is "
        }
        else if(nonVirtualUnitCount > 1){
            
            clientMsg = "some clients are "
        }
        
        
        if(clientMsg.isEmpty){
            self.navigateToIntakeForm()
        }
        else{
            
            let msg = clientMsg + "already associated with the unit. Do you want to continue to reassociate with the new unit?"
            
            let alertCtrl = Alert.showUIAlert(title: "Message", message: msg, vc: self)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel)
            { action -> Void in
                
            }
            
            alertCtrl.addAction(cancelAction)
            
            let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
                
                self.navigateToIntakeForm()
            }
            alertCtrl.addAction(okAction)
            
        }
        
    }
    
    func navigateToIntakeForm(){
        
        for selectedExistingClient  in self.selectedExistingClientsArray{
            self.saveSelectedClients(tenantId: selectedExistingClient.tenantId,dob:selectedExistingClient.dob)
        }
        
        // self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    func saveSelectedClients(tenantId:String,dob:String){
        
        
        var updateObjectDic:[String:String] = [:]
        
        //here check
        updateObjectDic["assignmentLocUnitId"] = SalesforceConnection.assignmentLocationUnitId
        
        updateObjectDic["unitId"] = SalesforceConnection.unitId
        
        updateObjectDic["actionStatus"] = "edit"
        
        if(dob != ""){
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from: dob)
            
            if(date != nil){
                
                dateFormatter.dateFormat = "MM/dd/yyyy"
                updateObjectDic["dob"] = dateFormatter.string(from: date!)
            }
            else{
                updateObjectDic["dob"] = dob
            }
        }
        
        //also check only that assignmentId ?
        ManageCoreData.updateRecord(salesforceEntityName: "Tenant", updateKeyValue: updateObjectDic, predicateFormat: "id == %@ AND assignmentId == %@", predicateValue: tenantId,predicateValue2: SalesforceConnection.assignmentId,isPredicate: true)
        
        
        
    }
    
    
    func cancelAction()
    {
        
        if arrSelectedIndex.count == 0
        {
            self.navigationController?.popViewController(animated: true)
            
        }
        else
        {
            let alertCtrl = Alert.showUIAlert(title: "Message", message: "Are you sure you want to cancel without saving?", vc: self)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel)
            { action -> Void in
                
            }
            
            alertCtrl.addAction(cancelAction)
            
            let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
                
                
                // self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }
            alertCtrl.addAction(okAction)
            
        }
        
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
            
            
            
            filteredTableData.removeAllObjects()
            
            
            
            var index = 0
            
            
            
            for searchitem in existingClientsDataArray
                
                
                
            {
                
                
                
                if searchitem.name.lowercased().contains(searchText.lowercased())
                    
                    
                    
                {
                    
                    
                    
                    filteredTableData.add(searchitem)
                    
                    
                    
                    
                    
                    
                    
                    for searchClientId in arrSelectedIndex
                        
                        
                        
                    {
                        
                        
                        
                        if searchitem.tenantId.contains(searchClientId as! String)
                            
                            
                            
                        {
                            
                            
                            
                            
                            
                            
                            
                            tblExistingClientsView.selectRow(at: IndexPath.init(row: index, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.none)
                            
                            
                            
                            break
                            
                            
                            
                        }
                        
                        
                        
                        
                        
                        
                        
                    }
                    
                    
                    
                    index = index + 1
                    
                    
                    
                }
                
                
                
            }
            
            
            
            
            
            
            
            
            
            
            
        }
        
        
        self.tblExistingClientsView.reloadData()
        
        
        
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
            
            
            
            tblExistingClientsView.reloadData()
            
            
            
        }
        
        
        
        
        
        
        
        // searchbarExistingClients.resignFirstResponder()
        
        
        
        view.endEditing(true)
        
        
        
    }
    
    
    
    
    
    
    
    // MARK: UITenantTableView and UIEditTableView
    
    
    
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int
        
        
        
    {
        
        return 1
        
    }
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
        
        
        
    {
        
        if isFiltered
            
        {
            
            
            
            return filteredTableData.count
            
            
            
        } else
            
            
            
        {
            
            
            
            return existingClientsDataArray.count
            
            
            
        }
        
        
        
        
    }
    
    
    
    
    
    
    
    // cell height
    
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        
        return UITableViewAutomaticDimension
        
        
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
        
        
        
    {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "existingClientCell", for: indexPath) as! ExistingClientsTableViewCell
        
        
        
        var clientData: ClientDataStruct
        
        
        
        if isFiltered
            
            
            
        {
            
            
            
            cell.name.text = (filteredTableData[indexPath.row] as! ClientDataStruct).name
            
            
            
            if((filteredTableData[indexPath.row] as! ClientDataStruct).phone.isEmpty){
                
                
                
                cell.phone.text = "                        "
                
                
                
            }
                
                
                
            else{
                
                
                
                cell.phone.text = (filteredTableData[indexPath.row] as! ClientDataStruct).phone.toPhoneNumber()
                
                
                
            }
            
            
            
            cell.age.text = (filteredTableData[indexPath.row] as! ClientDataStruct).age
            
            
            
            cell.email.text = (filteredTableData[indexPath.row] as! ClientDataStruct).email
            
            
            
            cell.clientId.text = (filteredTableData[indexPath.row] as! ClientDataStruct).tenantId
            
            
            
            clientData = (filteredTableData[indexPath.row] as! ClientDataStruct)
            
            
            
        }
            
            
            
            
            
            
            
        else
            
            
            
        {
            
            
            
            cell.name.text = existingClientsDataArray[indexPath.row].name
            
            
            
            if(existingClientsDataArray[indexPath.row].phone.isEmpty){
                
                
                
                cell.phone.text = "                        "
                
                
                
            }
                
                
                
            else{
                
                
                
                cell.phone.text = existingClientsDataArray[indexPath.row].phone.toPhoneNumber()
                
                
                
            }
            
            
            
            cell.age.text = existingClientsDataArray[indexPath.row].age
            
            
            
            cell.email.text = existingClientsDataArray[indexPath.row].email
            
            
            
            cell.clientId.text = existingClientsDataArray[indexPath.row].tenantId
            
            
            
            clientData = existingClientsDataArray[indexPath.row]
            
            
            
        }
        
        
        
        
        
        
        
        for searchClientId in arrSelectedIndex
            
            
            
        {
            
            
            
            if clientData.tenantId.contains(searchClientId as! String)
                
                
                
            {
                
                
                
                
                
                
                
                cell.backgroundColor = UIColor.clear//UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1)
                
                
                
                
                
                
                
                cell.existingClientView.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1)
                
                
                
                cell.contentView.backgroundColor = UIColor.clear
                
                
                
                cell.isSelected = true
                
                
                
                break
                
                
                
            }
                
                
                
                
                
                
                
            else
                
                
                
            {
                
                
                
                
                
                
                
                cell.existingClientView.backgroundColor = UIColor.white
                
                
                
                cell.backgroundColor = UIColor.clear
                
                
                
                cell.contentView.backgroundColor = UIColor.clear
                
                
                
                cell.isSelected = false
                
                
                
                
                
                
                
            }
            
            
            
        }
        
        
        
        if (cell.isSelected)
            
            
            
        {
            
            
            
            tblExistingClientsView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
            
            
            
        }
        
        
        
        let selectionView = UIView()
        
        
        
        selectionView.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1)
        
        
        
        cell.selectedBackgroundView = selectionView
        
        
        return cell
        
        
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
        
        
        
    {
        
        
        
        let currentCell = tableView.cellForRow(at: indexPath) as! ExistingClientsTableViewCell
        
        
        
        if isFiltered
            
            
            
        {
            
            
            
            arrSelectedIndex.add((filteredTableData.object(at: indexPath.row) as! ClientDataStruct).tenantId)
            
            
        }
            
            
            
        else
            
            
            
        {
            
            
            
            arrSelectedIndex.add(existingClientsDataArray[indexPath.row].tenantId)
            
            
            
        }
        
        
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
        
        
        
    {
        
        
        let currentCell = tableView.cellForRow(at: indexPath) as! ExistingClientsTableViewCell
        
        
        
        var clientID = ""
        
        
        
        if isFiltered
            
        {
            
            
            
            clientID = ((filteredTableData.object(at: indexPath.row) as! ClientDataStruct).tenantId)
            
            
            
        }
            
            
            
        else
            
        {
            
            clientID =  existingClientsDataArray[indexPath.row].tenantId
            
        }
        
        
        for searchClientId in arrSelectedIndex
            
            
        {
            
            
            
            if (searchClientId as! String) == (clientID)
                
                
            {
                
                
                
                arrSelectedIndex.remove(searchClientId)
                
                
                
                currentCell.existingClientView.backgroundColor = UIColor.white
                
                
                
                currentCell.backgroundColor = UIColor.clear
                
                
                
                //if arrSelectedIndex.count != 0 {
                
                
                
                break
                
                
                
                //}
                
                
                
            }
            
            
            
        }
        
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        // Dequeue with the reuse identifier
        
        
        
        let identifier = "existingClientsHeader"
        
        
        
        var cell: ExistingClientsHeaderTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? ExistingClientsHeaderTableViewCell
        
        
        
        
        if cell == nil {
            
            
            
            tableView.register(UINib(nibName: "ExistingClientsHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
            
            
            
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ExistingClientsHeaderTableViewCell
            
            
            
        }
        
        
        return cell
        
        
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44.0
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
        
    }
    
    
}
