//
//  SurveyViewModel.swift
//  EngageNYC
//
//  Created by Kamal on 21/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation

class SurveyViewModel{
    
    var skipLogicArray : [[String:SkipLogic]] = []
    var skipLogicDict = [String: SkipLogic]()
    var skipLogicParentChildArray = [SkipLogicParentChild]()
    
    
    static func getViewModel() -> SurveyViewModel {
        return SurveyViewModel()
    }
    
    func getContactName(contactId:String)->String{
        return ContactAPI.shared.getContactName(contactId: contactId)
    }
    
    func deleteSurveyResponse(assignmentLocUnitId:String){
        SurveyAPI.shared.deleteSurvey(assignmentLocUnitId: assignmentLocUnitId)
    }
    
    
    func saveInProgressSurvey(surveyObj:SurveyDO){
        
        let surveyRes = SurveyAPI.shared.getSavedSurvey(assignmentLocUnitId: surveyObj.assignmentLocUnitId)
        
        if(surveyRes == nil){
            SurveyAPI.shared.saveSurvey(surveyObj: surveyObj,status:actionStatus.inProgressSurvey.rawValue)
        }
        else{
            SurveyAPI.shared.updateSurvey(surveyObj: surveyObj,status:actionStatus.inProgressSurvey.rawValue)
            
        }
        
    }


    
    
    func submitSurvey(surveyObj:SurveyDO,canvasserTaskDataObject:CanvasserTaskDataObject){
        
        surveyObj.surveyRes = prepareSurveyData(surveyObj: surveyObj)
        
        let surveyRes = SurveyAPI.shared.getSavedSurvey(assignmentLocUnitId: canvasserTaskDataObject.locationUnitObj.assignmentLocUnitId)
        
        if(surveyRes == nil){
            SurveyAPI.shared.saveSurvey(surveyObj: surveyObj,status:actionStatus.completeSurvey.rawValue)
        }
        else{
            SurveyAPI.shared.updateSurvey(surveyObj: surveyObj,status:actionStatus.completeSurvey.rawValue)
            
        }

    }
    
    
    
    
    func prepareSurveyData(surveyObj:SurveyDO)->[[String: String]]{
        
        var surveyResArr = [[String: String]]()
        var questionResponseDict:[String:String] = [:]
        
        for (_, value) in surveyObj.surveyOutput {
            
            questionResponseDict["questionId"] = value.questionId!
            questionResponseDict["description"] = value.getDescription!
            
            if(value.questionType == "Single Select" || value.questionType == "Text Area"){
                
                questionResponseDict["answer"] = value.selectedAnswer!
            }
            else if(value.questionType == "Multi Select"){
                
                let multioption = value.multiOption.joined(separator: ";")
                
                questionResponseDict["answer"] = multioption
            }
            
            surveyResArr.append(questionResponseDict)
            
        }
        
        return surveyResArr
        
        
    }
    
    

    
    func getAllSurveys(assignmentId:String) -> [ListingPopOverDO]{
        
        var arrSurveys = [ListingPopOverDO]()
        
        
        if let surveyQuesRes = SurveyAPI.shared.getAllSurveys(assignmentId: assignmentId){
           
            for surveyQuesData in surveyQuesRes{
                let listingPopOverObj = ListingPopOverDO()
                listingPopOverObj.id = surveyQuesData.surveyId
                listingPopOverObj.name = surveyQuesData.surveyName
                listingPopOverObj.additionalId = surveyQuesData.surveyQuestionData
                
                arrSurveys.append(listingPopOverObj)
            }
            
        }
        return arrSurveys
  
    }
    
    func getAllContactsOnUnit(assignmentLocUnitId:String)->[ListingPopOverDO]{
        
        
        var arrClients = [ListingPopOverDO]()
        
        
        if let contacts = ContactAPI.shared.getAllContactsOnUnit(assignmentLocUnitId: assignmentLocUnitId){
            
            for contactData in contacts{
                let listingPopOverObj = ListingPopOverDO()
                listingPopOverObj.id = contactData.iOSContactId
                listingPopOverObj.name = contactData.contactName
                //listingPopOverObj.iOSId = contactData.iOSContactId
                listingPopOverObj.additionalId = contactData.unitName
                
                arrClients.append(listingPopOverObj)
            }
            
        }
        
        let notrevealInfoListingPopOverObj = ListingPopOverDO()
        notrevealInfoListingPopOverObj.id = noClientName.unknown.rawValue
        notrevealInfoListingPopOverObj.name = noClientName.unknown.rawValue
        notrevealInfoListingPopOverObj.additionalId = noClientName.unknown.rawValue
        
        arrClients.insert(notrevealInfoListingPopOverObj, at: 0)
        
        return arrClients
    }
    
    //if survey already taken on unit
    func isSurveyTaken(assignmentLocUnitId:String)->SurveyDO?{
        
        var objSurvey:SurveyDO!
        
        if let surveyRes = SurveyAPI.shared.getSavedSurvey(assignmentLocUnitId: assignmentLocUnitId){
            
            // check surveyId exist or not in surveyQuestion
            if let surveyQues = SurveyAPI.shared.isSurveyQuesExist(surveyId: surveyRes.surveyId!){
                
                objSurvey = SurveyDO()
                
                objSurvey.surveyId = surveyQues.surveyId
                objSurvey.surveyName = surveyQues.surveyName
                objSurvey.surveyQuestion = surveyQues.surveyQuestionData
                objSurvey.surveyOutput = (surveyRes.questionAnswers! as NSObject) as! [String : SurveyResult]
                objSurvey.surveyQuestionArrayIndex = Int(surveyRes.surveyQuestionIndex)
            }
            
        }
        return objSurvey
    }
    
    //if no survey taken on unit
    func getSurvey(assignmentId:String,surveyId:String)->SurveyDO?{
        
        var objSurvey:SurveyDO!
        
        if let surveyQues = SurveyAPI.shared.getSurvey(assignmentId: assignmentId,surveyId: surveyId){
            objSurvey = SurveyDO()
            
            objSurvey.surveyId = surveyQues.surveyId
            objSurvey.surveyName = surveyQues.surveyName
            objSurvey.surveyQuestion = surveyQues.surveyQuestionData
        }
        
        return objSurvey
    }
    
    
    //if no survey taken on unit
    func getDefaultSurvey(assignmentId:String)->SurveyDO?{
        
        var objSurvey:SurveyDO!
        
        if let surveyQues = SurveyAPI.shared.getDefaultSurvey(assignmentId: assignmentId){
            objSurvey = SurveyDO()
            
            objSurvey.surveyId = surveyQues.surveyId
            objSurvey.surveyName = surveyQues.surveyName
            objSurvey.surveyQuestion = surveyQues.surveyQuestionData
        }
        
        return objSurvey
    }
    
    func parseSurveyQuestion(objSurvey:SurveyDO)->SurveyDO?{
        
        let jsonData =  Utility.convertToJSON(text: objSurvey.surveyQuestion!) as!Dictionary<String, AnyObject>
        
        readSurveyJSONObject(object: jsonData,objSurvey:objSurvey)
        
        objSurvey.totalSurveyQuestions =  objSurvey.surveyQuestionArray.count
      
        return objSurvey
        
    }
    
    func readSurveyJSONObject(object:Dictionary<String, AnyObject>,objSurvey:SurveyDO){
        
        
        objSurvey.surveyQuestionArray = []
        objSurvey.skipLogicParentChildDict = [:]
        objSurvey.prevSkipLogicParentChildDict = [:]
        
        skipLogicParentChildArray = []
        
        guard let _ = object["surveyName"] as? String
            , let quesRes = object["Question"] as? [[String: AnyObject]] else { return }
        
        
        
        for data in quesRes {
            
            print("data: \(data)")
            
            guard let questionType = data["questionType"] as? String else {break}
            
            guard let required = data["required"] as? Bool else { break }
            
            guard let questionText = data["questionText"] as? String else { break }
            guard let questionId = data["questionId"] as? String else { break }
            guard let questionNumber = data["questionNumber"] as? String else{break}
            
            
            //skip logic
            guard let skipLogic = data["skipLogic"] as? String else {break}
            // guard let answer = data["answer"] as? String? else {break}  //for getdescription text
            guard let questionChoiceList = data["questionChoiceList"] as? [[String: AnyObject]]  else {break}
            
            
            
            addSurveyObject(questionId, questionType: questionType, questionText: questionText, questionNumber: questionNumber, required: required, choices: "", isSkipLogic: skipLogic, answer: "", questionChoiceList: questionChoiceList,objSurvey:objSurvey)
            
            
        }
        
        
        
        var tempArray = [SkipLogic]()
        
        
        for skipLogicparentChild in skipLogicParentChildArray{
            
            tempArray = []
            
            if objSurvey.skipLogicParentChildDict[skipLogicparentChild.parentQuestionNumber] != nil {
                
                var arrayValue:[SkipLogic] =  objSurvey.skipLogicParentChildDict[skipLogicparentChild.parentQuestionNumber]!
                
                arrayValue.append(SkipLogic(skipLogicType: skipLogicparentChild.skipLogicType, questionNumber: skipLogicparentChild.childQuesionNumber, selectedAnswer: skipLogicparentChild.selectedAnswer,showTextValue:skipLogicparentChild.showTextValue))
                
                objSurvey.skipLogicParentChildDict[skipLogicparentChild.parentQuestionNumber] = arrayValue
                
            }
                
            else{
                
                tempArray.append(SkipLogic(skipLogicType: skipLogicparentChild.skipLogicType, questionNumber: skipLogicparentChild.childQuesionNumber, selectedAnswer: skipLogicparentChild.selectedAnswer,showTextValue:skipLogicparentChild.showTextValue))
                
                objSurvey.skipLogicParentChildDict[skipLogicparentChild.parentQuestionNumber] = tempArray
                
            }
            
        }
        
        
        //For Previous button
        var prevTempArray = [SkipLogic]()
        
        
        for skipLogicparentChild in skipLogicParentChildArray{
            
            prevTempArray = []
            
            if objSurvey.prevSkipLogicParentChildDict[skipLogicparentChild.childQuesionNumber] != nil {
                
                var arrayValue:[SkipLogic] =  objSurvey.prevSkipLogicParentChildDict[skipLogicparentChild.childQuesionNumber]!
                
                arrayValue.append(SkipLogic(skipLogicType: skipLogicparentChild.skipLogicType, questionNumber: skipLogicparentChild.parentQuestionNumber, selectedAnswer: skipLogicparentChild.selectedAnswer,showTextValue:skipLogicparentChild.showTextValue))
                
                objSurvey.prevSkipLogicParentChildDict[skipLogicparentChild.childQuesionNumber] = arrayValue
                
            }
                
            else{
                
                prevTempArray.append(SkipLogic(skipLogicType: skipLogicparentChild.skipLogicType, questionNumber: skipLogicparentChild.parentQuestionNumber, selectedAnswer: skipLogicparentChild.selectedAnswer,showTextValue:skipLogicparentChild.showTextValue))
                
                objSurvey.prevSkipLogicParentChildDict[skipLogicparentChild.childQuesionNumber] = prevTempArray
                
            }
            
        }
        
        
        
        
        
        print(objSurvey.surveyQuestionArray)
        
        
        
    }
    
    
    func addSurveyObject(_ questionId:String,questionType:String,questionText:String,questionNumber:String,required:Bool,choices:String,isSkipLogic:String,answer:String,questionChoiceList:[[String: AnyObject]],objSurvey:SurveyDO){
        
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
        
        options = String(options.dropLast())
        
        
        let  objSurveyQues = SurveyQuestionDO(questionId: questionId, questionText: questionText,questionType:questionType,questionNumber:questionNumber,isRequired: required,choices: options , skipLogicArray:skipLogicArray , isSkipLogic: isSkipLogic,getDescriptionAnswer: answer)
        
        
        let objectStruct:structSurveyQuestion = structSurveyQuestion(key: questionId, objectSurveyQuestion: objSurveyQues)
        
        
        objSurvey.surveyQuestionArray.append(objectStruct)
        
    }
    
    
    
}
