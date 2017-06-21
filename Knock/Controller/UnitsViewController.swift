//
//  UnitsViewController.swift
//  MTXGIS
//
//  Created by Kamal on 23/02/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit
import Toast_Swift

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
        
       /* let floorFilterViewTapGesture = UITapGestureRecognizer(target: self, action: Selector(("FloorFilterViewTapped:")))
        
        // add it to the image view;
        floorFilterView.addGestureRecognizer(floorFilterViewTapGesture)
        // make sure imageView can be interacted with by user
        floorFilterView.isUserInteractionEnabled = true
        
        */
        
        
    
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
        
        self.tableView.tableFooterView = UIView()
        
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        
        dataFullAddress.text = SalesforceConnection.fullAddress
        //SalesforceRestApi.currentFullAddress = locName
      
        
       
        self.myPicker  = UIPickerView(frame: CGRect(x: 0, y: 200, width: view.frame.width, height: 300))
        //self.myPicker.backgroundColor = .whiteColor()
        self.myPicker.showsSelectionIndicator = true
        self.myPicker.delegate = self
        self.myPicker.dataSource = self
        
       /* let openFloorPickerTapGesture = UITapGestureRecognizer(target: self, action: Selector(("OpenFloorPickerTapped:")))
        
        // add it to the image view;
        floorSelectImage.addGestureRecognizer(openFloorPickerTapGesture)
        // make sure imageView can be interacted with by user
        floorSelectImage.isUserInteractionEnabled = true
 
 */
        
    }
    
    @IBAction func moreAction(_ sender: Any) {
        
    /*    let buttonPosition = (sender as AnyObject).convert(CGPoint(), to: tableView)
        let index = tableView.indexPathForRow(at: buttonPosition)
    */
         let indexRow = (sender as AnyObject).tag
        
         SalesforceConnection.unitId =  UnitDataArray[indexRow!].unitId
        
         showActionSheet()
       
        
    }
    
   
    @IBAction func backBtn(sender: AnyObject) {
        
        
        self.performSegue(withIdentifier: "GoBackToMapIdentifier", sender: nil)
        
        // _ = self.navigationController?.popViewControllerAnimated(true)
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
        
       UnitDataArray = [UnitsDataStruct]()
       OriginalUnitDataArray = [UnitsDataStruct]()
       floorArray = []
        
        
        let unitResults = ManageCoreData.fetchData(salesforceEntityName: "Unit",predicateFormat: "locationId == %@ AND assignmentId == %@" ,predicateValue: SalesforceConnection.locationId,predicateValue2:SalesforceConnection.assignmentId,isPredicate:true) as! [Unit]
 
        
        if(unitResults.count > 0){
            
            for unitData in unitResults{
                
                if(unitData.floor! != ""){
                    floorArray.append(unitData.floor!)
                }
                
                let objectUnitStruct:UnitsDataStruct = UnitsDataStruct(unitId: unitData.id!, unitName: unitData.name!, floor: unitData.floor!, surveyStatus: "", syncDate: "")
                
                UnitDataArray.append(objectUnitStruct)
                
            }
        }
        
        OriginalUnitDataArray = UnitDataArray
        
        
        floorFilteredArray = removeDuplicates(array: floorArray)
        floorFilteredArray.insert("All", at: 0)
        

       // self.floorTextField.text = "All"
       // self.tableView.reloadData()
        
         DispatchQueue.main.async {
            self.floorTextField.text = "All"
            self.tableView.reloadData()
            self.viewDidLayoutSubviews()
        }
        
        
       /*
         DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            
            DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
            }
        }
        
        */
 
        
    
        
        
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
        
        //self.heightConstraint.constant = tableView.contentSize.height
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
        
        
        cell.moreBtn.tag = indexPath.row
       
        
        
        if(SalesforceConnection.unitId != "" && UnitDataArray[indexPath.row].unitId == SalesforceConnection.unitId && Utilities.isSubmitSurvey == true){
            
            let date = Date()
            let formatter = DateFormatter()
            
            formatter.dateFormat = "MM/dd/yyyy"
            
          
            cell.dataSyncDate.text =   formatter.string(from: date)
            
            cell.dataSyncStatus.text = "Completed"
            
            
          /*  if(Reachability.isConnectedToNetwork()){
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
 */
            
        }
            
        else{
            
            
            
            cell.dataSyncDate.text = UnitDataArray[indexPath.row].syncDate
            
            cell.dataSyncStatus.text = UnitDataArray[indexPath.row].surveyStatus
            
            cell.pendingIcon.isHidden = true
            cell.dataSyncDate.isHidden = false
            
        }
        
        
        
        
        
        
        cell.dataUnitId.text = UnitDataArray[indexPath.row].unitId
        
        cell.dataFloor.text = UnitDataArray[indexPath.row].floor
        
        
        
        
        
        return cell
        
        
    }
    
    
    func getSurveyUnitResults()->[SurveyUnit]{
        
      // request.predicate = NSPredicate(format: "username = %@ AND password = %@", txtUserName.text!, txtPassword.text!)
        
         let surveyUnitResults = ManageCoreData.fetchData(salesforceEntityName: "SurveyUnit",predicateFormat: "unitId == %@ AND assignmentId = %@" ,predicateValue: SalesforceConnection.unitId,predicateValue2:SalesforceConnection.assignmentId,isPredicate:true) as! [SurveyUnit]
        
         return surveyUnitResults
        
    }
    
    
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        SalesforceConnection.unitId =  UnitDataArray[indexPath.row].unitId
        
        SalesforceConnection.unitName =  UnitDataArray[indexPath.row].unitName
        
        
    if("Completed" != UnitDataArray[indexPath.row].surveyStatus){
        
        let surveyUnitResults = getSurveyUnitResults()
        
        //update or delete particular surveyunit
        //add multiple conditions in predicateformat
        
        if(surveyUnitResults.count == 0){
        
            self.view.makeToast("Please choose survey from More button", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                if didTap {
                    print("completion from tap")
                } else {
                    print("completion without tap")
                }
            }
            
        }
        else{
            
            
            
                SalesforceConnection.surveyId = surveyUnitResults[0].surveyId!
            
                let surveyQuestionResults = ManageCoreData.fetchData(salesforceEntityName: "SurveyQuestion",predicateFormat: "surveyId == %@ AND assignmentId = %@" ,predicateValue: SalesforceConnection.surveyId,predicateValue2:SalesforceConnection.assignmentId,isPredicate:true) as! [SurveyQuestion]
                
                if(surveyQuestionResults.count == 1){
                    
                    
                    
                    let jsonData =  Utilities.convertToJSON(text: surveyQuestionResults[0].surveyQuestionData!) as!Dictionary<String, AnyObject>

                    
                    readSurveyJSONObject(object: jsonData)
                    
                    Utilities.totalSurveyQuestions =  Utilities.surveyQuestionArray.count
                    
                    //Utilities.currentUnitId = ""
                    //SalesforceRestApi.currentUnitName = ""
                    
                    if(Utilities.totalSurveyQuestions > 0){
                        
                        showSurveyQuestions()
                        print("ShowSurveyQuestions")
                    }
                    
                }
            
            
        }
    }
        
    else{
        
        let currentCell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as! UnitsCustomViewCell
        
        currentCell.shake(duration: 0.3, pathLength: 15)
     
        
        self.view.makeToast("Survey has been completed already.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
            if didTap {
                print("completion from tap")
            } else {
                print("completion without tap")
            }
        }
        
        }


    }
    
    
    
    var skipLogicArray : [[String:SkipLogic]] = []
    var skipLogicDict = [String: SkipLogic]()
    var skipLogicParentChildArray = [SkipLogicParentChild]()
    
    func addSurveyObject(_ questionId:String,questionType:String,questionText:String,questionNumber:String,required:Bool,choices:String,isSkipLogic:String,answer:String,questionChoiceList:[[String: AnyObject]]){
        
        skipLogicArray = []
        
        skipLogicDict = [:]
        
        
        
        var options = ""
        
        
        
        
        
        for questionChoice in questionChoiceList{
            
            let skipLogicType = questionChoice["skipLogicType"] as? String ?? ""
            let choice = questionChoice["choice"] as? String ?? ""
            let isSkipLogicPresent = questionChoice["isSkipLogicPresent"] as? Bool
            let childQuestionNumber = questionChoice["questionNumber"] as? String ?? ""
            
            let showTextValue = questionChoice["showText"] as? String ?? ""
            
            
            options = options + choice + ";"
            
            if(isSkipLogicPresent == true){
                
                let objectSkipLogic:SkipLogic = SkipLogic(skipLogicType: skipLogicType, questionNumber: childQuestionNumber,selectedAnswer: choice,showTextValue:showTextValue)
                
                skipLogicDict[choice] = objectSkipLogic
                
                skipLogicArray.append(skipLogicDict)
                
                if(skipLogicType == "Skip to Question"){
                    skipLogicParentChildArray.append(SkipLogicParentChild(childQuesionNumber: childQuestionNumber, parentQuestionNumber: questionNumber, selectedAnswer: choice, skipLogicType: skipLogicType,showTextValue:showTextValue))
                }
                
                
            }
            
            
            
        }
        
        
        //options = options.substring(to: options.characters.index(before: options.endIndex))
        
        options = String(options.characters.dropLast())
        
        
        let  objSurveyQues = SurveyQuestionDO(questionId: questionId, questionText: questionText,questionType:questionType,questionNumber:questionNumber,isRequired: required,choices: options , skipLogicArray:skipLogicArray , isSkipLogic: isSkipLogic,getDescriptionAnswer: answer)
        
        
        let objectStruct:structSurveyQuestion = structSurveyQuestion(key: questionId, objectSurveyQuestion: objSurveyQues)
        
        
        Utilities.surveyQuestionArray.append(objectStruct)
        
        
        
    }
    
    
    func readSurveyJSONObject(object:Dictionary<String, AnyObject>) {
        
        Utilities.surveyQuestionArray = []
        
        skipLogicParentChildArray = []
        
        
        Utilities.skipLogicParentChildDict = [:]
        
        Utilities.prevSkipLogicParentChildDict = [:]
       

        
        
        
        guard let surveyName = object["surveyName"] as? String
            , let results = object["Question"] as? [[String: AnyObject]] else { return }
        
        
        
        for data in results {
            
            print("data: \(data)")
            
            guard let questionType = data["questionType"] as? String else {break}
            
            guard let required = data["required"] as? Bool else { break }
            
            guard let questionText = data["questionText"] as? String else { break }
            guard let questionId = data["questionId"] as? String else { break }
            guard let questionNumber = data["questionNumber"] as? String else{break}
            //guard let choices = data["choices"] as? String else {break}
            
            
            //skip logic
            guard let skipLogic = data["skipLogic"] as? String else {break}
            // guard let answer = data["answer"] as? String? else {break}  //for getdescription text
            guard let questionChoiceList = data["questionChoiceList"] as? [[String: AnyObject]]  else {break}
            
            
            
            // let updatedAnswer = answer ?? ""
            
            
            
            addSurveyObject(questionId, questionType: questionType, questionText: questionText, questionNumber: questionNumber, required: required, choices: "", isSkipLogic: skipLogic, answer: "", questionChoiceList: questionChoiceList)
            
        }
        
        
        
        var tempArray = [SkipLogic]()
        
        
        for skipLogicparentChild in skipLogicParentChildArray{
            
            tempArray = []
            
            if Utilities.skipLogicParentChildDict[skipLogicparentChild.parentQuestionNumber] != nil {
                
                var arrayValue:[SkipLogic] =  Utilities.skipLogicParentChildDict[skipLogicparentChild.parentQuestionNumber]!
                
                arrayValue.append(SkipLogic(skipLogicType: skipLogicparentChild.skipLogicType, questionNumber: skipLogicparentChild.childQuesionNumber, selectedAnswer: skipLogicparentChild.selectedAnswer,showTextValue:skipLogicparentChild.showTextValue))
                
                Utilities.skipLogicParentChildDict[skipLogicparentChild.parentQuestionNumber] = arrayValue
                
            }
                
            else{
                
                tempArray.append(SkipLogic(skipLogicType: skipLogicparentChild.skipLogicType, questionNumber: skipLogicparentChild.childQuesionNumber, selectedAnswer: skipLogicparentChild.selectedAnswer,showTextValue:skipLogicparentChild.showTextValue))
                
                Utilities.skipLogicParentChildDict[skipLogicparentChild.parentQuestionNumber] = tempArray
                
            }
            
        }
        
        
        //For Previous button
        var prevTempArray = [SkipLogic]()
        
        
        for skipLogicparentChild in skipLogicParentChildArray{
            
            prevTempArray = []
            
            if Utilities.prevSkipLogicParentChildDict[skipLogicparentChild.childQuesionNumber] != nil {
                
                var arrayValue:[SkipLogic] =  Utilities.prevSkipLogicParentChildDict[skipLogicparentChild.childQuesionNumber]!
                
                arrayValue.append(SkipLogic(skipLogicType: skipLogicparentChild.skipLogicType, questionNumber: skipLogicparentChild.parentQuestionNumber, selectedAnswer: skipLogicparentChild.selectedAnswer,showTextValue:skipLogicparentChild.showTextValue))
                
                Utilities.prevSkipLogicParentChildDict[skipLogicparentChild.childQuesionNumber] = arrayValue
                
            }
                
            else{
                
                prevTempArray.append(SkipLogic(skipLogicType: skipLogicparentChild.skipLogicType, questionNumber: skipLogicparentChild.parentQuestionNumber, selectedAnswer: skipLogicparentChild.selectedAnswer,showTextValue:skipLogicparentChild.showTextValue))
                
                Utilities.prevSkipLogicParentChildDict[skipLogicparentChild.childQuesionNumber] = prevTempArray
                
            }
            
        }

        
        
        
        
        print(Utilities.surveyQuestionArray)
        
        
    }
    
    
    

    
    
    func showSurveyQuestions(){
        
        
        Utilities.SurveyOutput = [:]
        Utilities.answerSurvey = ""
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        Utilities.surveyQuestionArrayIndex = 0
        
        
        //SalesforceRestApi.surveyQuestionArrayIndex = SalesforceRestApi.surveyQuestionArrayIndex + 1
        
        Utilities.currentSurveyPage = Utilities.surveyQuestionArrayIndex + 1
        
        let objSurveyQues =  Utilities.surveyQuestionArray[Utilities.surveyQuestionArrayIndex].objectSurveyQuestion
        
        if(objSurveyQues?.questionType == "Single Select"){
            
            let surveyRadioButtonVC = storyboard.instantiateViewController(withIdentifier: "surveyRadioButtonVCIdentifier") as! SurveyRadioOptionViewController
            
            self.navigationController?.pushViewController(surveyRadioButtonVC, animated: true)
            
            /*
             let surveyRadioButtonVC = storyboard.instantiateViewControllerWithIdentifier("surveyRadioButtonVCIdentifier") as! SurveyRadioButtonViewController
             
             self.navigationController?.pushViewController(surveyRadioButtonVC, animated: true)
             
             */
        }
        else if(objSurveyQues?.questionType == "Multi Select"){
            
            let surveyMultiButtonVC = storyboard.instantiateViewController(withIdentifier: "surveyMultiOptionVCIdentifier") as! SurveyMultiOptionViewController
            
            self.navigationController?.pushViewController(surveyMultiButtonVC, animated: true)
            
            
        }
        else if(objSurveyQues?.questionType == "Text Area"){
            
            let surveyTextFieldVC = storyboard.instantiateViewController(withIdentifier: "surveyTextFiedVCIdentifier") as! SurveyTextViewController
            
            self.navigationController?.pushViewController(surveyTextFieldVC, animated: true)
            
            
            /*  let surveyTextFieldVC = storyboard.instantiateViewControllerWithIdentifier("surveyTextFiedVCIdentifier") as! SurveyTextFieldViewController
             
             self.navigationController?.pushViewController(surveyTextFieldVC, animated: true)
             
             */
        }
        
        
    }
    
    
    
    
    //canEditRowAt
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print("editingStyle")
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let more = UITableViewRowAction(style: .normal, title: "More") { action, index in
            
        
            //self.isEditing = false
            self.showActionSheet()
        }
        
      
        
        more.backgroundColor = UIColor(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1.0) // UIColor.blue
      
        
        return [more]
    }
    
    
    func showActionSheet(){
        
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .alert)
        
        // 2
        let unitAction = UIAlertAction(title: "Unit Information", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Unit Information")
            
            Utilities.currentSegmentedControl = "Unit"
            self.performSegue(withIdentifier: "moreOptionsModalIdentifier", sender: nil)
            
        })
        let tenantAction = UIAlertAction(title: "Tenant Information", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Tenant Information")
            
             Utilities.currentSegmentedControl = "Tenant"
             self.performSegue(withIdentifier: "moreOptionsModalIdentifier", sender: nil)
        })
        
        //
        let surveyAction = UIAlertAction(title: "Choose a Survey", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Choose a Survey")
            
            Utilities.currentSegmentedControl = "Survey"
            self.performSegue(withIdentifier: "moreOptionsModalIdentifier", sender: nil)
            
            /*
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let moreOptionsVC = storyboard.instantiateViewController(withIdentifier: "moreOptionsIdentifier") as! MoreOptionsViewController
            
            self.navigationController?.modalPresentationStyle = UIModalPresentationStyle.formSheet
            
            
            //self.present(moreOptionsVC, animated: true, completion: nil)
            
        
            
             self.navigationController?.pushViewController(moreOptionsVC, animated: true)
 */
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancel")
        })
        
        
        
        // 4
        optionMenu.addAction(unitAction)
        optionMenu.addAction(tenantAction)
        optionMenu.addAction(surveyAction)
        optionMenu.addAction(cancelAction)
        
        // optionMenu.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        
        //optionMenu.popoverPresentationController?.sourceView = self.view
        //optionMenu.popoverPresentationController?.sourceRect = self.view.bounds
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    
    /*
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Dequeue with the reuse identifier
        
        let identifier = "unitCellId"
        var cell: UnitsHeaderTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? UnitsHeaderTableViewCell
        if cell == nil {
            tableView.register(UINib(nibName: "UnitsHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? UnitsHeaderTableViewCell
        }
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  67.0
    }
    
    */
    
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
    
    @IBAction func UnwindBackFromSurvey(segue:UIStoryboardSegue) {
        
        print("UnwindBackFromSurvey")
        
    }
    
}


