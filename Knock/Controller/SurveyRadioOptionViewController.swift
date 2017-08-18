//
//  PecoSurveyViewController.swift
//  MTXGIS
//
//  Created by Kamal on 26/04/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit
import AudioToolbox

class SurveyRadioOptionViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var toolBarView: UIView!
    
    
    
    @IBOutlet weak var getDescriptionTextField: UITextField!
    
    //@IBOutlet weak var showTextLbl: UILabel!
    
    @IBOutlet weak var showTextLbl: UITextView!
    
    @IBOutlet weak var surveyName: UILabel!
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    //@IBOutlet weak var optionsCollectionView: UICollectionView!
    //@IBOutlet weak var textView: UIView!
    //@IBOutlet weak var radioOptionsView: UIView!
    
    @IBOutlet weak var optionsCollectionView: UICollectionView!
    
    @IBOutlet weak var radioOptionsView: UIView!
    
    
    var objSurveyQues:SurveyQuestionDO!
    var optionsIdArray = [String]()
    var optionsTextArray = [String]()
    
    var optionsDic : [String:String] = [:]
    
    var radiobuttonCurrentValue:String = ""
    
    @IBOutlet weak var flagView: UIStackView!
    @IBOutlet weak var prevBtnOutlet: UIButton!
    
    @IBOutlet weak var questionsView: UIView!
    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.toolBarView.layer.borderWidth = 2
        self.toolBarView.layer.borderColor =  UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).cgColor
        
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        getDescriptionTextField.layer.borderColor = UIColor.gray.cgColor
        
        getDescriptionTextField.layer.borderWidth = 1.0
        
        getDescriptionTextField.layer.cornerRadius = 10.0
        
        
        
        
        /* let btnName = UIButton()
         btnName.setImage(UIImage(named: "ExitSurvey"), forState: .Normal)
         btnName.frame = CGRectMake(0, 0, 30, 30)
         btnName.addTarget(self, action: Selector("action"), forControlEvents: .TouchUpInside)
         
         //.... Set Right/Left Bar Button item
         let rightBarButton = UIBarButtonItem()
         rightBarButton.customView = btnName
         self.navigationItem.rightBarButtonItem = rightBarButton
         */
        
        /*
         var rightAddBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ViewController.addTapped))
         
         var rightSearchBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: #selector(ViewController.searchTapped))
         
         self.navigationItem.setRightBarButtonItems([rightAddBarButtonItem,rightSearchBarButtonItem], animated: true)
         */
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
        let rightExitSurveyBarButtonItem = UIBarButtonItem(image: UIImage(named: "ExitSurvey.png"), style: .plain, target: self, action: #selector(SurveyRadioOptionViewController.exitFromSurvey))
        
        self.navigationItem.rightBarButtonItem  = rightExitSurveyBarButtonItem
        
        
        //      if(Utilities.surveyQuestionArrayIndex == 0){
        //
        //            let rightChooseSurveyBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "SurveyTaken.png"), style: .plain, target: self, action: #selector(SurveyRadioOptionViewController.showChooseSurvey))
        //
        //            self.navigationItem.setRightBarButtonItems([rightExitSurveyBarButtonItem,rightChooseSurveyBarButtonItem], animated: true)
        //
        //
        //        }
        //
        //        else{
        //             self.navigationItem.setRightBarButtonItems([rightExitSurveyBarButtonItem], animated: true)
        //        }
        //
        
        self.navigationItem.title =  SalesforceConnection.surveyName
        
        
        
        
        
        
        let leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action:  nil)
        self.navigationItem.leftBarButtonItem  = leftBarButtonItem
        
        
        
        
        objSurveyQues = Utilities.surveyQuestionArray[Utilities.surveyQuestionArrayIndex].objectSurveyQuestion
        
        questionText.text = objSurveyQues.questionText
        
        if(Utilities.SurveyOutput[objSurveyQues.questionNumber] != nil){
            let objSurveyOutput:SurveyResult = Utilities.SurveyOutput[objSurveyQues.questionNumber]!
            getDescriptionTextField.text = objSurveyOutput.getDescription
        }
        
        
        
        // let options = objSurveyQues.choices!.replace("\r\n", withString:";")
        let options = objSurveyQues.choices!
        
        print(options)
        
        
        optionsTextArray = options.components(separatedBy: ";")
        
        
        
        
        
        /*  for optionData in objSurveyQues.singleOptionsString!
         {
         optionsIdArray.append(optionData.componentsSeparatedByString(";")[1])
         optionsTextArray.append(optionData.componentsSeparatedByString(";")[0])
         
         optionsDic[optionData.componentsSeparatedByString(";")[1]] = optionData.componentsSeparatedByString(";")[0]
         }
         */
        
        pageControl.numberOfPages = Utilities.surveyQuestionArray.count
        
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        
        
        // optionsCollectionView.delegate = self
        // optionsCollectionView.dataSource = self
        
        //view.frame.width
        
        // Do any additional setup after loading the view.
    }
    @IBAction func switchSurvey(_ sender: Any) {
        
        
       SurveyUtility.SwitchNewSurvey(vc: self)
        
    }
    
    
    @IBAction func inTake(_ sender: Any) {
        
       SurveyUtility.InTake(vc: self)


    }
    
   
    
    
    
    
    //func exitFromSurvey(_: UIBarButtonItem!)  {
    func exitFromSurvey()
    {
        let msgtitle = "Message"
        
        
        let alertController = UIAlertController(title: "Message", message: "Are you sure want to exit from survey?", preferredStyle: .alert)
        alertController.setValue(NSAttributedString(string: msgtitle, attributes: [NSFontAttributeName :  UIFont(name: "Arial", size: 17.0)!, NSForegroundColorAttributeName : UIColor.black]), forKey: "attributedTitle")
        
        
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Do some stuff
        }
        alertController.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
            
            Utilities.isExitFromSurvey = true
            Utilities.isSubmitSurvey = false

            
            SurveyUtility.saveInProgressSurveyToCoreData(surveyStatus: Utilities.inProgressSurvey)

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)

            self.performSegue(withIdentifier: "UnwindBackFromSurveyIdentifier", sender: self)
            
            //Do some other stuff
        }
        alertController.addAction(okAction)
        
        
        /* alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
         switch action.style{
         case .Default:
         
         self.performSegueWithIdentifier("unwindToUnit", sender: self)
         
         case .Cancel:
         print("cancel")
         
         case .Destructive:
         print("destructive")
         }
         
         
         }
         ))
         */
        
        self.present(alertController, animated: true, completion: nil)
        
        
        
        
        
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
        
        //  self.navigationItem.title = String(Utilities.currentSurveyPage) + " / " + String(Utilities.totalSurveyQuestions)
        
        //self.surveyName.text = "Survey: 59 Booster St, New York, NY ,12201"
        
        //self.optionsCollectionView.reloadData()
        
        self.surveyName.text = "Unit: " + SalesforceConnection.unitName + "  |  " + SalesforceConnection.fullAddress
        
        
        
        // flagView.isHidden = true
        
        
        /*if(Utilities.surveyQuestionArrayIndex != 0){
         flagView.isHidden = true
         }
         else{
         flagView.isHidden = false
         }
         */
        
    }
    
    
    
    var isSkipLogic:Bool = false
    
    @IBAction func nextQuestion(_ sender: UIButton) {
        
        isSkipLogic = false
        
        isNextButtonPressed = true
        
        if(objSurveyQues.isRequired == false && radiobuttonCurrentValue.isEmpty){
            radiobuttonCurrentValue = ""
            
        }
        else if(objSurveyQues.isRequired == true && radiobuttonCurrentValue.isEmpty){
            // JLToast.makeText("This is required field.", duration: 1).show()
            
            self.questionsView.shake()
            
            return
        }
        
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
        
        
        
        let objSurveyResult:SurveyResult =  SurveyResult(questionId:objSurveyQues.questionId, questionType: objSurveyQues.questionType, getDescription: getDescription, selectedAnswer: radiobuttonCurrentValue,multiOption: [])
        
        Utilities.SurveyOutput[objSurveyQues.questionNumber] = objSurveyResult
        
        
        // Utilities.SurveyOutput[objSurveyQues.questionId] = radiobuttonCurrentValue
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        //Move to End of Survey
        if(objSurveyQues.isSkipLogic == "true"){
            let skipLogicArr:[[String:SkipLogic]] =  objSurveyQues.skipLogicArray
            
            for objectSkipLogic in skipLogicArr{
                if(objectSkipLogic[radiobuttonCurrentValue] != nil){
                    let tempObject:SkipLogic = objectSkipLogic[radiobuttonCurrentValue]!
                    
                    if(tempObject.skipLogicType == "End of Survey"){
                        
                        
                        //Here we have to delete key value
                        
                        let startingIndex  = Utilities.surveyQuestionArrayIndex + 1
                        
                        let count = Utilities.totalSurveyQuestions - 1
                        
                        Utilities.deleteSkipSurveyData(startingIndex: startingIndex, count: count)
                        
                        
                        
                        let surveySubmitVC = storyboard.instantiateViewController(withIdentifier: "submitSurveyIdentifier") as! SubmitSurveyViewController
                        
                         SurveyUtility.TransitionVC(subType: kCATransitionFromRight, sourceVC: self, destinationVC: surveySubmitVC)
                        
                        
                        
                       // self.navigationController?.pushViewController(surveySubmitVC, animated: true)
                        
                        
                        return
                        
                    }
                }
            }
        }
        
        
        
        if(Utilities.surveyQuestionArrayIndex == Utilities.totalSurveyQuestions - 1){
            
            // self.navigationItem.title = "Previous"
            
            let surveySubmitVC = storyboard.instantiateViewController(withIdentifier: "submitSurveyIdentifier") as! SubmitSurveyViewController
            
            
             SurveyUtility.TransitionVC(subType: kCATransitionFromRight, sourceVC: self, destinationVC: surveySubmitVC)
            
            //self.navigationController?.pushViewController(surveySubmitVC, animated: true)
            
            
            
            
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
                        
                        
                        if(objectSurveyResult.selectedAnswer == object.selectedAnswer){
                            
                            //skip question
                            
                            if(currentIndex == Utilities.totalSurveyQuestions - 1){
                                
                                //objSurveyQues = nil
                                
                                let surveySubmitVC = storyboard.instantiateViewController(withIdentifier: "submitSurveyIdentifier") as! SubmitSurveyViewController
                                
                                 SurveyUtility.TransitionVC(subType: kCATransitionFromRight, sourceVC: self, destinationVC: surveySubmitVC)
                                
                                
                                
                               // self.navigationController?.pushViewController(surveySubmitVC, animated: true)
                                
                                return
                                
                            }
                                
                            else{
                                
                                
                                //Here we have to delete key value
                                
                                /* let count  = Utilities.surveyQuestionArrayIndex
                                 
                                 let startingIndex = Utilities.surveyQuestionArrayIndex
                                 
                                 Utilities.surveyQuestionArrayIndex = Utilities.surveyQuestionArrayIndex + 1
                                 
                                 Utilities.currentSurveyPage = Utilities.surveyQuestionArrayIndex + 1
                                 */
                                
                                
                                //2 ----(4-1)---> 6  =  1+3 =  2 and 4
                                //3 ----1---> 5  =
                                //3 ----0---> 4  =
                                
                                
                                
                                
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
                
            }//end of if skiplogic
            
            
            
            if(isSkipLogic == false){
                
                Utilities.surveyQuestionArrayIndex = Utilities.surveyQuestionArrayIndex + 1
                
                Utilities.currentSurveyPage = Utilities.surveyQuestionArrayIndex + 1
                
                objSurveyQues =  Utilities.surveyQuestionArray[Utilities.surveyQuestionArrayIndex].objectSurveyQuestion
                
            }
            
            
            if(objSurveyQues?.questionType == "Single Select"){
                
                
                
                //  self.navigationItem.title = "Previous"
                
                let surveyRadioButtonVC = storyboard.instantiateViewController(withIdentifier: "surveyRadioButtonVCIdentifier") as! SurveyRadioOptionViewController
                
                 SurveyUtility.TransitionVC(subType: kCATransitionFromRight, sourceVC: self, destinationVC: surveyRadioButtonVC)
                
              // self.navigationController?.pushViewController(surveyRadioButtonVC, animated: true)
                
                
                
            }
                
            else if(objSurveyQues?.questionType == "Multi Select"){
                
                let surveyMultiButtonVC = storyboard.instantiateViewController(withIdentifier: "surveyMultiOptionVCIdentifier") as! SurveyMultiOptionViewController
                
                 SurveyUtility.TransitionVC(subType: kCATransitionFromRight, sourceVC: self, destinationVC: surveyMultiButtonVC)
                
                //self.navigationController?.pushViewController(surveyMultiButtonVC, animated: true)
                
                
            }
                
            else if(objSurveyQues?.questionType == "Text Area"){
                
                //    self.navigationItem.title = "Previous"
                
                let surveyTextFieldVC = storyboard.instantiateViewController(withIdentifier: "surveyTextFiedVCIdentifier") as! SurveyTextViewController
                
                 SurveyUtility.TransitionVC(subType: kCATransitionFromRight, sourceVC: self, destinationVC: surveyTextFieldVC)
                
                //self.navigationController?.pushViewController(surveyTextFieldVC, animated: true)
                
                
                
                
            }
            
            
        }
        
        
    }
    
    var isPrevSkip:Bool = false
    @IBAction func prevQuestion(_ sender: UIButton) {
        
        isPrevSkip = false
        //1 2 (3) 4 5 [6]
        //      <------>
        //3-->6 and 3-->5
        //surveyQuestionArrayIndex(6)
        
        //Dictionary child parent and parent child
        //6 3
        
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
         
         // self.presentViewController(pecoSurveyRadioButtonVC, animated: true ,completion: nil)
         
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
    
    
    
    
    var widthToUse : CGFloat?
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        optionsCollectionView.reloadData()
        
        widthToUse = size.width - 140
        
        let collectionViewLayout = optionsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.invalidateLayout()
        
        //self.optionsCollectionView?
        
    }
    
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
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        /*let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
         
         collectionViewLayout?.sectionInset = UIEdgeInsetsMake(25, 45, 5, 5)
         
         collectionViewLayout?.invalidateLayout()*/
        
        if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
            print("Landscape")
            //here you can do the logic for the cell size if phone is in landscape
        } else {
            print("Portrait") //logic if not landscape
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return optionsTextArray.count
        //return 4
    }
    
    //selectItema
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        
        
        if let object = Utilities.SurveyOutput[objSurveyQues.questionNumber] {
            
            if(optionsTextArray[indexPath.row] == object.selectedAnswer){
                
                cell.isSelected = true
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredVertically)
                
                radiobuttonCurrentValue = object.selectedAnswer
                
                cell.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) //green
                
                
                if(objSurveyQues.isSkipLogic == "true"){
                    let skipLogicArr:[[String:SkipLogic]] =  objSurveyQues.skipLogicArray
                    
                    for objectSkipLogic in skipLogicArr{
                        if(objectSkipLogic[object.selectedAnswer] != nil){
                            let tempObject:SkipLogic = objectSkipLogic[object.selectedAnswer]!
                            
                            if(tempObject.skipLogicType == "Show Text"){
                                getDescriptionTextField.isHidden = true
                                showTextLbl.isHidden = false
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
                
                
                
                
                /*
                 if(getDescriptionTextField.hidden == false){
                 
                 if let object = Utilities.SurveyOutput[objSurveyQues.questionNumber] {
                 getDescriptionTextField.text = object.getDescription
                 }
                 
                 
                 }
                 
                 */
                
                
            }
                
                // }
                
                
                
            else{
                cell.backgroundColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1) //blue
                
                
            }
        }
            
            
        else{
            
            cell.backgroundColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1) //blue
            
        }
        
        
        
        cell.optionText.text = optionsTextArray[indexPath.row]
        cell.optionId.text = optionsTextArray[indexPath.row]
        
        
        
        
        
        
        
        
        
        // cell.layer.cornerRadius = 5
        // cell.layer.masksToBounds = true
        
        // cell.backgroundColor = UIColor.redColor()
        
        /* let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
         
         collectionViewLayout?.sectionInset = UIEdgeInsetsMake(25, 45, 5, 5)
         
         collectionViewLayout?.invalidateLayout()
         */
        
        return cell
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentCell = collectionView.cellForItem(at: indexPath) as! SurveyOptionsButtonCell
        
        currentCell.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) // green
        
        
        
        radiobuttonCurrentValue = currentCell.optionId.text!
        
        if(radiobuttonCurrentValue == ""){
            print("blank")
        }
        
        if(objSurveyQues.isSkipLogic == "true"){
            let skipLogicArr:[[String:SkipLogic]] =  objSurveyQues.skipLogicArray
            
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
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let currentCell = collectionView.cellForItem(at: indexPath) as! SurveyOptionsButtonCell
        
        currentCell.backgroundColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1) //blue
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //
        
        //CGRectGetWidth(collectionView.frame)
        
        let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        
        // let width = collectionView.bounds.width - collectionViewLayout!.sectionInset.left - collectionViewLayout!.sectionInset.right
        
        var collectionViewWidth = collectionView.bounds.width
        
        if let w = widthToUse
        {
            collectionViewWidth = w
        }
        
        let width = collectionViewWidth - collectionViewLayout!.sectionInset.left - collectionViewLayout!.sectionInset.right - 170
        
        return CGSize(width: width, height:50)
        
        
        
        //return CGSizeMake(collectionView.bounds.size.width , 50)
    }
    
    /*func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
     
     
     return UIEdgeInsetsMake(5, 15, 5, 15)
     }*/
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


