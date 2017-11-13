//
//  SubmitSurveyViewController.swift
//  MTXGIS
//
//  Created by Kamal on 23/03/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit
import Toast_Swift

class SubmitSurveyViewController: UIViewController {
    
    @IBOutlet weak var signatureView: YPDrawSignatureView!
    
    var surveyRes : [String:String] = [:]
    var isexitSurvey:Bool = false
    
    // @IBOutlet weak var submitBtn: UIButton!
    
    @IBOutlet weak var toolBarView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signatureView.layer.borderWidth = 1
        self.signatureView.layer.borderColor = UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).cgColor
        
        self.toolBarView.layer.borderWidth = 2
        self.toolBarView.layer.borderColor =  UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).cgColor
        
        // submitBtn.layer.cornerRadius = 5
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

        
       // self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.navigationItem.title = "Ready to Submit?"
        
        let leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(SubmitSurveyViewController.backFromSubmitSurvey))
        
       //  let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ExitSurvey.png"), style: .plain, target: self, action: #selector(SubmitSurveyViewController.backFromSubmitSurvey))
        
        self.navigationItem.leftBarButtonItem  = leftBarButtonItem

        
        let rightBarButtonItem = UIBarButtonItem(title: "Exit Survey", style: .plain, target: self, action: #selector(SubmitSurveyViewController.exitFromSurvey))
        
        self.navigationItem.rightBarButtonItem  = rightBarButtonItem
        
        
    }
    
    func backFromSubmitSurvey(){
        
        //handle SkipLogic
        let objSurveyQues =  Utilities.surveyQuestionArray[Utilities.surveyQuestionArrayIndex].objectSurveyQuestion
        
        
        if(Utilities.skipLogicParentChildDict[(objSurveyQues?.questionNumber)!] != nil){
            
            let arrayValue:[SkipLogic]  = Utilities.skipLogicParentChildDict[objSurveyQues!.questionNumber]!
            
            for object in arrayValue{
                
                if(Utilities.SurveyOutput[object.questionNumber] != nil){
                    let objectSurveyResult:SurveyResult =  Utilities.SurveyOutput[object.questionNumber]!
                    
                    //right now not handle multi select
                    if(objectSurveyResult.selectedAnswer == object.selectedAnswer){
                        
                        //skip question
                        
                        Utilities.surveyQuestionArrayIndex = Utilities.surveyQuestionArrayIndex - 1
                        
                        
                        
                    }
                }
                
            }
            
        }
        
         SurveyUtility.goToPreviousQuestion(sourceVC:self)
        
    }
    
    func exitFromSurvey()
    {
        let alertCtrl = Alert.showUIAlert(title: "Message", message: "Are you sure you want to exit from survey?", vc: self)

        
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel) { action -> Void in
           
        }
        alertCtrl.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            
            Utilities.isExitFromSurvey = true
            Utilities.isSubmitSurvey = false
            
            Utilities.surveyQuestionArrayIndex = Utilities.surveyQuestionArrayIndex + 1

            self.performSegue(withIdentifier: "UnwindBackFromSurveyIdentifier", sender: self)
            
        }
        alertCtrl.addAction(okAction)
        
        
       
        
    }
    
    
    @IBAction func submitSurvey(_ sender: Any) {
        //self.isexitSurvey = false
        Utilities.isExitFromSurvey = false
        self.performSegue(withIdentifier: "UnwindBackFromSurveyIdentifier", sender: self)
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        
//        
//        //handle SkipLogic
//        let objSurveyQues =  Utilities.surveyQuestionArray[Utilities.surveyQuestionArrayIndex].objectSurveyQuestion
//        
//        
//        if(Utilities.skipLogicParentChildDict[(objSurveyQues?.questionNumber)!] != nil){
//            
//            let arrayValue:[SkipLogic]  = Utilities.skipLogicParentChildDict[objSurveyQues!.questionNumber]!
//            
//            for object in arrayValue{
//                
//                if(Utilities.SurveyOutput[object.questionNumber] != nil){
//                    let objectSurveyResult:SurveyResult =  Utilities.SurveyOutput[object.questionNumber]!
//                    
//                    //right now not handle multi select
//                    if(objectSurveyResult.selectedAnswer == object.selectedAnswer){
//                        
//                        //skip question
//                        
//                        Utilities.surveyQuestionArrayIndex = Utilities.surveyQuestionArrayIndex - 1
//                        
//                        
//                        
//                    }
//                }
//                
//            }
//            
//        }
//        
//    }
    
    
    
    
    var questionArray = [[String: String]]()
    
    var surveyResponseStr:String = ""
    var formatString:String = ""
    var responseDict : [String:AnyObject] = [:]
    
    
    func prepareSurveyData(){
        
        //"{\"surveyId\":\"a0G35000000kQID\",\"response\":[{\"answer\":\"encrypt\",\"questionId\":\"a0F35000000EqIQ\",\"description\":\"Testing desc\"}]}"
        
        
        
        
        
        // print(Utilities.SurveyOutput)
        
        //"contactId" + ":" + "" + caseresponse
        
        // "key" + ":" + "value" + ","
        
        var questionResponseDict:[String:String] = [:]
        
        for (_, value) in Utilities.SurveyOutput {
            
            questionResponseDict["questionId"] = value.questionId!
            questionResponseDict["description"] = value.getDescription!
            
            if(value.questionType == "Single Select" || value.questionType == "Text Area"){
                
                questionResponseDict["answer"] = value.selectedAnswer!
            }
            else if(value.questionType == "Multi Select"){
                
                let multioption = value.multiOption.joined(separator: ";")
                
                questionResponseDict["answer"] = multioption
            }
            
            questionArray.append(questionResponseDict)
            
        }
        
        
        //        responseDict["surveyId"] = SalesforceConnection.surveyId as AnyObject?
        //        responseDict["response"] = questionArray as AnyObject?
        //
        //
        //        formatString = Utilities.jsonToString(json: responseDict as AnyObject)!
        //
        //        print(formatString)
        //
        //        surveyResponseStr = try! formatString.aesEncrypt(SalesforceConfig.key, iv: SalesforceConfig.iv)
        //
        //
        //
        //        print(surveyResponseStr)
        //
        
         let surveyResResultsArr = ManageCoreData.fetchData(salesforceEntityName: "SurveyResponse",predicateFormat: "assignmentLocUnitId == %@" ,predicateValue: SalesforceConnection.assignmentLocationUnitId, isPredicate:true) as! [SurveyResponse]
        
        if(surveyResResultsArr.count>0){
            updateSurveyToCoreData()
        }
        else{
             saveSurveyToCoreData()
        }
        
       
        
        //fetchSurveyFromCoreData()
        
        Utilities.isSubmitSurvey = true
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
        
        
        // sendSurveyToSalesforce()
        
        
        /*
         formatString = "{\"surveyId\":\"\(SalesforceConnection.surveyId)\",\"response\":["
         
         for (key, value) in Utilities.SurveyOutput {
         if(value.questionType == "Single Select" || value.questionType == "Text Area"){
         formatString =  formatString + "{\"questionId\":\"\(value.questionId!)\",\"answer\":\"\(value.selectedAnswer!)\",\"description\":\"\(value.getDescription!)\"}" + ","
         }
         else if(value.questionType == "Multi Select"){
         
         let multioption = value.multiOption.joined(separator: ";")
         
         formatString =  formatString + "{\"questionId\":\"\(value.questionId!)\",\"answer\":\"\(multioption)\",\"description\":\"\(value.getDescription!)\"}" + ","
         }
         
         }
         
         
         
         if(formatString.isEmpty){
         formatString = ""
         }
         else{
         formatString =  formatString.substring(to: formatString.characters.index(before: formatString.endIndex)) + "]}"
         }
         
         */
        
        
        
    }
    
    func saveSurveyToCoreData(){
        let surveyResponseObject = SurveyResponse(context: context)
        
        surveyResponseObject.surveyId = SalesforceConnection.surveyId
        
        surveyResponseObject.unitId = SalesforceConnection.unitId
        surveyResponseObject.assignmentLocUnitId = SalesforceConnection.assignmentLocationUnitId
        
        surveyResponseObject.actionStatus = Utilities.completeSurvey
        surveyResponseObject.surveySignature = base64String
       
        
        surveyResponseObject.contactId = SalesforceConfig.currentUserContactId
        surveyResponseObject.userId = SalesforceConnection.salesforceUserId
        
        if(SalesforceConnection.selectedTenantForSurvey == "empty"){
            surveyResponseObject.clientId = ""
        }
        else{
            surveyResponseObject.clientId = SalesforceConnection.selectedTenantForSurvey
        }
        
        surveyResponseObject.surveyQuestionRes = questionArray as NSObject?
        
        surveyResponseObject.questionAnswers = Utilities.SurveyOutput as NSObject?
        
        surveyResponseObject.surveyQuestionIndex = 0
        
        appDelegate.saveContext()
        
    }
    
    func updateSurveyToCoreData(){
        
        var updateObjectDic:[String:AnyObject] = [:]
        
         updateObjectDic["surveyId"] = SalesforceConnection.surveyId as AnyObject?
        
        //  updateObjectDic["surveyQuestionIndex"] = Int64(Utilities.surveyQuestionArrayIndex) as AnyObject?
        
        
        
        
        updateObjectDic["surveyQuestionRes"] = questionArray as NSObject?
        
        updateObjectDic["actionStatus"] = Utilities.completeSurvey as AnyObject?
        updateObjectDic["surveySignature"] = base64String as AnyObject?
        
        updateObjectDic["contactId"] = SalesforceConfig.currentUserContactId as AnyObject?
        updateObjectDic["userId"] = SalesforceConnection.salesforceUserId as AnyObject?
        
        if(SalesforceConnection.selectedTenantForSurvey == "empty"){
            updateObjectDic["clientId"] = "" as AnyObject?
        }
        else{
            updateObjectDic["clientId"] = SalesforceConnection.selectedTenantForSurvey as AnyObject?
        }
        
        
        updateObjectDic["questionAnswers"] = Utilities.SurveyOutput as NSObject?
        
        
        ManageCoreData.updateAnyObjectRecord(salesforceEntityName: "SurveyResponse", updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocUnitId == %@", predicateValue: SalesforceConnection.assignmentLocationUnitId,isPredicate: true)
        
        
    }
    
        
    
    
    
    
    
    
    
    
    
    var base64String:String = ""
    
    override func prepare(for segue: UIStoryboardSegue!, sender: Any!) {
        
        
        
        if(segue.identifier == "UnwindBackFromSurveyIdentifier"){
            if let signatureImage = self.signatureView.getSignature(10) {
                // Saving signatureImage from the line above to the Photo Roll.
                // The first time you do this, the app asks for access to your pictures.
                
                base64String = self.convertImageToBase64(signatureImage)
                
                //print("base64String: \(base64String)")
                
                // let signImage = self.convertBase64ToImage(base64String)
                
                
                // UIImageWriteToSavedPhotosAlbum(signImage, nil, nil, nil)
                
                // Since the Signature is now saved to the Photo Roll, the View can be cleared anyway.
                self.signatureView.clear()
                
            }
            
            if(Utilities.isExitFromSurvey == false){
                prepareSurveyData()
                
            }
            else{
                
                SurveyUtility.saveInProgressSurveyToCoreData(surveyStatus: Utilities.inProgressSurvey)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)

            }
            
            
            
        }
        
        
    }
    
    
    
    
    // convert images into base64 and keep them into string
    
    func convertImageToBase64(_ image: UIImage) -> String {
        
        let imageData = UIImagePNGRepresentation(image)
        let base64String = imageData!.base64EncodedString(options: [])
        return base64String
        
    }// end convertImageToBase64
    
    
    
    // convert images into base64 and keep them into string
    
    func convertBase64ToImage(_ base64String: String) -> UIImage {
        
        let decodedData = Data(base64Encoded: base64String, options: NSData.Base64DecodingOptions(rawValue: 0) )
        
        let decodedimage = UIImage(data: decodedData!)
        
        return decodedimage!
        
    }// end convertBase64ToImage
    
    
    
    
    
}
