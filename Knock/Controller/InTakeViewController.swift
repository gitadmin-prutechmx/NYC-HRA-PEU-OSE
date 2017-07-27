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

    @IBOutlet weak var nextOutlet: UIBarButtonItem!
    
    @IBOutlet weak var fullAddressTxt: UILabel!
    
    @IBOutlet weak var tblTenantView: UITableView!
    
    @IBOutlet weak var addTenantOutlet: UIButton!
    
    @IBOutlet weak var segmentedOutlet: UISegmentedControl!
    
    var clientDataArray = [ClientUnitDataStruct]()
    
     var selectedClientId:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTenantOutlet.layer.cornerRadius = 5
        
        fullAddressTxt.text = "Unit: " + SalesforceConnection.unitName + "  |  " + SalesforceConnection.fullAddress
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        
        
        
        self.navigationController?.navigationBar.tintColor = UIColor.white

        
        self.navigationItem.rightBarButtonItem = nil
        
        
        populateClientData()
        
       

        // Do any additional setup after loading the view.
    }
    
    
    
    func populateClientData(){
        
        clientDataArray = [ClientUnitDataStruct]()
        
        
        let clientResults = ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "assignmentId == %@ AND locationId == %@ AND unitId == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId,predicateValue3: SalesforceConnection.unitId,isPredicate:true) as! [Tenant]
        
        
        if(clientResults.count > 0){
            
            for clientData in clientResults{
                
                
                
                let objectClientStruct:ClientUnitDataStruct = ClientUnitDataStruct(clientId: clientData.id!,name: clientData.name!, firstName: clientData.firstName!, lastName: clientData.lastName!, email: clientData.email!, phone: clientData.phone!, age: clientData.age!,dob:clientData.dob!)
                
                clientDataArray.append(objectClientStruct)
                
            }
        }
        
        
        
        
       // selectedTenantId = setSelectedTenant()
        
        self.tblTenantView.reloadData()
        
      
        
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addTenant(_ sender: Any) {
        SalesforceConnection.currentTenantId =  ""
        
        self.performSegue(withIdentifier: "showSaveEditTenantIdentifier", sender: nil)
    }

    @IBAction func editTenant(_ sender: Any) {
      
        let indexRow = (sender as AnyObject).tag
        
        SalesforceConnection.currentTenantId =  clientDataArray[indexRow!].clientId
        
        self.performSegue(withIdentifier: "showSaveEditTenantIdentifier", sender: nil)
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        let msgtitle = "Message"
        
        let alertController = UIAlertController(title: "Message", message: "Are you sure you want to cancel without saving?", preferredStyle: .alert)
        alertController.setValue(NSAttributedString(string: msgtitle, attributes: [NSFontAttributeName :  UIFont(name: "Arial", size: 17.0)!, NSForegroundColorAttributeName : UIColor.black]), forKey: "attributedTitle")
        
        
        
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Do some stuff
        }
        alertController.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
            
            self.dismiss(animated: true, completion: nil)
            //Do some other stuff
        }
        alertController.addAction(okAction)
        
        
        self.present(alertController, animated: true, completion: nil)
        

        
    }
    
    @IBAction func next(_ sender: Any) {
        
    }
    
    @IBAction func segmentedChange(_ sender: Any) {
        
      switch segmentedOutlet.selectedSegmentIndex
        {
        case 0:
           // Utilities.currentUnitClientPage = "Unit"
           self.navigationItem.rightBarButtonItem =  nil
        
        case 1:
           // Utilities.currentUnitClientPage = "Client"
           self.navigationItem.rightBarButtonItem =  nextOutlet
        
        default:
            break;
        }
        
    }
    
    
    // MARK: UITenantTableView and UIEditTableView
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if(tableView == tblTenantView){
            return 1
        }
        else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == tblTenantView){
            return clientDataArray.count
        }
        else{
            return 1
        }
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
 
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        
        if(tableView == tblTenantView){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TenantViewCell
            
            if(clientDataArray[indexPath.row].clientId == selectedClientId){
                
                
                cell.tenantView.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) //green
                cell.contentView.backgroundColor =  UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) //green
                cell.isSelected = true
                cell.setSelected(true, animated: true)
                
                
            }
            
            cell.email.text = clientDataArray[indexPath.row].email
            cell.phone.text = clientDataArray[indexPath.row].phone
            cell.name.text = clientDataArray[indexPath.row].name
            cell.age.text = clientDataArray[indexPath.row].age
            cell.tenantId.text = clientDataArray[indexPath.row].clientId
            
            cell.editBtn.tag = indexPath.row
            
            
            return cell
        }
            
        else{
             let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            return cell
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(tableView == tblTenantView){
            let indexPathArray = tableView.indexPathsForVisibleRows
            
            for indexPath in indexPathArray!{
                
                let cell = tableView.cellForRow(at: indexPath) as! TenantViewCell
                
                if tableView.indexPathForSelectedRow != indexPath {
                    
                    cell.tenantView.backgroundColor = UIColor.white
                    cell.contentView.backgroundColor = UIColor.clear
                    
                }
                else{
                    
                    cell.tenantView.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) //green
                    
                    cell.contentView.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) //green
                    
                    
                }
            }
            
            selectedClientId = clientDataArray[indexPath.row].clientId
        }
        else{
            
            
        }
        
    }
    
  
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Dequeue with the reuse identifier
        if tableView == tblTenantView
        {
            let identifier = "tenantHeader"
            var cell: TenantHeaderTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? TenantHeaderTableViewCell
            
            if cell == nil {
                tableView.register(UINib(nibName: "TenantHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
                cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? TenantHeaderTableViewCell
            }
            
            return cell
        }
        else{
            return UIView()
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == tblTenantView
        {
            return 44.0
        }
        else{
            return  0.0
        }
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
