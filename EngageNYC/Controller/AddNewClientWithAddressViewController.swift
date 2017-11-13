//
//  AddNewClientWithAddressViewController.swift
//  EngageNYC
//
//  Created by Cloudzeg Laptop on 10/6/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

struct ClientNoUnitDataStruct
{
    var clientId : String = ""
    var name:String = ""
    var firstName : String = ""
    var lastName : String = ""
    var email : String = ""
    var phone : String = ""
    var age : String = ""
    var dob:String = ""
    var address:String = ""
    
    //var teantStatus:String = ""
    //var inTakeStaus:String = ""
    
}

class AddNewClientWithAddressViewController: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    @IBOutlet weak var tblAddClientListing: UITableView!
    @IBOutlet weak var btnAddClient: UIButton!
    
    var clientDataArray = [ClientNoUnitDataStruct]()
    
       override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        btnAddClient.layer.cornerRadius = 5
        btnAddClient.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector:#selector(AddNewClientWithAddressViewController.UpdateNoUnitClientView), name: NSNotification.Name(rawValue: "UpdateNoUnitClientView"), object:nil
        )
        
    }
    
    func UpdateNoUnitClientView(){
        print("UpdateNoUnitClientView")
        
        populateNoUnitClientData()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        UpdateNoUnitClientView()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    var clientResults = [Tenant]()
    
    func populateNoUnitClientData(){
        
        clientDataArray = [ClientNoUnitDataStruct]()
        
        clientResults = ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "assignmentLocId == %@ && assignmentId == %@" ,predicateValue: SalesforceConnection.assignmentLocationId,predicateValue2: SalesforceConnection.assignmentId, isPredicate:true) as! [Tenant]
        
        if(clientResults.count > 0){
            
            for clientData in clientResults{
                
             var address = clientData.streetNum! + " " + clientData.streetName! + " "
                
             address = address + clientData.borough! + ", " + clientData.zip!
                
                
                
                //if (clientData.unitId!.isEmpty){
                    
                let objectClientStruct:ClientNoUnitDataStruct = ClientNoUnitDataStruct(clientId: clientData.id!,name: clientData.name!, firstName: clientData.firstName!, lastName: clientData.lastName!, email: clientData.email!, phone: clientData.phone!, age: clientData.age!,dob:clientData.dob!,address:address)
                
                    clientDataArray.append(objectClientStruct)
                //}
                
            }
        }
        
        
        
        
        // selectedTenantId = setSelectedTenant()
        
        self.tblAddClientListing.reloadData()
        
        
        
        
        
    }
    
    // MARK: UITenantTableView and UIEditTableView
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return clientDataArray.count
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AddClientWithAddressTableViewCell
        
        let selectionView = UIView()
        selectionView.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1)
        cell.selectedBackgroundView = selectionView

        cell.AddClientWithAddressView.backgroundColor = UIColor.white
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
        
        cell.address.text = clientDataArray[indexPath.row].address
        
        return cell
      }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
   
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        
        
        let identifier = "addNewClientHeaderIdentifier"
        var cell: AddNewClientHeaderTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? AddNewClientHeaderTableViewCell
        
        if cell == nil {
            tableView.register(UINib(nibName: "AddNewClientHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? AddNewClientHeaderTableViewCell
        }
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showAddClientIdentifier" {
            let vc = segue.destination as! UINavigationController
            let addVC = vc.viewControllers[0]  as! SaveEditTenantViewController
            print(addVC.preferredContentSize)
            addVC.isSurveyAddClient = false
        }
    }


    @IBAction func btnCancelAction(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addNewClientAction(_ sender: Any)
    {
        
       self.performSegue(withIdentifier: "showAddClientIdentifier", sender: nil)
    }

   

}
