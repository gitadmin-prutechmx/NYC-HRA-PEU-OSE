//
//  SurveyRadioOptionViewController.swift
//  EngageNYC
//
//  Created by MTX on 1/17/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class SurveyRadioOptionViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
{
    
    @IBOutlet weak var getDescriptionTextField: UITextField!
    @IBOutlet weak var showTextLbl: UITextView!
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet  var optionsCollectionView: UICollectionView!
    @IBOutlet weak var questionsView: UIView!
    @IBOutlet weak var radioOptionsView: UIView!
     @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSurveySelect: UIButton!
    
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblUnit: UILabel!
    @IBOutlet weak var lblSelectSurvey: UILabel!
    
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    
    var widthToUse : CGFloat?
    
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    var surveyObj:SurveyDO!
    var viewModel:SurveyViewModel!
    
     var surveyQuestionObj:SurveyQuestionDO!
     var optionsIdArray = [String]()
     var optionsTextArray = [String]()
     var optionsDic : [String:String] = [:]
     var radiobuttonCurrentValue:String = ""

    var isNextButtonPressed:Bool = false
    var isPrevButtonPressed:Bool = false
    var isSkipLogic:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpView()
    }
    func setUpView()
    {
        optionsCollectionView.allowsMultipleSelection = false
        getDescriptionTextField.layer.borderColor = UIColor.gray.cgColor
        
        getDescriptionTextField.layer.borderWidth = 1.0
        
        getDescriptionTextField.layer.cornerRadius = 10.0
        
        
        if(surveyObj != nil){
            
            surveyQuestionObj = surveyObj.surveyQuestionArray[surveyObj.surveyQuestionArrayIndex].objectSurveyQuestion
            
            questionText.text = surveyQuestionObj.questionText
            
            if let answerObj = surveyObj.surveyOutput[surveyQuestionObj.questionNumber] {
                getDescriptionTextField.text = answerObj.getDescription
            }
            
            
            // let options = objSurveyQues.choices!.replace("\r\n", withString:";")
            let options = surveyQuestionObj.choices!
            
            print(options)
            
            
            optionsTextArray = options.components(separatedBy: ";")
            
            
            lblSelectSurvey.text = surveyObj.surveyName
            lblUnit.text = canvasserTaskDataObject.locationUnitObj.locationUnitName
            lblLocation.text = canvasserTaskDataObject.locationObj.objMapLocation.locName
            
            btnLogin.setTitle(canvasserTaskDataObject.userObj.userName, for: .normal)
            
            if(surveyObj.surveyQuestionArrayIndex == 0){
                
                btnPrevious.isHidden = true
                
            }
                
            else{
                btnPrevious.isHidden = false
                
            }
            
            Utility.surveyPageControl(pageControl: pageControl, surveyObj: surveyObj)

        }
        
    }
    
   
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if(isNextButtonPressed == true)
        {
            isNextButtonPressed = false
        }
    }
 
    
    func populateSurveyOutput(){

        var getDescription:String = ""

        if(getDescriptionTextField.isHidden == false){
            getDescription = getDescriptionTextField.text ?? "";
        }

        else if (showTextLbl.isHidden == false){
            getDescription = showTextLbl.text ?? "";
        }
        else{
            getDescription = ""
        }

        let objSurveyRes:SurveyResult =  SurveyResult(questionId:surveyQuestionObj.questionId, questionType: surveyQuestionObj.questionType, getDescription: getDescription, selectedAnswer: radiobuttonCurrentValue,multiOption: [])

        surveyObj.surveyOutput[surveyQuestionObj.questionNumber] = objSurveyRes

    }


    
    @IBAction func btnLoginUserNamePressed(_ sender: Any) {
        Utility.openNavigationItem(btnLoginUserName: self.btnLogin, vc: self)
    }
    
    @IBAction func btnBackAction(_ sender: Any)
    {
        Utility.exitFromSurvey(vctrl: self, surveyVM: viewModel, surveyObj: surveyObj)
        
    }
    
    @IBAction func btnNextPress(_ sender: Any)
    {
        getDescriptionTextField.resignFirstResponder()
        showNextQuestion()
        
    }
    @IBAction func btnPrevPress(_ sender: Any)
    {
        getDescriptionTextField.resignFirstResponder()
        showPreviousQuestion()
    }
    
    
    @IBAction func btnSurveySelectPressed(_ sender: Any) {
        Utility.showAllSurveyOnAssignment(btnSelectedSurveyName: btnSurveySelect, vc: self, surveyId: surveyObj.surveyId, assignmentId: canvasserTaskDataObject.assignmentObj.assignmentId, viewModel: viewModel)
    }
    
    @IBAction func btnInTakePressed(_ sender: Any) {
        Utility.showInTake(vc: self,canvasserTaskDataObject: canvasserTaskDataObject)
    }
    
    
}

extension SurveyRadioOptionViewController:ListingPopoverDelegate{
    func selectedItem(withObj obj: ListingPopOverDO, selectedIndex index: Int, popOverType type: PopoverType) {
        if(type == .surveyList){
            
             Utility.switchToNewSurvey(surveyObj: surveyObj, vctrl: self, listingPopOverObj: obj, btnSurveySelect: btnSurveySelect, viewModel: viewModel, canvasserTaskDataObject: canvasserTaskDataObject)
        }
        else{
             Utility.selectedNavigationItem(obj: obj, vc: self,isFromSurveyScreen: true,canvasserTaskDataObject:canvasserTaskDataObject)
        }
    }
    
}

extension SurveyRadioOptionViewController {
    
    func showNextQuestion(){
        
        isSkipLogic = false
        
        isNextButtonPressed = true
        
        if(surveyQuestionObj.isRequired == false && radiobuttonCurrentValue.isEmpty){
            radiobuttonCurrentValue = ""
            
        }
        else if(surveyQuestionObj.isRequired == true && radiobuttonCurrentValue.isEmpty){
            
            self.questionsView.shake()
            
            return
        }
        
        
        populateSurveyOutput()
        print(surveyQuestionObj.questionNumber)
        
     
        //Move to End of Survey
        if(surveyQuestionObj.isSkipLogic == "true")
        {
            let skipLogicArr:[[String:SkipLogic]] =  surveyQuestionObj.skipLogicArray
            
            for objectSkipLogic in skipLogicArr{
                if(objectSkipLogic[radiobuttonCurrentValue] != nil){
                    
                    let tempObject:SkipLogic = objectSkipLogic[radiobuttonCurrentValue]!
                    
                    if(tempObject.skipLogicType == "End of Survey"){
                        
                            //Here we have to delete key value
                            
                            let startingIndex  = surveyObj.surveyQuestionArrayIndex + 1
                            
                            let count = surveyObj.totalSurveyQuestions - 1
                            
                            surveyObj = Utility.deleteSkipSurveyData(startingIndex: startingIndex, count: count,objSurvey: surveyObj)
                            
                            
                            
                            Utility.showSubmitSurveyVC(vc: self, surveyObj: surveyObj, canvasserTaskDataObject: canvasserTaskDataObject, surveyVM: viewModel)
                            
                            
                            return
                            
                        
                        
                    }
                }
            }
        }
        
        
        
        if(surveyObj.surveyQuestionArrayIndex == surveyObj.totalSurveyQuestions - 1){
            
                 Utility.showSubmitSurveyVC(vc: self, surveyObj: surveyObj, canvasserTaskDataObject: canvasserTaskDataObject, surveyVM: viewModel)
            
                return
            
            
        }
            
        else{
            
            let currentIndex = surveyObj.surveyQuestionArrayIndex
            
            //handle SkipLogic
            var objSurveyQues =  surveyObj.surveyQuestionArray[currentIndex!].objectSurveyQuestion
            
            if(surveyObj.skipLogicParentChildDict[(objSurveyQues?.questionNumber)!] != nil){
                
                let arrayValue:[SkipLogic]  = surveyObj.skipLogicParentChildDict[objSurveyQues!.questionNumber]!
                
                for object in arrayValue{
                    
                    if(surveyObj.surveyOutput[objSurveyQues!.questionNumber] != nil){
                        let objectSurveyResult:SurveyResult =  surveyObj.surveyOutput[objSurveyQues!.questionNumber]!
                        
                        
                        if(objectSurveyResult.selectedAnswer == object.selectedAnswer){
                            
                            //skip question
                            
                            if(currentIndex == surveyObj.totalSurveyQuestions - 1){
                                
                                
                                     Utility.showSubmitSurveyVC(vc: self, surveyObj: surveyObj, canvasserTaskDataObject: canvasserTaskDataObject, surveyVM: viewModel)
                                
                                    return
                                
                            }
                                
                            else{
                               
                                
                                
                                let numberofQuestionsSkip = (Int(object.questionNumber)! - Int(objSurveyQues!.questionNumber)!)-1 //childquestionnumber - parentquestionumber
                                
                                
                                let count  = currentIndex! + numberofQuestionsSkip
                                
                                
                                let startingIndex = currentIndex! + 1
                                
                                if(startingIndex < count){
                                    
                                     surveyObj = Utility.deleteSkipSurveyData(startingIndex: startingIndex, count: count,objSurvey: surveyObj)
                                    
                                }
                                
                                
                                
                                
                                
                                surveyObj.surveyQuestionArrayIndex = Int(object.questionNumber)! - 1
                                
                                surveyObj.currentSurveyPage = Int(object.questionNumber)! - 1
                                
                                objSurveyQues =  surveyObj.surveyQuestionArray[surveyObj.surveyQuestionArrayIndex].objectSurveyQuestion
                                
                                isSkipLogic = true
                                
                                break;
                                
                            }
                            
                        }
                    }
                    
                }
                
            }//end of if skiplogic
            
            
            
            if(isSkipLogic == false){
                
                surveyObj.surveyQuestionArrayIndex = surveyObj.surveyQuestionArrayIndex + 1
                
                surveyObj.currentSurveyPage = surveyObj.surveyQuestionArrayIndex + 1
                
                objSurveyQues =  surveyObj.surveyQuestionArray[surveyObj.surveyQuestionArrayIndex].objectSurveyQuestion
                
            }
            
            
            if(objSurveyQues?.questionType == "Single Select"){
                
                
                Utility.showSurveyRadioOptionVC(vc: self, surveyObj: surveyObj, canvasserTaskDataObject: canvasserTaskDataObject, surveyVM: viewModel, subType: kCATransitionFromRight)
      
                
            }
                
            else if(objSurveyQues?.questionType == "Multi Select"){
                
                Utility.showSurveyMultiOptionVC(vc: self, surveyObj: surveyObj, canvasserTaskDataObject: canvasserTaskDataObject, surveyVM: viewModel, subType: kCATransitionFromRight)
 
                
            }
                
            else if(objSurveyQues?.questionType == "Text Area"){
               
                
                Utility.showSurveyTextVC(vc: self, surveyObj: surveyObj, canvasserTaskDataObject: canvasserTaskDataObject, surveyVM: viewModel, subType: kCATransitionFromRight)
   
            }
            
            
        }
        
    }
    
    func showPreviousQuestion(){
        
        isPrevButtonPressed = false

        
         if let objSurveyQues =  surveyObj.surveyQuestionArray[surveyObj.surveyQuestionArrayIndex].objectSurveyQuestion{
            
             if(surveyObj.prevSkipLogicParentChildDict[(objSurveyQues.questionNumber)!] != nil){
                
                let arrayValue:[SkipLogic]  = surveyObj.prevSkipLogicParentChildDict[(objSurveyQues.questionNumber)!]! //parent object result
                
                for object in arrayValue{
                    
                    if(surveyObj.surveyOutput[object.questionNumber] != nil){
                        let objectSurveyResult:SurveyResult =  surveyObj.surveyOutput[object.questionNumber]! //child object result
                        
                        if(objectSurveyResult.questionType == "Multi Select"){
                            if(objectSurveyResult.multiOption.contains(object.selectedAnswer)){
                                //skip question
                                
                                surveyObj.surveyQuestionArrayIndex = Int(object.questionNumber)! - 1
                                
                                isPrevButtonPressed = true
                               
                                break;
                                
                            }
                        }
                            
                            
                        else if(objectSurveyResult.selectedAnswer == object.selectedAnswer){
                            
                            //skip question
                            
                            surveyObj.surveyQuestionArrayIndex = Int(object.questionNumber)! - 1
                            
                            isPrevButtonPressed = true
                            
                            break;
                            
                        }
                    }
                    
                }
                
                
                
                
            }
        
        
            if(isPrevButtonPressed == false){
                
                surveyObj.surveyQuestionArrayIndex = surveyObj.surveyQuestionArrayIndex - 1
                
            }
            
            
            
           Utility.showPreviousQuestion(vctrl: self, surveyObj: surveyObj, canvasserTaskDataObject: canvasserTaskDataObject, viewModel: viewModel)
            
           // self.navigationController?.popViewController(animated: true)
            
        }

    }
}

extension SurveyRadioOptionViewController{
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        optionsCollectionView.reloadData()
        
        widthToUse = size.width - 140
        
        let collectionViewLayout = optionsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.invalidateLayout()

        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return optionsTextArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SurveyOptionsButtonCell
        
        
        
        
        cell.contentView.layer.cornerRadius = 10.0;
        cell.contentView.layer.borderWidth = 1.0;
        cell.contentView.layer.borderColor = UIColor.clear.cgColor;
        cell.contentView.layer.masksToBounds = true;
        
        cell.layer.shadowColor = UIColor.gray.cgColor;
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0);
        cell.layer.shadowRadius = 2.0;
        cell.layer.shadowOpacity = 1.0;
        cell.layer.masksToBounds = false;
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath;
        
        
        if let object = surveyObj.surveyOutput[surveyQuestionObj.questionNumber]
        {
            
            if(optionsTextArray[indexPath.row] == object.selectedAnswer)
            {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredVertically)
                
                radiobuttonCurrentValue = object.selectedAnswer
                
                cell.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) // green
               
                if(surveyQuestionObj.isSkipLogic == "true")
                {
                    let skipLogicArr:[[String:SkipLogic]] =  surveyQuestionObj.skipLogicArray
                    
                    for objectSkipLogic in skipLogicArr{
                        if(objectSkipLogic[object.selectedAnswer] != nil)
                        {
                            let tempObject:SkipLogic = objectSkipLogic[object.selectedAnswer]!
                            
                            if(tempObject.skipLogicType == "Show Text"){
                                getDescriptionTextField.isHidden = true
                                showTextLbl.isHidden = false
                            }
                            else if(tempObject.skipLogicType == "Input Text"){
                                showTextLbl.isHidden = true
                                getDescriptionTextField.isHidden = false
                                
                            }
                            else
                            {
                                showTextLbl.isHidden = true
                                getDescriptionTextField.isHidden = true
                            }
                        }
                        else{
                            showTextLbl.isHidden = true
                            getDescriptionTextField.isHidden = true
                        }
                    }
                    
                    
                }
                
                
            }
                
            else
            {
                
                cell.backgroundColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1) //blue
            }
            
            
        }
            
            
        else
        {
            
            cell.backgroundColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1) //blue
            
        }
        
        
        cell.optionText.text = optionsTextArray[indexPath.row]
        cell.optionId.text = optionsTextArray[indexPath.row]
        
        
        return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        guard collectionView.cellForItem(at: indexPath) != nil else
        {
            return
        }
        
        
        
        let currentCell = collectionView.cellForItem(at: indexPath) as! SurveyOptionsButtonCell
        
        currentCell.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) // green
        
        radiobuttonCurrentValue = currentCell.optionId.text!
        
        if(radiobuttonCurrentValue == "")
        {
            print("blank")
        }
        
        if(surveyQuestionObj.isSkipLogic == "true")
        {
            let skipLogicArr:[[String:SkipLogic]] =  surveyQuestionObj.skipLogicArray
            
            for objectSkipLogic in skipLogicArr{
                if(objectSkipLogic[radiobuttonCurrentValue] != nil){
                    let tempObject:SkipLogic = objectSkipLogic[radiobuttonCurrentValue]!
                    if(tempObject.skipLogicType == "Show Text"){
                        showTextLbl.isHidden = false
                        showTextLbl.text = tempObject.showTextValue
                        
                        getDescriptionTextField.isHidden = true
                        
                    }
                    else if(tempObject.skipLogicType == "Input Text"){
                        showTextLbl.isHidden = true
                        getDescriptionTextField.isHidden = false
                        
                        
                        
                    }
                    else{
                        showTextLbl.isHidden = true
                        getDescriptionTextField.isHidden = true
                    }
                }
                else{
                    showTextLbl.isHidden = true
                    getDescriptionTextField.isHidden = true
                }
            }
            
            
        }
        
        
        populateSurveyOutput()
        
        
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    {
        
        guard collectionView.cellForItem(at: indexPath) != nil else {
            return
        }
        
        
        let currentCell = collectionView.cellForItem(at: indexPath) as! SurveyOptionsButtonCell
        
        currentCell.backgroundColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1) //blue
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        
        var collectionViewWidth = collectionView.bounds.width
        
        if let w = widthToUse
        {
            collectionViewWidth = w
        }
        
        let width = collectionViewWidth - collectionViewLayout!.sectionInset.left - collectionViewLayout!.sectionInset.right - 170
        
        return CGSize(width: width, height:50)
        
        
    }
    
    
    
    
}


