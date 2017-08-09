//
//  SurveyUtility.swift
//  Knock
//
//  Created by Kamal on 04/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import Foundation

class SurveyUtility {
    
    static var navigationController:UINavigationController? = nil
    
    static var sourceViewController:UIViewController? = nil
    
    class func showSurvey(){
        
        let surveyQuestionResults =
            ManageCoreData.fetchData(salesforceEntityName: "SurveyQuestion",predicateFormat: "surveyId == %@ AND assignmentId = %@" ,predicateValue: SalesforceConnection.surveyId,predicateValue2:SalesforceConnection.assignmentId,isPredicate:true) as! [SurveyQuestion]
        
        if(surveyQuestionResults.count == 1){
            
            
            let jsonData =  Utilities.convertToJSON(text: surveyQuestionResults[0].surveyQuestionData!) as!Dictionary<String, AnyObject>
            
            
            readSurveyJSONObject(object: jsonData)
            
            Utilities.totalSurveyQuestions =  Utilities.surveyQuestionArray.count
            
            
            if(Utilities.totalSurveyQuestions > 0){
                
                showSurveyQuestions()
                print("ShowSurveyQuestions")
            }
            
        }
    }
    
    static var skipLogicArray : [[String:SkipLogic]] = []
    static var skipLogicDict = [String: SkipLogic]()
    static var skipLogicParentChildArray = [SkipLogicParentChild]()
    
    class func addSurveyObject(_ questionId:String,questionType:String,questionText:String,questionNumber:String,required:Bool,choices:String,isSkipLogic:String,answer:String,questionChoiceList:[[String: AnyObject]]){
        
        SurveyUtility.skipLogicArray = []
        
        SurveyUtility.skipLogicDict = [:]
        
        
        
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
                
                SurveyUtility.skipLogicDict[choice] = objectSkipLogic
                
                SurveyUtility.skipLogicArray.append(skipLogicDict)
                
                if(skipLogicType == "Skip to Question"){
                    SurveyUtility.skipLogicParentChildArray.append(SkipLogicParentChild(childQuesionNumber: childQuestionNumber, parentQuestionNumber: questionNumber, selectedAnswer: choice, skipLogicType: skipLogicType,showTextValue:showTextValue))
                }
                
                
            }
            
            
            
        }
        
        
        //options = options.substring(to: options.characters.index(before: options.endIndex))
        
        options = String(options.characters.dropLast())
        
        
        let  objSurveyQues = SurveyQuestionDO(questionId: questionId, questionText: questionText,questionType:questionType,questionNumber:questionNumber,isRequired: required,choices: options , skipLogicArray:SurveyUtility.skipLogicArray , isSkipLogic: isSkipLogic,getDescriptionAnswer: answer)
        
        
        let objectStruct:structSurveyQuestion = structSurveyQuestion(key: questionId, objectSurveyQuestion: objSurveyQues)
        
        
        Utilities.surveyQuestionArray.append(objectStruct)
        
        
        
    }
    
    
    class func readSurveyJSONObject(object:Dictionary<String, AnyObject>) {
        
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
            
            //            addSurveyObject(questionId, questionType: questionType, questionText: questionText, questionNumber: questionNumber, required: required, choices: "", isSkipLogic: skipLogic, answer: "", questionChoiceList: questionChoiceList)
            
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
    
    
    
    
    
    
    class func showSurveyQuestions(){
        
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        if let surveyResponse = getSurveyFromCoreData(){
            
            Utilities.SurveyOutput = (surveyResponse.surveyQuestionRes! as NSObject) as! [String : SurveyResult]
            
            
            
            Utilities.surveyQuestionArrayIndex = Int(surveyResponse.surveyQuestionIndex)
            
        }
        else{
            
            Utilities.SurveyOutput = [:]
            
            Utilities.surveyQuestionArrayIndex = 0
            
        }
        
        Utilities.answerSurvey = ""
        
        if(Utilities.surveyQuestionArrayIndex == Utilities.totalSurveyQuestions){
            
            Utilities.surveyQuestionArrayIndex = Utilities.surveyQuestionArrayIndex - 1
            
            let surveySubmitVC = storyboard.instantiateViewController(withIdentifier: "submitSurveyIdentifier") as! SubmitSurveyViewController
            
            
            SurveyUtility.TransitionVC(subType: kCATransitionFromRight, sourceVC: sourceViewController, destinationVC: surveySubmitVC)
            
        }
            
        else{
            
            
            
            
            Utilities.currentSurveyPage = Utilities.surveyQuestionArrayIndex + 1 //Not use this time
            
            let objSurveyQues =  Utilities.surveyQuestionArray[Utilities.surveyQuestionArrayIndex].objectSurveyQuestion
            
            if(objSurveyQues?.questionType == "Single Select"){
                
                let surveyRadioButtonVC = storyboard.instantiateViewController(withIdentifier: "surveyRadioButtonVCIdentifier") as! SurveyRadioOptionViewController
                
                
                
                
                
                TransitionVC(subType: kCATransitionFromRight, sourceVC: sourceViewController, destinationVC: surveyRadioButtonVC)
                
                
                //  navigationController?.pushViewController(surveyRadioButtonVC, animated: true)
                
                
            }
            else if(objSurveyQues?.questionType == "Multi Select"){
                
                let surveyMultiButtonVC = storyboard.instantiateViewController(withIdentifier: "surveyMultiOptionVCIdentifier") as! SurveyMultiOptionViewController
                
                TransitionVC(subType: kCATransitionFromRight, sourceVC: sourceViewController, destinationVC: surveyMultiButtonVC)
                
                // navigationController?.pushViewController(surveyMultiButtonVC, animated: true)
                
                
            }
            else if(objSurveyQues?.questionType == "Text Area"){
                
                let surveyTextFieldVC = storyboard.instantiateViewController(withIdentifier: "surveyTextFiedVCIdentifier") as! SurveyTextViewController
                
                TransitionVC(subType: kCATransitionFromRight, sourceVC: sourceViewController, destinationVC: surveyTextFieldVC)
                
                //navigationController?.pushViewController(surveyTextFieldVC, animated: true)
                
                
                /*  let surveyTextFieldVC = storyboard.instantiateViewControllerWithIdentifier("surveyTextFiedVCIdentifier") as! SurveyTextFieldViewController
                 
                 self.navigationController?.pushViewController(surveyTextFieldVC, animated: true)
                 
                 */
            }
        }
        
        
    }
    
    
    class func goToPreviousQuestion(sourceVC:UIViewController?){
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        let objSurveyQues =  Utilities.surveyQuestionArray[Utilities.surveyQuestionArrayIndex].objectSurveyQuestion
        
        if(objSurveyQues?.questionType == "Single Select"){
            
            let surveyRadioButtonVC = storyboard.instantiateViewController(withIdentifier: "surveyRadioButtonVCIdentifier") as! SurveyRadioOptionViewController
            
            
            //   navigationController?.pushViewController(surveyRadioButtonVC, animated: true)
            
            TransitionVC(subType: kCATransitionFromLeft, sourceVC: sourceVC, destinationVC: surveyRadioButtonVC)
            
            
        }
        else if(objSurveyQues?.questionType == "Multi Select"){
            
            let surveyMultiButtonVC = storyboard.instantiateViewController(withIdentifier: "surveyMultiOptionVCIdentifier") as! SurveyMultiOptionViewController
            
            
            // navigationController?.pushViewController(surveyMultiButtonVC, animated: true)
            
            TransitionVC(subType: kCATransitionFromLeft, sourceVC: sourceVC, destinationVC: surveyMultiButtonVC)
            
            
            
        }
        else if(objSurveyQues?.questionType == "Text Area"){
            
            let surveyTextFieldVC = storyboard.instantiateViewController(withIdentifier: "surveyTextFiedVCIdentifier") as! SurveyTextViewController
            
            // navigationController?.pushViewController(surveyTextFieldVC, animated: true)
            
            TransitionVC(subType: kCATransitionFromLeft, sourceVC: sourceVC, destinationVC: surveyTextFieldVC)
            
        }
        
        
        
        
        
    }
    
    
    class func TransitionVC(subType:String,sourceVC:UIViewController?,destinationVC:UIViewController?){
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = kCATransitionPush
        
        
        transition.subtype = subType//kCATransitionFromLeft
        
        let destinationNavVC = UINavigationController(rootViewController: destinationVC!)
        
        sourceVC?.view.window!.layer.add(transition, forKey: kCATransition)
        
        sourceVC?.present(destinationNavVC, animated: false, completion: nil)
        
    }
    
    
    class func getSurveyFromCoreData() -> SurveyResponse?{
        
        let surveyResResultsArr = ManageCoreData.fetchData(salesforceEntityName: "SurveyResponse",predicateFormat: "unitId == %@ && actionStatus == %@" ,predicateValue: SalesforceConnection.unitId,predicateValue2: "InProgress", isPredicate:true) as! [SurveyResponse]
        
        if(surveyResResultsArr.count > 0){
            return surveyResResultsArr[0]
        }
        
        return nil
    }
    
    
    class func saveInProgressSurveyToCoreData(){
        
        let surveyResResultsArr = ManageCoreData.fetchData(salesforceEntityName: "SurveyResponse",predicateFormat: "unitId == %@ && actionStatus == %@" ,predicateValue: SalesforceConnection.unitId,predicateValue2: "InProgress", isPredicate:true) as! [SurveyResponse]
        
        if(surveyResResultsArr.count > 0){
            updateSurveyRes()
        }
        else{
            saveSurveyRes()
        }
        
    }
    
    class func saveSurveyRes(){
        
        let surveyResponseObject = SurveyResponse(context: context)
        
        surveyResponseObject.surveyId = SalesforceConnection.surveyId
        
        surveyResponseObject.unitId = SalesforceConnection.unitId
        surveyResponseObject.assignmentLocUnitId = SalesforceConnection.assignmentLocationUnitId
        
        surveyResponseObject.actionStatus = "InProgress"
        
        surveyResponseObject.surveyQuestionIndex = Int64(Utilities.surveyQuestionArrayIndex)
        
        surveyResponseObject.surveyQuestionRes = Utilities.SurveyOutput as NSObject?
        
        // Serialized data
        //let data = NSKeyedArchiver.ar
        
        appDelegate.saveContext()
        
    }
    
    class func updateSurveyRes(){
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["surveyId"] = SalesforceConnection.surveyId as AnyObject?
        
        updateObjectDic["surveyQuestionIndex"] = Int64(Utilities.surveyQuestionArrayIndex) as AnyObject?
        
        
        updateObjectDic["surveyQuestionRes"] = Utilities.SurveyOutput as NSObject?
        
        //  updateObjectDic["surveySignature "] =
        
        ManageCoreData.updateAnyObjectRecord(salesforceEntityName: "SurveyResponse", updateKeyValue: updateObjectDic, predicateFormat: "unitId == %@", predicateValue: SalesforceConnection.unitId,isPredicate: true)
        
        
        
    }
    
    class func SwitchNewSurvey(vc:UIViewController){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let chooseSurveyVC = storyboard.instantiateViewController(withIdentifier: "chooseSurveyIdentifier") as! ChooseSurveyViewController
        
        
        // SurveyUtility.navigationController = self.navigationController!
        
        SurveyUtility.sourceViewController = vc
        
        
        let completionHandler:(ChooseSurveyViewController)->Void = { chooseSurveyVC in
            
            ManageCoreData.deleteSurveyResponseRecord(salesforceEntityName: "SurveyResponse", predicateFormat: "unitId == %@", predicateValue: SalesforceConnection.unitId, isPredicate: true)
            
            SurveyUtility.showSurvey()
            
        }
        
        
        chooseSurveyVC.completionHandler = completionHandler
        
        
        let navigationController = UINavigationController(rootViewController: chooseSurveyVC)
        
        navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
        
        
        vc.present(navigationController, animated: true, completion: nil)
        
        
        
    }
    
    class func InTake(vc:UIViewController){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let inTakeVC = storyboard.instantiateViewController(withIdentifier: "inTakeIdentifier") as! InTakeViewController
        
        
        
        
        let navigationController = UINavigationController(rootViewController: inTakeVC)
        
        navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
        
        
        vc.present(navigationController, animated: true, completion: nil)
    }
    
    
}
