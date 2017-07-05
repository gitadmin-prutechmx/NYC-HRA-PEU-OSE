//
//  AddNewUnitViewController.swift
//  Knock
//
//  Created by Kamal on 22/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class AddNewUnitViewController: UIViewController,UITextFieldDelegate{
   
    var saveUnitDict : [String:String] = [:]
    
    @IBOutlet weak var apartmentView: UIView!
    @IBOutlet weak var apartmentName: UITextField!

    @IBOutlet weak var notesTextArea: UITextView!
//    @IBOutlet weak var apartmentName: UITextField!
//    
//    @IBOutlet weak var notesTextArea: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        

        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        notesTextArea.layer.cornerRadius = 5
        notesTextArea.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        notesTextArea.layer.borderWidth = 0.5
        notesTextArea.clipsToBounds = true
        
        //NotesTextArea.text = "Description"
        notesTextArea.textColor = UIColor.black


        apartmentName.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let aSet = NSCharacterSet.alphanumerics.inverted
        //let aSet =  NSCharacterSet(charactersIn:"0123456789abc").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        
                let currentCharacterCount = apartmentName.text?.characters.count ?? 0
                if (range.length + range.location > currentCharacterCount){
                    return false
                }
                let newLength = currentCharacterCount + string.characters.count - range.length
                if(newLength > 5){
                    return false
                }
        
        
        return string == numberFiltered
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
        
        var apartmentNumberVal:String = ""
        var notesVal:String = ""
        
        
        
       
        
       
        if let apartmentNumberTemp = apartmentName.text{
            
            apartmentNumberVal = apartmentNumberTemp
            
        }
        
        if(apartmentNumberVal.isEmpty){
            
            apartmentView.shake()
            
            self.view.makeToast("Please fill apartment.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                               
            }
            
            
            return
            
        }

        
        if let notesTemp = notesTextArea.text{
            
            notesVal = notesTemp
            
        }
        
        
      
        
       
        saveUnitDict = Utilities.createUnitDicData(unitName: "Apt " + apartmentNumberVal, apartmentNumber: apartmentNumberVal, locationId: SalesforceConnection.locationId, assignmentLocId: SalesforceConnection.assignmentLocationId, notes: notesVal, iosLocUnitId: UUID().uuidString, iosAssignLocUnitId: UUID().uuidString)
        
        
        saveNewlyCreatedUnitData()
        
        
        //...............create unit
        
        
        //update static values as well check then update SalesforceConnection
        
        
        //then check connection is on or off if yes then convert into string and push to salesforce and when response (if error then hide progress and show message) and update database with unit id and assilocunitid and type also
        
       
            
        
        
        self.view.makeToast("Unit information has been created successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
            
           // Utilities.isSubmitSurvey = false
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
            
            self.dismiss(animated: true, completion: nil)
            
        }

    
//            if(Network.reachability?.isReachable)!{
//    
//                  pushAddNewUnitDataToSalesforce()
//                }
//                
//            else{
//                self.view.makeToast("Unit information has been created successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
//                    
//                    Utilities.isSubmitSurvey = false
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
//                    
//                    self.dismiss(animated: true, completion: nil)
//                    
//                }
//            }
//        
        

        
    }
    
    func pushAddNewUnitDataToSalesforce(){
        var saveUnit : [String:String] = [:]
        
        saveUnit["unit"] = Utilities.encryptedParams(dictParameters: saveUnitDict as AnyObject)
        
        
        
        SVProgressHUD.show(withStatus: "Saving Unit...", maskType: SVProgressHUDMaskType.gradient)
        
        
        SalesforceConnection.loginToSalesforce(companyName: SalesforceConnection.companyName) { response in
            
            if(response)
                
            {
                
                SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.createUnit, params: saveUnit){ jsonData in
                    
                    
                    
                    SVProgressHUD.dismiss()
                    
                    let isError = Utilities.parseAddNewUnitResponse(jsonObject: jsonData.1)
                    
                    if(isError==false){
                        self.view.makeToast("Unit information has been created successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                            
                           // Utilities.isSubmitSurvey = false
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
                            
                            self.dismiss(animated: true, completion: nil)
                            
                        }
                        
                        
                    }
                    else{
                        
                        Utilities.showErrorMessage(toastView: self.view, message: "Error while updating Tenant info", delay: 1.0, toastPosition: .center)
                        
                        
                    }
                    
                    
                    
                }
                
            }
            
            
        }
    }
    
    
   
    
    
    func saveNewlyCreatedUnitData(){
         let unitObject = Unit(context: context)
        
        unitObject.id = saveUnitDict["iOSLocUnitId"]
        
        unitObject.assignmentLocUnitId = saveUnitDict["iOSAssignmentLocUnitId"]
        
        
        
        unitObject.locationId = SalesforceConnection.locationId
        
        unitObject.assignmentLocId = SalesforceConnection.assignmentLocationId

        
        
        unitObject.name =  saveUnitDict["unitName"]
        
        unitObject.apartment = saveUnitDict["apartmentNumber"]

        unitObject.notes = saveUnitDict["notes"]
  
        unitObject.assignmentId = SalesforceConnection.assignmentId
        
        
        
        
        
        unitObject.actionStatus = "create"
        
        unitObject.surveyStatus = ""
        unitObject.surveySyncDate = ""
        unitObject.unitSyncDate = ""
        
        appDelegate.saveContext()
    }
    
    
    
    
    
  
}
