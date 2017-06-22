//
//  SaveEditTenantViewController.swift
//  Knock
//
//  Created by Kamal on 22/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class SaveEditTenantViewController: UIViewController
{
    
    @IBOutlet weak var firstNameTxtField: UITextField!
    
    @IBOutlet weak var lastNameTxtField: UITextField!
    
    @IBOutlet weak var emailTxtField: UITextField!
    
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    
    @IBOutlet weak var dobTextField: UITextField!
    
var picker = UIDatePicker()
    
    @IBOutlet weak var txtDob: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        
        let todayBtn = UIBarButtonItem(title: "Today", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SaveEditTenantViewController.tappedToolBarBtn))
        
        let okBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(SaveEditTenantViewController.donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label.font = UIFont(name: "Helvetica", size: 12)
        
        label.backgroundColor = UIColor.clear
        
        label.textColor = UIColor.white
        
        label.text = "Select a due date"
        
        label.textAlignment = NSTextAlignment.center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([todayBtn,flexSpace,textBtn,flexSpace,okBarBtn], animated: true)
        
        txtDob.inputAccessoryView = toolBar

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true);
    }
    
    @IBAction func save(_ sender: Any) {
       self.navigationController?.popViewController(animated: true);
    }
    
    @IBAction func editingDidBegain(_ sender: UITextField)
    {
       // let datePickerView: UIDatePicker = UIDatePicker()
        
        picker.datePickerMode = .date
        sender.inputView = picker
        
       // txtDob.inputView = picker
        picker.addTarget(self, action: #selector(SaveEditTenantViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
        
        
        
    }
    
    func datePickerValueChanged(sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        txtDob.text = dateFormatter.string(from: picker.date)
        //txtDob.text = dateFormatter.string(from: sender.date)
        
    }
  
    func tappedToolBarBtn(sender: UIBarButtonItem)
    {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        txtDob.text = dateFormatter.string(from: picker.date)

        //txtDob.text = dateformatter.string(from: NSDate() as Date)
        
        txtDob.resignFirstResponder()
    }

    func donePressed(sender: UIBarButtonItem) {
        
        txtDob.resignFirstResponder()
        
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
