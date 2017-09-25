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
     var arrAgeList = NSMutableArray()
     let pickerView = UIPickerView()
    var selectedRow = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        pickerView.delegate = self
         self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        arrAgeList = [ "First", "Second", "Third", "Fourth", "Fith","None"]
        pickerView.backgroundColor = .white
        pickerView.showsSelectionIndicator = true
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.bordered, target: self, action: #selector(AddressViewController.donePicker))
       
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.bordered, target: self, action: #selector(AddressViewController.canclePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        self.boroughTxtField.inputView = pickerView
        boroughTxtField.inputAccessoryView = toolBar
        
    }
    
    
    func donePicker()
    {
            self.boroughTxtField.text = arrAgeList[selectedRow]as? String
            boroughTxtField.resignFirstResponder()
        
    }
    func canclePicker()
    {
        boroughTxtField.resignFirstResponder()
       
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnCancelAction(_ sender: Any)
    {
        let alertCtrl = Alert.showUIAlert(title: "Message", message: "Are you sure you want to cancel without saving?", vc: self)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel)
        { action -> Void in
            
        }
        
        alertCtrl.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            
            
            self.dismiss(animated: true, completion: nil)
        }
        alertCtrl.addAction(okAction)

    }
    
    //Mark Pickerview delegate methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        
        return self.arrAgeList.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        
        
            return arrAgeList.object(at: row)as? String

        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedRow = row
     //  self.boroughTxtField.text = arrAgeList.object(at: row) as? String
        
    }

    @IBAction func btnSaveAction(_ sender: Any)
    {
        
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


