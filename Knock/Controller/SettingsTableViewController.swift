//
//  SettingsTableViewController.swift
//  Knock
//
//  Created by Kamal on 12/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController
{
    @IBOutlet weak var syncTimeSlider: UISlider!
    //    @IBOutlet weak var syncTimeSlider: UISlider!
    var dpShowDateVisible = false
    @IBOutlet weak var syncTimeView: UIView!
    @IBOutlet weak var syncTimeLbl: UILabel!
    @IBOutlet weak var dpShowDate: UIDatePicker!
    @IBOutlet weak var TimeLbl: UILabel!
    
    @IBOutlet weak var btnShowTime: UIButton!
    
    @IBOutlet weak var syncTimePickerView: UIView!
    @IBOutlet weak var syncDateView: UIView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        syncTimeView.layer.cornerRadius = 5
        
        tableView.allowsSelection = true
        
        
        
        
        
        
        populateSettings()
        
        
    }
    
    func getBackGroundTime(bgDate:Date)->String{
        //let date = Date()
        
        
        let calendar = Calendar.current
        //        let hour = calendar.component(.hour, from: date)
        //        let minutes = calendar.component(.minute, from: date)
        //
        let components = calendar.dateComponents([.hour, .minute], from: bgDate)
        
        var updatedHour = components.hour!
        let updatedMinute = components.minute!
        var locale:String = "AM"
        
        if(updatedHour > 12){
            updatedHour =  (components.hour! % 12)
            locale = "PM"
        }
        
        return "\(updatedHour):\(String(format: "%02d", updatedMinute)) \(locale)"
        
    }
    
    func populateSettings(){
        
        let userSettingData = ManageCoreData.fetchData(salesforceEntityName: "Setting", isPredicate:false) as! [Setting]
        
        if(userSettingData.count > 0){
            
            syncTimeSlider.value = Float(userSettingData[0].offlineSyncTime!)!
            
//            if let backgroundDate = userSettingData[0].backgroundTime{
//                dpShowDate.date = backgroundDate as Date
//                
//                TimeLbl.text = getBackGroundTime(bgDate: dpShowDate.date)
//            }
//            else{
//                dpShowDate.date = Date()
//                
//                TimeLbl.text = getBackGroundTime(bgDate: dpShowDate.date)
//            }
//            
           
            
            syncTimeLbl.text = userSettingData[0].offlineSyncTime!
        }
    }
    
    func saveSettings(){
        
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["offlineSyncTime"] = syncTimeLbl.text! as AnyObject?
        
       // updateObjectDic["backgroundTime"] = dpShowDate.date as AnyObject?
        
        
        ManageCoreData.updateDate(salesforceEntityName: "Setting", updateKeyValue: updateObjectDic, predicateFormat: "settingsId == %@", predicateValue: "1",isPredicate: true)
        
        
        
        Utilities.timer?.invalidate()
        Utilities.startBackgroundSyncing()
        
    }
    
    
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    func toggleShowDateDatepicker ()
    //    {
    //        dpShowDateVisible = !dpShowDateVisible
    //
    //        tableView.beginUpdates()
    //        tableView.endUpdates()
    //    }
    //
    //    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    //    {
    //        if indexPath.section == 1
    //        {
    //            if  indexPath.row == 0
    //            {
    //                toggleShowDateDatepicker()
    //                dpShowDateChanged()
    //            }
    //
    //        }
    //
    //    }
    //
    func tableView(tableView:UITableView,heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if !dpShowDateVisible && indexPath.row == 1
        {
            return 0
        }
        else {
            return 44
        }
    }
    
    func dpShowDateChanged ()
    {
        
        TimeLbl.text = DateFormatter.localizedString(from: dpShowDate.date, dateStyle:.none, timeStyle: .short)
        
    }
    
    
    @IBAction func syncTimeSlider(_ sender: UISlider) {
        
        let currentValue = Int(sender.value)
        syncTimeLbl.text = "\(currentValue)"
    }
    
    @IBAction func dpShowTimeAction(_ sender: Any)
    {
        dpShowDateChanged()
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
        
        
        
        
        // self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        saveSettings()
        
        self.view.makeToast("Settings saved successfully", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
            
           // Utilities.startBackgroundSync()
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
        
        
        
        // self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func btnShowTimeAction(_ sender: UIButton)
    {
        sender.isSelected = !sender.isSelected
        if sender.isSelected
        {
            syncTimePickerView.isHidden = true
        }
        else
        {
            syncTimePickerView.isHidden = false
        }
        
    }
    
    
}
