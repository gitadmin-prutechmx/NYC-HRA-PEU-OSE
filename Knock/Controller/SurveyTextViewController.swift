//
//  PecoSurveyTextViewController.swift
//  MTXGIS
//
//  Created by Kamal on 27/04/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class SurveyTextViewController: UIViewController {
    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var questionView: UIView!
    
    @IBOutlet weak var surveyName: UILabel!
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet weak var questionTextField: UITextField!
    
    @IBOutlet weak var pageControl: UIPageControl!
    var surveyObject:SurveyQuestionDO!
    
   
    @IBOutlet weak var prevBtnOutlet: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.toolBarView.layer.borderWidth = 2
        self.toolBarView.layer.borderColor =  UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).cgColor
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white

        
         self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        let rightExitSurveyBarButtonItem = UIBarButtonItem(image: UIImage(named: "ExitSurvey.png"), style: .plain, target: self, action: #selector(SurveyRadioOptionViewController.exitFromSurvey))
        
        self.navigationItem.rightBarButtonItem  = rightExitSurveyBarButtonItem

        
        
        self.navigationItem.title =  SalesforceConnection.surveyName
        

        
        let leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem  = leftBarButtonItem
        
        
        
        
        
        
        //  self.title = String(Utilities.currentSurveyPage) + " /  " + String(Utilities.totalSurveyQuestions)
        
        surveyObject = Utilities.surveyQuestionArray[Utilities.surveyQuestionArrayIndex].objectSurveyQuestion
        
        questionText.text = surveyObject.questionText
        
        questionTextField.layer.borderColor = UIColor.gray.cgColor
        
        questionTextField.layer.borderWidth = 1.0
        
        questionTextField.layer.cornerRadius = 10.0
        
        if let object = Utilities.SurveyOutput[surveyObject.questionNumber] {
            questionTextField.text = object.selectedAnswer
        }
        
        
        pageControl.numberOfPages = Utilities.surveyQuestionArray.count
        
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        
        
        // Do any additional setup after loading the view.
    }
    
    func exitFromSurvey()
    {
        let alertCtrl = Alert.showUIAlert(title: "Message", message: "Are you sure you want to exit from survey?", vc: self)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel) { action -> Void in
            //Do some stuff
        }
        alertCtrl.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            
            Utilities.isExitFromSurvey = true
            Utilities.isSubmitSurvey = false
            
            SurveyUtility.saveInProgressSurveyToCoreData(surveyStatus: Utilities.inProgressSurvey)

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)

            self.performSegue(withIdentifier: "UnwindBackFromSurveyIdentifier", sender: self)
            //Do some other stuff
        }
        alertCtrl.addAction(okAction)
        
   
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(Utilities.surveyQuestionArrayIndex == 0){
            
            prevBtnOutlet.isHidden = true
            // self.navigationItem.leftBarButtonItem = nil
            //self.navigationItem.setHidesBackButton(true, animated:true);
        }
            
        else{
            prevBtnOutlet.isHidden = false
            //self.navigationItem.title = "Back"
        }
        
        
        pageControl.currentPage = Utilities.surveyQuestionArrayIndex
        
        // self.navigationItem.title = String(Utilities.currentSurveyPage) + " / " + String(Utilities.totalSurveyQuestions)
        
        //self.surveyName.text = "Survey: 59 Booster St, New York, NY ,12201"
        
        self.surveyName.text = "Unit: " + SalesforceConnection.unitName + "  |  " + SalesforceConnection.fullAddress
        
        //flagView.isHidden = true
    }
    
    
    /*   func exitFromSurvey(_ sender: UIBarButtonItem) {
     
     
     self.performSegue(withIdentifier: "unwindToUnit", sender: self)
     
     
     }
     
     */
    
    
    var isNextButtonPressed:Bool = false
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if(isNextButtonPressed == false)
        {
            //Utilities.currentSurveyPage = Utilities.surveyQuestionArrayIndex
            
            // Utilities.surveyQuestionArrayIndex = Utilities.surveyQuestionArrayIndex - 1
        }
        else{
            isNextButtonPressed = false
        }
    }
    
    @IBAction func switchSurvey(_ sender: Any) {
        
        SurveyUtility.SwitchNewSurvey(vc: self)
    }
    
    @IBAction func inTake(_ sender: Any) {
        
        SurveyUtility.InTake(vc: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var isSkipLogic:Bool = false
    
    @IBAction func nextQuestion(_ sender: UIButton) {
        
        isSkipLogic = false
        isNextButtonPressed = true
        
        
        
        if ((questionTextField.text?.isEmpty) != nil){
            Utilities.answerSurvey = questionTextField.text!
        }
        else{
            Utilities.answerSurvey = ""
        }
        
        
        if(surveyObject.isRequired == false && Utilities.answerSurvey.isEmpty){
            Utilities.answerSurvey = ""
            
        }
        else if(surveyObject.isRequired == true && Utilities.answerSurvey.isEmpty){
            
            self.questionView.shake()
            
            //self.questionsView.shake()
            // JLToast.makeText("This is required field.", duration: 1).show()
            return
        }
        
        
        let objSurveyResult:SurveyResult =  SurveyResult(questionId:surveyObject.questionId, questionType: surveyObject.questionType, getDescription: "", selectedAnswer: Utilities.answerSurvey,multiOption: [])
        
        Utilities.SurveyOutput[surveyObject.questionNumber] = objSurveyResult
        
        
        //  Utilities.SurveyOutput[surveyObject.questionId] = Utilities.answerSurvey
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if(Utilities.surveyQuestionArrayIndex == Utilities.totalSurveyQuestions - 1){
            
            // self.navigationItem.title = "Previous"
            
            let surveySubmitVC = storyboard.instantiateViewController(withIdentifier: "submitSurveyIdentifier") as! SubmitSurveyViewController
            
            
            
           SurveyUtility.TransitionVC(subType: kCATransitionFromRight, sourceVC: self, destinationVC: surveySubmitVC)
            
            
          //  self.navigationController?.pushViewController(surveySubmitVC, animated: true)
            
            /*   let navigationController = UINavigationController(rootViewController: surveySubmitVC)
             
             self.presentViewController(navigationController, animated: true, completion: nil)
             
             */
        }
            
        else{
            
            
            
            let currentIndex = Utilities.surveyQuestionArrayIndex
            
            //handle SkipLogic
            var objSurveyQues =  Utilities.surveyQuestionArray[currentIndex].objectSurveyQuestion
            
            
            if(Utilities.skipLogicParentChildDict[(objSurveyQues?.questionNumber)!] != nil){
                
                let arrayValue:[SkipLogic]  = Utilities.skipLogicParentChildDict[objSurveyQues!.questionNumber]!
                
                for object in arrayValue{
                    
                    if(Utilities.SurveyOutput[objSurveyQues!.questionNumber] != nil){
                        let objectSurveyResult:SurveyResult =  Utilities.SurveyOutput[objSurveyQues!.questionNumber]!
                        
                        //right now not handle multi select
                        if(objectSurveyResult.selectedAnswer == object.selectedAnswer){
                            
                            //skip question
                            
                            if(currentIndex == Utilities.totalSurveyQuestions - 1){
                                
                                
                                
                                let surveySubmitVC = storyboard.instantiateViewController(withIdentifier: "submitSurveyIdentifier") as! SubmitSurveyViewController
                                
                                
                                SurveyUtility.TransitionVC(subType: kCATransitionFromRight, sourceVC: self, destinationVC: surveySubmitVC)
                                
                                
                               // self.navigationController?.pushViewController(surveySubmitVC, animated: true)
                                
                                return
                                
                            }
                                
                            else{
                                
                                
                                //Here we have to delete key value
                                
                                let numberofQuestionsSkip = (Int(object.questionNumber)! - Int(objSurveyQues!.questionNumber)!)-1 //childquestionnumber - parentquestionumber
                                
                                
                                let count  = currentIndex + numberofQuestionsSkip
                                
                                
                                let startingIndex = currentIndex + 1
                                
                                if(startingIndex < count){
                                    Utilities.deleteSkipSurveyData(startingIndex: startingIndex, count: count)
                                }
                                
                                
                                
                                
                                Utilities.surveyQuestionArrayIndex = Int(object.questionNumber)! - 1
                                
                                Utilities.currentSurveyPage = Int(object.questionNumber)! - 1
                                
                                objSurveyQues =  Utilities.surveyQuestionArray[Utilities.surveyQuestionArrayIndex].objectSurveyQuestion
                                
                                isSkipLogic = true
                                
                                break;
                                
                            }
                            
                            
                        }
                    }
                    
                }
                
            }//end of if skip logic
            
            if(isSkipLogic == false){
                
                Utilities.surveyQuestionArrayIndex = Utilities.surveyQuestionArrayIndex + 1
                
                Utilities.currentSurveyPage = Utilities.surveyQuestionArrayIndex + 1
                
                objSurveyQues =  Utilities.surveyQuestionArray[Utilities.surveyQuestionArrayIndex].objectSurveyQuestion
                
            }
            
            
            
            if(objSurveyQues?.questionType == "Single Select"){
                
                // self.navigationItem.title = "Previous"
                
                let surveyRadioButtonVC = storyboard.instantiateViewController(withIdentifier: "surveyRadioButtonVCIdentifier") as! SurveyRadioOptionViewController
                
                          SurveyUtility.TransitionVC(subType: kCATransitionFromRight, sourceVC: self, destinationVC: surveyRadioButtonVC)
                
                //self.navigationController?.pushViewController(surveyRadioButtonVC, animated: true)
                
                
                
            }
                
            else if(objSurveyQues?.questionType == "Multi Select"){
                
                let surveyMultiButtonVC = storyboard.instantiateViewController(withIdentifier: "surveyMultiOptionVCIdentifier") as! SurveyMultiOptionViewController
                
                          SurveyUtility.TransitionVC(subType: kCATransitionFromRight, sourceVC: self, destinationVC: surveyMultiButtonVC)
                
                //self.navigationController?.pushViewController(surveyMultiButtonVC, animated: true)
                
                
            }
                
            else if(objSurveyQues?.questionType == "Text Area"){
                
                // self.navigationItem.title = "Previous"
                
                let surveyTextFieldVC = storyboard.instantiateViewController(withIdentifier: "surveyTextFiedVCIdentifier") as! SurveyTextViewController
                
                          SurveyUtility.TransitionVC(subType: kCATransitionFromRight, sourceVC: self, destinationVC: surveyTextFieldVC)
                
                //self.navigationController?.pushViewController(surveyTextFieldVC, animated: true)
                
                
                
            }
            
            
            
        }
    }
    
    var isPrevSkip:Bool = false
    
    @IBAction func prevQuestion(_ sender: UIButton) {
        
        isPrevSkip = false
        
        //handle SkipLogic
        let objSurveyQues =  Utilities.surveyQuestionArray[Utilities.surveyQuestionArrayIndex].objectSurveyQuestion
        
        // let parentIndex = Int((objSurveyQues?.questionNumber)!)! - 1
        
        
        //6
        if(Utilities.prevSkipLogicParentChildDict[(objSurveyQues?.questionNumber)!] != nil){
            
            let arrayValue:[SkipLogic]  = Utilities.prevSkipLogicParentChildDict[(objSurveyQues?.questionNumber)!]! //parent object result
            
            for object in arrayValue{
                
                //let childIndex = Int((object.questionNumber)!)! - 1
                
                //3
                if(Utilities.SurveyOutput[object.questionNumber] != nil){
                    let objectSurveyResult:SurveyResult =  Utilities.SurveyOutput[object.questionNumber]! //child object result
                    
                    if(objectSurveyResult.questionType == "Multi Select"){
                        if(objectSurveyResult.multiOption.contains(object.selectedAnswer)){
                            //skip question
                            
                            Utilities.surveyQuestionArrayIndex = Int(object.questionNumber)! - 1
                            
                            isPrevSkip = true
                            //Utilities.surveyQuestionArrayIndex = Utilities.surveyQuestionArrayIndex - 1
                            break;
                            
                        }
                    }
                        
                        
                    else if(objectSurveyResult.selectedAnswer == object.selectedAnswer){
                        
                        //skip question
                        
                        Utilities.surveyQuestionArrayIndex = Int(object.questionNumber)! - 1
                        
                        isPrevSkip = true
                        //Utilities.surveyQuestionArrayIndex = Utilities.surveyQuestionArrayIndex - 1
                        
                        break;
                        
                    }
                }
                
            }
            
        }
        if(isPrevSkip == false){
            
            Utilities.surveyQuestionArrayIndex = Utilities.surveyQuestionArrayIndex - 1
            
        }
        
        
        
         SurveyUtility.goToPreviousQuestion(sourceVC:self)
        
        //self.navigationController?.popViewController(animated: true);
        
        /* Utilities.surveyQuestionArrayIndex = Utilities.surveyQuestionArrayIndex - 1
         
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         
         if(Utilities.surveyQuestionArrayIndex == -1){
         
         let startSurveyVC = storyboard.instantiateViewControllerWithIdentifier("startSurveyVCIdentifier") as! StartSurveyViewController
         
         
         let navigationController = UINavigationController(rootViewController: startSurveyVC)
         
         self.presentViewController(navigationController, animated: true, completion: nil)
         
         }
         
         else{
         
         let objSurveyQues =  Utilities.surveyQuestionArray[Utilities.surveyQuestionArrayIndex].objectSurveyQuestion
         
         if(objSurveyQues.questionType == "renderSelectRadio"){
         
         
         
         //  self.navigationItem.title = "Previous"
         
         let pecoSurveyRadioButtonVC = storyboard.instantiateViewControllerWithIdentifier("pecoSurveyRadioButtonVCIdentifier") as! PecoSurveyRadioOptionViewController
         
         //self.presentViewController(pecoSurveyRadioButtonVC, animated: true ,completion: nil)
         
         self.navigationController?.pushViewController(pecoSurveyRadioButtonVC, animated: true)
         
         
         
         
         
         }
         else if(objSurveyQues.questionType == "renderFreeText"){
         
         //    self.navigationItem.title = "Previous"
         
         let pecoSurveyTextFieldVC = storyboard.instantiateViewControllerWithIdentifier("pecoSurveyTextFiedVCIdentifier") as! PecoSurveyTextViewController
         
         self.navigationController?.pushViewController(pecoSurveyTextFieldVC, animated: true)
         
         
         }
         
         }
         
         */
        
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


