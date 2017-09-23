//
//  InTakeViewController.swift
//  Knock
//
//  Created by Kamal on 27/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

struct ClientUnitDataStruct
{
    var clientId : String = ""
    var name:String = ""
    var firstName : String = ""
    var lastName : String = ""
    var email : String = ""
    var phone : String = ""
    var age : String = ""
    var dob:String = ""
    //var teantStatus:String = ""
    //var inTakeStaus:String = ""
    
}



class InTakeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    @IBOutlet weak var btnExistingClients: UIButton!
    @IBOutlet weak var viewTenent: UIView!
    @IBOutlet weak var btnGotoCase: UIButton!
    
    @IBOutlet weak var fullAddressTxt: UILabel!
   
    
    @IBOutlet weak var tblTenantView: UITableView!
    
    @IBOutlet weak var addTenantOutlet: UIButton!
    
    
    var clientDataArray = [ClientUnitDataStruct]()
    var caseDataArray = [CaseDataStruct]()
    
    var selectedClientId:String = ""
    var selectedClientName:String = ""
    var selectedCaseId:String = ""
    var selectedCaseNo:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTenantOutlet.layer.cornerRadius = 5
        btnExistingClients.layer.cornerRadius = 5
        btnGotoCase.layer.cornerRadius = 5
        
        fullAddressTxt.text = "Unit: " + SalesforceConnection.unitName + "  |  " + SalesforceConnection.fullAddress
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        
        
        
        self.navigationController?.navigationBar.tintColor = UIColor.white

        NotificationCenter.default.addObserver(self, selector:#selector(InTakeViewController.UpdateClientView), name: NSNotification.Name(rawValue: "UpdateClientView"), object:nil
        )
        
    }
    
    func UpdateClientView(){
        print("UpdateClientView")
      
        populateClientData()
    }
    

    // Cleanup notifications added in viewDidLoad
    deinit {
        NotificationCenter.default.removeObserver("UpdateClientView")
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        selectedClientId = ""
        selectedClientName = ""
        selectedCaseId = ""
        selectedCaseNo = ""
 
        
       
            showClientView()
        
        

    }
    
       
    var clientResults = [Tenant]()
    
    
    func populateClientData(){
        
        clientDataArray = [ClientUnitDataStruct]()
        
        
        clientResults = ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "assignmentId == %@ AND locationId == %@ AND unitId == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId,predicateValue3: SalesforceConnection.unitId,isPredicate:true) as! [Tenant]
        
        
        if(clientResults.count > 0){
            
            for clientData in clientResults{
                
                
                
                let objectClientStruct:ClientUnitDataStruct = ClientUnitDataStruct(clientId: clientData.id!,name: clientData.name!, firstName: clientData.firstName!, lastName: clientData.lastName!, email: clientData.email!, phone: clientData.phone!, age: clientData.age!,dob:clientData.dob!)
                
                clientDataArray.append(objectClientStruct)
                
            }
        }
        
        
        
        
       // selectedTenantId = setSelectedTenant()
        
        self.tblTenantView.reloadData()
        
      
        
        
        
    }


   
    
    @IBAction func addTenant(_ sender: Any) {
        
        //Utilities.currentSurveyInTake = "Client"
        
        showAddNewClient()
    }
    
    func showAddNewClient(){
        
        SalesforceConnection.currentTenantId =  ""
        
        SalesforceConnection.isNewContactWithAddress = false
        
        self.performSegue(withIdentifier: "showSaveEditTenantIdentifier", sender: nil)
    }

    @IBAction func editTenant(_ sender: Any) {
      
        let indexRow = (sender as AnyObject).tag
        
        SalesforceConnection.currentTenantId =  clientDataArray[indexRow!].clientId
        
        SalesforceConnection.isNewContactWithAddress = false
        
        self.performSegue(withIdentifier: "showSaveEditTenantIdentifier", sender: nil)
        
    }
        
    @IBAction func discloseSwitch(_ sender: Any) {
    }
    @IBAction func cancel(_ sender: Any) {
        
          self.dismiss(animated: true, completion: nil)
    }
    
    
   
    @IBAction func btnExistingClientsViewAction(_ sender: Any)
    {
        self.performSegue(withIdentifier: "ExistingViewIdentifier", sender: nil)
    }
    
    @IBAction func btnGotoCaseAction(_ sender: Any) {
        
        if(selectedClientId == ""){
            viewTenent.shake()
            self.view.makeToast("Please select client. ", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                
            }
            
        }
        else{
            SalesforceConnection.currentTenantId = selectedClientId
            
            SalesforceConnection.currentTenantName =  selectedClientName
            
            self.performSegue(withIdentifier: "showCaseIdentifier", sender: nil)
            
            
            
        }
    }
    
    func addRightBarButtonOnClient()
    {
        
        self.navigationItem.rightBarButtonItem =  nil
        
        let rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(InTakeViewController.saveAction))
        
        self.navigationItem.rightBarButtonItem  = rightBarButtonItem
    }
    
    
    func showClientView(){

        addRightBarButtonOnClient()
        populateClientData()
        
    }
    
       
    func saveAction()
    {
        
        if(selectedClientId == ""){
            viewTenent.shake()
            self.view.makeToast("Please select client. ", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                
            }
            
        }
        else{
            
            SalesforceConnection.selectedTenantForSurvey = selectedClientId
            
            self.dismiss(animated: true, completion: nil)
            
            
        }
        

    }
    
    
  
    
    // MARK: UITenantTableView and UIEditTableView
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return clientDataArray.count
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
 
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TenantViewCell
            
            cell.tenantView.backgroundColor = UIColor.white
            cell.contentView.backgroundColor = UIColor.clear
            

            
            cell.email.text = clientDataArray[indexPath.row].email
            if(clientDataArray[indexPath.row].phone.isEmpty){
                cell.phone.text = "             "
            }
            else{
                cell.phone.text = clientDataArray[indexPath.row].phone.toPhoneNumber()
            }
            cell.name.text = clientDataArray[indexPath.row].name
            cell.age.text = clientDataArray[indexPath.row].age
            cell.tenantId.text = clientDataArray[indexPath.row].clientId
            
            cell.editBtn.tag = indexPath.row
            
            
            return cell
        
            
                
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
            let indexPathArray = tblTenantView.indexPathsForVisibleRows
            
            for indexPath in indexPathArray!
            {
                
                let cell = tblTenantView.cellForRow(at: indexPath) as! TenantViewCell
                
                if tblTenantView.indexPathForSelectedRow != indexPath {
                    
                    cell.tenantView.backgroundColor = UIColor.white
                    cell.contentView.backgroundColor = UIColor.clear
                    
                }
                else{
                    
                    cell.tenantView.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) //green
                    
                    cell.contentView.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) //green
                    
                    
                }
            }
            
            selectedClientId = clientDataArray[indexPath.row].clientId
            selectedClientName = clientDataArray[indexPath.row].name

        
    }
    
  
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Dequeue with the reuse identifier
        
            let identifier = "tenantHeader"
            var cell: TenantHeaderTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? TenantHeaderTableViewCell
            
            if cell == nil {
                tableView.register(UINib(nibName: "TenantHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
                cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? TenantHeaderTableViewCell
            }
            
            return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       
            return 44.0
    }

}
    
    


