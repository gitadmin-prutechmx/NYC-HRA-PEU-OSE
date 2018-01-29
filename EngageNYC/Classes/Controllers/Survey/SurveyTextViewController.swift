//
//  SurveyTextViewController.swift
//  EngageNYC
//
//  Created by MTX on 1/17/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class SurveyTextViewController: UIViewController
{
  
    
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet weak var questionTextField: UITextField!
    
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSurveySelect: UIButton!
    
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblUnit: UILabel!
    @IBOutlet weak var lblSelectSurvey: UILabel!
    
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnNext: UIButton!
     @IBOutlet weak var pageControl: UIPageControl!
    
    
    
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    var surveyObj:SurveyDO!
    var viewModel:SurveyViewModel!
    
    var surveyQuestionObj:SurveyQuestionDO!
    
    var isNextButtonPressed:Bool = false
    var isPrevButtonPressed:Bool = false
    
    var isSkipLogic:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
    }
    
    
    func setUpView()
    {
        
        questionTextField.layer.borderColor = UIColor.gray.cgColor
        
        questionTextField.layer.borderWidth = 1.0
        
        questionTextField.layer.cornerRadius = 10.0
        
        
        
        questionTextField.layer.borderColor = UIColor.gray.cgColor
        
        questionTextField.layer.borderWidth = 1.0
        
        questionTextField.layer.cornerRadius = 10.0
        
        
        if(surveyObj != nil){
            surveyQuestionObj = surveyObj.surveyQuestionArray[surveyObj.surveyQuestionArrayIndex].objectSurveyQuestion
            
            questionText.text = surveyQuestionObj.questionText
            
            if let answerObj = surveyObj.surveyOutput[surveyQuestionObj.questionNumber] {
                questionTextField.text = answerObj.selectedAnswer
            }
            
            
          
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
    
    
    
    
    @IBAction func btnBackAction(_ sender: Any)
    {
       Utility.exitFromSurvey(vctrl: self, surveyVM: viewModel, surveyObj: surveyObj)
       
    }
    
    @IBAction func btnLoginUserNamePressed(_ sender: Any) {
        
        Utility.openNavigationItem(btnLoginUserName: self.btnLogin, vc: self)
    }
    
    
    @IBAction func btnSurveySelectPressed(_ sender: Any) {
        Utility.showAllSurveyOnAssignment(btnSelectedSurveyName: btnSurveySelect, vc: self, surveyId: surveyObj.surveyId, assignmentId: canvasserTaskDataObject.assignmentObj.assignmentId, viewModel: viewModel)
    }
    
    @IBAction func btnInTakePressed(_ sender: Any) {
        
        Utility.showInTake(vc: self,canvasserTaskDataObject: canvasserTaskDataObject)
    }
    
    
    @IBAction func btnNextpress(_ sender: Any)
    {
        questionTextField.resignFirstResponder()
        self.showNextQuestion()
    }
    
    
    @IBAction func btnPrevPress(_ sender: Any)
    {
        questionTextField.resignFirstResponder()
        self.showPreviousQuestion()
    }
}

extension SurveyTextViewController:ListingPopoverDelegate{
    func selectedItem(withObj obj: ListingPopOverDO, selectedIndex index: Int, popOverType type: PopoverType) {
        if(type == .surveyList){
            
            Utility.switchToNewSurvey(surveyObj: surveyObj, vctrl: self, listingPopOverObj: obj, btnSurveySelect: btnSurveySelect, viewModel: viewModel, canvasserTaskDataObject: canvasserTaskDataObject)
        }
        else{
          Utility.selectedNavigationItem(obj: obj, vc: self,isFromSurveyScreen: true,canvasserTaskDataObject:canvasserTaskDataObject)
        }
    }

}

extension SurveyTextViewController{
    
    func showNextQuestion(){
        
        isSkipLogic = false
        isNextButtonPressed = true
        
        if ((questionTextField.text?.isEmpty) != nil){
            surveyObj.answerSurvey = questionTextField.text!
        }
        else
        {
            surveyObj.answerSurvey = ""
        }
        
        
        if(surveyQuestionObj.isRequired == false && surveyObj.answerSurvey.isEmpty){
            surveyObj.answerSurvey = ""
            
        }
        else if(surveyQuestionObj.isRequired == true && surveyObj.answerSurvey.isEmpty){
            
            self.questionView.shake()
            return
        }
        
        
        let objSurveyResult:SurveyResult =  SurveyResult(questionId:surveyQuestionObj.questionId, questionType: surveyQuestionObj.questionType, getDescription: "", selectedAnswer: surveyObj.answerSurvey,multiOption: [])
        
        surveyObj.surveyOutput[surveyQuestionObj.questionNumber] = objSurveyResult
        //  Utilities.SurveyOutput[surveyObject.questionId] = Utilities.answerSurvey
        
        if(surveyObj.surveyQuestionArrayIndex == surveyObj.totalSurveyQuestions - 1){
            
              Utility.showSubmitSurveyVC(vc: self, surveyObj: surveyObj, canvasserTaskDataObject: canvasserTaskDataObject, surveyVM: viewModel)
            
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
                        
                        //right now not handle multi select
                        if(objectSurveyResult.selectedAnswer == object.selectedAnswer){
                            
                            //skip question
                            
                            if(currentIndex == surveyObj.totalSurveyQuestions - 1){
                                
                                Utility.showSubmitSurveyVC(vc: self, surveyObj: surveyObj, canvasserTaskDataObject: canvasserTaskDataObject, surveyVM: viewModel)
                                
                                return
                                
                                
                                
                            }
                                
                            else{
                                
                                
                                //Here we have to delete key value
                                
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
                
            }//end of if skip logic
            
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
        
        //handle SkipLogic
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
            
        }
        
    }
    
    
    
    
}
