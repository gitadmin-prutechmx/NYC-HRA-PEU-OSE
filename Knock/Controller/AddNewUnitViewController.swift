//
//  AddNewUnitViewController.swift
//  Knock
//
//  Created by Kamal on 22/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class AddNewUnitViewController: UIViewController {
   
    @IBOutlet weak var apartmentName: UITextField!

    @IBOutlet weak var notesTextArea: UITextView!
//    @IBOutlet weak var apartmentName: UITextField!
//    
//    @IBOutlet weak var notesTextArea: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        notesTextArea.layer.cornerRadius = 5
        notesTextArea.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        notesTextArea.layer.borderWidth = 0.5
        notesTextArea.clipsToBounds = true
        
        //NotesTextArea.text = "Description"
        notesTextArea.textColor = UIColor.black


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        saveUnitInfo()
    }
    
    
    func saveUnitInfo(){
        
        var saveUnitDict : [String:String] = [:]
        
        var saveUnit : [String:String] = [:]
        
        
       
        var apartmentNumberVal:String = ""
        var notesVal:String = ""
        
        
        
       
        
       
        if let apartmentNumberTemp = apartmentName.text{
            
            apartmentNumberVal = apartmentNumberTemp
            
        }
        
        if let notesTemp = notesTextArea.text{
            
            notesVal = notesTemp
            
        }
        
        
      
        
       // saveUnitDict["locationUnitId"] = SalesforceConnection.unitId
        
        saveUnitDict["unitName"] = "Apt " + apartmentNumberVal
        
        saveUnitDict["apartmentNumber"] = apartmentNumberVal
        
        saveUnitDict["locationId"] = SalesforceConnection.locationId
        
        saveUnitDict["assignLocId"] = SalesforceConnection.assignmentLocationId
        
        saveUnitDict["notes"] = notesVal
        
        //...............create unit
        
        //update static values as well check then update SalesforceConnection
        
        // saveUnitDict["iosLocUnitId"] = new loc unit id
        // saveUnitDict["iosAssignmentLocUnitId"] = new assignment loc unit id
        
        
        // save whole data into database with type "create"
        
        //then check connection is on or off if yes then convert into string and push to salesforce and when response (if error then hide progress and show message) and update database with unit id and assilocunitid and type also
        
        //.................update unit
        
        //where call 2 min syncing?
        
        
        

        
        
        
        
        
        
        let convertedString = Utilities.jsonToString(json: saveUnitDict as AnyObject)
        
        
        
        let encryptSaveUnitStr = try! convertedString?.aesEncrypt(SalesforceConfig.key, iv: SalesforceConfig.iv)
        
        
        
        saveUnit["unit"] = encryptSaveUnitStr
        
        
        
        SVProgressHUD.show(withStatus: "Saving Unit...", maskType: SVProgressHUDMaskType.gradient)
        
        
        SalesforceConnection.loginToSalesforce(companyName: SalesforceConnection.companyName) { response in
            
            if(response)
                
            {
                
                SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.createUnit, params: saveUnit){ jsonData in
                    
                    
                    
                    
                    
                    SVProgressHUD.dismiss()
                    
                    self.parseResponse(jsonObject: jsonData.1)
                    
                    
                    
                    
                }
                
            }
            
            
        }
        
        
        
        
    }
    
    func parseResponse(jsonObject: Dictionary<String, AnyObject>){
        
        guard let isError = jsonObject["hasError"] as? Bool,
            
            let unitDataDict = jsonObject["unitData"] as? [String: AnyObject] else { return }
        
        
        
        
        if(isError == false){
            
            
            
            let unitObject = Unit(context: context)
            
            
            unitObject.id = unitDataDict["locUnitId"] as! String?
            
            unitObject.name = unitDataDict["unitName"] as! String?
            
            unitObject.apartment = unitDataDict["apartmentNumber"] as! String?
            
            
            
            
            
            unitObject.assignmentId = SalesforceConnection.assignmentId
            
            unitObject.locationId = SalesforceConnection.locationId
            
            unitObject.assignmentLocUnitId = unitDataDict["assignmentLocUnitId"] as! String?
            
            unitObject.surveyStatus = ""
            unitObject.syncDate = ""
            
            appDelegate.saveContext()
            
            updateAssignmentUnit()
            
            
            
            
            
            
            
            self.view.makeToast("Unit information has been created successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                if didTap {
                    
                    Utilities.isSubmitSurvey = false
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                    
                    
                } else {
                    
                    Utilities.isSubmitSurvey = false
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
                    
                    self.dismiss(animated: true, completion: nil)
                    
                    
                }
                
            }
            
            
            
            
            
        }
            
        else{
            
            self.view.makeToast("Error while updating Tenant info", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                if didTap {
                    
                    print("completion from tap")
                    
                } else {
                    
                    print("completion without tap")
                    
                }
                
            }
            
            
            
        }
        
        
        
    }
    
    func updateAssignmentUnit(){
        
        let assignementResults = ManageCoreData.fetchData(salesforceEntityName: "Assignment",predicateFormat: "id == %@" ,predicateValue: SalesforceConnection.assignmentId,isPredicate:true) as! [Assignment]
        
        if(assignementResults.count > 0){
            
           let totalUnits = String(Int(assignementResults[0].totalUnits!)! + 1)
            

        ManageCoreData.updateData(salesforceEntityName: "Assignment", valueToBeUpdate: totalUnits,updatekey:"totalUnits", predicateFormat: "id == %@", predicateValue: SalesforceConnection.assignmentId, isPredicate: true)
       }
    }
}
