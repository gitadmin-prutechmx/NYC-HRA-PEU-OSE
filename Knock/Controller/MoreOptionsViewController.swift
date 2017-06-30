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
    
}


class MoreOptionsViewController: UIViewController,UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var attemptNo: DLRadioButton!
    @IBOutlet weak var attemptYes: DLRadioButton!
    
    @IBOutlet weak var contactNo: DLRadioButton!
    @IBOutlet weak var contactYes: DLRadioButton!
    
    
    @IBOutlet weak var reKnockYes: DLRadioButton!
    @IBOutlet weak var reKnockNo: DLRadioButton!
    
    
    var attempt:String = ""
    var contact:String = ""
    var reknockNeeded:String = ""
    
    var tenantStatus:String = ""
    var inTakeStatus:String = ""
    
     var notes:String = ""
    
    var selectedTenantId:String = ""
    
    
    @IBOutlet weak var saveOutlet: UIBarButtonItem!
    @IBOutlet weak var addTenantOutlet: UIButton!
   
    @IBOutlet weak var notesTextArea: UITextView!
    
    @IBOutlet weak var tblTeanantVw: UITableView!

    @IBOutlet weak var ChooseInTakeStatusBtn: UIButton!
    @IBOutlet weak var ChooseTenantStatusBtn: UIButton!
    
    
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
    
    

    let chooseTenantStatusDropDown = DropDown()
    let chooseInTakeStatusDropDown = DropDown()
    
    
    
    lazy var dropDowns: [DropDown] = {
        return [
            self.chooseTenantStatusDropDown,
            self.chooseInTakeStatusDropDown
        ]
    }()
    
    
      var editUnitDict : [String:String] = [:]
      var tenantAssignDict : [String:String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTenantOutlet.layer.cornerRadius = 5
        
         setUpDropDowns()
        
        NotificationCenter.default.addObserver(self, selector:#selector(MoreOptionsViewController.UpdateTenantView), name: NSNotification.Name(rawValue: "UpdateTenantView"), object:nil
        )
        
        NotificationCenter.default.addObserver(self, selector:#selector(MoreOptionsViewController.UpdateSurveyView), name: NSNotification.Name(rawValue: "UpdateSurveyView"), object:nil
        )
        
        fullAddressText.text = "59 Wooster St, New York, NY 10012"// SalesforceConnection.fullAddress
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.navigationItem.title = SalesforceConnection.unitName
        
        notesTextArea.layer.cornerRadius = 5
        notesTextArea.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        notesTextArea.layer.borderWidth = 0.5
        notesTextArea.clipsToBounds = true
        
        //NotesTextArea.text = "Description"
        notesTextArea.textColor = UIColor.black

       
        
        if(Utilities.currentSegmentedControl == "Unit"){
            segmentedControl.selectedSegmentIndex = 0
            
            chooseUnitInfoView.isHidden = false
            chooseSurveyView.isHidden = true
            chooseTenantInfoView.isHidden = true
            
            populateEditUnit()
            
            self.saveOutlet.title = "Save"
        }
        else if(Utilities.currentSegmentedControl == "Tenant"){
            segmentedControl.selectedSegmentIndex = 1
            
            chooseTenantInfoView.isHidden = false
            
            chooseUnitInfoView.isHidden = true
            chooseSurveyView.isHidden = true
            
            self.saveOutlet.title = "Assign Tenant"
            
            
            populateTenantData()
            
        }
        else if(Utilities.currentSegmentedControl == "Survey"){
            segmentedControl.selectedSegmentIndex = 2
            
            chooseUnitInfoView.isHidden = true
            chooseTenantInfoView.isHidden = true
            chooseSurveyView.isHidden = false
            
            self.saveOutlet.title = "Save"
            
             populateSurveyData()
            setSelectedSurveyId()
            
            
           
        }

        // Do any additional setup after loading the view.
    }
    
    
    func UpdateTenantView(){
        print("UpdateTenantView")
        populateTenantData()
    }
    
    func UpdateSurveyView(){
       print("UpdateSurveyView")
        populateSurveyData()
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
    
    func setUpDropDowns(){
        setUpTenantStatusDropDown()
        setUpInTakeStatusDropDown()

    }
    
    func setUpTenantStatusDropDown(){
        chooseTenantStatusDropDown.anchorView = ChooseTenantStatusBtn
        
        
        chooseTenantStatusDropDown.bottomOffset = CGPoint(x: 0, y: ChooseTenantStatusBtn.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        chooseTenantStatusDropDown.dataSource = [
            "Not Home",
            "Refused",
            "Vacant",
            "Do Not Attempt",
            "Canvass Again"
        ]
        
        // Action triggered on selection
        chooseTenantStatusDropDown.selectionAction = { [unowned self] (index, item) in
            
            self.tenantStatus = item
            self.ChooseTenantStatusBtn.setTitle(item, for: .normal)
        }

    }
    
    func setUpInTakeStatusDropDown(){
        chooseInTakeStatusDropDown.anchorView = ChooseInTakeStatusBtn
        
        
        chooseInTakeStatusDropDown.bottomOffset = CGPoint(x: 0, y: ChooseInTakeStatusBtn.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        chooseInTakeStatusDropDown.dataSource = [
            "No Issues",
            "Refused",
            "Not Primary Tenant",
            "Superintendent Door",
            "Landlords Door",
            "Privacy Concern",
            "Left Contact Info",
            "Laguage Barrier"
        ]
        
        // Action triggered on selection
        chooseInTakeStatusDropDown.selectionAction = { [unowned self] (index, item) in
            
            self.inTakeStatus = item
            self.ChooseInTakeStatusBtn.setTitle(item, for: .normal)
        }
        
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
        
        

        
        setSelectedTenant()
        
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
    
    func setSelectedTenant(){
        
        let tenantAssignResults = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId ==%@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId, predicateValue4: SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate:true) as! [EditUnit]
        
        
        if(tenantAssignResults.count > 0){
            
            selectedTenantId = tenantAssignResults[0].tenantId!
            
        }

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
    
    // MARK: UITenantTableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tenantDataArray.count
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
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
    
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath) as! TenantViewCell
//         cell.contentView.backgroundColor = UIColor.white
//    }
//    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Dequeue with the reuse identifier
        
        let identifier = "tenantHeader"
        var cell: TenantHeaderTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? TenantHeaderTableViewCell
        if cell == nil {
            tableView.register(UINib(nibName: "TenantHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? TenantHeaderTableViewCell
        }
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  44.0
    }

    
    @IBAction func selectAttempt(_ sender: DLRadioButton) {
         attempt = sender.selected()!.titleLabel!.text!
    }

    
    @IBAction func selectContact(_ sender: DLRadioButton) {
         contact = sender.selected()!.titleLabel!.text!
    }
    
    
    @IBAction func selectReknock(_ sender: DLRadioButton) {
         reknockNeeded = sender.selected()!.titleLabel!.text!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func selectTenantStatus(_ sender: Any) {
        chooseTenantStatusDropDown.show()
    }
    
    @IBAction func selectInTakeStatus(_ sender: Any) {
        chooseInTakeStatusDropDown.show()
    }
    
    @IBAction func changeSegmented(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
             chooseSurveyView.isHidden = true
             chooseTenantInfoView.isHidden = true
             chooseUnitInfoView.isHidden = false
             Utilities.currentSegmentedControl = "Unit"
             self.saveOutlet.title = "Save"
             populateEditUnit()
            
        case 1:
             chooseTenantInfoView.isHidden = false
             chooseSurveyView.isHidden = true
             chooseUnitInfoView.isHidden = true
             Utilities.currentSegmentedControl = "Tenant"
             self.saveOutlet.title = "Assign Tenant"
             populateTenantData()
        case 2:
             chooseSurveyView.isHidden = false
             chooseUnitInfoView.isHidden = true
             chooseTenantInfoView.isHidden = true
             Utilities.currentSegmentedControl = "Survey"
             self.saveOutlet.title = "Save"
             populateSurveyData()
             setSelectedSurveyId()
            
            
        default:
            chooseSurveyView.isHidden = false
            chooseUnitInfoView.isHidden = false
            chooseTenantInfoView.isHidden = false
            Utilities.currentSegmentedControl = "Default"
            self.saveOutlet.title = "Save"
        }
    }
    
    func populateEditUnit(){
        let editUnitResults = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId,predicateValue4:SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate:true) as! [EditUnit]
        
        if(editUnitResults.count > 0){
            if(editUnitResults[0].attempt == "Yes"){
                attemptYes.isSelected = true
            }
            else  if(editUnitResults[0].attempt == "No"){
                attemptNo.isSelected = true
            }
            
            attempt = editUnitResults[0].attempt!
            
            if(editUnitResults[0].isContact == "Yes"){
                contactYes.isSelected = true
            }
            else if(editUnitResults[0].isContact == "No"){
                contactNo.isSelected = true
            }
            
            contact = editUnitResults[0].isContact!
            
            if(editUnitResults[0].reKnockNeeded == "Yes"){
                reKnockYes.isSelected = true
            }
            else if(editUnitResults[0].reKnockNeeded == "No"){
            
                reKnockNo.isSelected = true
            }
            
            reknockNeeded = editUnitResults[0].reKnockNeeded!
            
            if(editUnitResults[0].tenantStatus! != ""){
                    tenantStatus = editUnitResults[0].tenantStatus!
                
                    self.ChooseTenantStatusBtn.setTitle(editUnitResults[0].tenantStatus , for: .normal)
            }
            if(editUnitResults[0].inTakeStatus! != ""){
                    inTakeStatus = editUnitResults[0].inTakeStatus!
                
                    self.ChooseInTakeStatusBtn.setTitle(editUnitResults[0].inTakeStatus , for: .normal)
            }
            
            notesTextArea.text = editUnitResults[0].unitNotes
            
            
        }
    }

    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        
          if(Utilities.currentSegmentedControl == "Survey"){
        
                updateUnitAndSurvey(type:"Updating Survey..")
        
            
          }
         else if(Utilities.currentSegmentedControl == "Tenant"){
            
            if(selectedTenantId == ""){
                
                self.view.makeToast("Please select tenant", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    if didTap {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
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
            
            self.view.makeToast("Tenant has been assigned successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                self.dismiss(animated: true, completion: nil)
                
            }
            
//            if(Network.reachability?.isReachable)!{
//                
//                pushAssignTenantDataToSalesforce()
//            }
//                
//            else{
//                self.view.makeToast("Tenant has been assigned successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
//                    
//                    self.dismiss(animated: true, completion: nil)
//                    
//                }
//            }
            

            
        }
        
          else  if(Utilities.currentSegmentedControl == "Unit"){
        
            updateUnitAndSurvey(type:"Updating Unit..")
        }
         
        
                
           
        
    }
    
   
    
    func pushAssignTenantDataToSalesforce(){
        var updateTenantAssign : [String:String] = [:]
        
        updateTenantAssign["tenantAssignmentDetail"] = Utilities.encryptedParams(dictParameters: tenantAssignDict as AnyObject)
        

        
       SVProgressHUD.show(withStatus: "Assigning tenant...", maskType: SVProgressHUDMaskType.gradient)
        
        SalesforceConnection.loginToSalesforce(companyName: SalesforceConnection.companyName) { response in
            
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
            
//            editUnitDict = Utilities.editUnitAndSurveyDicData(tenantStatus: tenantStatus, notes: notes, attempt: attempt, contact: contact, reKnockNeeded: reknockNeeded, inTakeStatus: inTakeStatus, assignmentLocationUnitId: SalesforceConnection.assignmentLocationUnitId,type:type)
            
            let editUnitResults = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId,predicateValue4:SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate:true) as! [EditUnit]
            
            if(editUnitResults.count > 0){
                
                updateEditUnitInDatabase()
            }
            else{
                saveEditUnitInDatabase(currentAttempt: attempt, currentInTakeStatus: inTakeStatus, currentReknockNeeded: reknockNeeded, currentTenantStatus: tenantStatus, currentNotes: notes, currentIsContact: contact, currentTenantId: "", currentSurveyId: "")
                
            }
        }
            
        else{
            
//            editUnitDict = Utilities.editUnitAndSurveyDicData(selectedSurveyId:selectedSurveyId,type:type)
            
            let editSurveyUnitResults = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "assignmentId == %@ AND locationId == %@ AND assignmentLocId == %@ AND unitId == %@ AND assignmentLocUnitId == %@" ,predicateValue: SalesforceConnection.assignmentId,predicateValue2: SalesforceConnection.locationId, predicateValue3: SalesforceConnection.assignmentLocationId,predicateValue4:SalesforceConnection.unitId,predicateValue5: SalesforceConnection.assignmentLocationUnitId,isPredicate:true) as! [EditUnit]
            
            if(editSurveyUnitResults.count > 0){
                
                updateEditUnitSurveyInDatabase()
            }
            else{
                saveEditUnitSurveyInDatabase()
                
            }
        }
      
        
        self.view.makeToast("Unit information has been updated successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
            
           // Utilities.isSubmitSurvey = false
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
            
            self.dismiss(animated: true, completion: nil)
            
        }

        
       
        
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
        
        SalesforceConnection.loginToSalesforce(companyName: SalesforceConnection.companyName) { response in
            
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
    
    
    
    func saveEditUnitInDatabase(currentAttempt:String,currentInTakeStatus:String,currentReknockNeeded:String,currentTenantStatus:String,currentNotes:String,currentIsContact:String,currentTenantId:String,currentSurveyId:String){
        
        
        let editUnitObject = EditUnit(context: context)
        
        editUnitObject.locationId = SalesforceConnection.locationId
        editUnitObject.assignmentId = SalesforceConnection.assignmentId
        editUnitObject.assignmentLocId = SalesforceConnection.assignmentLocationId
        editUnitObject.unitId = SalesforceConnection.unitId
        editUnitObject.assignmentLocUnitId = SalesforceConnection.assignmentLocationUnitId
        editUnitObject.actionStatus = "create"
        
        
        editUnitObject.attempt = currentAttempt
        editUnitObject.inTakeStatus = currentInTakeStatus
        editUnitObject.reKnockNeeded = currentReknockNeeded
        editUnitObject.tenantStatus = currentTenantStatus
        editUnitObject.unitNotes = currentNotes
        editUnitObject.isContact = currentIsContact
        
        
        editUnitObject.tenantId = currentTenantId
        
        editUnitObject.surveyId = currentSurveyId
        
        
        appDelegate.saveContext()

    }
    
    func saveTenantAssignInDatabase(){
        
        saveEditUnitInDatabase(currentAttempt: "", currentInTakeStatus: "", currentReknockNeeded: "", currentTenantStatus: "", currentNotes: "", currentIsContact: "", currentTenantId: selectedTenantId, currentSurveyId: "")
        
        
    }
    
    func saveEditUnitSurveyInDatabase(){
        
        saveEditUnitInDatabase(currentAttempt: "", currentInTakeStatus: "", currentReknockNeeded: "", currentTenantStatus: "", currentNotes: "", currentIsContact: "", currentTenantId: "", currentSurveyId: selectedSurveyId)
        
    }
    
    
    
    

    
    
    func updateEditUnitInDatabase(){
        
        var updateObjectDic:[String:String] = [:]
        
        //updateObjectDic["id"] = tenantDataDict["tenantId"] as! String?
        
        
        updateObjectDic["tenantStatus"] = tenantStatus
        updateObjectDic["inTakeStatus"] = inTakeStatus
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


 

}
