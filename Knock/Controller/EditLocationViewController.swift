//
//  EditLocationViewController.swift
//  Knock
//
//  Created by Kamal on 16/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit
import DropDown
import DLRadioButton

class EditLocationViewController: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    
    @IBOutlet weak var tblEditLocation : UITableView?
    
    var strStatus: String!
   
    
    var attempt:String = ""
    var canvassingStatus:String = ""
    var numberOfUnits:String = ""
    var notes:String = ""
    
    
     var arrStatusOption = NSMutableArray()
     var editLocDict : [String:String] = [:]
    
    @IBOutlet weak var fullAddressLbl: UILabel!

    
    @IBOutlet weak var NotesTextArea: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       //setupStatusDropDown()
        
        fullAddressLbl.text = SalesforceConnection.fullAddress
         //self.txtStatusList.inputView = pickerView
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        
       // self.tblEditLocation?.separatorStyle = UITableViewCellSeparatorStyle.none
       
        //self.tblEditLocation?.tableFooterView = UIView()
        self.tblEditLocation?.dataSource = self
        self.tblEditLocation?.delegate = self
        self.navigationController?.navigationBar.tintColor = UIColor.white

        NotesTextArea.layer.cornerRadius = 5
        NotesTextArea.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        NotesTextArea.layer.borderWidth = 0.5
        NotesTextArea.clipsToBounds = true
        
       
        NotesTextArea.textColor = UIColor.black
        
      
       // populateEditLocation()
        
    
        
      

        // Do any additional setup after loading the view.
    }
    
    
    
    
    //Mark: tableview delegets
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 3
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
        if indexPath.section == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "attemptCell", for: indexPath) as! EditLocAttemptTableViewCell
            
         //   cell.switchOn.addTarget(self, action: #selector(EditLocationViewController.attemptChanged(_:)), for: .valueChanged)
            
            return cell
        }
        
        
    else if indexPath.section == 1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "statusCell", for: indexPath) as! EditLocStatusTableViewCell
            
            
            if (strStatus ?? "").isEmpty
            {
                 cell.btnSelectStatus.setTitle("Select Status", for: .normal)
            }
            
            else
            {
                cell.btnSelectStatus.setTitle(strStatus, for: .normal)
                
            }
            
           
            
            //cell.btnSelcetStatus.index = selectedItem.row
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noOfUnitsCell", for: indexPath) as! EditLocNoOfUnitsTableViewCell
            
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
//     func attemptChanged(_ sender: Any)
//     {
//    
//            if(attemptRdb.isOn){
//                attempt = "Yes"
//            }
//            else{
//                attempt = "No"
//            }
//    
//        }
 
    
    func populateEditLocation(){
        
        let editLocationResults = ManageCoreData.fetchData(salesforceEntityName: "EditLocation",predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId, isPredicate:true) as! [EditLocation]
        
        if(editLocationResults.count > 0){
            

            
            canvassingStatus = editLocationResults[0].canvassingStatus!
            
          //  txtStatusList.text = canvassingStatus
            
            numberOfUnits = editLocationResults[0].noOfUnits!
          //  txtUnits.text = numberOfUnits
            
            notes = editLocationResults[0].notes!
            NotesTextArea.text = notes
            
            if(editLocationResults[0].attempt == "Yes"){
               // attemptRdb.isOn = true
            }
            else if (editLocationResults[0].attempt == "No"){
               // attemptRdb.isOn = false
            }
            else{
                editLocationResults[0].attempt = "No"
            }
            
            attempt = editLocationResults[0].attempt!
            
        }

    }
    
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
   
   

    
    
    

    func updateEditLocationInDatabase(){
            
            var updateObjectDic:[String:String] = [:]
            
            //updateObjectDic["id"] = tenantDataDict["tenantId"] as! String?
            
            updateObjectDic["attempt"] = attempt
            updateObjectDic["canvassingStatus"] = canvassingStatus
            updateObjectDic["noOfUnits"] = numberOfUnits
            updateObjectDic["notes"] = notes
            updateObjectDic["actionStatus"] = "edit"
        
            
            
            ManageCoreData.updateRecord(salesforceEntityName: "EditLocation", updateKeyValue: updateObjectDic, predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ ", predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId,isPredicate: true)
            
        
        
    }
    
    @IBAction func cancelLocation(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func saveLocation(_ sender: Any) {
       
        if let notesTemp = NotesTextArea.text{
            notes = notesTemp
        }
        
        updateEditLocationInDatabase()
        
        self.view.makeToast("Location has been edited successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
            
            self.dismiss(animated: true, completion: nil)
            
        }
        

        

    }
    
   
   
}
