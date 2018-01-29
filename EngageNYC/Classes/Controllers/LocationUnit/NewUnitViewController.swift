//
//  NewUnitViewController.swift
//  EngageNYCDev
//
//  Created by Kamal on 10/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit
import Toast_Swift

enum virtualUnitEnum:String{
    case VUTrue = "true"
    case VUFalse = "false"
}


enum actionStatus:String{
    case create = "create"
    case edit = "edit"
    case no = ""
    case inProgressSurvey = "InProgress"
    case completeSurvey = "Complete"
    case temp = "Temp"
}
enum privateHomeEnum:String{
    case yes = "Yes"
    case no = "No"
}

class NewUnitDO{
    
    var unitName:String!
    var apartmentNumber:String!
    var unitNotes:String!
    var isPrivateHome:String!
    var isVirtualUnit:String!
    var actionStatus:String!
    
    var assignmentId:String!
    var locationId:String!
    var assignmentLocId:String!
    
    var syncDate:String!
    
    var iOSLocUnitId:String!
    var iOSAssignmentLocUnitId:String!
}

//protocol UpdateUnitListingDelegate {
//    func reloadUnitListing()
//}

class NewUnitViewController: UIViewController,UITextFieldDelegate {
    
    
    //    typealias typeCompletionHandler = () -> ()
    //    var completion : typeCompletionHandler = {}
    
    //var syncCompletion:(()->())?
    var completionHandler : ((_ childVC:NewUnitViewController) -> Void)?
    
    //var delegate : UpdateUnitListingDelegate?
    
    @IBOutlet weak var leftBarButton: UIButton!
    @IBOutlet weak var rightBarButton: UIButton!
    
    @IBOutlet weak var apartmentView: UIView!
    
    
    @IBOutlet weak var txtUnit: UITextField!
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var switchPrivateHome: UISwitch!
    
    
    var privateHome:String = privateHomeEnum.no.rawValue
    var unitName:String = ""
    var viewModel:NewUnitViewModel!
    
    var isFromUnitListing:Bool = false
    var canvassserTaskDataObject:CanvasserTaskDataObject!
    var locUnitId:String!
    var assignmentLocUnitId:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.bindView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true;
    }
    
    func setUpUI(){
        txtNotes.layer.cornerRadius = 5
        txtNotes.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        txtNotes.layer.borderWidth = 0.5
        txtNotes.clipsToBounds = true
        txtNotes.textColor = UIColor.black
        
        txtUnit.delegate = self
        
        if(isFromUnitListing == true){
            if let image = UIImage(named: "CloseBtn.png") {
                leftBarButton.setImage(image, for: .normal)
            }
            
        }
    }
    
    @IBAction func btnLeftPressed(_ sender: Any) {
        
        self.closePopUp()
        
    }
    
    func closePopUp(){
        
        let alertCtrl = Alert.showUIAlert(title: "Message", message: Static.exitMessage, vc: self)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel)
        { action -> Void in
            
            
        }
        
        alertCtrl.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            
            if(self.isFromUnitListing == true){
                self.dismiss(animated: true, completion: nil)
            }
            else{
                self.navigationController?.popViewController(animated: true)
            }
        }
        alertCtrl.addAction(okAction)
    }
    
    
    @IBAction func btnRightPressed(_ sender: Any) {
        
        var unitNotes = ""
        
        if(validateUnitInfo()){
            
            if let notesVal = txtNotes.text{
                
                unitNotes = notesVal

            }
            
            let genLocUnitId = UUID().uuidString
            let genAssignmentLocUnitId = UUID().uuidString
            
            let objNewUnit = NewUnitDO()
            objNewUnit.assignmentId = canvassserTaskDataObject.assignmentObj.assignmentId
            objNewUnit.locationId = canvassserTaskDataObject.locationObj.objMapLocation.locId
            objNewUnit.assignmentLocId = canvassserTaskDataObject.locationObj.objMapLocation.assignmentLocId
            
            objNewUnit.unitName = txtUnit.text
            objNewUnit.unitNotes = unitNotes
            objNewUnit.isVirtualUnit = virtualUnitEnum.VUFalse.rawValue
            objNewUnit.isPrivateHome = privateHome
            objNewUnit.actionStatus = actionStatus.create.rawValue
            objNewUnit.syncDate = ""
            
            objNewUnit.iOSLocUnitId = genLocUnitId
            objNewUnit.iOSAssignmentLocUnitId = genAssignmentLocUnitId
            
            
            viewModel.saveNewUnit(objNewUnitDO: objNewUnit)
            
            
            self.view.makeToast("New Unit has been created successfully.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
            
                //Notification Center:- reload unitlisting
                CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.UNITLISTING_SYNC.rawValue, sender: nil, userInfo: nil)
                
                
                if(self.isFromUnitListing == true){
                    self.dismiss(animated: true, completion: nil)
                }
                else{
                    self.locUnitId = genLocUnitId
                    self.assignmentLocUnitId = genLocUnitId
                    self.completionHandler?(self)
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
            
            
            //Delegate
            //            if delegate != nil{
            //                delegate?.reloadUnitListing()
            //            }
            
            //Completion block
            //self.completionHandler(self)
        }
        
        
       
        
    }
    
    
    @IBAction func switchPrivateHomePressed(_ sender: Any) {
        
        if((sender as AnyObject).isOn == true){
            privateHome = privateHomeEnum.yes.rawValue
            txtUnit.text = "PH/Main"
            txtUnit.isEnabled = false
            
            
        }
        else{
            privateHome = privateHomeEnum.no.rawValue
            txtUnit.text = unitName
            txtUnit.isEnabled = true
        }
        
    }
    
    func validateUnitInfo()->Bool{
        
        rightBarButton.isEnabled = false
        
        
        var unitName = ""
        
        if let unitVal = txtUnit.text{
            
            unitName = unitVal
            
        }
        
        if(unitName.isEmpty){
            
            apartmentView.shake()
            
            self.view.makeToast("Please Enter Unit Number.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                
                self.rightBarButton.isEnabled = true
                
            }
            
            
            return false
            
        }
        
        
        unitName = unitName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        
        if let locationUnitRes = self.viewModel.getAllLocationUnits(assignmentId: canvassserTaskDataObject.assignmentObj.assignmentId,assignmentLocId: canvassserTaskDataObject.locationObj.objMapLocation.assignmentLocId){
            
            if(locationUnitRes.count > 0){
                
                for locationUnitData in locationUnitRes
                {
                    if(locationUnitData.unitName?.lowercased() == unitName.lowercased()){
                        
                        apartmentView.shake()
                        
                        self.view.makeToast("This Unit Number already exist.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                            
                            self.rightBarButton.isEnabled = true
                            
                        }
                        
                        
                        return false
                    }
                }
                
                
            }
        }
        
        
        return true
        
        
        
    }
    
}

extension NewUnitViewController{
    func bindView(){
        self.viewModel = NewUnitViewModel.getViewModel()
    }
}

extension NewUnitViewController{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        let aSet =  NSCharacterSet(charactersIn:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789 ").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        
        let currentCharacterCount = txtUnit.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        if(newLength > 10){
            return false
        }
        
        unitName = txtUnit.text! + string
        
        return string == numberFiltered
    }
    
}
