//
//  ExistingClientsViewController.swift
//  Knock
//
//  Created by Cloudzeg Laptop on 9/15/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class ExistingClientsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    @IBOutlet weak var tblExistingClientsView: UITableView!
    
    var arrSelectedIndex = [AnyObject]()
    var existingClientsDataArray = [ClientDataStruct]()
    
   
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.navigationItem.rightBarButtonItem =  nil
        
        let rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(ExistingClientsViewController.saveAction))
        
        self.navigationItem.rightBarButtonItem  = rightBarButtonItem
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateExistingClientData()
    }
    
    
    func populateExistingClientData(){
        
        existingClientsDataArray = [ClientDataStruct]()
        
        
        Utilities.unitClientDict = [:]
        Utilities.caseDict = [:]
        
        Utilities.createUnitDictionary()
        Utilities.createCaseDictionary()
        
        let clientResults = ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "assignmentId == %@ AND locationId == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId,isPredicate:true) as! [Tenant]
        
        
        if(clientResults.count > 0){
            
            for tenantData in clientResults{
                
                let unitObject = Utilities.unitClientDict[tenantData.unitId!]
                
                let objectTenantStruct:ClientDataStruct = ClientDataStruct(tenantId: tenantData.id!,name: tenantData.name!, firstName: tenantData.firstName!, lastName: tenantData.lastName!, email: tenantData.email!, phone: tenantData.phone!, age: tenantData.age!,dob:tenantData.dob!,unitId:tenantData.unitId!,assignmentLocUnitId:tenantData.assignmentLocUnitId!,unitName:(unitObject?.unitName)!,surveyStatus:(unitObject?.surveyStatus)!,isVirtualUnit:tenantData.virtualUnit!)
                
                existingClientsDataArray.append(objectTenantStruct)
                
            }
        }
        
      
        
        
        DispatchQueue.main.async {
            
            self.tblExistingClientsView.reloadData()
            //self.viewDidLayoutSubviews()
        }
        
        
        
        
    }

    
    func saveAction()
    {
        
        
        
    }
        
        
    
    

    
    // MARK: UITenantTableView and UIEditTableView
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return existingClientsDataArray.count
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
       
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "existingClientCell", for: indexPath) as! ExistingClientsTableViewCell
        
        
        
        cell.existingClientView.backgroundColor = UIColor.white
        cell.contentView.backgroundColor = UIColor.clear
        let selectionView = UIView()
        selectionView.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1)
        cell.selectedBackgroundView = selectionView
        
        
        cell.name.text = existingClientsDataArray[indexPath.row].name
        cell.phone.text = existingClientsDataArray[indexPath.row].phone.toPhoneNumber()
        cell.age.text = existingClientsDataArray[indexPath.row].age
        cell.email.text = existingClientsDataArray[indexPath.row].email
        cell.clientId.text = existingClientsDataArray[indexPath.row].tenantId
        
        //unit id ,unit name and cases
        
        /*let noOfCases = Utilities.caseDict[clientDataArray[indexPath.row].tenantId]
        
        if let caseCount = noOfCases{
            cell.lblCase.text = caseCount
        }
        else{
            cell.lblCase.text = "0"
        }
        
        
        
        
        cell.lblUnitName.text = clientDataArray[indexPath.row].unitName
        cell.lblUnitId.text = clientDataArray[indexPath.row].unitId
 
 */
        
        return cell
        
        
        
    }
    
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
       // arrSelectedIndex.append(indexPath as AnyObject)
    }
    
   func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
   {
        //arrSelectedIndex.remove(at: indexPath!)
    }

     /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
            let cell = tblExistingClientsView.cellForRow(at: indexPath) as! ExistingClientsTableViewCell
                
                cell.existinClientsView.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) //green
                
                cell.contentView.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) //green
        
    }
   
 
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        let cell = tblExistingClientsView.cellForRow(at: indexPath) as! ExistingClientsTableViewCell
        
        
        cell.existinClientsView.backgroundColor = UIColor.white
        
        cell.contentView.backgroundColor = UIColor.clear

    }
    
    */
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
