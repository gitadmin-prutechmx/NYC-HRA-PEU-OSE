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

class EditLocationViewController: UIViewController {
    
     var attempt:String = ""
     var canvassingStatus:String = ""
    
    @IBOutlet weak var fullAddressLbl: UILabel!

    @IBOutlet weak var NoOfUnitsTextField: UITextField!
    @IBOutlet weak var NotesTextArea: UITextView!
    
    
    @IBOutlet weak var canvassingStatusDropDown: UIButton!
    
    let chooseStatusDropDown = DropDown()
   
    
    
    lazy var dropDowns: [DropDown] = {
        return [
            self.chooseStatusDropDown
        ]
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       setupStatusDropDown()
        
        fullAddressLbl.text = SalesforceConnection.fullAddress
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white

        NotesTextArea.layer.cornerRadius = 5
        NotesTextArea.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        NotesTextArea.layer.borderWidth = 0.5
        NotesTextArea.clipsToBounds = true
        
        //NotesTextArea.text = "Description"
        NotesTextArea.textColor = UIColor.black
        


        // Do any additional setup after loading the view.
    }
    
    func setupStatusDropDown() {
        chooseStatusDropDown.anchorView = canvassingStatusDropDown
        
        // Will set a custom with instead of anchor view width
        //		dropDown.width = 100
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        chooseStatusDropDown.bottomOffset = CGPoint(x: 0, y: canvassingStatusDropDown.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        chooseStatusDropDown.dataSource = [
            "Canvassed",
            "Not Canvassed",
            "Permanently Inaccessible",
            "Temporarily Inaccessible",
            "Incomplete",
            "Address not Found",
            "Not a Target Building",
            "Do not Knock"
        ]
        
        // Action triggered on selection
        chooseStatusDropDown.selectionAction = { [unowned self] (index, item) in
            
            self.canvassingStatus = item
            self.canvassingStatusDropDown.setTitle(item, for: .normal)
        }
        
        
        // Action triggered on dropdown cancelation (hide)
        //		dropDown.cancelAction = { [unowned self] in
        //			// You could for example deselect the selected item
        //			self.dropDown.deselectRowAtIndexPath(self.dropDown.indexForSelectedRow)
        //			self.actionButton.setTitle("Canceled", forState: .Normal)
        //		}
        
        // You can manually select a row if needed
        //		dropDown.selectRowAtIndex(3)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func chooseStatus(_ sender: Any) {
        chooseStatusDropDown.show()
    }
    
   
    @IBAction func selectAttempt(_ sender: DLRadioButton) {
        
       
        attempt = sender.selected()!.titleLabel!.text!
        
//        if (sender.isMultipleSelectionEnabled) {
//            for button in sender.selectedButtons() {
//                print(String(format: "%@ is selected.\n", button.titleLabel!.text!));
//            }
//        } else {
//            print(String(format: "%@ is selected.\n", sender.selected()!.titleLabel!.text!));
//        }
//        
//    }

    }

    @IBAction func saveLocation(_ sender: Any) {
        
        /*  { \"canvassingStatus\":\"Canvassed\",\"assignmentLocationId\":\"a0K35000000rhQw\",\"Notes\":\"jaipur Notes\",\"attempt\":\"Yes\",\"numberOfUnits\":\"5\"}
         */
        
        var editLocDict : [String:String] = [:]
        var updateLocation : [String:String] = [:]
        
        var numberOfUnits:String = ""
        if let numberofUnitsTemp = NoOfUnitsTextField.text{
            numberOfUnits = numberofUnitsTemp
        }
        
        var notes:String = ""
        if let notesTemp = NotesTextArea.text{
            notes = notesTemp
        }
        
        
         editLocDict["canvassingStatus"] = canvassingStatus
         editLocDict["assignmentLocationId"] = SalesforceConnection.assignmentLocationId
         editLocDict["Notes"] = notes
         editLocDict["attempt"] = attempt
         editLocDict["numberOfUnits"] = numberOfUnits
        
         //updateLocation["assignmentIds"] = editLocDict as AnyObject?
        
        let convertedString = Utilities.jsonToString(json: editLocDict as AnyObject)
        
        let encryptEditLocStr = try! convertedString?.aesEncrypt(SalesforceConfig.key, iv: SalesforceConfig.iv)
        
        updateLocation["location"] = encryptEditLocStr
        
          SVProgressHUD.show(withStatus: "Updating location...", maskType: SVProgressHUDMaskType.gradient)
        
        SalesforceConnection.loginToSalesforce(companyName: SalesforceConnection.companyName) { response in
            
            if(response)
            {

                SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.updateLocation, params: updateLocation){ jsonData in
            
                    SVProgressHUD.dismiss()
                    self.view.makeToast("Location has been updated successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                        if didTap {
                            self.dismiss(animated: true, completion: nil)
                        } else {
                             self.dismiss(animated: true, completion: nil)
                        }
                    }
                   
                    
            
                    //print(jsonData.1)
                    //self.parseMessage(jsonObject: jsonData.1)
                }
            }

        }
        
        
            
        
        
    }
    
    
    func parseMessage(jsonObject: Dictionary<String, AnyObject>){
    
        guard let isError = jsonObject["hasError"] as? Int64 else { return }
        
       
      
 
        
        if(isError == 0){
            self.view.makeToast("Location has been updated successfully.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                if didTap {
                    print("completion from tap")
                } else {
                    print("completion without tap")
                }
            }
             self.dismiss(animated: true, completion: nil)
        }
        else{
            self.view.makeToast("Error while updating location", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                if didTap {
                    print("completion from tap")
                } else {
                    print("completion without tap")
                }
            }

        }
        
    }
    
    @IBAction func cancelLocation(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    

   
}
