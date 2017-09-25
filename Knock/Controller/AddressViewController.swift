//
//  AddressViewController.swift
//  Knock
//
//  Created by Cloudzeg Laptop on 9/23/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class AddressViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate

{

    @IBOutlet weak var streetNumView: UIView!
    @IBOutlet weak var streetNumLbl: UILabel!
    @IBOutlet weak var aptFloorTxtField: UITextField!
    @IBOutlet weak var aptFloorView: UIView!
    @IBOutlet weak var aptTextField: UITextField!
    @IBOutlet weak var aptNoView: UIView!
    @IBOutlet weak var zipView: UIView!
    @IBOutlet weak var zipTxtField: UITextField!
    @IBOutlet weak var boroughTxtField: UITextField!
    @IBOutlet weak var boroughView: UIView!
    @IBOutlet weak var streetNumTxtField: UITextField!
    @IBOutlet weak var streetNameView: UIView!
    @IBOutlet weak var streetNameLbl: UILabel!
    @IBOutlet weak var streetNameTxtField: UITextField!
     var arrNameList = NSMutableArray()
     let pickerView = UIPickerView()
    var selectedRow = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        pickerView.delegate = self
         self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        arrNameList = [ "First", "Second", "Third", "Fourth", "Fifth","None"]
        pickerView.backgroundColor = .white
        pickerView.showsSelectionIndicator = true
        
        let rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(AddressViewController.saveAction))
        
        self.navigationItem.rightBarButtonItem  = rightBarButtonItem
        
        let leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(AddressViewController.cancelAction))
        
        self.navigationItem.leftBarButtonItem  = leftBarButtonItem
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = false
        toolBar.tintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        toolBar.barTintColor = UIColor.white
              
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddressViewController.donePicker))
       
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style:UIBarButtonItemStyle.plain, target: self, action: #selector(AddressViewController.canclePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        self.boroughTxtField.inputView = pickerView
        boroughTxtField.inputAssistantItem.leadingBarButtonGroups.removeAll()
        boroughTxtField.inputAssistantItem.trailingBarButtonGroups.removeAll()
        boroughTxtField.inputAccessoryView = toolBar
        
    }
    
    
    func donePicker()
    {
            self.boroughTxtField.text = arrNameList[selectedRow]as? String
            boroughTxtField.resignFirstResponder()
        
    }
    func canclePicker()
    {
        boroughTxtField.resignFirstResponder()
       
    }
    
    func saveAction()
    {
    
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelAction ()
    {
        let alertCtrl = Alert.showUIAlert(title: "Message", message: "Are you sure you want to cancel without saving?", vc: self)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel)
        { action -> Void in
            
        }
        
        alertCtrl.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            
            
            // self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
        alertCtrl.addAction(okAction)
    }
    
    
    func validate(phoneNumber: String) -> Bool
    {
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = phoneNumber.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        return  phoneNumber == filtered
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        let str = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField == streetNameTxtField
        {
            return (streetNameTxtField.text != nil)
            
        }
        else
        {
            return validate(phoneNumber: str)
        }
    }
    //Mark Pickerview delegate methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        
        return self.arrNameList.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        
        
            return arrNameList.object(at: row)as? String

        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedRow = row
     //  self.boroughTxtField.text = arrAgeList.object(at: row) as? String
        
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


