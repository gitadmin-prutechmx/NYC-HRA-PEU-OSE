//
//  Utility.swift
//  EngageNYC
//
//  Created by Kamal on 12/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation
import SwiftMessages
import Zip
import SalesforceSDKCore

class Utility{
    
    class func convertDictToArray(orderedSectionFieldDict:[Int: [String:[MetadataConfigDO]]])->[MetadataConfigObjects]{
        
        var metadataConfigArray = [MetadataConfigObjects]()
        
        
        let orderedKeys = orderedSectionFieldDict.keys.sorted()
        
        for orderedKey in orderedKeys {
            
            for (key, value) in orderedSectionFieldDict[orderedKey]! {
                metadataConfigArray.append(MetadataConfigObjects(sectionName: key, sectionObjects: value))
            }
        }
        
        return metadataConfigArray
        
    }
    
    
    class func showInTake(vc:UIViewController,canvasserTaskDataObject:CanvasserTaskDataObject){
        
        if let inTakeVC = IntakeStoryboard().instantiateViewController(withIdentifier: "IntakeViewController") as? IntakeViewController{
            
            inTakeVC.canvasserTaskDataObject = canvasserTaskDataObject
            
            let navigationController = UINavigationController(rootViewController: inTakeVC)
            navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
            vc.present(navigationController, animated: true)
            
        }
        
    }
    
    
    class func switchToNewSurvey(surveyObj:SurveyDO,vctrl:UIViewController,listingPopOverObj:ListingPopOverDO,btnSurveySelect:UIButton,viewModel:SurveyViewModel,canvasserTaskDataObject:CanvasserTaskDataObject){
        
        if(surveyObj.surveyOutput.count > 0 ){
            
            let alertCtrl = Alert.showUIAlert(title: "Message", message: "Are you sure you want to switch survey? Switch to new survey will result to loss of your existing survey data.", vc: vctrl)
            
            
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel) { action -> Void in
                //Do some stuff
            }
            alertCtrl.addAction(cancelAction)
            
            let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
                
                //delete surveyresponse
                viewModel.deleteSurveyResponse(assignmentLocUnitId: surveyObj.assignmentLocUnitId)
                
                initializeSurvey(surveyVM: viewModel, canvasserTaskDataObject: canvasserTaskDataObject, vctrl: vctrl,surveyId: listingPopOverObj.id,contactId: surveyObj.clientId)
                
            }
            alertCtrl.addAction(okAction)
            
        }
            
        else if(listingPopOverObj.id == surveyObj.surveyId){
            //nothing do
        }
            
        else{
            
            initializeSurvey(surveyVM: viewModel, canvasserTaskDataObject: canvasserTaskDataObject, vctrl: vctrl,surveyId: listingPopOverObj.id, contactId: surveyObj.clientId)
        }
        
        
        
    }
    
    
    
    class func initializeSurvey(surveyVM:SurveyViewModel,canvasserTaskDataObject:CanvasserTaskDataObject,vctrl:UIViewController,surveyId:String?=nil,contactId:String,isClientInTake:Bool=false){
        
        var surveyObj = surveyVM.isSurveyTaken(assignmentLocUnitId: canvasserTaskDataObject.locationUnitObj.assignmentLocUnitId)
        
        
        
        if surveyObj == nil{
            if surveyId != nil{
                surveyObj = surveyVM.getSurvey(assignmentId: canvasserTaskDataObject.assignmentObj.assignmentId, surveyId: surveyId!)
            }
            else{
                surveyObj = surveyVM.getDefaultSurvey(assignmentId: canvasserTaskDataObject.assignmentObj.assignmentId)
                if(surveyObj == nil){
                    
                    vctrl.view.makeToast("There is no default survey on this assignment.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                      
                    }
                    
                    
                }
                
            }
        }
        
        if let objSurvey = surveyObj{
            
            if let surveyObject = surveyVM.parseSurveyQuestion(objSurvey: objSurvey){
                
                if(surveyObject.totalSurveyQuestions > 0){
                    
                    surveyObject.assignmentLocUnitId = canvasserTaskDataObject.locationUnitObj.assignmentLocUnitId
                    surveyObject.canvasserContactId = canvasserTaskDataObject.contactObj.contactId
                    surveyObject.assignmentId = canvasserTaskDataObject.assignmentObj.assignmentId
                    surveyObj?.clientId = contactId
                    surveyObj?.canvasserContactId = canvasserTaskDataObject.userObj.contactId
                    surveyObj?.isClientInTake = isClientInTake
                    //surveyObject.locationUnitVC = vctrl as! LocationUnitViewController
                    
                    Utility.showSurvey(surveyObject: surveyObject, canvasserTaskDataObject: canvasserTaskDataObject, surveyVM: surveyVM, vctrl: vctrl)
                    
                }
                else{
                    showSwiftErrorMessage(error: "There are no questions associated with the survey:- \(surveyObject.surveyName!)",title: "Message")
                }
                
            }
            
        }
       
        
        
    }
    
    class func showSurvey(surveyObject:SurveyDO,canvasserTaskDataObject:CanvasserTaskDataObject,surveyVM:SurveyViewModel,vctrl:UIViewController){
        
        surveyObject.answerSurvey = ""
        
        if(surveyObject.surveyQuestionArrayIndex == surveyObject.totalSurveyQuestions){
            
            surveyObject.surveyQuestionArrayIndex = surveyObject.surveyQuestionArrayIndex - 1
            
            showSubmitSurveyVC(vc: vctrl, surveyObj: surveyObject, canvasserTaskDataObject: canvasserTaskDataObject, surveyVM: surveyVM)
            
        }
            
        else{
            
            surveyObject.currentSurveyPage = surveyObject.surveyQuestionArrayIndex + 1 //Not use this time
            
            
            if(surveyObject.surveyQuestionArrayIndex > surveyObject.totalSurveyQuestions){
                surveyObject.surveyQuestionArrayIndex = surveyObject.surveyQuestionArrayIndex - 1
            }
            
            if let objSurveyQues =  surveyObject.surveyQuestionArray[surveyObject.surveyQuestionArrayIndex].objectSurveyQuestion{
                
                if(objSurveyQues.questionType == "Single Select"){
                    
                    showSurveyRadioOptionVC(vc: vctrl, surveyObj: surveyObject, canvasserTaskDataObject: canvasserTaskDataObject, surveyVM: surveyVM, subType: kCATransitionFromRight)
                    
                }
                else if(objSurveyQues.questionType == "Multi Select"){
                    
                    showSurveyMultiOptionVC(vc: vctrl, surveyObj: surveyObject, canvasserTaskDataObject: canvasserTaskDataObject, surveyVM: surveyVM, subType: kCATransitionFromRight)
                    
                    
                }
                else if(objSurveyQues.questionType == "Text Area"){
                    
                    showSurveyTextVC(vc: vctrl, surveyObj: surveyObject, canvasserTaskDataObject: canvasserTaskDataObject, surveyVM: surveyVM, subType: kCATransitionFromRight)
                    
                }
                
            }
            
            
        }
        
        
    }
    
    
    
    class func surveyPageControl(pageControl:UIPageControl,surveyObj:SurveyDO){
        
        pageControl.numberOfPages = surveyObj.surveyQuestionArray.count
        
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        
        pageControl.currentPage = surveyObj.surveyQuestionArrayIndex
        
    }
    
    class func exitFromSurvey(vctrl:UIViewController,surveyVM:SurveyViewModel,surveyObj:SurveyDO,isSubmitSurvey:Bool?=false,isShowDashboard:Bool?=false){
        
        let alertCtrl = Alert.showUIAlert(title: "Message", message: "Are you sure you want to exit from survey?", vc: vctrl)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel) { action -> Void in
            
        }
        alertCtrl.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            
            updateSurveyofUnit(surveyVM: surveyVM, surveyObj: surveyObj,isSubmitSurvey: isSubmitSurvey)
            
            if(isShowDashboard!){
                vctrl.performSegue(withIdentifier: "UnwindBackToDashboardIdentifier", sender: self)
               
            }
            else{
                
                vctrl.performSegue(withIdentifier: "UnwindBackFromSurveyIdentifier", sender: self)
                
                CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.UNITLISTING_SYNC.rawValue, sender: nil, userInfo: nil)
            }
            
        }
        alertCtrl.addAction(okAction)
        
        
    }
    
    class func updateSurveyofUnit(surveyVM:SurveyViewModel,surveyObj:SurveyDO,isSubmitSurvey:Bool?=false){
        
        if(isSubmitSurvey)!{
            surveyObj.surveyQuestionArrayIndex = surveyObj.surveyQuestionArrayIndex + 1
        }
        
        surveyVM.saveInProgressSurvey(surveyObj: surveyObj)
        
        
    }
    
    class func deleteSkipSurveyData(startingIndex:Int,count:Int,objSurvey:SurveyDO)-> SurveyDO{
        
        for questionIndex in startingIndex...count {
            
            //Clear data which questions skipped
            let objTempSurveyQues =  objSurvey.surveyQuestionArray[questionIndex].objectSurveyQuestion
            
            if(objSurvey.surveyOutput[(objTempSurveyQues?.questionNumber)!] != nil){
                
                //delete data from dictionary
                objSurvey.surveyOutput.removeValue(forKey: (objTempSurveyQues?.questionNumber)!)
            }
            
            
        }
        
        return objSurvey
        
        
    }
    
    
    
    
    
    
    
    
    class func isiOSGeneratedId(generatedId:String)->NSUUID?{
        return NSUUID(uuidString: generatedId)
    }
    
    
    class func isValidEmail(str:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: str)
    }
    
    class func jsonToString(json: AnyObject)->String?{
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be
            return convertedString!
            
        } catch let myJSONError {
            print(myJSONError)
        }
        
        return nil
        
    }
    
    
    class func convertToJSON(text: String) ->  [String: Any]? {
        
        if let data = text.data(using: .utf8) {
            
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
            } catch {
                
                print(error.localizedDescription)
                
            }
            
        }
        
        return nil
        
    }
    
    class func UnzipFile(){
        
        do {
            
            
            let mapDataPath = Bundle.main.path(forResource: "MapData", ofType: "zip")
            let mapLayerPath = "\(String(describing: mapDataPath))/MapData/NewYorkLayers.geodatabase"
            
            let filemanager = FileManager.default
            
            if !(filemanager.fileExists(atPath: mapLayerPath)) {
                
                let unZipFilePath = try Zip.quickUnzipFile(URL(string: mapDataPath!)!) // Unzip
                print(unZipFilePath)
            }
        }
        catch {
            showSwiftErrorMessage(error: "Something went wrong while unzip geodatabase.")
        }
        
        
    }
    
    class func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
   
    
    
    class func getEventFormattedAddress(eventObj:Events)->String{
        
        let streetNum = eventObj.streetNum ?? ""
        let streetName = eventObj.streetName ?? ""
        let borough = eventObj.borough ?? ""
        let zip = eventObj.zip ?? ""
        
        if(streetNum.isEmpty && streetName.isEmpty && borough.isEmpty && zip.isEmpty){
            return ""
        }
        
        return "\(streetNum) \(streetName), \(borough),\(zip)"
        
    }
    
    class func switchBetweenViewControllers(senderVC: UIViewController, fromVC : UIViewController, toVC: UIViewController){
        let newVC = toVC
        let oldVC = fromVC
        
        oldVC.willMove(toParentViewController: nil)
        senderVC.addChildViewController(newVC)
        newVC.view.frame = oldVC.view.frame
        senderVC.transition(from: oldVC, to: newVC, duration: 0.25, options: .transitionCrossDissolve, animations: {
            //nothing
        }) { (finished) in
            oldVC.removeFromParentViewController()
            newVC.didMove(toParentViewController: senderVC)
        }
    }
    
    class func showSwiftErrorMessage(error:String,title:String? = "Error"){
        
        let view: MessageView
        
        view = try! SwiftMessages.viewFromNib()
        
        view.configureContent(title: title, body: error, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: "Dismiss", buttonTapHandler: { _ in SwiftMessages.hide() })
        
         let iconStyle: IconStyle
        
        iconStyle = .light
        
        view.configureTheme(backgroundColor: UIColor.init(red: 76.0/255.0, green: 76.0/255.0, blue: 76.0/255.0, alpha: 1.0), foregroundColor: UIColor.white, iconImage: nil, iconText: "")
        
        
        view.configureDropShadow()
        
        var config = SwiftMessages.defaultConfig
        
        config.duration = .seconds(seconds: 5)
        
        config.dimMode = .gray(interactive: true)
        
        config.shouldAutorotate = true
        
        config.interactiveHide = false
        
        // Show
        SwiftMessages.show(config: config, view: view)
    }
    
    class func showAllClientsOnSurvey(btnSelectedClientName:UIButton, vc:UIViewController,surveyObj:SurveyDO,viewModel:SurveyViewModel){
        
        if let popoverContent = ListingPopOverStoryboard().instantiateViewController(withIdentifier: "ListingPopoverTableViewController") as? ListingPopoverTableViewController{
            popoverContent.modalPresentationStyle = .popover
            popoverContent.popoverPresentationController?.sourceView = btnSelectedClientName
            popoverContent.popoverPresentationController?.sourceRect = btnSelectedClientName.bounds
            popoverContent.type = .clientList
            
            //popoverContent.iOSselectedId = surveyObj.clientId
            popoverContent.selectedId = surveyObj.clientId
            
            popoverContent.arrList = viewModel.getAllContactsOnUnit(assignmentLocUnitId: surveyObj.assignmentLocUnitId)
            popoverContent.delegate = vc as! ListingPopoverDelegate
            vc.present(popoverContent, animated: true, completion: nil)
        }
        
    }
    
    class func showAllSurveyOnAssignment(btnSelectedSurveyName:UIButton, vc:UIViewController,surveyId:String,assignmentId:String,viewModel:SurveyViewModel){
        
        if let popoverContent = ListingPopOverStoryboard().instantiateViewController(withIdentifier: "ListingPopoverTableViewController") as? ListingPopoverTableViewController{
            popoverContent.modalPresentationStyle = .popover
            popoverContent.popoverPresentationController?.sourceView = btnSelectedSurveyName
            popoverContent.popoverPresentationController?.sourceRect = btnSelectedSurveyName.bounds
            popoverContent.type = .surveyList
            popoverContent.selectedId = surveyId
            popoverContent.arrList = viewModel.getAllSurveys(assignmentId: assignmentId)
            popoverContent.delegate = vc as! ListingPopoverDelegate
            vc.present(popoverContent, animated: true, completion: nil)
        }
        
    }
    
    class func showInTakeNavItems(btn:UIButton,type:PopoverType,navItems:[ListingPopOverDO],vctrl:UIViewController){
        
        if let popoverContent = ListingPopOverStoryboard().instantiateViewController(withIdentifier: "ListingPopoverTableViewController") as? ListingPopoverTableViewController{
            popoverContent.modalPresentationStyle = .popover
            popoverContent.popoverPresentationController?.sourceView = btn
            popoverContent.popoverPresentationController?.sourceRect = btn.bounds
            popoverContent.type = type
            popoverContent.arrList = navItems
            popoverContent.delegate = vctrl as! ListingPopoverDelegate
            vctrl.present(popoverContent, animated: true, completion: nil)
        }
        
    }
    
    
    class func setUpNavItems(resourceFileName:String)->[ListingPopOverDO]{
        
        var navObjects = [ListingPopOverDO]()
        
        let path = Bundle.main.path(forResource: resourceFileName, ofType: "plist")
        guard let navArray = NSArray(contentsOfFile: path!) as? [[String:Any]] else { return navObjects}
        
        
        
        for dict in navArray{
            guard let id = dict["id"] as? String else { continue }
            guard let name = dict["name"] as? String else { continue }
            
            
            let listingPopOverObj = ListingPopOverDO()
            listingPopOverObj.id = id
            listingPopOverObj.name = name
            
            navObjects.append(listingPopOverObj)
            
        }
        
        return navObjects
        
    }
    
    
    class func openNavigationItem(btnLoginUserName:UIButton, vc:UIViewController,isDashboard:Bool?=false,isMapLocation:Bool?=false,isSurveyModule:Bool?=false){
        
        let path = Bundle.main.path(forResource: "NavigationItem", ofType: "plist")
        guard let navArray = NSArray(contentsOfFile: path!) as? [[String:Any]] else { return }
        
        var navObjects = [ListingPopOverDO]()
        
        for dict in navArray{
            guard let id = dict["id"] as? String else { continue }
            guard let name = dict["name"] as? String else { continue }
            
            
            let listingPopOverObj = ListingPopOverDO()
            listingPopOverObj.id = id
            listingPopOverObj.name = name
            
            if(isDashboard == true){
                if(name != NavigationItems.home.rawValue && name != NavigationItems.refreshLocation.rawValue){
                    navObjects.append(listingPopOverObj)
                }
            }
            else if(isMapLocation == true){
                navObjects.append(listingPopOverObj)
            }
            else if(isSurveyModule == true){
                if(name != NavigationItems.refreshData.rawValue && name != NavigationItems.refreshLocation.rawValue){
                    navObjects.append(listingPopOverObj)
                }
            }
            else{
                if(name != NavigationItems.refreshLocation.rawValue){
                    navObjects.append(listingPopOverObj)
                }
            }
            
            
            
        }
        
        if let popoverContent = ListingPopOverStoryboard().instantiateViewController(withIdentifier: "ListingPopoverTableViewController") as? ListingPopoverTableViewController{
            popoverContent.modalPresentationStyle = .popover
            popoverContent.popoverPresentationController?.sourceView = btnLoginUserName
            popoverContent.popoverPresentationController?.sourceRect = btnLoginUserName.bounds
            popoverContent.type = .navigation
            popoverContent.arrList = navObjects
            popoverContent.delegate = vc as! ListingPopoverDelegate
            vc.present(popoverContent, animated: true, completion: nil)
        }
    }
    
   
    
    class func selectedNavigationItem(obj:ListingPopOverDO,vc:UIViewController,isFromSurveyScreen:Bool? = false,isSubmitSurvey:Bool?=false,canvasserTaskDataObject:CanvasserTaskDataObject?=nil,surveyVM:SurveyViewModel?=nil,surveyObj:SurveyDO?=nil){
        
        
        Logger.shared.log(level: .error, msg: "Name: \(obj.name)")
        
        if let name = NavigationItems(rawValue: obj.name) {
            
            switch name {
            case .home:
                if(isFromSurveyScreen == false){
                    
                    vc.performSegue(withIdentifier: "UnwindBackToDashboardIdentifier", sender: self)
                    
                    
//                    if let dashboardVC = dashboardStoryboard().instantiateViewController(withIdentifier: "DashboardViewController") as? DashboardViewController
//                    {
//                        dashboardVC.isFirstTimeLoad = false
//                        dashboardVC.modalPresentationStyle = UIModalPresentationStyle.formSheet
//                        vc.navigationController?.pushViewController(dashboardVC, animated: true)
//                    }
                }
                else{
                    
                    exitFromSurvey(vctrl: vc, surveyVM: surveyVM!, surveyObj: surveyObj!,isSubmitSurvey: isSubmitSurvey,isShowDashboard: true)
                }
                
                
                Logger.shared.log(level: .verbose, msg: "Home: \(obj.name)")
            case .refreshData:
                
                
                    if(NetworkUtility.shared.isConnected() == true){
                        
                        if(Static.isBackgroundSync == false){
                            
                            Static.isRefreshBtnClick = true
                            
                            RefreshAll.sharedInstance.refreshFullData(isFromSurveyScreen: isFromSurveyScreen)
                        }
                        else{
                            vc.view.makeToast("Background syncing is in progress. Please try after some time.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                                
                            }
                        }
                    }
                    else{
                        
                        Static.isBackgroundSync = false
                        Static.isRefreshBtnClick = false
                        
                        vc.view.makeToast("No internet connection.", duration: 2.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                            
                        }
                    }
                
                
                Logger.shared.log(level: .verbose, msg: "RefreshData: \(obj.name)")
                
            case .accessNYC:
                
                if let url = URL(string: "https://access.nyc.gov"){
                    if UIApplication.shared.canOpenURL(url){
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                
                //                if UIApplication.shared.canOpenURL(URL(string: "https://access.nyc.gov")!)
                //                {
                //                    if #available(iOS 10.0, *) {
                //                        UIApplication.shared.open(URL(string: "https://access.nyc.gov")!, options: [UIApplicationOpenURLOptionUniversalLinksOnly:""], completionHandler: { (completed) in
                //                            self.navigationController?.popToRootViewController(animated: true)
                //                        })
                //
                //                    }
                //                    else
                //                    {
                //                        // Fallback on earlier versions
                //                        UIApplication.shared.openURL(URL(string : "https://access.nyc.gov")!)
                //                        self.navigationController?.popToRootViewController(animated: true)
                //                    }
                //                }
                Logger.shared.log(level: .verbose, msg: "Access NYC: \(obj.name)")
            case .settings:
                if let settingsVC = SettingsStoryboard().instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController
                {
                    
                    vc.present(settingsVC, animated: true, completion: nil)
                    // vc.view.addSubview(settingsVC.view)
                    Logger.shared.log(level: .verbose, msg: "Settings: \(obj.name)")
                    
                }
                
            case .signOut:
        
                    let alertCtrl = Alert.showUIAlert(title: "Message", message: "Are you sure you want to logout?", vc: vc)
                    
                    let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel)
                    { action -> Void in
                        
                    }
                    
                    alertCtrl.addAction(cancelAction)
                    
                    let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
                        
                        if(isFromSurveyScreen)!{
                            
                            updateSurveyofUnit(surveyVM: surveyVM!, surveyObj: surveyObj!,isSubmitSurvey: isSubmitSurvey)
                              RefreshAll.sharedInstance.refreshFullData(isFromSurveyScreen: true, isLogout: true)
                        }
                        else{
                            RefreshAll.sharedInstance.refreshFullData(isLogout: true)
                        }
                        
                    }
                    alertCtrl.addAction(okAction)
                
                
                Logger.shared.log(level: .verbose, msg: "Signout: \(obj.name)")
            case .events:
                if let eventVC = EventsStoryboard().instantiateViewController(withIdentifier: "EventsViewController") as? EventsViewController{
                    
                    eventVC.isFromSurveyScreen = isFromSurveyScreen!
                    if let canvasserObj = canvasserTaskDataObject{
                        eventVC.canvasserTaskDataObject = canvasserObj
                    }
                    
                    
                    let navigationController = UINavigationController(rootViewController: eventVC)
                    navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
                    vc.present(navigationController, animated: true)
                }
            case .refreshLocation:
                RefreshAll.sharedInstance.refreshESRIData()
            }
        }
        
        
    }
    
    
    class func showSurveyTextVC(vc:UIViewController,surveyObj:SurveyDO,canvasserTaskDataObject:CanvasserTaskDataObject,surveyVM:SurveyViewModel,subType:String){
        
        if let surveyTextVC = SurveyTextStoryboard().instantiateViewController(withIdentifier: "SurveyTextViewController") as? SurveyTextViewController{
            
            surveyTextVC.canvasserTaskDataObject = canvasserTaskDataObject
            surveyTextVC.viewModel = surveyVM
            surveyTextVC.surveyObj = surveyObj
            
            
            
            //            if(subType == kCATransitionFromLeft){
            //                TransitionVC(subType: subType, sourceVC: vc, destinationVC: surveyTextVC)
            //            }
            //            else{
            //                 surveyTextVC.modalPresentationStyle = UIModalPresentationStyle.formSheet
            //                 vc.navigationController?.pushViewController(surveyTextVC, animated: true)
            //            }
            
            
            TransitionVC(subType: subType, sourceVC: vc, destinationVC: surveyTextVC)
        }
        
    }
    
    class func showSurveyRadioOptionVC(vc:UIViewController,surveyObj:SurveyDO,canvasserTaskDataObject:CanvasserTaskDataObject,surveyVM:SurveyViewModel,subType:String){
        
        if let surveyRadioOptionVC = SurveyRadioOptionStoryboard().instantiateViewController(withIdentifier: "SurveyRadioOptionViewController") as? SurveyRadioOptionViewController{
            
            surveyRadioOptionVC.canvasserTaskDataObject = canvasserTaskDataObject
            surveyRadioOptionVC.viewModel = surveyVM
            surveyRadioOptionVC.surveyObj = surveyObj
            
            TransitionVC(subType: subType, sourceVC: vc, destinationVC: surveyRadioOptionVC)
            
            //            if(subType == kCATransitionFromLeft){
            //              TransitionVC(subType: subType, sourceVC: vc, destinationVC: surveyRadioOptionVC)
            //            }
            //            else{
            //                surveyRadioOptionVC.modalPresentationStyle = UIModalPresentationStyle.formSheet
            //                vc.navigationController?.pushViewController(surveyRadioOptionVC, animated: true)
            //
            //            }
            
        }
        
    }
    
    class func showSurveyMultiOptionVC(vc:UIViewController,surveyObj:SurveyDO,canvasserTaskDataObject:CanvasserTaskDataObject,surveyVM:SurveyViewModel,subType:String){
        
        if let surveyMultiOptionVC = SurveyMultiOptionStoryboard().instantiateViewController(withIdentifier: "SurveyMultiOptionViewController") as? SurveyMultiOptionViewController{
            
            surveyMultiOptionVC.canvasserTaskDataObject = canvasserTaskDataObject
            surveyMultiOptionVC.viewModel = surveyVM
            surveyMultiOptionVC.surveyObj = surveyObj
            
            TransitionVC(subType: subType, sourceVC: vc, destinationVC: surveyMultiOptionVC)
            
            //            if(subType == kCATransitionFromLeft){
            //                TransitionVC(subType: subType, sourceVC: vc, destinationVC: surveyMultiOptionVC)
            //            }
            //            else{
            //                 surveyMultiOptionVC.modalPresentationStyle = UIModalPresentationStyle.formSheet
            //                 vc.navigationController?.pushViewController(surveyMultiOptionVC, animated: true)
            //            }
            
            
        }
        
    }
    
    class func showSubmitSurveyVC(vc:UIViewController,surveyObj:SurveyDO,canvasserTaskDataObject:CanvasserTaskDataObject,surveyVM:SurveyViewModel){
        
        if let submitSurveyVC = SubmitSurveyStoryboard().instantiateViewController(withIdentifier: "SubmitSurveyViewController") as? SubmitSurveyViewController{
            
            submitSurveyVC.canvasserTaskDataObject = canvasserTaskDataObject
            submitSurveyVC.viewModel = surveyVM
            submitSurveyVC.surveyObj = surveyObj
            
            TransitionVC(subType: kCATransitionFromRight, sourceVC: vc, destinationVC: submitSurveyVC)
            
            //
            //            submitSurveyVC.modalPresentationStyle = UIModalPresentationStyle.formSheet
            //            vc.navigationController?.pushViewController(submitSurveyVC, animated: true)
            
        }
        
    }
    
    // convert images into base64 and keep them into string
    
    class func convertImageToBase64(_ image: UIImage) -> String {
        
        let imageData = UIImagePNGRepresentation(image)
        let base64String = imageData!.base64EncodedString(options: [])
        return base64String
        
    }// end convertImageToBase64
    
    
    
    // convert images into base64 and keep them into string
    
    class func convertBase64ToImage(_ base64String: String) -> UIImage {
        
        let decodedData = Data(base64Encoded: base64String, options: NSData.Base64DecodingOptions(rawValue: 0) )
        
        let decodedimage = UIImage(data: decodedData!)
        
        return decodedimage!
        
    }// end convertBase64ToImage
    
    
    class func showPreviousQuestion(vctrl:UIViewController,surveyObj:SurveyDO,canvasserTaskDataObject:CanvasserTaskDataObject,viewModel:SurveyViewModel){
        
        if let objSurveyQues =  surveyObj.surveyQuestionArray[surveyObj.surveyQuestionArrayIndex].objectSurveyQuestion{
            
            
            if(objSurveyQues.questionType == "Single Select"){
                
                
                showSurveyRadioOptionVC(vc: vctrl, surveyObj: surveyObj, canvasserTaskDataObject: canvasserTaskDataObject, surveyVM: viewModel, subType: kCATransitionFromLeft)
                
                
            }
                
            else if(objSurveyQues.questionType == "Multi Select"){
                
                showSurveyMultiOptionVC(vc: vctrl, surveyObj: surveyObj, canvasserTaskDataObject: canvasserTaskDataObject, surveyVM: viewModel,subType: kCATransitionFromLeft)
                
                
            }
                
            else if(objSurveyQues.questionType == "Text Area"){
                
                
                showSurveyTextVC(vc: vctrl, surveyObj: surveyObj, canvasserTaskDataObject: canvasserTaskDataObject, surveyVM: viewModel,subType: kCATransitionFromLeft)
                
            }
            
            
        }
    }
    
    
    class func TransitionVC(subType:String,sourceVC:UIViewController?,destinationVC:UIViewController?){
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = kCATransitionPush
        
        
        transition.subtype = subType//kCATransitionFromLeft or kCATransitionFromRight
        
        //  let destinationNavVC = UINavigationController(rootViewController: destinationVC!)
        
        sourceVC?.view.window!.layer.add(transition, forKey: kCATransition)
        
        sourceVC?.present(destinationVC!, animated: false, completion: nil)
        
    }
    
    
    class func startBackgroundSyncing(){
        // Scheduling timer to Call the function **Countdown** with the interval of 1 seconds
        
        if let settingRes = SettingsAPI.shared.getSettings(){
            
            for settingData in settingRes{
                
                //if false{
                if settingData.isSyncON{
                    
                    let syncTime:TimeInterval = TimeInterval(CGFloat(Int(settingData.offlineSyncTime!)! * 60))
                    
                    Static.timer = Timer.scheduledTimer(timeInterval: syncTime, target: self, selector: #selector(checkConnection), userInfo: nil, repeats: true)
                    
                    print("offlineSyncTime")
                    print("Timer initialize")
                    
                }
                
            }
            
            
            
        }
        
        
        
        
    }
    
    @objc class func checkConnection(){
        
        if(NetworkUtility.shared.isConnected() == true){
            
            if(Static.isRefreshBtnClick == false && Static.isBackgroundSync == false){
                
                Static.isBackgroundSync = true
                
                Logger.shared.log(level: .info, msg: "Background syncing start..")
                
                RefreshAll.sharedInstance.refreshDataWithOutModel()
                
            }
            
        }
        
        
    }
    
    class func displayErrorMessage(errorMsg:String){
        Static.isBackgroundSync = false
        Static.isRefreshBtnClick = false
        
        if let refreshView  = Static.refreshView {
            refreshView.dismiss(animated: true, completion: nil)
            Static.refreshView = nil
            RefreshAll.sharedInstance.callNotifications()
        }
        
        showSwiftErrorMessage(error: errorMsg)
    }
    
    class func convertToDateTimeFormat(dateVal:String)->String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let formattedDate = dateFormatter.date(from: dateVal)
        
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "MM/dd/yyyy hh:mm a"
        return dateFormatter1.string(from: formattedDate!)
        
    }
    
    class func currentDateAndTime()-> String{
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
    
        return dateFormatter.string(from: Date())
    
    }
    
    class func makeButtonBorder(btn:UIButton){
        btn.backgroundColor = .clear
        btn.layer.cornerRadius = 5
        btn.layer.borderWidth = 1
        btn.layer.borderColor =  UIColor(red:20/255.0, green:123/255.0, blue:237/255.0, alpha: 1.0).cgColor
    }
    
    class func enableDisableIntakeAddBtn(btn:UIButton,lbl:UILabel,img:UIImageView,isHidden:Bool){
        btn.isHidden = isHidden
        lbl.isHidden = isHidden
        if(isHidden){
             img.image = UIImage()
        }
        
       
    }
    
    class func saveUnZipFilePath(mapDataZipFile:String){
        
        do {
            let mapDataPath = Bundle.main.path(forResource: mapDataZipFile, ofType: "zip")
            
            let unZipFilePath = try Zip.quickUnzipFile(URL(string: mapDataPath!)!) // Unzip
            
            let mapDirpath = unZipFilePath.absoluteString + mapDataZipFile
            
            SettingsAPI.shared.updateMapZipFilePathSetting(mapZipFilePath: mapDirpath)
        }
        catch {
            Utility.showSwiftErrorMessage(error: "Something went wrong while unzip geodatabase.")
        }
        
    }
    
    
    
    
    
    
    
    
}

