//
//  MoreOptionsViewController.swift
//  Knock
//
//  Created by Kamal on 19/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit
import DLRadioButton
import DropDown

struct SurveyDataStruct
{
    var surveyId : String = ""
    var surveyName : String = ""
    
}

struct TenantDataStruct
{
    var tenantId : String = ""
    var name:String = ""
    var firstName : String = ""
    var lastName : String = ""
    var email : String = ""
    var phone : String = ""
    var age : String = ""
    var dob:String = ""
    //var teantStatus:String = ""
    //var inTakeStaus:String = ""
    
}

protocol ReasonStatusProtocol {
    func getReasonStatus(strReasonStatus:String)
}



class MoreOptionsViewController: UIViewController,UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource,ReasonStatusProtocol
{
    
    typealias typeCompletionHandler = () -> ()
    var completion : typeCompletionHandler = {}

    
    var completionHandler : ((_ childVC:MoreOptionsViewController) -> Void)?
    
    var attempt:String = ""
    var contact:String = ""
    var reknockNeeded:String = ""
    var inTake:String = ""
    
    var reasonStatus:String = ""
    
    var notes:String = ""
    
    var selectedTenantId:String = ""
    
    let pickerView = UIPickerView()
  
    var reasonCell:UITableViewCell!
    
    @IBOutlet weak var saveOutlet: UIBarButtonItem!
    @IBOutlet weak var addTenantOutlet: UIButton!
   
   // @IBOutlet weak var notesTextArea: UITextView!
    
    @IBOutlet weak var tblTeanantVw: UITableView!

    @IBOutlet weak var notesTextArea: UITextView!
    
    @IBOutlet weak var tblEditUnit: UITableView!
    
    @IBOutlet weak var chooseSurveyView: UIView!
    @IBOutlet weak var chooseUnitInfoView: UIView!
    @IBOutlet weak var chooseTenantInfoView: UIView!
    
    @IBOutlet weak var surveyCollectionView: UICollectionView!
    
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var fullAddressText: UILabel!
    
    var selectedSurveyId:String = ""
    

    var surveyDataArray = [SurveyDataStruct]()
    var surveyUnitResults = [EditUnit]()
    
    var tenantDataArray = [TenantDataStruct]()
    var tenantResults = [Tenant]()
    
    
    
      var editUnitDict : [String:String] = [:]
      var tenantAssignDict : [String:String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTenantOutlet.layer.cornerRadius = 5
        
        
        
   
        
        
       
        
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(MoreOptionsViewController.UpdateTenantView), name: NSNotification.Name(rawValue: "UpdateTenantView"), object:nil
        )
        
        NotificationCenter.default.addObserver(self, selector:#selector(MoreOptionsViewController.UpdateSurveyView), name: NSNotification.Name(rawValue: "UpdateSurveyView"), object:nil
        )
        
        fullAddressText.text =  SalesforceConnection.fullAddress
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        

        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.navigationItem.title = SalesforceConnection.unitName
        
        notesTextArea.layer.cornerRadius = 5
        notesTextArea.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        notesTextArea.layer.borderWidth = 0.5
        notesTextArea.clipsToBounds = true
        
        //NotesTextArea.text = "Description"
        notesTextArea.textColor = UIColor.black

        
        
        
        
        segmentedControl.selectedSegmentIndex = 0
        
        chooseUnitInfoView.isHidden = false
        chooseSurveyView.isHidden = true
        chooseTenantInfoView.isHidden = true
        
        populateEditUnit()
        
        
        
//        if(Utilities.currentSegmentedControl == "Unit"){
//            segmentedControl.selectedSegmentIndex = 0
//            
//            chooseUnitInfoView.isHidden = false
//            chooseSurveyView.isHidden = true
//            chooseTenantInfoView.isHidden = true
//            
//            populateEditUnit()
//            
//            //self.saveOutlet.title = "Save"
//        }
//        else if(Utilities.currentSegmentedControl == "Tenant"){
//            segmentedControl.selectedSegmentIndex = 1
//            
//            chooseTenantInfoView.isHidden = false
//            
//            chooseUnitInfoView.isHidden = true
//            chooseSurveyView.isHidden = true
//            
//            //self.saveOutlet.title = "Assign Tenant"
//            
//            
//            populateTenantData()
//            
//        }
//        else if(Utilities.currentSegmentedControl == "Survey"){
//            segmentedControl.selectedSegmentIndex = 2
//            
//            chooseUnitInfoView.isHidden = true
//            chooseTenantInfoView.isHidden = true
//            chooseSurveyView.isHidden = false
//            
//            self.saveOutlet.title = "Save"
//            
//             populateSurveyData()
//            setSelectedSurveyId()
//            
//            
//           
//        }

        // Do any additional setup after loading the view.
    }
    
    func getReasonStatus(strReasonStatus:String){
        
        reasonStatus = strReasonStatus
        tblEditUnit?.reloadData()

    }
    
    func UpdateTenantView(){
        print("UpdateTenantView")
        populateTenantData()
        
        
    }
    
    func UpdateSurveyView(){
       print("UpdateSurveyView")
        populateSurveyData()
    }
    
    func attemptChanged(_ sender: UISwitch) {
        if(sender.isOn){
            attempt = "Yes"
        }
        else{
            attempt = "No"
        }
    }
    
    
    func inTakeChanged(_ sender: UISwitch) {
        
        if(sender.isOn)
        {
            inTake = "Yes"
            reasonCell.detailTextLabel?.isEnabled = false
            reasonCell.detailTextLabel?.text = "Select Reason"
            
            
        }
        else
        {
            inTake = "No"
            reasonCell.detailTextLabel?.isEnabled = true
            reasonCell.detailTextLabel?.text = reasonStatus
            
        }
        
    }
    
    func contactChanged(_ sender: UISwitch) {
        
        if(sender.isOn){
            contact = "Yes"
        }
        else{
            contact = "No"
        }
        
    }
    
    func reKnockChanged(_ sender: UISwitch) {
        
        if(sender.isOn){
            reknockNeeded = "Yes"
        }
        else{
            reknockNeeded = "No"
        }
    }
    
    // Cleanup notifications added in viewDidLoad
    deinit {
        NotificationCenter.default.removeObserver("UpdateTenantView")
        NotificationCenter.default.removeObserver("UpdateSurveyView")
    }
    

    
    @IBAction func addTenant(_ sender: Any) {
        
        SalesforceConnection.currentTenantId =  ""
        
        self.performSegue(withIdentifier: "showSaveEditTenantIdentifier", sender: nil)
    }
    
    
    
    func setSelectedSurveyId(){
        
        surveyUnitResults = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId == %@ ",predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId,predicateValue4:SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate:true) as! [EditUnit]
        
       
        
        if(surveyUnitResults.count == 1){
            selectedSurveyId = surveyUnitResults[0].surveyId!
        }
        else{
            selectedSurveyId = ""
        }

    }
    @IBAction func editTenantAction(_ sender: Any) {
        
        let indexRow = (sender as AnyObject).tag
        
        SalesforceConnection.currentTenantId =  tenantDataArray[indexRow!].tenantId
        
        self.performSegue(withIdentifier: "showSaveEditTenantIdentifier", sender: nil)

    }
    

    
    func populateTenantData(){
        
        tenantDataArray = [TenantDataStruct]()
      
        
        let tenantResults = ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "assignmentId == %@ AND locationId == %@ AND unitId == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId,predicateValue3: SalesforceConnection.unitId,isPredicate:true) as! [Tenant]
        
        
        if(tenantResults.count > 0){
            
            for tenantData in tenantResults{
                
                
                
                let objectTenantStruct:TenantDataStruct = TenantDataStruct(tenantId: tenantData.id!,name: tenantData.name!, firstName: tenantData.firstName!, lastName: tenantData.lastName!, email: tenantData.email!, phone: tenantData.phone!, age: tenantData.age!,dob:tenantData.dob!)
                
                tenantDataArray.append(objectTenantStruct)
                
            }
        }
        
        

        
       selectedTenantId = setSelectedTenant()
        
        self.tblTeanantVw.reloadData()
        
        //self.surveyCollectionView.reloadData()
        
        
        /*
         DispatchQueue.global(qos: .background).async {
         print("This is run on the background queue")
         
         DispatchQueue.main.async {
         print("This is run on the main queue, after the previous code in outer block")
         }
         }
         
         */
        
        
        
        
        
    }
    
     var tempInTake:String = ""
     var tempAttempt:String = ""
     var tempContact:String = ""
     var tempReason:String = ""
     var tempReKnock:String = ""
    
    
    func getIntakeContactAttempt(){
        
        let editUnitResults = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId ==%@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId, predicateValue4: SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate:true) as! [EditUnit]
        
        
        if(editUnitResults.count > 0){
            
            tempInTake = editUnitResults[0].inTake!
            tempAttempt = editUnitResults[0].attempt!
            tempContact = editUnitResults[0].isContact!
            
            tempReason = editUnitResults[0].reason!
            tempReKnock = editUnitResults[0].reKnockNeeded!
        }
        
        
    }

    
    func setSelectedTenant()->String{
        
        let tenantAssignResults = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId ==%@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId, predicateValue4: SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate:true) as! [EditUnit]
        
        
        if(tenantAssignResults.count > 0){
            
            return tenantAssignResults[0].tenantId!
            
        }
        
        return ""
        
   
    }
    
    
    
    func populateSurveyData(){
        
        surveyDataArray = [SurveyDataStruct]()
        //let unitResults = ManageCoreData.fetchData(salesforceEntityName: "Unit",predicateFormat: "locationId == %@" ,predicateValue: SalesforceConnection.locationId,isPredicate:true) as! [Unit]
        
        let surveyQuestionResults = ManageCoreData.fetchData(salesforceEntityName: "SurveyQuestion",predicateFormat: "assignmentId == %@" ,predicateValue: SalesforceConnection.assignmentId,isPredicate:true) as! [SurveyQuestion]
        
        
        if(surveyQuestionResults.count > 0){
            
            for surveyData in surveyQuestionResults{
                
               
                let objectSurveyStruct:SurveyDataStruct = SurveyDataStruct(surveyId: surveyData.surveyId!, surveyName: surveyData.surveyName!)
                
                surveyDataArray.append(objectSurveyStruct)
                
            }
        }
        
       
         self.surveyCollectionView.reloadData()
        
        
        /*
         DispatchQueue.global(qos: .background).async {
         print("This is run on the background queue")
         
         DispatchQueue.main.async {
         print("This is run on the main queue, after the previous code in outer block")
         }
         }
         
         */
        
        
        
        
        
    }
  
    
    // MARK: UITenantTableView and UIEditTableView
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
         if(tableView == tblTeanantVw){
            return 1
        }
         else{
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == tblTeanantVw){
            return tenantDataArray.count
        }
        else{
            return 1
        }
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        
    if(tableView == tblTeanantVw){
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TenantViewCell
        
        if(tenantDataArray[indexPath.row].tenantId == selectedTenantId){
            
            
           cell.tenantView.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) //green
           cell.contentView.backgroundColor =  UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) //green
            cell.isSelected = true
            cell.setSelected(true, animated: true)
            
            
        }
        
        cell.email.text = tenantDataArray[indexPath.row].email
        cell.phone.text = tenantDataArray[indexPath.row].phone
        cell.name.text = tenantDataArray[indexPath.row].name
        cell.age.text = tenantDataArray[indexPath.row].age
        cell.tenantId.text = tenantDataArray[indexPath.row].tenantId
        
        cell.editBtn.tag = indexPath.row
       
        
            return cell
        }
        
    else{
        
        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "attemptCell", for: indexPath)
        
            cell.backgroundColor = UIColor.clear
        
        
            cell.textLabel?.text = "Attempt?"
        
            cell.selectionStyle = .none
        
            //accessory switch
            let attemptSwitch = UISwitch(frame: CGRect.zero)
        
            if(attempt == "Yes"){
                attemptSwitch.isOn = true
            }
            else if (attempt == "No"){
                attemptSwitch.isOn = false
            // attemptRdb.isOn = false
            }
            else{
                attemptSwitch.isOn = false
            }
        
        
        
            attemptSwitch.addTarget(self, action: #selector(MoreOptionsViewController.attemptChanged(_:)), for: UIControlEvents.valueChanged)
        
            cell.accessoryView = attemptSwitch
            return cell
          }
        else if(indexPath.section == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
            
            cell.backgroundColor = UIColor.clear
            
            
            cell.textLabel?.text = "Contact?"
            
            cell.selectionStyle = .none
            
            //accessory switch
            let contactSwitch = UISwitch(frame: CGRect.zero)
            
            if(contact == "Yes"){
                contactSwitch.isOn = true
            }
            else if (contact == "No"){
                contactSwitch.isOn = false
                // attemptRdb.isOn = false
            }
            else{
                contactSwitch.isOn = false
            }
            
            
            
            contactSwitch.addTarget(self, action: #selector(MoreOptionsViewController.contactChanged(_:)), for: UIControlEvents.valueChanged)
            
            cell.accessoryView = contactSwitch
            return cell

        }
        else if(indexPath.section == 2){
            let cell = tableView.dequeueReusableCell(withIdentifier: "inTakeCell", for: indexPath)
            
            cell.backgroundColor = UIColor.clear
            
            
            cell.textLabel?.text = "Intake?"
            
            cell.selectionStyle = .none
            
            //accessory switch
            let inTakeSwitch = UISwitch(frame: CGRect.zero)
            
            if(inTake == "Yes"){
                inTakeSwitch.isOn = true
            }
            else if (inTake == "No"){
                inTakeSwitch.isOn = false
                // attemptRdb.isOn = false
            }
            else{
                
                inTakeSwitch.isOn = false
            }
            
            
            
            inTakeSwitch.addTarget(self, action: #selector(MoreOptionsViewController.inTakeChanged(_:)), for: UIControlEvents.valueChanged)
            
            cell.accessoryView = inTakeSwitch
            return cell
            
        }
        else if(indexPath.section == 3){
            reasonCell = tableView.dequeueReusableCell(withIdentifier: "reasonCell", for: indexPath)
            
            reasonCell.accessoryType = .disclosureIndicator
            
            reasonCell.backgroundColor = UIColor.clear
            
            
            reasonCell.textLabel?.text = "Reason"
            
            if(reasonStatus.isEmpty){
                reasonCell.detailTextLabel?.text = "Select Reason"
            }
            else{
                reasonCell.detailTextLabel?.text = reasonStatus
            }
            
            reasonCell.detailTextLabel?.textColor = UIColor.lightGray

           
            return reasonCell
            
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reKnockCell", for: indexPath)
            
            cell.backgroundColor = UIColor.clear
            
            
            cell.textLabel?.text = "Reknock needed?"
            
            cell.selectionStyle = .none
            
            //accessory switch
            let reKnockSwitch = UISwitch(frame: CGRect.zero)
            
            if(reknockNeeded == "Yes"){
                reKnockSwitch.isOn = true
            }
            else if (reknockNeeded == "No"){
                reKnockSwitch.isOn = false
                // attemptRdb.isOn = false
            }
            else{
                reKnockSwitch.isOn = false
            }
            
            
            
            reKnockSwitch.addTarget(self, action: #selector(MoreOptionsViewController.reKnockChanged(_:)), for: UIControlEvents.valueChanged)
            
            cell.accessoryView = reKnockSwitch
            return cell
            
        }
        
      }
        
  }
    
   
    
 func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    if(tableView == tblTeanantVw){
        let indexPathArray = tableView.indexPathsForVisibleRows
        
        for indexPath in indexPathArray!{
            
             let cell = tableView.cellForRow(at: indexPath) as! TenantViewCell
            
            if tableView.indexPathForSelectedRow != indexPath {
               
                cell.tenantView.backgroundColor = UIColor.white
                cell.contentView.backgroundColor = UIColor.clear
                
            }
            else{
                
                cell.tenantView.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) //green
                
                cell.contentView.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) //green
                

            }
        }
        
            selectedTenantId = tenantDataArray[indexPath.row].tenantId
        }
    else{
        
        if indexPath.section == 3{
            
            if(inTake == "No"){
                
                
                let reasonStatusVC = self.storyboard!.instantiateViewController(withIdentifier: "reasonStatusIdentifier") as? SelectReasonStatusViewController
                
                reasonStatusVC?.reasonStatusProtocol = self
                
                reasonStatusVC?.selectedReasonStatus = reasonStatus
                
                self.navigationController?.pushViewController(reasonStatusVC!, animated: true)
                
                //tableView.cellforRow
//                for (var i = 0; i < [self.tableView numberOfRowsInSection:indexPath.section]; i++) {
//                    if (i != indexPath.row) {
//                        UITableViewCell* cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
//                        //Do your stuff
//                    }
//                }
                

            }
            
        }
        
    
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        }
        
    }
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath) as! TenantViewCell
//         cell.contentView.backgroundColor = UIColor.white
//    }
//    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Dequeue with the reuse identifier
        if tableView == tblTeanantVw
        {
            let identifier = "tenantHeader"
            var cell: TenantHeaderTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? TenantHeaderTableViewCell
            
            if cell == nil {
                tableView.register(UINib(nibName: "TenantHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
                cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? TenantHeaderTableViewCell
            }
            
            return cell
        }
        else{
            return UIView()
        }
    
       
      
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == tblTeanantVw
        {
            return 44.0
        }
        else{
            return  0.0
        }
    }

    
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    @IBAction func changeSegmented(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            
             showEditUnitView()
            
            
            
        case 1:
            
            if(isEditViewValid()){
                showTenantView()
            }
            
          
           
        case 2:
            
            if(isEditViewValid() && isTenantViewValid()){
                    showSurveyView()
            }
            
            
            
        default:
            
            chooseSurveyView.isHidden = false
            chooseUnitInfoView.isHidden = false
            chooseTenantInfoView.isHidden = false
            Utilities.currentSegmentedControl = "Default"
            //self.saveOutlet.title = "Continue"
        }
    }
    
    
    func isTenantViewValid()->Bool{
        
        
        
        if(setSelectedTenant() == ""){
            
            chooseTenantInfoView.shake()
            
            segmentedControl.selectedSegmentIndex = 1
            Utilities.currentSegmentedControl = "Tenant"
            
            self.view.makeToast("Please click next", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                
                
            }
            
            return false
            
        }
        else{
            
           return true
        }
        
    }
    
    func isEditViewValid()->Bool{
        
        getIntakeContactAttempt()
        
         // if((tempAttempt != "" && tempAttempt != "No") && (tempContact != "" && tempContact != "No") && (tempInTake != "" && tempInTake != "No" )){
            
        if(((tempAttempt != "" && tempAttempt != "No")
            && (tempContact != "" && tempContact != "No")
            && ((tempInTake != "" && tempInTake != "Yes" )&&(tempReKnock != "" && tempReKnock != "No")))||((tempAttempt != "" && tempAttempt != "No")
            && (tempContact != "" && tempContact != "No")
            && ((tempInTake != "" && tempInTake != "No" )))){
            
            return true
        }
            
        else{
            
            chooseUnitInfoView.shake()
            
            segmentedControl.selectedSegmentIndex = 0
            Utilities.currentSegmentedControl = "Unit"
            
            self.view.makeToast("Please click next", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
            }
            
            return false
        }
        
    }
    
    
    func showEditUnitView(){
        
        chooseSurveyView.isHidden = true
        chooseTenantInfoView.isHidden = true
        chooseUnitInfoView.isHidden = false
        segmentedControl.selectedSegmentIndex = 0
        Utilities.currentSegmentedControl = "Unit"
        //self.saveOutlet.title = "Continue"
        
        populateEditUnit()
        
    }
    
    
    func showTenantView(){
        
        
        chooseTenantInfoView.isHidden = false
        chooseSurveyView.isHidden = true
        chooseUnitInfoView.isHidden = true
        segmentedControl.selectedSegmentIndex = 1
        Utilities.currentSegmentedControl = "Tenant"
       // self.saveOutlet.title = "Continue"
        
        
       
       
        
        populateTenantData()
        
    }
    
    
    func showSurveyView(){
        
        
        chooseSurveyView.isHidden = false
        chooseUnitInfoView.isHidden = true
        chooseTenantInfoView.isHidden = true
        segmentedControl.selectedSegmentIndex = 2
        Utilities.currentSegmentedControl = "Survey"
        //self.saveOutlet.title = "Save"
        
        populateSurveyData()
        setSelectedSurveyId()

        
    }
    
    
    func populateEditUnit(){
        let editUnitResults = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId,predicateValue4:SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate:true) as! [EditUnit]
        
        if(editUnitResults.count > 0){
            
            if(editUnitResults[0].attempt == ""){
               editUnitResults[0].attempt = "No"
            }
            
            attempt = editUnitResults[0].attempt!
            
            
            
            if(editUnitResults[0].isContact == ""){
               editUnitResults[0].isContact = "No"
            }
        
            
            contact = editUnitResults[0].isContact!
            
            
            
            
            if(editUnitResults[0].reKnockNeeded == ""){
               editUnitResults[0].reKnockNeeded = "No"
            }
          
            
            reknockNeeded = editUnitResults[0].reKnockNeeded!
            
            
            
            
            if(editUnitResults[0].inTake == ""){
               editUnitResults[0].inTake = "No"
            }
            
            inTake = editUnitResults[0].inTake!
            
           
            
            if(editUnitResults[0].reason! != ""){
                
                reasonStatus = editUnitResults[0].reason!
      
            }

            notesTextArea.text = editUnitResults[0].unitNotes
            
            
        }
    }

    
    
    @IBAction func cancel(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Message", message: "Are you sure you want to cancel without saving", preferredStyle: .alert)
        
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Do some stuff
        }
        alertController.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
       
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
            
            self.dismiss(animated: true, completion: nil)
            //Do some other stuff
        }
        alertController.addAction(okAction)
        
        
        self.present(alertController, animated: true, completion: nil)
        
        

 
    }
    
    @IBAction func save(_ sender: Any) {
        
          if(Utilities.currentSegmentedControl == "Survey"){
        
            if(selectedSurveyId == ""){
                
                 chooseSurveyView.shake()
                
                self.view.makeToast("Please select survey", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    
                }
                
                
                return
            }

            
            updateUnitAndSurvey(type:"Updating Survey..")
        
            
          }
         else if(Utilities.currentSegmentedControl == "Tenant"){
            
            if(selectedTenantId == ""){
                
                chooseTenantInfoView.shake()
                
                self.view.makeToast("Please select client", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
                    
                    self.dismiss(animated: true, completion: nil)
                   
                }

                
                return
            }
            
            
            
            
            let tenantAssignResults = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId ==%@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId, predicateValue4: SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId, isPredicate:true) as! [EditUnit]
            
            
            if(tenantAssignResults.count > 0){
                
                updateTenantAssignInDatabase()
                
            }
                
            else{
                saveTenantAssignInDatabase()
            }
            
            showSurveyView()
            
            
//            self.view.makeToast("Tenant has been assigned successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
//                
//                self.dismiss(animated: true, completion: nil)
//                
//            }
//            
            
        }
        
          else  if(Utilities.currentSegmentedControl == "Unit"){
        
           // Intake = No but Re-knock = Yes
            
            if((attempt == "Yes" && contact == "Yes"  && (inTake == "No" && reknockNeeded == "Yes")) || (attempt == "Yes" && contact == "Yes"  && inTake == "Yes")){
                updateUnitAndSurvey(type:"Updating Unit..")
                showTenantView()
            }
//            else if(attemptRdb.isOn && contactRdb.isOn && (inTakeRdb.isOn == false && reasonStatus != "")){
//                updateUnitAndSurvey(type:"Updating Unit..")
//            }
            else{
                
                
                chooseUnitInfoView.shake()
                updateUnitAndSurvey(type:"Updating Unit..")
                
                self.view.makeToast("You can only proceed to next step if Attempt , Contact and Reknock selected. ", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
                    
                    self.dismiss(animated: true, completion: nil)
                    
                }
            }
        }
         
        
                
           
        
    }
    
   
    
    func pushAssignTenantDataToSalesforce(){
        var updateTenantAssign : [String:String] = [:]
        
        updateTenantAssign["tenantAssignmentDetail"] = Utilities.encryptedParams(dictParameters: tenantAssignDict as AnyObject)
        

        
       SVProgressHUD.show(withStatus: "Assigning tenant...", maskType: SVProgressHUDMaskType.gradient)
        
        SalesforceConnection.loginToSalesforce() { response in
            
            if(response)
            {
                
                
                SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.updateUnit, params: updateTenantAssign){ jsonData in
                    
                    SVProgressHUD.dismiss()
                    self.selectedTenantId = ""
                    
                    
                    self.view.makeToast("Tenant has been assigned successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                    
                    
                    
                }
            }
            
        }
        
    }
    
    
    
    
    func updateUnitAndSurvey(type:String){
      
     
        if let notesTemp = notesTextArea.text{
            notes = notesTemp
        }
        
        
   
        
        if(type == "Updating Unit.."){

            
            let editUnitResults = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId,predicateValue4:SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate:true) as! [EditUnit]
            
            if(inTake == "Yes"){
                reasonStatus = ""
            }
            
            if(editUnitResults.count > 0){
                
                updateEditUnitInDatabase()
            }
            else{
                saveEditUnitInDatabase(currentAttempt: attempt, currentInTake: inTake, currentReknockNeeded: reknockNeeded, currentReason: reasonStatus, currentNotes: notes, currentIsContact: contact, currentTenantId: "", currentSurveyId: "")
                
            }
            
            
           
            
        }
         
            
        //editsurvey
        else{
            

            
            let editSurveyUnitResults = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId,predicateValue4:SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate:true) as! [EditUnit]
            
            if(editSurveyUnitResults.count > 0){
                
                updateEditUnitSurveyInDatabase()
            }
            else{
                saveEditUnitSurveyInDatabase()
                
            }
            
            // self.dismiss(animated: true, completion: nil)
          
            
            
            self.dismiss(animated: true) {
                SalesforceConnection.surveyId = self.selectedSurveyId
                self.completionHandler?(self)
                print("Completion");
            }
            
//            self.dismiss(animated: true, completion: {
//                
//                self.completion()
//                print("Completion");
//            })
//        
            
        }
      
        
//        self.view.makeToast("Unit information has been updated successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
//            
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
//            
//            self.dismiss(animated: true, completion: nil)
//            
//        }

        
       
        
//        if(Network.reachability?.isReachable)!{
//            
//            pushEditUnitDataToSalesforce(type:type)
//        }
//            
//        else{
//            self.view.makeToast("Unit information has been updated successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
//                
//                Utilities.isSubmitSurvey = false
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
//                
//                self.dismiss(animated: true, completion: nil)
//                
//            }
//        }
        
        

    }
    
    
    
    func pushEditUnitDataToSalesforce(type:String){
        
        var updateUnit : [String:String] = [:]
        
        updateUnit["unit"] = Utilities.encryptedParams(dictParameters: editUnitDict as AnyObject)
        
        SVProgressHUD.show(withStatus: type, maskType: SVProgressHUDMaskType.gradient)
        
        SalesforceConnection.loginToSalesforce() { response in
            
            if(response)
            {
                
                
                SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.updateUnit, params: updateUnit){ jsonData in
                    
                    SVProgressHUD.dismiss()
                    
                    
                        self.view.makeToast("Unit information has been updated successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                            
                            //Utilities.isSubmitSurvey = false
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
                            
                            self.dismiss(animated: true, completion: nil)
                            
                        }
                        
                        
                    
                }
            }
            
        }


    }
    
    
   
    
    
  
    
    func updateEditUnitSurveyInDatabase(){
        
        var updateObjectDic:[String:String] = [:]
        
        //updateObjectDic["id"] = tenantDataDict["tenantId"] as! String?
        
        
        updateObjectDic["surveyId"] = selectedSurveyId
        updateObjectDic["actionStatus"] = "edit"
        
        
        ManageCoreData.updateRecord(salesforceEntityName: "EditUnit", updateKeyValue: updateObjectDic, predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId ==%@", predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId, predicateValue4: SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate: true)
        

    }

  

//    func saveEditUnitInDatabase(){
//        
//        let editUnitObject = EditUnit(context: context)
//        
//        editUnitObject.locationId = SalesforceConnection.locationId
//        editUnitObject.assignmentId = SalesforceConnection.assignmentId
//        editUnitObject.assignmentLocId = SalesforceConnection.assignmentLocationId
//        editUnitObject.unitId = SalesforceConnection.unitId
//        editUnitObject.assignmentLocUnitId = SalesforceConnection.assignmentLocationUnitId
//        editUnitObject.actionStatus = "create"
//        
//        
//        editUnitObject.attempt = attempt
//        editUnitObject.inTakeStatus = inTakeStatus
//        editUnitObject.reKnockNeeded = reknockNeeded
//        editUnitObject.tenantStatus = tenantStatus
//        editUnitObject.unitNotes = notes
//        editUnitObject.isContact = contact
//        
//        editUnitObject.tenantId = selectedTenantId
//        
//        editUnitObject.surveyId = selectedSurveyId
//
//        
//        appDelegate.saveContext()
//
//    }
    
    
    
    func saveEditUnitInDatabase(currentAttempt:String,currentInTake:String,currentReknockNeeded:String,currentReason:String,currentNotes:String,currentIsContact:String,currentTenantId:String,currentSurveyId:String){
        
        
        let editUnitObject = EditUnit(context: context)
        
        editUnitObject.locationId = SalesforceConnection.locationId
        editUnitObject.assignmentId = SalesforceConnection.assignmentId
        editUnitObject.assignmentLocId = SalesforceConnection.assignmentLocationId
        editUnitObject.unitId = SalesforceConnection.unitId
        editUnitObject.assignmentLocUnitId = SalesforceConnection.assignmentLocationUnitId
        editUnitObject.actionStatus = "create"
        
        
        editUnitObject.attempt = currentAttempt
       
        editUnitObject.reKnockNeeded = currentReknockNeeded
        
        editUnitObject.inTake = currentInTake
        editUnitObject.reason = currentReason
        
        editUnitObject.unitNotes = currentNotes
        editUnitObject.isContact = currentIsContact
        
        
        editUnitObject.tenantId = currentTenantId
        
        editUnitObject.surveyId = currentSurveyId
        
        
        appDelegate.saveContext()

    }
    
    func saveTenantAssignInDatabase(){
        
        saveEditUnitInDatabase(currentAttempt: "", currentInTake: "", currentReknockNeeded: "", currentReason: "", currentNotes: "", currentIsContact: "", currentTenantId: selectedTenantId, currentSurveyId: "")
        
        
    }
    
    func saveEditUnitSurveyInDatabase(){
        
        saveEditUnitInDatabase(currentAttempt: "", currentInTake: "", currentReknockNeeded: "", currentReason: "", currentNotes: "", currentIsContact: "", currentTenantId: "", currentSurveyId: selectedSurveyId)
        
    }
    
    
    
    

    
    
    func updateEditUnitInDatabase(){
        
        var updateObjectDic:[String:String] = [:]
        
        //updateObjectDic["id"] = tenantDataDict["tenantId"] as! String?
        
       
        
        updateObjectDic["reason"] = reasonStatus
        updateObjectDic["inTake"] = inTake
        updateObjectDic["unitNotes"] = notes
        updateObjectDic["attempt"] = attempt
        updateObjectDic["isContact"] = contact
        updateObjectDic["reKnockNeeded"] = reknockNeeded
        updateObjectDic["actionStatus"] = "edit"
        
        
        
        ManageCoreData.updateRecord(salesforceEntityName: "EditUnit", updateKeyValue: updateObjectDic, predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId ==%@", predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId, predicateValue4: SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate: true)
        
        
        
    }
    
    
    
    
    
      
    func updateTenantAssignInDatabase(){
        var updateObjectDic:[String:String] = [:]
        
        //updateObjectDic["id"] = tenantDataDict["tenantId"] as! String?
        
        updateObjectDic["tenantId"] = selectedTenantId
        updateObjectDic["actionStatus"] = "edit"
       
        
        ManageCoreData.updateRecord(salesforceEntityName: "EditUnit", updateKeyValue: updateObjectDic, predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId ==%@", predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId, predicateValue4: SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate: true)
        
     
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return surveyDataArray.count
        //return 4
    }
    

    
    var widthToUse : CGFloat?
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        surveyCollectionView.reloadData()
        
        widthToUse = size.width - 40
        
        let collectionViewLayout = surveyCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.invalidateLayout()
        
        //self.optionsCollectionView?
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SurveyCollectionViewCell
        
        if(selectedSurveyId == surveyDataArray[indexPath.row].surveyId){
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredVertically)
            cell.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) //green
        }
        else{
            cell.isSelected = false
             cell.backgroundColor = UIColor.init(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1) //gray
            
        }
        cell.surveyName.text = surveyDataArray[indexPath.row].surveyName
        cell.surveyId.text = surveyDataArray[indexPath.row].surveyId
        
        return cell
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentCell = collectionView.cellForItem(at: indexPath) as! SurveyCollectionViewCell
        
        currentCell.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) // green
        
        
       selectedSurveyId = currentCell.surveyId.text!
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let currentCell = collectionView.cellForItem(at: indexPath) as! SurveyCollectionViewCell
        
        currentCell.backgroundColor = UIColor.init(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1) //gray
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        
        
        var collectionViewWidth = collectionView.bounds.width
        
        if let w = widthToUse
        {
            collectionViewWidth = w
        }
        
        let width = collectionViewWidth - collectionViewLayout!.sectionInset.left - collectionViewLayout!.sectionInset.right
        
        //let width = -170
        
        return CGSize(width: width, height:50)
        
    }


    
    func dismissVCCompletion(completionHandler: @escaping typeCompletionHandler) {
        self.completion = completionHandler
    }
 

}
