//
//  SubmitSurveyViewController.swift
//  EngageNYC
//
//  Created by MTX on 1/17/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class SubmitSurveyViewController: UIViewController {
    
    @IBOutlet weak var btnSurvey: UIButton!
    
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSelectClient: UIButton!
    @IBOutlet weak var signatureView: YPDrawSignatureView!
    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var btnAddNewClient: UIButton!
    
    @IBOutlet weak var lblSurveyName: UILabel!
    
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    var surveyObj:SurveyDO!
    var viewModel:SurveyViewModel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        
        Utility.makeButtonBorder(btn: btnAddNewClient)
    }
    
    func setUpView()
    {
        self.signatureView.layer.borderWidth = 1
        self.signatureView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        
        self.toolBarView.layer.borderWidth = 2
        self.toolBarView.layer.borderColor =  UIColor.clear.cgColor
        
        btnSelectClient.layer.cornerRadius = 7.0
        btnSelectClient.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        btnSelectClient.layer.borderWidth = 1.0
        btnSelectClient.clipsToBounds = true
        
        lblSurveyName.text = surveyObj.surveyName
        btnLogin.setTitle(canvasserTaskDataObject.userObj.userName, for: .normal)
        
        //if come from clientlisting show get clientId and clientname from there and show it here
        //if come from unitlisting first check whether it is selected if not then get it from database.
        
        if(surveyObj.clientId.isEmpty){
            btnSurvey.isEnabled = false
        }
        else if(surveyObj.clientId == noClientName.unknown.rawValue){
            btnSelectClient.setTitle(noClientName.unknown.rawValue, for: .normal)
            btnSurvey.isEnabled = true
        }
        else{
            
            btnSelectClient.setTitle(viewModel.getContactName(contactId: surveyObj.clientId), for: .normal)
            btnSurvey.isEnabled = true
        }
        
        
    }

    
    @IBAction func btnBackPress(_ sender: Any)
    {
        //handle SkipLogic
        if let objSurveyQues =  surveyObj.surveyQuestionArray[surveyObj.surveyQuestionArrayIndex].objectSurveyQuestion{
            
            if(surveyObj.skipLogicParentChildDict[(objSurveyQues.questionNumber)!] != nil){
                
                let arrayValue:[SkipLogic]  = surveyObj.skipLogicParentChildDict[objSurveyQues.questionNumber]!
                
                for object in arrayValue{
                    
                    if(surveyObj.surveyOutput[object.questionNumber] != nil){
                        let objectSurveyResult:SurveyResult =  surveyObj.surveyOutput[object.questionNumber]!
                        
                        //right now not handle multi select
                        if(objectSurveyResult.selectedAnswer == object.selectedAnswer){
                            
                            //skip question
                            
                            surveyObj.surveyQuestionArrayIndex = surveyObj.surveyQuestionArrayIndex - 1

                        }
                    }
                    
                }
                
            }
            
        }
        
        
        Utility.showPreviousQuestion(vctrl: self, surveyObj: surveyObj, canvasserTaskDataObject: canvasserTaskDataObject, viewModel: viewModel)
        
    }
    
    @IBAction func btnLoginUserNamePressed(_ sender: Any) {
        Utility.openNavigationItem(btnLoginUserName: self.btnLogin, vc: self)
    }
    
    @IBAction func btnSubmitSurveyPress(_ sender: Any) {
        
         self.submitSurvey()
         self.performSegue(withIdentifier: "UnwindBackFromSurveyIdentifier", sender: self)
         CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.UNITLISTING_SYNC.rawValue, sender: nil, userInfo: nil)
        
    }
    @IBAction func btnExitSurveyPressed(_ sender: Any) {
        
      
        Utility.exitFromSurvey(vctrl: self, surveyVM: viewModel, surveyObj: surveyObj,isSubmitSurvey: true)
        
    }
    
    @IBAction func btnSelectClientPressed(_ sender: Any) {
        
        Utility.showAllClientsOnSurvey(btnSelectedClientName: btnSelectClient, vc: self, surveyObj: surveyObj, viewModel: viewModel)
    }
    
    @IBAction func btnAddClientPressed(_ sender: Any) {
        
        if let clientInfoVC = ClientInfoStoryboard().instantiateViewController(withIdentifier: "ClientInfoViewController") as? ClientInfoViewController{
            
            clientInfoVC.showAddressScreen = false
            clientInfoVC.fromSubmitSurveyScreen = true
            
            clientInfoVC.canvasserTaskDataObject = canvasserTaskDataObject
            let navigationController = UINavigationController(rootViewController: clientInfoVC)
            navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
            self.present(navigationController, animated: true)
        }
        
    }
    
}

extension SubmitSurveyViewController{
    func submitSurvey(){
        
        if let signatureImage = self.signatureView.getSignature(10) {
            // Saving signatureImage from the line above to the Photo Roll.
            // The first time you do this, the app asks for access to your pictures.
            
            surveyObj.surveySign = Utility.convertImageToBase64(signatureImage)
            
            //print("base64String: \(base64String)")
            
            // let signImage = self.convertBase64ToImage(base64String)
            
            
            // UIImageWriteToSavedPhotosAlbum(signImage, nil, nil, nil)
            
            // Since the Signature is now saved to the Photo Roll, the View can be cleared anyway.
            self.signatureView.clear()
            
        }
        
        viewModel.submitSurvey(surveyObj: surveyObj, canvasserTaskDataObject: canvasserTaskDataObject)
        

    }
}

extension SubmitSurveyViewController:ListingPopoverDelegate{
    func selectedItem(withObj obj: ListingPopOverDO, selectedIndex index: Int, popOverType type: PopoverType) {
        if(type == .clientList){
            btnSelectClient.setTitle(obj.name, for: .normal)
            surveyObj.clientId = obj.id
            btnSurvey.isEnabled = true
        }
        else{
             Utility.selectedNavigationItem(obj: obj, vc: self,isFromSurveyScreen: true,isSubmitSurvey: true, canvasserTaskDataObject:canvasserTaskDataObject,surveyVM: viewModel,surveyObj: surveyObj)
        }
    }
}
