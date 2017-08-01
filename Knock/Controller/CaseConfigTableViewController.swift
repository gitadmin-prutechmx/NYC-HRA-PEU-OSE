//
//  TableViewController.swift
//  TestApplication
//
//  Created by Kamal on 29/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

struct caseConfigObjects {
    
    var sectionName : String!
    var sectionObjects : [CaseDO]!
}


protocol PickListProtocol {
    func getPickListValue(pickListValue:String)
}

protocol MultiPickListProtocol {
    func getMultiPickListValue(multiPickListValue:String)
}


class CaseConfigTableViewController: UITableViewController,PickListProtocol,MultiPickListProtocol,UITextViewDelegate,UITextFieldDelegate {
    
    
    
    var selectedIndexPath:IndexPath?
    private var dateTimePickerCellExpanded: Bool = false
    
    
    
    @IBOutlet var caseTblView: UITableView!
    var caseConfigArray = [caseConfigObjects]()
    
    var sectionFieldDict : [String:[CaseDO]] = [:]
    
    
    var pickListDict:[String:String] = [:]
    var multiPickListDict:[String:String] = [:]
    var selectedSwitchDict:[String:String] = [:]
    var selectedTextAreaDict:[String:String] = [:]
    var selectedTextFieldDict:[String:String] = [:]
    var selectedPhoneTextFieldDict:[String:Int64] = [:]
   // var selectedDateTimeDict:[String:String] = [:]
    
    
    var switchDict:[Int:String] = [:]
    var textAreaDict:[Int:String] = [:]
    var textFieldDict:[Int:String] = [:]
    var phoneTextFieldDict:[Int:String] = [:]
    
    
    var tempArray = [CaseDO]()
    
    
    var currentPickListApiName:String = ""
    var currentMultiPickListApiName:String = ""
    
    @IBOutlet weak var dateView: UIView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    func getPickListValue(pickListValue:String){
        
        pickListDict[currentPickListApiName] = pickListValue
        
        caseTblView?.reloadData()
        
    }
    
    func getMultiPickListValue(multiPickListValue:String){
        
        multiPickListDict[currentMultiPickListApiName] = multiPickListValue
        
        caseTblView?.reloadData()
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utilities.currentApiName = ""
        Utilities.selectedDateTimeDict = [:]
        Utilities.selectedDatePicker = [:]

        
        readJson()
        
    }
    
    
    
  
    
    
    private func parseJson(jsonObject: Dictionary<String, AnyObject>){
        
        
        guard
            let sectionResults = jsonObject["Section"] as? [[String: AnyObject]] else { return }
        
        for sectionData in sectionResults {
            
            guard let fieldListResults = sectionData["fieldList"] as? [[String: AnyObject]]  else { break }
            
            let sectionName = sectionData["sectionName"] as? String  ?? ""
            
            tempArray = []
            
            for fieldListData in fieldListResults {
                
                let apiName = fieldListData["apiName"] as? String  ?? ""
                let dataType = fieldListData["dataType"] as? String  ?? ""
                
                
                if sectionFieldDict[sectionName] != nil {
                    
                    var arrayValue:[CaseDO] =  sectionFieldDict[sectionName]!
                    
                    
                    arrayValue.append(CaseDO(sequence: fieldListData["sequence"] as? String  ?? "", pickListValue: fieldListData["picklistValue"] as? String  ?? "", fieldName: fieldListData["fieldName"] as? String  ?? "", dataType: dataType, apiName: apiName,sectionName:sectionName))
                    
                    sectionFieldDict[sectionName] = arrayValue
                    
                    if(dataType == "PICKLIST"){
                        pickListDict[apiName] = ""
                    }
                    else if(dataType == "MULTIPICKLIST"){
                        multiPickListDict[apiName] = ""
                    }
                    else if(dataType == "BOOLEAN"){
                        selectedSwitchDict[apiName] = ""
                    }
                    else if(dataType == "TEXTAREA"){
                        selectedTextAreaDict[apiName] = ""
                    }
                    else if(dataType == "DATE"){
                       Utilities.selectedDateTimeDict[apiName] = ""
                       Utilities.selectedDatePicker[apiName] = Date()
                        
                    }
                    else{
                        selectedTextFieldDict[apiName] = ""
                    }
                }
                    
                else{
                    
                    tempArray.append(CaseDO(sequence: fieldListData["sequence"] as? String  ?? "", pickListValue: fieldListData["picklistValue"] as? String  ?? "", fieldName: fieldListData["fieldName"] as? String  ?? "", dataType: dataType, apiName: apiName,sectionName:sectionName))
                    
                    
                    
                    sectionFieldDict[sectionName] = tempArray
                    
                    if(dataType == "PICKLIST"){
                        pickListDict[apiName] = ""
                    }
                    else if(dataType == "MULTIPICKLIST"){
                        multiPickListDict[apiName] = ""
                    }
                    else if(dataType == "BOOLEAN"){
                        selectedSwitchDict[apiName] = ""
                    }
                    else if(dataType == "TEXTAREA"){
                        selectedTextAreaDict[apiName] = ""
                    }
                    else if(dataType == "DATE"){
                         Utilities.selectedDateTimeDict[apiName] = ""
                         Utilities.selectedDatePicker[apiName] = Date()
                    }
                    else{
                        selectedTextFieldDict[apiName] = ""
                    }
                }
                
            }
            
            
            
            
            
            
        }
        
        convertToArray()
    }
    
    
    private func convertToArray(){
        
        // caseConfigArray.append(sectionFieldDict)
        for (key, value) in sectionFieldDict {
            print("\(key) -> \(value)")
            caseConfigArray.append(caseConfigObjects(sectionName: key, sectionObjects: value))
        }
    }
    
    
    private func readJson() {
        
        let caseConfigResults =  ManageCoreData.fetchData(salesforceEntityName: "CaseConfig", isPredicate:false) as! [CaseConfig]
        
        
        if(caseConfigResults.count>0){
            
            parseJson(jsonObject: caseConfigResults[0].caseConfigData as! Dictionary<String, AnyObject>)
            
        }
        
     
        
        
        
//        do {
//            if let file = Bundle.main.url(forResource: "data", withExtension: "json") {
//                let data = try Data(contentsOf: file)
//                let json = try JSONSerialization.jsonObject(with: data, options: [])
//                if let object = json as? [String: AnyObject] {
//                    
//                    parseJson(jsonObject: object)
//                    // json is a dictionary
//                    print(object)
//                } else if let object = json as? [Any] {
//                    // json is an array
//                    print(object)
//                } else {
//                    print("JSON is invalid")
//                }
//            } else {
//                print("no file")
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.caseConfigArray.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return caseConfigArray[section].sectionName
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
//        returnedView.backgroundColor = UIColor.darkGray
//        
//        let label = UILabel(frame: CGRect(x: 5, y: 0, width: view.frame.size.width, height: 25))
//        label.text = caseConfigArray[section].sectionName
//        label.textColor = UIColor.white
//        returnedView.addSubview(label)
//        
//        return returnedView
//    }
//    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return caseConfigArray[section].sectionObjects.count
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let caseObject:CaseDO = caseConfigArray[indexPath.section].sectionObjects[indexPath.row]
        
        
        if(caseObject.dataType == "BOOLEAN"){
            
            let switchCell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            
            
            switchCell.textLabel?.text = caseObject.fieldName
            switchCell.textLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            switchCell.backgroundColor = UIColor.white
            
            
            switchCell.selectionStyle = .none
            
            
            switchDict[indexPath.row] = caseObject.apiName
            
            //accessory switch
            let uiSwitch = UISwitch(frame: CGRect.zero)
            
            uiSwitch.tag = indexPath.row
            
            uiSwitch.backgroundColor = UIColor.white
            
            if(selectedSwitchDict[caseObject.apiName] == "" || selectedSwitchDict[caseObject.apiName] == "No" ){
                uiSwitch.isOn = false
            }
            else{
                uiSwitch.isOn = true
            }
            
            
            uiSwitch.addTarget(self, action: #selector(CaseConfigTableViewController.switchChanged(_:)), for: UIControlEvents.valueChanged)
            
            switchCell.accessoryView = uiSwitch
            
            
            
            return switchCell
            
            
        }
        else if(caseObject.dataType == "TEXTAREA"){
            
            let textAreaCell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            
            textAreaCell.textLabel?.text = caseObject.fieldName
            textAreaCell.textLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            // textAreaCell.backgroundColor = UIColor.clear
            
            
            textAreaCell.selectionStyle = .none
            
            textAreaDict[indexPath.row] = caseObject.apiName
            
            //UITextView
            let textArea = UITextView(frame: CGRect(x: 0, y: 0, width: 200, height: 99))
            
            textArea.tag = indexPath.row
            textArea.delegate = self
            
            textArea.text = selectedTextAreaDict[caseObject.apiName]
            
            let grayColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
            
            
            
            //            tf.layer.borderColor = blackColor.cgColor
            //
            //            tf.layer.borderWidth = 2.0
            //
            textArea.layer.backgroundColor = grayColor.cgColor
            
            textAreaCell.accessoryView = textArea
            
            
            
            return textAreaCell
        }
        else if(caseObject.dataType == "PICKLIST"){
            
            
            let pickListCell = tableView.dequeueReusableCell(withIdentifier: "rightDetailCell", for: indexPath)
            
            
            pickListCell.textLabel?.text = caseObject.fieldName
            pickListCell.textLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            // pickListCell.backgroundColor = UIColor.clear
            
            
            pickListCell.accessoryType = .disclosureIndicator
            
            let pickListValue = pickListDict[caseObject.apiName]
            
            if(pickListValue?.isEmpty)!{
                pickListCell.detailTextLabel?.text = "Select Picklist"
            }
            else{
                pickListCell.detailTextLabel?.text = pickListValue
            }
            
            pickListCell.detailTextLabel?.textColor = UIColor.gray
            pickListCell.detailTextLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            return pickListCell
            
        }
        else if(caseObject.dataType == "MULTIPICKLIST"){
            
            
            let multiPickListCell = tableView.dequeueReusableCell(withIdentifier: "rightDetailCell", for: indexPath)
            
            
            multiPickListCell.textLabel?.text = caseObject.fieldName
            multiPickListCell.textLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            //  multiPickListCell.backgroundColor = UIColor.clear
            
            
            multiPickListCell.accessoryType = .disclosureIndicator
            
            let multiPickListValue = multiPickListDict[caseObject.apiName]
            
            if(multiPickListValue?.isEmpty)!{
                multiPickListCell.detailTextLabel?.text = "Select Multi Picklist"
            }
            else{
                multiPickListCell.detailTextLabel?.text = multiPickListValue
            }
            
            multiPickListCell.detailTextLabel?.textColor = UIColor.gray
            multiPickListCell.detailTextLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            return multiPickListCell
            
        }
            
        else if(caseObject.dataType == "DATE"){
            
            let dateTimeCell = tableView.dequeueReusableCell(withIdentifier: "dateTimeCell", for: indexPath) as! DateTimeTableViewCell
            
            dateTimeCell.title.text = caseObject.fieldName
            
            dateTimeCell.title.font = UIFont.init(name: "Arial", size: 16.0)
            
            //dateTimeCell.backgroundColor = UIColor.clear
            dateTimeCell.selectionStyle = .none
            
            
            
            let dateLabelValue = Utilities.selectedDateTimeDict[caseObject.apiName]
            
            if(dateLabelValue?.isEmpty)!{
                dateTimeCell.detail.text = "Select Date"
            }
            else{
                dateTimeCell.detail.text = dateLabelValue
            }
            
            let dateValue = Utilities.selectedDatePicker[caseObject.apiName]
            
            
            dateTimeCell.datePicker.date = dateValue!
            
            
            
            
            // dateTimeCell.accessoryType = .disclosureIndicator
            
            dateTimeCell.detail.textColor = UIColor.gray
            dateTimeCell.detail.font = UIFont.init(name: "Arial", size: 16.0)
            
            return dateTimeCell
        }
        else if(caseObject.dataType == "PHONE"){
            
            let phoneCell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            
            phoneCell.textLabel?.text = caseObject.fieldName
            phoneCell.textLabel?.font = UIFont.init(name: "Arial", size: 16.0)
   
            
            phoneCell.selectionStyle = .none
            
            phoneTextFieldDict[indexPath.row] = caseObject.apiName
            
            //UIPhoneTextField
            let phoneTextfield = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
            //textfield.placeholder = "Enter text here"
            
            phoneTextfield.tag = indexPath.row
            phoneTextfield.delegate = self
            
         //   phoneTextfield.text = String(describing: selectedPhoneTextFieldDict[caseObject.apiName])
            
            
            
            let whiteColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
            
            
            phoneTextfield.layer.backgroundColor = whiteColor.cgColor
            
            phoneCell.accessoryView = phoneTextfield
            
            
            
            return phoneCell
        }
        else{
            
            let textCell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            
            textCell.textLabel?.text = caseObject.fieldName
            textCell.textLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            //textCell.backgroundColor = UIColor.clear
            //            textCell.layer.borderWidth = 1
            //            textCell.layer.cornerRadius = 8
            //            textCell.clipsToBounds = true
            
            
            textCell.selectionStyle = .none
            
            textFieldDict[indexPath.row] = caseObject.apiName
            
            //UITextField
            let textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
            //textfield.placeholder = "Enter text here"
            
            textfield.tag = indexPath.row
            textfield.delegate = self
            
            textfield.text = selectedTextFieldDict[caseObject.apiName]
            
            
            
            let grayColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
            
            //            tf.layer.borderColor = blackColor.cgColor
            //
            //            tf.layer.borderWidth = 2.0
            //
            textfield.layer.backgroundColor = grayColor.cgColor
            
            textCell.accessoryView = textfield
            
            
            
            return textCell
        }
        
        
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let caseObject:CaseDO = caseConfigArray[indexPath.section].sectionObjects[indexPath.row]
        
        if(caseObject.dataType == "PICKLIST"){
            
            currentPickListApiName = caseObject.apiName
            
            let pickListVC = self.storyboard!.instantiateViewController(withIdentifier: "picklistIdentifier") as? PickListViewController
            
            pickListVC?.picklistStr = caseObject.pickListValue
            
            
            pickListVC?.pickListProtocol = self
            pickListVC?.selectedPickListValue = pickListDict[currentPickListApiName]!
            
            self.navigationController?.pushViewController(pickListVC!, animated: true)
        }
            
        else if(caseObject.dataType == "MULTIPICKLIST"){
            
            currentMultiPickListApiName = caseObject.apiName
            
            let multiPickListVC = self.storyboard!.instantiateViewController(withIdentifier: "multiPicklistIdentifier") as? MultiPickListViewController
            
            multiPickListVC?.multiPicklistStr = caseObject.pickListValue
            
            multiPickListVC?.multiPickListProtocol = self
            multiPickListVC?.selectedMultiPickListValue = multiPickListDict[currentMultiPickListApiName]!
            
            self.navigationController?.pushViewController(multiPickListVC!, animated: true)
        }
        else if(caseObject.dataType == "DATE"){
            
            Utilities.currentApiName = caseObject.apiName
            
            let previousIndexPath =   selectedIndexPath
            if(indexPath == selectedIndexPath){
                selectedIndexPath = nil
            }
            else{
                selectedIndexPath = indexPath
            }
            
            var indexPaths:Array<IndexPath> = []
            if let previous = previousIndexPath{
                indexPaths += [previous]
            }
            if let current = selectedIndexPath{
                indexPaths += [current]
            }
            
            if indexPaths.count > 0 {
                tableView.reloadRows(at: indexPaths, with: UITableViewRowAnimation.automatic)
            }
            //            if dateTimePickerCellExpanded {
            //                dateTimePickerCellExpanded = false
            //            } else {
            //                dateTimePickerCellExpanded = true
            //            }
            //            tableView.beginUpdates()
            //            tableView.endUpdates()
            //
            
        }
        
        
        
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let caseObject:CaseDO = caseConfigArray[indexPath.section].sectionObjects[indexPath.row]
        
        if(caseObject.dataType == "DATE"){
          (cell as! DateTimeTableViewCell).watchFrameChanges()
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let caseObject:CaseDO = caseConfigArray[indexPath.section].sectionObjects[indexPath.row]
        
        if(caseObject.dataType == "DATE"){
            (cell as! DateTimeTableViewCell).ignoreFrameChanges()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        let caseObject:CaseDO = caseConfigArray[indexPath.section].sectionObjects[indexPath.row]
        
        if(caseObject.dataType == "TEXTAREA"){
            return 100.0
        }
            
        else if(caseObject.dataType == "DATE"){
            if indexPath == selectedIndexPath {
                return DateTimeTableViewCell.expandHeight
            } else {
                return DateTimeTableViewCell.defaultHeight
            }
        }
            //        else if(caseObject.dataType == "DATE"){
            //            if dateTimePickerCellExpanded {
            //                return 250.0
            //            } else {
            //                return 44.0
            //            }
            //        }
        else{
            return UITableViewAutomaticDimension
        }
        
        
        
        
    }
    
    func switchChanged(_ sender: UISwitch)
    {
        
        let index = sender.tag
        
        var selectedValue:String = "No"
        
        if(sender.isOn){
            selectedValue = "Yes"
        }
        
        selectedSwitchDict[switchDict[index]!] =  selectedValue
        
        print(selectedSwitchDict)
    }
    
    // textViewDidEndEditing
    
    //    func textViewDidEndEditing(_ textView: UITextView) {
    //        selectedTextAreaDict[textAreaDict[textView.tag]!] =  textView.text!
    //        textView.resignFirstResponder()
    //    }
    //
    //    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    //         selectedTextAreaDict[textAreaDict[textView.tag]!] =  textView.text!
    //         return true
    //    }
    
    
    
    //    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    //
    //
    //        let aSet =  NSCharacterSet(charactersIn:"0123456789").inverted
    //        let compSepByCharInSet = string.components(separatedBy: aSet)
    //        let numberFiltered = compSepByCharInSet.joined(separator: "")
    //
    //        let currentCharacterCount = phoneTextField.text?.characters.count ?? 0
    //        if (range.length + range.location > currentCharacterCount){
    //            return false
    //        }
    //        let newLength = currentCharacterCount + string.characters.count - range.length
    //        if(newLength > 10){
    //            return false
    //        }
    //
    //
    //        return string == numberFiltered
    //    }
    //
    //
    
//    func textViewDidEndEditing(_ textView: UITextView) -> Bool {
//        selectedTextAreaDict[textAreaDict[textView.tag]!] =  textView.text!
//        textView.resignFirstResponder()
//        return true
//    }
//    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
         selectedTextAreaDict[textAreaDict[textView.tag]!] =  textView.text! + text
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

    selectedTextFieldDict[textFieldDict[textField.tag]!] =  textField.text! + string
        return true
    }
   
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        selectedTextFieldDict[textFieldDict[textField.tag]!] =  textField.text!
//        textField.resignFirstResponder()
//    }
    
    
//    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        
//    
//        let aSet =  NSCharacterSet(charactersIn:"0123456789").inverted
//        let compSepByCharInSet = string.components(separatedBy: aSet)
//        let numberFiltered = compSepByCharInSet.joined(separator: "")
//        
//        let currentCharacterCount = phoneTextField.text?.characters.count ?? 0
//        if (range.length + range.location > currentCharacterCount){
//            return false
//        }
//        let newLength = currentCharacterCount + string.characters.count - range.length
//        if(newLength > 10){
//            return false
//        }
//        
//        
//        return string == numberFiltered
//    }
//    
    
    @IBAction func save(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true);
        
        print(multiPickListDict)
        print(pickListDict)
        print(selectedSwitchDict)
        
        print(selectedTextAreaDict)
        
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
            
            
            self.navigationController?.popViewController(animated: true);
            //Do some other stuff
        }
        alertController.addAction(okAction)
        
        
        self.present(alertController, animated: true, completion: nil)
        

        
        
        // self.navigationController?.popViewController(animated: true);
    }
    
    
}


