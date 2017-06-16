//
//  UnitsViewController.swift
//  MTXGIS
//
//  Created by Kamal on 23/02/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

struct UnitsDataStruct
{
    var unitId : String = ""
    var unitName : String = ""
    var floor: String = ""
    var surveyStatus: String = ""
    var syncDate: String = ""
}


class UnitsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    

    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    @IBOutlet weak var floorFilterView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var dataFullAddress: UILabel!
    
    @IBOutlet weak var toolBarView: UIView!
    
    
    @IBOutlet weak var floorSelectImage: UIImageView!
    @IBOutlet weak var floorTextField: UITextField!
    var locId:String!
    var locName:String!
    var updatedUnitId:String?
    
    var unitDictionaryArray:Dictionary<String, AnyObject> = [:]
    
    var unitNameArray = [String]()
    var unitIdArray = [String]()
    var floorArray = [String]()
    var surveyStatusArray = [String]()
    var syncDateArray = [String]()
    
    @IBOutlet weak var newUnitLbl: UILabel!
    @IBOutlet weak var newCaseLbl: UILabel!
    
    
    let picker_values = ["val 1", "val 2", "val 3", "val 4"]
    var floorFilteredArray = [String]()
    var selectedFloorValue:String = "All"
    
    var UnitDataArray = [UnitsDataStruct]()
    
    var myPicker: UIPickerView! = UIPickerView()
    
    @IBOutlet weak var unitView: UIStackView!
    @IBOutlet weak var cellContentView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            
            print("RevealViewController")
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
           // self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        self.toolBarView.layer.borderWidth = 2
        self.toolBarView.layer.borderColor =  UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).cgColor
        
        let newUnitTapGesture = UITapGestureRecognizer(target: self, action: Selector(("NewUnitLblTapped:")))
        
        // add it to the image view;
        newUnitLbl.addGestureRecognizer(newUnitTapGesture)
        // make sure imageView can be interacted with by user
        newUnitLbl.isUserInteractionEnabled = true
        
        let newCaseTapGesture = UITapGestureRecognizer(target: self, action: Selector(("NewCaseLblTapped:")))
        
        // add it to the image view;
        newCaseLbl.addGestureRecognizer(newCaseTapGesture)
        // make sure imageView can be interacted with by user
        newCaseLbl.isUserInteractionEnabled = true
        
        let floorFilterViewTapGesture = UITapGestureRecognizer(target: self, action: Selector(("FloorFilterViewTapped:")))
        
        // add it to the image view;
        floorFilterView.addGestureRecognizer(floorFilterViewTapGesture)
        // make sure imageView can be interacted with by user
        floorFilterView.isUserInteractionEnabled = true
        
        
        
        
    
         NotificationCenter.default.addObserver(self, selector:#selector(UnitsViewController.UpdateUnitView), name: NSNotification.Name(rawValue: "UpdateUnitView"), object:nil
        )
        
    
        
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "MTXLogoWhite")
        imageView.image = image
        self.navigationItem.titleView = imageView
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        
        dataFullAddress.text = locName // SalesforceRestApi.currentFullAddress
        //SalesforceRestApi.currentFullAddress = locName
      
        
       
        self.myPicker  = UIPickerView(frame: CGRect(x: 0, y: 200, width: view.frame.width, height: 300))
        //self.myPicker.backgroundColor = .whiteColor()
        self.myPicker.showsSelectionIndicator = true
        self.myPicker.delegate = self
        self.myPicker.dataSource = self
        
        let openFloorPickerTapGesture = UITapGestureRecognizer(target: self, action: Selector(("OpenFloorPickerTapped:")))
        
        // add it to the image view;
        floorSelectImage.addGestureRecognizer(openFloorPickerTapGesture)
        // make sure imageView can be interacted with by user
        floorSelectImage.isUserInteractionEnabled = true
        
    }
    
    @IBAction func backBtn(sender: AnyObject) {
        
        
        self.performSegue(withIdentifier: "GoBackToMapIdentifier", sender: nil)
        
        // _ = self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func UnwindBackFromSubmitSurvey(segue:UIStoryboardSegue) {
        
        print("UnwindBackFromSubmitSurvey")
        
    }
    
    func NewUnitLblTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
       // self.performSegue(withIdentifier: "showAddNewUnitIdentifier", sender: nil)
    }
    
    func NewCaseLblTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        //self.performSegue(withIdentifier: "showAddNewCaseIdentifier", sender: nil)
    }
    
    func OpenFloorPickerTapped(gesture: UIGestureRecognizer) {
        self.floorTextField.becomeFirstResponder()
    }
    
    func FloorFilterViewTapped(gesture: UIGestureRecognizer) {
        self.floorTextField.becomeFirstResponder()
    }
    
    
    
    
    func UpdateUnitView(){
        print("updateTabledata")
        updateTableViewData()
    }
    
    // Cleanup notifications added in viewDidLoad
    deinit {
        NotificationCenter.default.removeObserver("UpdateUnitView")
    }
    
    
    
    // var unitDataArray = [UnitsDataStruct]()
    
    
    func updateTableViewData(){
        
        let unitResults = ManageCoreData.fetchData(salesforceEntityName: "Unit",isPredicate:false) as! [Unit]
        
        if(unitResults.count > 0){
            
            for unitData in unitResults{
                
                let objectUnitStruct:UnitsDataStruct = UnitsDataStruct(unitId: unitData.id!, unitName: unitData.name!, floor: unitData.floor!, surveyStatus: "", syncDate: "")
                
                UnitDataArray.append(objectUnitStruct)
                
            }
        }
        
        OriginalUnitDataArray = UnitDataArray
        
        self.floorTextField.text = "All"
        self.tableView.reloadData()
        
       /*  DispatchQueue.main.async {
            self.floorTextField.text = "All"
            self.tableView.reloadData()
            self.viewDidLayoutSubviews()
        }*/
        
 
        
    
        
        
    }
    
    func removeDuplicates(array: [String]) -> [String] {
        var encountered = Set<String>()
        var result: [String] = []
        for value in array {
            if encountered.contains(value) {
                // Do not add a duplicate element.
            }
            else {
                // Add value to the set.
                encountered.insert(value)
                // ... Append the value.
                result.append(value)
            }
        }
        return result
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        super.viewWillAppear(animated)
        
        updateTableViewData()
    }
    
    
    /*func readJSONObject(object: Dictionary<String, AnyObject>) {
        
        var unitNameArray1 = [String]()
        var unitIdArray1 = [String]()
        var floorArray1 = [String]()
        var surveyStatusArray1 = [String]()
        var syncDateArray1 = [String]()
        
        var UnitDataArray1 = [UnitsDataStruct]()
        
        guard let _ = object["errorMessage"] as? String
            , let results = object["data"] as? [[String: AnyObject]] else { return }
        
        for data in results {
            guard let dataLocId = data["locId"] as? String else { break }
            
            /* print("dataLocId \(dataLocId)")
             print("locId \(locId)")*/
            
            if(dataLocId == locId){
                
                guard let units = data["units"] as? [[String: AnyObject]] else { return }
                
                print("Units \(units)")
                
                
                
                for unit in units{
                    
                    let unitId = unit["unitId"] as? String ?? ""
                    let unitName = unit["name"] as? String ?? ""
                    let floor = unit["floor"] as? String ?? ""
                    let surveyStatus = unit["surveyStatus"] as? String ?? ""
                    let syncDate = unit["surveyTakenDate"] as? String ?? ""
                    
                    
                    let objectUnitStruct:UnitsDataStruct = UnitsDataStruct(unitId: unitId, unitName: unitName, floor: floor, surveyStatus: surveyStatus, syncDate: syncDate)
                    
                    
                    UnitDataArray1.append(objectUnitStruct)
                    
                    
                    
                    unitNameArray1.append(unitName)
                    unitIdArray1.append(unitId)
                    floorArray1.append(floor)
                    surveyStatusArray1.append(surveyStatus)
                    syncDateArray1.append(syncDate)
                    
                    print("unitName \(unitName)")
                    
                    
                }
            }
            
        }
        
        unitIdArray = unitIdArray1
        floorArray = floorArray1
        unitNameArray = unitNameArray1
        surveyStatusArray = surveyStatusArray1
        syncDateArray = syncDateArray1
        
        UnitDataArray = UnitDataArray1
        OriginalUnitDataArray = UnitDataArray1
        
        print("readJsonData done")
        
        
    }
    
    */
    
    
    override func viewDidLayoutSubviews() {
        
        self.heightConstraint.constant = tableView.contentSize.height
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UITableViewDataSource
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return UnitDataArray.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)  as! UnitsCustomViewCell
        
        
        
        cell.dataUnit.text = UnitDataArray[indexPath.row].unitName
       
        /*
        
        if(SalesforceRestApi.currentUnitId != nil && unitIdArray[indexPath.row] == SalesforceRestApi.currentUnitId && SalesforceRestApi.isSubmitSurvey == true){
            
            
            
            if(Reachability.isConnectedToNetwork()){
                cell.pendingIcon.isHidden = true
                cell.dataSyncDate.text = "Pending"
                cell.dataSyncDate.isHidden = false
                
            }
            else{
                cell.pendingIcon.isHidden = false
                cell.dataSyncDate.text = ""
                cell.dataSyncDate.isHidden = true
            }
            
            cell.dataSyncStatus.text = "Completed"
            
        }
            
        else{
            
            
            
            cell.dataSyncDate.text = UnitDataArray[indexPath.row].syncDate
            
            cell.dataSyncStatus.text = UnitDataArray[indexPath.row].surveyStatus
            
            cell.pendingIcon.isHidden = true
            cell.dataSyncDate.isHidden = false
            
        }
        
        */
        
        
        cell.dataSyncDate.text = UnitDataArray[indexPath.row].syncDate
        
        cell.dataSyncStatus.text = UnitDataArray[indexPath.row].surveyStatus
        
        cell.pendingIcon.isHidden = true
        cell.dataSyncDate.isHidden = false
        
        
        cell.dataUnitId.text = UnitDataArray[indexPath.row].unitId
        
        cell.dataFloor.text = UnitDataArray[indexPath.row].floor
        
        
        
        
        
        return cell
        
        
    }
    
    
    
    
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    
     func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        
        
        
        
        if(segue.identifier == "showSurveyIdentifier"){
            
        }
        else if(segue.identifier == "showAddNewUnitIdentifier"){
            
         
            
        }
            
        else if(segue.identifier == "UnwindBackFromUnit"){
            
        }
        
        
        
    }
    
    @IBAction func NewUnitBtn(sender: AnyObject) {
        
        
        //self.performSegue(withIdentifier: "showAddNewUnitIdentifier", sender: sender)
    }
    
    
    @IBAction func NewCaseBtn(sender: AnyObject) {
        
        //self.performSegue(withIdentifier: "showAddNewCaseIdentifier", sender: sender)
        
    }
    
    
    
    
    func cancelPicker() {
        //Remove view when select cancel
        self.floorTextField.resignFirstResponder() // To resign the inputView on clicking done.
    }
    
    var filterActive : Bool = false
    var filteredStruct = [UnitsDataStruct]()
    var OriginalUnitDataArray = [UnitsDataStruct]()
    
    func doneButton() {
        //Remove view when select cancel
        self.floorTextField.resignFirstResponder() // To resign the inputView on clicking done.
        floorTextField.text = selectedFloorValue
        
        
        if(selectedFloorValue != "All"){
            
            filteredStruct = OriginalUnitDataArray.filter {
                
                $0.floor  == selectedFloorValue
            }
            
            UnitDataArray = filteredStruct
            print(UnitDataArray.count)
        }
        else{
            
            UnitDataArray = OriginalUnitDataArray
        }
        
        if(UnitDataArray.count == 0){
            filterActive = false;
        } else {
            filterActive = true;
        }
        self.tableView.reloadData()
        
        
        
    }
    
    
    //MARK: - Delegates and data sources
    
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 1
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return floorFilteredArray.count
    }
    
    //MARK: Delegates
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return floorFilteredArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedFloorValue = floorFilteredArray[row]
    }
    
    
    @IBAction func textFieldShouldBeginEditing(sender: UITextField) {
        
        
        
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.bordered, target: self, action: #selector(UnitsViewController.doneButton))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.bordered, target: self, action: #selector(UnitsViewController.cancelPicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        sender.inputView = myPicker
        sender.inputAccessoryView = toolBar
       
    }
    
}


