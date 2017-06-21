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
        
         self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.navigationItem.title = "Ready to Submit?"
        
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ExitSurvey.png"), style: .plain, target: self, action: #selector(SubmitSurveyViewController.exitFromSurvey))
        //#selector(self.exitFromSurvey(_:))
        self.navigationItem.rightBarButtonItem  = rightBarButtonItem
        
        
    }
    
    func exitFromSurvey()  {
        
        let alertController = UIAlertController(title: "Message", message: "Are you sure want to exit from survey", preferredStyle: .alert)
        
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Do some stuff
        }
        alertController.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
            self.isexitSurvey = true
            self.performSegue(withIdentifier: "UnwindBackFromSurveyIdentifier", sender: self)
            //Do some other stuff
        }
        alertController.addAction(okAction)
        
        
        self.present(alertController, animated: true, completion: nil)
        
        
        
    }

    
    @IBAction func submitSurvey(_ sender: Any) {
        self.isexitSurvey = false
        self.performSegue(withIdentifier: "UnwindBackFromSurveyIdentifier", sender: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        
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
        
        
        
        
           // Utilities.currentSurveyPage = Utilities.surveyQuestionArrayIndex
            
            //Utilities.surveyQuestionArrayIndex = Utilities.surveyQuestionArrayIndex - 1
    }
    
    
    
    var surveyResponseStr:String = ""
    
    func prepareSurveyData(){
        var formatString:String = ""
        
        print(Utilities.SurveyOutput)
        
        //"{\"surveyId\":\"a0G35000000kQID\",\"response\":[{\"answer\":\"encrypt\",\"questionId\":\"a0F35000000EqIQ\",\"description\":\"Testing desc\"}]}"
        
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
        
        surveyResponseStr = try! formatString.aesEncrypt(SalesforceConfig.key, iv: SalesforceConfig.iv)
        
        
        
        
        
       // surveyRes["surveyId"] = Utilities.SurveyId
        //surveyRes["unitId"] = Utilities.currentUnitId
       
        

        print(surveyResponseStr)
        sendSurveyToSalesforce()
        
    }
    
    
    func sendSurveyToSalesforce(){
        
        let surveyResponseObject = SurveyResponse(context: context)
        surveyResponseObject.surveyId = SalesforceConnection.surveyId
        surveyResponseObject.assignmentId = SalesforceConnection.assignmentId
        surveyResponseObject.unitId = SalesforceConnection.unitId
        surveyResponseObject.locationId = SalesforceConnection.locationId
        surveyResponseObject.surveyResponse = surveyResponseStr
        
        appDelegate.saveContext()
        
        
        
        SVProgressHUD.show(withStatus: "Submit survey response..", maskType: SVProgressHUDMaskType.gradient)
        
        SalesforceConnection.loginToSalesforce(companyName: SalesforceConnection.companyName) { response in
            
         if(response)
            {
                
                self.surveyRes["surveyResponseFile"] = self.surveyResponseStr
                
                SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.submitSurveyResponse, params: self.surveyRes){ jsonData in
                    
                    
                    
                        print(jsonData)
                        
                        SVProgressHUD.dismiss()
                    
                        Utilities.isSubmitSurvey = true

                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
                        
                        
                        // JLToast.makeText("Survey Response has been submitted successfully.", duration: 3).show()
                        
                        
                    
                    
                    
                }
            }
        }
        
       /* Utilities.SubmitSurveyResponse(false,successHandler:{
            
            (isSurveySuccess) in
            
            self.view.makeToast("Survey submitted successfully", duration: 5.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                if didTap {
                    print("completion from tap")
                } else {
                    print("completion without tap")
                }
            }
            
            
            
            
        })
 
 */
        
        
        
    /*    Utilities.saveResponseDataJSON(surveyRes,key: "SurveyResponse")
        
        if Reachability.isConnectedToNetwork() == true {
            
            //call to SalesforceRest api method
            Utilities.SubmitSurveyResponse(false,successHandler:{
                
                (isSurveySuccess) in
                
                self.view.makeToast("Survey submitted successfully", duration: 5.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    if didTap {
                        print("completion from tap")
                    } else {
                        print("completion without tap")
                    }
                }
                

                
                
            })
            
            
        }
        
        else{
            
            Utilities.ClearResponseCache()
            
            self.view.makeToast("No internet", duration: 5.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                if didTap {
                    print("completion from tap")
                } else {
                    print("completion without tap")
                }
            }
        }
        
       
        */
        
        
    }
    
    

    func SubmitSurveyResponse(_ fromSurveyView:Bool = false){
        
       
        
   /*     let surveyRes = Utilities.loadResponseDataJSON("SurveyResponse")
        
    
        Utilities.LoginToSurveySalesforce({
            
            (accessToken) in
            
            //Utilities.GetAndSaveDataFromSalesforce(accessToken, Url: Utilities.submitSurveyRes, HttpMethod: "POST", isSubmitResponse: true, successHandler: {
            
            Utilities.GetAndSaveDataFromSalesforce(accessToken, Url: Utilities.submitSurveyRes, Params: surveyRes as [String : AnyObject]?, HttpMethod: "POST", isSubmitResponse: true, successHandler: {
                
                (jsonSurveyResponse) in
                
                //var res = jsonSurveyResponse as! [String:String]
                
                Utilities.currentUnitId = nil
                Utilities.isSubmitSurvey = false
                
                //Delete SurveyResponse data from cache
                Utilities.DeletJSONData("SurveyResponse")
                
                
              /*
                 Utilities.GetAndSaveDataFromSalesforce(accessToken, Url: Utilities.getAllUnitsUrl, HttpMethod: "GET", successHandler: {
                    (jsonUnits) in
                    
                    //Delete SurveyResponse data from cache
                    Utilities.DeletJSONData("Units")
                    
                    
                    //Save Units Data
                    Utilities.saveJSON(jsonUnits as Data, key: "Units")
                    
                    
                    //SVProgressHUD.dismiss()
                    
                    
                    if(fromSurveyView == true){
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                    
                    
                    
                })
                
                */
                
              
            })
            
            
            
        })
        
        
        */
        
    }
    
    
    

    
    

     override func prepare(for segue: UIStoryboardSegue!, sender: Any!) {
     
        if(segue.identifier == "UnwindBackFromSurveyIdentifier"){
            if let signatureImage = self.signatureView.getSignature(10) {
                // Saving signatureImage from the line above to the Photo Roll.
                // The first time you do this, the app asks for access to your pictures.
            
             /*   let base64String = self.convertImageToBase64(signatureImage)
            
                let signImage = self.convertBase64ToImage(base64String)
            
                print("base64String: \(base64String)")
                UIImageWriteToSavedPhotosAlbum(signImage, nil, nil, nil)
            
                // Since the Signature is now saved to the Photo Roll, the View can be cleared anyway.
                self.signatureView.clear()
 */
        }
        
            if(isexitSurvey==false){
                prepareSurveyData()
                
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
