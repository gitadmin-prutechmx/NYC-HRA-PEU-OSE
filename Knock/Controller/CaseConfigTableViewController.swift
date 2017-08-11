//
//  CaseCaseConfigTableViewController.swift
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
    
    
    @IBOutlet weak var issueView: UIView!
    var caseDynamicDict:[String:AnyObject] = [:]
    
    
    var selectedIndexPath:IndexPath?
    private var dateTimePickerCellExpanded: Bool = false
    
    @IBOutlet weak var btnGotoissue: UIButton!
    
    
    @IBOutlet weak var lblDescrption: UILabel!
    @IBOutlet var caseTblView: UITableView!
    var caseConfigArray = [caseConfigObjects]()
    
    var sectionFieldDict : [String:[CaseDO]] = [:]
    
    var orderedSectionFieldDict: [Int: [String:[CaseDO]]] = [:]
    
    
    
    var switchDict:[Int:String] = [:]
    var textAreaDict:[Int:String] = [:]
    var textFieldDict:[Int:String] = [:]
    var phoneTextFieldDict:[Int:String] = [:]      //handle tag + apiname
    
    
    var tempArray = [CaseDO]()
    
    
    var currentPickListApiName:String = ""
    var currentMultiPickListApiName:String = ""
    
    @IBOutlet weak var dateView: UIView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    func getPickListValue(pickListValue:String){
        
        Utilities.caseConfigDict[currentPickListApiName] = pickListValue as AnyObject?
        //pickListDict[currentPickListApiName] = pickListValue
        
        reloadTableView()
    }
    
    func getMultiPickListValue(multiPickListValue:String){
        
        Utilities.caseConfigDict[currentMultiPickListApiName] = multiPickListValue as AnyObject?
        
        // multiPickListDict[currentMultiPickListApiName] = multiPickListValue
        
        reloadTableView()
        
        
    }
    
    func reloadTableView(){
        
        phoneTextFieldDict = [:]
        switchDict = [:]
        textAreaDict = [:]
        textFieldDict = [:]
        
        caseTblView?.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblDescrption.text = SalesforceConnection.dateOfIntake
        
        btnGotoissue.layer.cornerRadius = 5
        btnGotoissue.layer.borderColor = UIColor.black.cgColor
        btnGotoissue.layer.borderWidth = 1
        btnGotoissue.clipsToBounds = true
        
        
        if(SalesforceConnection.caseNumber.isEmpty){
            self.navigationItem.title = "Case Info"
            issueView.isHidden = true
            issueView.frame.size.height = 0.0
            
        }
        else{
            self.navigationItem.title = SalesforceConnection.caseNumber
            issueView.isHidden = false
            issueView.frame.size.height = 78.0
        }
        
        Utilities.caseConfigDict = [:]
        caseDynamicDict = [:]
        
        if(Utilities.caseActionStatus == "View"){
            self.navigationItem.rightBarButtonItem = nil
        }
        
        
        if(SalesforceConnection.caseId != ""){
            readCaseData()
        }
        
        readJson()
        
        
    }
    
    private func readCaseData(){
        let caseResults = ManageCoreData.fetchData(salesforceEntityName: "Cases",predicateFormat: "caseId == %@" ,predicateValue: SalesforceConnection.caseId,isPredicate:true) as! [Cases]
        
        if(caseResults.count > 0){
            caseDynamicDict = caseResults[0].caseDynamic as! [String : AnyObject]
        }
    }
    
    
    
    
    
    
    private func parseJson(jsonObject: Dictionary<String, AnyObject>){
        
        
        guard
            let sectionResults = jsonObject["Section"] as? [[String: AnyObject]] else { return }
        
        var sequence = 0
        
        for sectionData in sectionResults {
            
            guard let fieldListResults = sectionData["fieldList"] as? [[String: AnyObject]]  else { break }
            
            let sectionName = sectionData["sectionName"] as? String  ?? ""
            
            sequence = sequence + 1
            
            sectionFieldDict = [:]
            
            tempArray = []
            
            for fieldListData in fieldListResults {
                
                let apiName = fieldListData["apiName"] as? String  ?? ""
                let dataType = fieldListData["dataType"] as? String  ?? ""
                
                
                if sectionFieldDict[sectionName] != nil {
                    
                    var arrayValue:[CaseDO] =  sectionFieldDict[sectionName]!
                    
                    
                    arrayValue.append(CaseDO(sequence: fieldListData["sequence"] as? String  ?? "", pickListValue: fieldListData["picklistValue"] as? String  ?? "", fieldName: fieldListData["fieldName"] as? String  ?? "", dataType: dataType, apiName: apiName,sectionName:sectionName))
                    
                    sectionFieldDict[sectionName] = arrayValue
                    
                    
                    orderedSectionFieldDict[sequence] = sectionFieldDict
                    
                    if(dataType == "DATE"){
                        
                        if let dateVal = caseDynamicDict[apiName]{
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let date = dateFormatter.date(from: dateVal as! String)!
                            Utilities.caseConfigDict[apiName] = date as AnyObject?
                            
                        }
                        else{
                            Utilities.caseConfigDict[apiName] = nil
                        }
                        
                        
                    }
                        
                    else{
                        Utilities.caseConfigDict[apiName] = caseDynamicDict[apiName]
                    }
                    
                }
                    
                else{
                    
                    tempArray.append(CaseDO(sequence: fieldListData["sequence"] as? String  ?? "", pickListValue: fieldListData["picklistValue"] as? String  ?? "", fieldName: fieldListData["fieldName"] as? String  ?? "", dataType: dataType, apiName: apiName,sectionName:sectionName))
                    
                    
                    
                    sectionFieldDict[sectionName] = tempArray
                    
                    orderedSectionFieldDict[sequence] = sectionFieldDict
                    
                    if(dataType == "DATE"){
                        
                        if let dateVal = caseDynamicDict[apiName]{
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let date = dateFormatter.date(from: dateVal as! String)!
                            Utilities.caseConfigDict[apiName] = date as AnyObject?
                            
                        }
                        else{
                            Utilities.caseConfigDict[apiName] = nil
                        }
                        
                        
                    }
                        
                    else{
                        Utilities.caseConfigDict[apiName] = caseDynamicDict[apiName]
                    }
                    
                    
                }
                
            }
            
            
            
            
            
            
        }
        
        convertToArray()
    }
    
    
    private func convertToArray(){
        
        
//        for (key, value) in sectionFieldDict {
//            print("\(key) -> \(value)")
//            caseConfigArray.append(caseConfigObjects(sectionName: key, sectionObjects: value))
//        }
//        
        
        
        let orderedKeys = orderedSectionFieldDict.keys.sorted()
        print(orderedKeys.description)
        
        for orderedKey in orderedKeys {
            
             print("Key = \(orderedKey) Value = \(orderedSectionFieldDict[orderedKey]!)" )
            
            for (key, value) in orderedSectionFieldDict[orderedKey]! {
                print("\(key) -> \(value)")
                caseConfigArray.append(caseConfigObjects(sectionName: key, sectionObjects: value))
            }
            
           
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
    
    @IBAction func btnGotoIssueAction(_ sender: Any) {
        //self.performSegue(withIdentifier: "showIssueIdentifier", sender: nil)
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
            
            
            if let switchValue = Utilities.caseConfigDict[caseObject.apiName]{
                uiSwitch.isOn = switchValue as! Bool
            }
            else{
                uiSwitch.isOn = false
            }
            
            
            if(Utilities.caseActionStatus != "View"){
                
                uiSwitch.addTarget(self, action: #selector(CaseConfigTableViewController.switchChanged(_:)), for: UIControlEvents.valueChanged)
                
            }
            else{
                uiSwitch.isEnabled = false
            }
            
            
            switchCell.accessoryView = uiSwitch
            
            
            
            return switchCell
            
            
        }
        else if(caseObject.dataType == "TEXTAREA"){
            
            let textAreaCell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            
            textAreaCell.textLabel?.text = caseObject.fieldName
            textAreaCell.textLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            textAreaCell.textLabel?.numberOfLines = 2
            
            // textAreaCell.backgroundColor = UIColor.clear
            
            
            textAreaCell.selectionStyle = .none
            
            textAreaDict[indexPath.row] = caseObject.apiName
            
            //UITextView
            let textArea = UITextView(frame: CGRect(x: 0, y: 0, width: 200, height: 99))
            textArea.font = UIFont.init(name: "Arial", size: 16.0)
            textArea.textAlignment = .right
            
            textArea.tag = indexPath.row
            textArea.delegate = self
            
            if let textAreaValue = Utilities.caseConfigDict[caseObject.apiName] as! String! {
                textArea.text  = textAreaValue
            }
            else{
                textArea.text  = ""
            }
            
            
            
            let grayColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
            
            //            tf.layer.borderColor = blackColor.cgColor
            //
            //            tf.layer.borderWidth = 2.0
            //
            textArea.layer.backgroundColor = grayColor.cgColor
            
            if(Utilities.caseActionStatus == "View"){
                textArea.isEditable = false
            }
            
            textArea.textColor = UIColor.gray
            
            textAreaCell.accessoryView = textArea
            
            
            
            return textAreaCell
        }
        else if(caseObject.dataType == "PICKLIST"){
            
            
            let pickListCell = tableView.dequeueReusableCell(withIdentifier: "rightDetailCell", for: indexPath)
            
            
            pickListCell.textLabel?.text = caseObject.fieldName
            pickListCell.textLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            // pickListCell.backgroundColor = UIColor.clear
            
            if(Utilities.caseActionStatus == "View"){
                pickListCell.accessoryType = .none
                pickListCell.selectionStyle = .none
                
            }
            else{
                pickListCell.accessoryType = .disclosureIndicator
                 pickListCell.selectionStyle = .default
            }
            
            
            
            if let pickListValue = Utilities.caseConfigDict[caseObject.apiName] as! String! {
                pickListCell.detailTextLabel?.text = pickListValue
            }
                        else{
                            pickListCell.detailTextLabel?.text = ""
                        }
            
            pickListCell.detailTextLabel?.textColor = UIColor.gray
            pickListCell.detailTextLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            return pickListCell
            
        }
        else if(caseObject.dataType == "MULTIPICKLIST"){
            
            
            let multiPickListCell = tableView.dequeueReusableCell(withIdentifier: "rightDetailCell", for: indexPath)
            
            
            multiPickListCell.textLabel?.text = caseObject.fieldName
            multiPickListCell.textLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            if(Utilities.caseActionStatus == "View"){
                multiPickListCell.accessoryType = .none
                
            }
            else{
                multiPickListCell.accessoryType = .disclosureIndicator
            }
            
            
            
            
            
            if let multiPickListValue = Utilities.caseConfigDict[caseObject.apiName] as! String! {
                multiPickListCell.detailTextLabel?.text = multiPickListValue
            }
                        else{
                            multiPickListCell.detailTextLabel?.text = ""
                        }
            
            
            
            multiPickListCell.detailTextLabel?.numberOfLines = 2
            
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
            
            dateTimeCell.datePicker.datePickerMode = UIDatePickerMode.date
            
            if let val = Utilities.caseConfigDict[caseObject.apiName]{
                let dateVal = val as! Date
                dateTimeCell.datePicker.date = dateVal
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy"
                dateTimeCell.detail.text = dateFormatter.string(from: dateVal)
                
            }
                
            else
            {
                //dateTimeCell.datePicker.setDate(Date(), animated: false)
                dateTimeCell.datePicker.date = Date()
                dateTimeCell.detail.text = ""
                
//                let isToday = NSDate()
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "MM-dd-yyyy"
//                dateTimeCell.detail.text = dateFormatter.string(from: isToday as Date)
//               
              
            }
            
            
            if(Utilities.caseActionStatus == "View"){
               dateTimeCell.accessoryType = .none
            }
            else{
                 dateTimeCell.accessoryType = .disclosureIndicator
            }
            
           
            
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
            
            phoneTextfield.textAlignment = .right
            phoneTextfield.tag = indexPath.row
            phoneTextfield.delegate = self
            
            if let phoneVal = Utilities.caseConfigDict[caseObject.apiName]{
                phoneTextfield.text = String(describing: phoneVal)
            }
            else{
                phoneTextfield.text = ""
            }
            
            
            
            
            let whiteColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
            
            
            phoneTextfield.layer.backgroundColor = whiteColor.cgColor
            
            if(Utilities.caseActionStatus == "View"){
                phoneTextfield.isEnabled = false
            }
            
            phoneCell.accessoryView = phoneTextfield
            
            phoneTextfield.textColor = UIColor.gray
            
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
            //tf.placeholder = "Enter text here"
            
            textfield.textAlignment = .right
            textfield.tag = indexPath.row
            textfield.delegate = self
            
            if let textFieldValue = Utilities.caseConfigDict[caseObject.apiName] as! String! {
                textfield.text  = textFieldValue
            }
            else{
                textfield.text  = ""
            }
            
            
            
            let grayColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
            
            //            tf.layer.borderColor = blackColor.cgColor
            //
            //            tf.layer.borderWidth = 2.0
            //
            textfield.layer.backgroundColor = grayColor.cgColor
            
            if(Utilities.caseActionStatus == "View"){
                textfield.isEnabled = false
            }
            
            textfield.textColor = UIColor.gray
            
            textCell.accessoryView = textfield
            
            
            
            return textCell
        }
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let caseObject:CaseDO = caseConfigArray[indexPath.section].sectionObjects[indexPath.row]
        
        if(caseObject.dataType == "PICKLIST" && Utilities.caseActionStatus != "View"){
            
            currentPickListApiName = caseObject.apiName
            
            let pickListVC = self.storyboard!.instantiateViewController(withIdentifier: "picklistIdentifier") as? PickListViewController
            
            pickListVC?.picklistStr = caseObject.pickListValue
            
            
            pickListVC?.pickListProtocol = self
            
            if let selectedVal = Utilities.caseConfigDict[currentPickListApiName]{
                pickListVC?.selectedPickListValue = selectedVal as! String
            }
            else{
                pickListVC?.selectedPickListValue = ""
            }
            
            self.navigationController?.pushViewController(pickListVC!, animated: true)
        }
            
        else if(caseObject.dataType == "MULTIPICKLIST" && Utilities.caseActionStatus != "View"){
            
            currentMultiPickListApiName = caseObject.apiName
            
            let multiPickListVC = self.storyboard!.instantiateViewController(withIdentifier: "multiPicklistIdentifier") as? MultiPickListViewController
            
            multiPickListVC?.multiPicklistStr = caseObject.pickListValue
            
            multiPickListVC?.multiPickListProtocol = self
            
            if let selectedVal = Utilities.caseConfigDict[currentMultiPickListApiName]{
                multiPickListVC?.selectedMultiPickListValue = selectedVal as! String
            }
            else{
                multiPickListVC?.selectedMultiPickListValue = ""
            }
            
            
            
            self.navigationController?.pushViewController(multiPickListVC!, animated: true)
        }
        else if(caseObject.dataType == "DATE" && Utilities.caseActionStatus != "View"){
            
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
        
        
        
        
        //        let cornerRadius: CGFloat = 5
        //        cell.backgroundColor = .clear
        //
        //        let layer = CAShapeLayer()
        //        let pathRef = CGMutablePath()
        //        let bounds = cell.bounds.insetBy(dx: 20, dy: 0)
        //        var addLine = false
        //
        //        if indexPath.row == 0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
        //            pathRef.__addRoundedRect(transform: nil, rect: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
        //        } else if indexPath.row == 0 {
        //            pathRef.move(to: .init(x: bounds.minX, y: bounds.maxY))
        //            pathRef.addArc(tangent1End: .init(x: bounds.minX, y: bounds.minY), tangent2End: .init(x: bounds.midX, y: bounds.minY), radius: cornerRadius)
        //            pathRef.addArc(tangent1End: .init(x: bounds.maxX, y: bounds.minY), tangent2End: .init(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)
        //            pathRef.addLine(to: .init(x: bounds.maxX, y: bounds.maxY))
        //            addLine = true
        //        } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
        //            pathRef.move(to: .init(x: bounds.minX, y: bounds.minY))
        //            pathRef.addArc(tangent1End: .init(x: bounds.minX, y: bounds.maxY), tangent2End: .init(x: bounds.midX, y: bounds.maxY), radius: cornerRadius)
        //            pathRef.addArc(tangent1End: .init(x: bounds.maxX, y: bounds.maxY), tangent2End: .init(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)
        //            pathRef.addLine(to: .init(x: bounds.maxX, y: bounds.minY))
        //        } else {
        //            pathRef.addRect(bounds)
        //            addLine = true
        //        }
        //
        //        layer.path = pathRef
        //        layer.fillColor = UIColor(white: 1, alpha: 0.8).cgColor
        //
        //        if (addLine == true) {
        //            let lineLayer = CALayer()
        //            let lineHeight = 1.0 / UIScreen.main.scale
        //            lineLayer.frame = CGRect(x: bounds.minX + 10, y: bounds.size.height - lineHeight, width: bounds.size.width - 10, height: lineHeight)
        //            lineLayer.backgroundColor = tableView.separatorColor?.cgColor
        //            layer.addSublayer(lineLayer)
        //        }
        //
        //        let testView = UIView(frame: bounds)
        //        testView.layer.insertSublayer(layer, at: 0)
        //        testView.backgroundColor = .clear
        //        cell.backgroundView = testView
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
    
        Utilities.caseConfigDict[switchDict[index]!] = sender.isOn as AnyObject?
        
       
    }
    
  
    
    
 
    
    func textViewDidEndEditing(_ textView: UITextView) -> Bool {
        
        Utilities.caseConfigDict[textAreaDict[textView.tag]!] =  textView.text! as AnyObject?
        
        // selectedTextAreaDict[textAreaDict[textView.tag]!] =  textView.text!
        textView.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(phoneTextFieldDict[textField.tag] != nil){
            let aSet =  NSCharacterSet(charactersIn:"0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            
            let currentCharacterCount = textField.text?.characters.count ?? 0
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            let newLength = currentCharacterCount + string.characters.count - range.length
            if(newLength > 10){
                return false
            }
      
            
            Utilities.caseConfigDict[phoneTextFieldDict[textField.tag]!] = Int64(textField.text! + string)
                as AnyObject
            
            return string == numberFiltered
        }
        else{
            Utilities.caseConfigDict[textFieldDict[textField.tag]!] =  (textField.text! + string) as AnyObject?
            return true
        }
        
    }
    
    var iosCaseId:String = ""
    
    @IBAction func save(_ sender: Any) {
        
        
        var msg:String = ""
        
        prepareCaseResponse()
        
        //New Case --> Edit Case (Not handled)
        //Edit Case
        
        if(SalesforceConnection.caseId != ""){
            
            iosCaseId = SalesforceConnection.caseId
            
            if(SalesforceConnection.caseNumber != ""){
                caseResponseDict["Id"] = SalesforceConnection.caseId as AnyObject?
            }
            
            let caseResults = ManageCoreData.fetchData(salesforceEntityName: "AddCase",predicateFormat: "caseId == %@" ,predicateValue: SalesforceConnection.caseId,isPredicate:true) as! [AddCase]

            if(caseResults.count > 0){
                updateCaseResponseInCoreData()
            }
            else{
                saveCaseResponseInCoreData()
            }
            
            updateCaseInCoreData()
            
            msg = "Case has been updated successfully."
        }
        else{
            iosCaseId = UUID().uuidString
            
            saveCaseResponseInCoreData()
            saveCaseInCoreData()
            msg = "Case has been created successfully."
        }
        
      
        
       
        self.view.makeToast(msg, duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateCaseView"), object: nil)
            
            
            
            self.navigationController?.popViewController(animated: true);
            
            
        }
        
    }
    
    var caseResponseDict:[String:AnyObject] = [:]
    
    func prepareCaseResponse(){
        
        
        let dateOfIntakeFormat = DateFormatter()
        dateOfIntakeFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        caseResponseDict["Date_of_Intake__c"] = dateOfIntakeFormat.string(from: Date()) as AnyObject?
        
       
        for (key, value) in Utilities.caseConfigDict {
            
            if let str = value as? String {
                caseResponseDict[key] = str.replacingOccurrences(of: ",", with: ";") as AnyObject?
            }
            else{
                
                if let dateVal = value as? Date {
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    caseResponseDict[key] = dateFormatter.string(from: dateVal) as AnyObject?
                    
                }
                else{
                    caseResponseDict[key] = value
                }
            }
            
        }
        
      
        
        print(caseResponseDict)
        
        
        
    }
    
    
    func saveCaseResponseInCoreData(){
        let addCaseObject = AddCase(context: context)
        
        
        addCaseObject.clientId = SalesforceConnection.currentTenantId
        
        addCaseObject.caseResponse = caseResponseDict as NSObject?
        
        addCaseObject.caseId = iosCaseId
        
        addCaseObject.actionStatus = "create"
        
       
        

        appDelegate.saveContext()
    }
    
    
    func updateCaseResponseInCoreData(){
        
        var updateObjectDic:[String:AnyObject] = [:]

        
        updateObjectDic["caseResponse"] = caseResponseDict as NSObject?
     
       
        ManageCoreData.updateAnyObjectRecord(salesforceEntityName: "AddCase", updateKeyValue: updateObjectDic, predicateFormat: "caseId == %@", predicateValue: SalesforceConnection.caseId,isPredicate: true)
        
        
    }
    
    
    
    
    func saveCaseInCoreData(){
        let caseObject = Cases(context: context)
        
        caseObject.assignmentLocUnitId = SalesforceConnection.assignmentLocationUnitId
        caseObject.unitId = SalesforceConnection.unitId
        caseObject.caseId =  iosCaseId
        caseObject.caseNo =  ""
        caseObject.contactId = SalesforceConnection.currentTenantId
        caseObject.contactName = SalesforceConnection.currentTenantName
        caseObject.caseStatus = "Open"
        
        caseObject.caseOwnerId = SalesforceConnection.salesforceUserId
        caseObject.caseOwner = "Nik Samajdwar"//SalesforceConfig.currentU
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        let dateString = dateFormatter.string(from: Date())
        
        caseObject.createdDate = dateString

        caseObject.caseDynamic = caseResponseDict as NSObject?
        
        
        appDelegate.saveContext()
    }
    
    func updateCaseInCoreData(){
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        
        updateObjectDic["caseDynamic"] = caseResponseDict as NSObject?
        
        
        ManageCoreData.updateAnyObjectRecord(salesforceEntityName: "Cases", updateKeyValue: updateObjectDic, predicateFormat: "caseId == %@", predicateValue: SalesforceConnection.caseId,isPredicate: true)
    }
    
    
    
    @IBAction func cancel(_ sender: Any) {
        
        if(Utilities.caseActionStatus == "View"){
            self.navigationController?.popViewController(animated: true);
            
        }
        else{
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
            
        }
        
        
        // self.navigationController?.popViewController(animated: true);
    }
    
    
}


