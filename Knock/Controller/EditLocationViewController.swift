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

class EditLocationViewController: UIViewController,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource
{
    @IBOutlet weak var attemptRdb: UISwitch!
    @IBOutlet weak var txtUnits: UILabel!
    
    let pickerView = UIPickerView()
    @IBOutlet weak var txtStatusList: UITextField!
    
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
         self.txtStatusList.inputView = pickerView
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        

        
        self.navigationController?.navigationBar.tintColor = UIColor.white

        NotesTextArea.layer.cornerRadius = 5
        NotesTextArea.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        NotesTextArea.layer.borderWidth = 0.5
        NotesTextArea.clipsToBounds = true
        
        //NotesTextArea.text = "Description"
        NotesTextArea.textColor = UIColor.black
        pickerView.delegate = self
        arrStatusOption = ["Blocked","Planned","In Progress","Completed"]
        

        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        
        let cancelBtn = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SaveEditTenantViewController.cancelPressed))
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(SaveEditTenantViewController.donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label.font = UIFont(name: "Helvetica", size: 12)
        
        label.backgroundColor = UIColor.clear
        
        label.textColor = UIColor.white
        
        label.text = "Select Status"
        
        label.textAlignment = NSTextAlignment.center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([cancelBtn,flexSpace,textBtn,flexSpace,doneBtn], animated: true)
        
        txtStatusList.inputAccessoryView = toolBar
        populateEditLocation()
        
    
        
      

        // Do any additional setup after loading the view.
    }
    
    func cancelPressed(sender: UIBarButtonItem)
    {
        
        txtStatusList.resignFirstResponder()
    }
    
    func donePressed(sender: UIBarButtonItem) {
        
       
        txtStatusList.text = canvassingStatus
        
        txtStatusList.resignFirstResponder()
        
    }

    
    @IBAction func attemptChanged(_ sender: Any) {
        
        if(attemptRdb.isOn){
            attempt = "Yes"
        }
        else{
            attempt = "No"
        }

    }
    
    // MARK: Pickerview Delegates Methods
       public func numberOfComponents(in pickerView: UIPickerView) -> Int
       {
        return 1
    }
   
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        
            return self.arrStatusOption.count
        
       
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        
            return arrStatusOption.object(at: row) as? String

        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        
         canvassingStatus = (arrStatusOption.object(at: row) as? String)!
        
        //  self.txtStatusList.text = arrStatusOption.object(at: row) as? String
            
        
    }
    
//MARK: - uitextfiled delegate
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let aSet = NSCharacterSet(charactersIn:"0123456789abc").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        
       
//        let currentCharacterCount = NoOfUnitsTextField.text?.characters.count ?? 0
//        if (range.length + range.location > currentCharacterCount){
//            return false
//        }
//        let newLength = currentCharacterCount + string.characters.count - range.length
//        if(newLength > 5){
//            return false
//        }
        
        
        return string == numberFiltered
    }
    
    func populateEditLocation(){
        
        let editLocationResults = ManageCoreData.fetchData(salesforceEntityName: "EditLocation",predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId, isPredicate:true) as! [EditLocation]
        
        if(editLocationResults.count > 0){
            
//            if(editLocationResults[0].canvassingStatus! != ""){
//                self.canvassingStatusDropDown.setTitle(editLocationResults[0].canvassingStatus!, for: .normal)
//            }
            
            canvassingStatus = editLocationResults[0].canvassingStatus!
            
            txtStatusList.text = canvassingStatus
            
            numberOfUnits = editLocationResults[0].noOfUnits!
            txtUnits.text = numberOfUnits
            
            notes = editLocationResults[0].notes!
            NotesTextArea.text = notes
            
            if(editLocationResults[0].attempt == "Yes"){
                attemptRdb.isOn = true
            }
            else if (editLocationResults[0].attempt == "No"){
                attemptRdb.isOn = false
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
        
        self.view.makeToast("Location has been edit successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
//        editLocDict = Utilities.editLocData(canvassingStatus: canvassingStatus, assignmentLocationId: SalesforceConnection.assignmentLocationId, notes: notes, attempt: attempt, numberOfUnits: numberOfUnits)
//        
//        if(Network.reachability?.isReachable)!{
//            
//            pushEditLocDataToSalesforce()
//        }
//            
//        else{
//            self.view.makeToast("Location has been edit successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
//                
//                self.dismiss(animated: true, completion: nil)
//                
//            }
//        }
//
// 
        

    }
    
    func pushEditLocDataToSalesforce(){
       
        var updateLocation : [String:String] = [:]
        
        updateLocation["location"] = Utilities.encryptedParams(dictParameters: editLocDict as AnyObject)

        
        
        
        SVProgressHUD.show(withStatus: "Updating Location...", maskType: SVProgressHUDMaskType.gradient)
        
        SalesforceConnection.loginToSalesforce(companyName: SalesforceConnection.companyName) { response in
            
            if(response)
            {
                
                
               SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.updateLocation, params: updateLocation){ jsonData in
                    
                    SVProgressHUD.dismiss()
                
                   // Utilities.parseEditLocationResponse(jsonObject: jsonData.1)
                
                    self.view.makeToast("Location has been assigned successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                    
                    
                    
                }
            }
            
        }

    }

   
}
