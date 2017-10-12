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


protocol CanvassingStatusProtocol {
    func getCanvasssingStatus(strCanvassingStatus:String)
}

class EditLocationViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,CanvassingStatusProtocol
{
    
    // @IBOutlet weak var tblEditLocation : UITableView?
    
    
    
    var attempt:String = ""
    var canvassingStatus:String = ""
    var numberOfUnits:String = ""
    var notes:String = ""
    
    
    var arrStatusOption = NSMutableArray()
    var editLocDict : [String:String] = [:]
    
    @IBOutlet weak var fullAddressLbl: UILabel!
    @IBOutlet weak var tblEditLocation: UITableView!
    
    @IBOutlet weak var NotesTextArea: UITextView!
    
    // @IBOutlet weak var NotesTextArea: UITextView!
    
    func getCanvasssingStatus(strCanvassingStatus:String){
        
        canvassingStatus = strCanvassingStatus
        tblEditLocation?.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //setupStatusDropDown()
        
        fullAddressLbl.text = SalesforceConnection.fullAddress
        //self.txtStatusList.inputView = pickerView
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        
        // self.tblEditLocation?.separatorStyle = UITableViewCellSeparatorStyle.none
        
        self.tblEditLocation?.tableFooterView = UIView()
        //self.tblEditLocation?.dataSource = self
        //self.tblEditLocation?.delegate = self
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        NotesTextArea.layer.cornerRadius = 5
        NotesTextArea.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        NotesTextArea.layer.borderWidth = 0.5
        NotesTextArea.clipsToBounds = true
        
        
        NotesTextArea.textColor = UIColor.black
        
        
        populateEditLocation()
        
        
        // self.tblEditLocation?.tableFooterView = UIView()
        
        
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1{
            
            
            let canvassingStatusVC = self.storyboard!.instantiateViewController(withIdentifier: "canvassingStatusIdentifier") as? SelectCanvasssingStatusViewController
            
            canvassingStatusVC?.canvassingStatusProtocol = self
            
            canvassingStatusVC?.selectedCanvassingStatus = canvassingStatus
            
            self.navigationController?.pushViewController(canvassingStatusVC!, animated: true)
            
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "attemptCell")!
            cell.backgroundColor = UIColor.clear
            
            
            cell.textLabel?.text = "Attempt"
            cell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            cell.selectionStyle = .none
            
            //accessory switch
            let attemptSwitch = UISwitch(frame: CGRect.zero)
            
            if(attempt == "Yes"){
                attemptSwitch.isOn = true
            }
            else if (attempt == "No"){
                attemptSwitch.isOn = false
                // attemptRdb.isOn = false
            }
            else{
                attemptSwitch.isOn = false
            }
            
            
            
            attemptSwitch.addTarget(self, action: #selector(EditLocationViewController.attemptChanged(_:)), for: UIControlEvents.valueChanged)
            
            cell.accessoryView = attemptSwitch
            return cell
        }
        else if(indexPath.section == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "statusCell")!
            cell.backgroundColor = UIColor.clear
            
            cell.accessoryType = .disclosureIndicator
            
            cell.textLabel?.text = "Canvassing Status"
            // cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
            cell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            if(canvassingStatus.isEmpty){
                cell.detailTextLabel?.text = "Select Status"
                cell.detailTextLabel?.font = UIFont.init(name: "Arial", size: 18.0)
                
            }
            else{
                cell.detailTextLabel?.text = canvassingStatus
                cell.detailTextLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            }
            
            cell.detailTextLabel?.textColor = UIColor.lightGray
            
            //let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 21))
            
            return cell
            
        }
            
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noOfUnitsCell", for: indexPath)
            
            cell.selectionStyle = .none
            
            cell.textLabel?.text = "# of Units"
            cell.textLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            cell.detailTextLabel?.text = numberOfUnits
            cell.detailTextLabel?.font = UIFont.init(name: "Arial", size: 18.0)
            cell.detailTextLabel?.textColor = UIColor.lightGray
            
            return cell
        }
        
        
        
        
        
        
    }
    
    
    //    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    //        return 0.1
    //    }
    
    
    
    
    
    
    func attemptChanged(_ sender: UISwitch)
    {
        
        //let index = sender.tag
        if(sender.isOn){
            attempt = "Yes"
        }
        else{
            attempt = "No"
        }
        
        //let indexRow = (sender as AnyObject).tag
        
    }
    
    
    func populateEditLocation(){
        
        let editLocationResults = ManageCoreData.fetchData(salesforceEntityName: "EditLocation",predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId, isPredicate:true) as! [EditLocation]
        
        if(editLocationResults.count > 0){
            
            
            
            canvassingStatus = editLocationResults[0].canvassingStatus!
            
            
            numberOfUnits = editLocationResults[0].noOfUnits!
            
            notes = editLocationResults[0].notes!
            NotesTextArea.text = notes
            
            
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
    
    @IBAction func cancelLocation(_ sender: Any)
    {
        let alertCtrl = Alert.showUIAlert(title: "Message", message: "Are you sure you want to close without saving?", vc: self)

        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel) { action -> Void in
        }
        alertCtrl.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        alertCtrl.addAction(okAction)

    }
    
    
    @IBAction func saveLocation(_ sender: Any) {
        
        if let notesTemp = NotesTextArea.text{
            notes = notesTemp
        }
        
        updateEditLocationInDatabase()
        
        self.view.makeToast("Location has been edited successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
            
            Utilities.isEditLoc = true
            Utilities.CanvassingStatus = self.canvassingStatus
            
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateLocationView"), object: nil)
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
        
        
        
    }
    
    
    
}
