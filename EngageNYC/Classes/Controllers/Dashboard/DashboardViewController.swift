//
//  DashboardViewController.swift
//  EngageNYC
//
//  Created by Kamal on 07/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

enum NavigationItems:String {
    case refreshData = "Refresh Data"
    case home = "Home"
    case events = "Events"
    case accessNYC = "Access NYC"
    case settings = "Settings"
    case signOut = "Sign Out"
}

class DashboardInfo {
    var arrCharts:[ChartDO]!
    var arrAssignments:[AssignmentDO]!
}
enum ArrowDirection {
    case up
    case down
    case none
}

class UserDataObject{
    var userId:String!
    var contactId:String!
    var userName:String!
    
    init(userId:String,contactId:String,userName:String){
        self.contactId = contactId
        self.userId = userId
        self.userName = userName
    }
}

class AssignmentDataObject{
    var assignmentId:String!
    var assignmentName:String!
    
    init(assignmentId:String,assignmentName:String){
        self.assignmentId = assignmentId
        self.assignmentName = assignmentName
    }
}
class SortingHeaderCell {
    
    var title : String!
    var subTitle : String!
    var arrowPosition : ArrowDirection!
    var textAllignment : NSTextAlignment!
    var canSort : Bool = true
    var index : Int = 0
    var headerBgColor: UIColor!
    
    init(withTitle headerTitle : String, headerSubTitle : String, headerArrowPostion : ArrowDirection, allignment : NSTextAlignment) {
        
        self.title = headerTitle
        self.subTitle = headerSubTitle
        self.arrowPosition = headerArrowPostion
        self.textAllignment = allignment
    }
}

class LocationDataObject{
    var objMapLocation:MapLocationDO!

    init(objMapLocation:MapLocationDO){
        self.objMapLocation = objMapLocation
    }
//    var locationId:String!
//    var locationName:String!
//    var locationStatus:String!
//    var assignmentLocationId:String!
//
//    init(locationId:String,locationName:String,locationStatus:String,assignmentLocationId:String){
//        self.locationId = locationId
//        self.locationName = locationName
//        self.locationStatus = locationStatus
//        self.assignmentLocationId = assignmentLocationId
//    }
}

class LocationUnitDataObject{
    var locationUnitId:String!
    var locationUnitName:String!
    var assignmentLocUnitId:String!
    
    init(locationUnitId:String,locationUnitName:String,assignmentLocUnitId:String){
        self.locationUnitId = locationUnitId
        self.locationUnitName = locationUnitName
        self.assignmentLocUnitId = assignmentLocUnitId
    }
}

class ContactDataObject{
    var contactId:String!
    init(contactId:String){
        self.contactId = contactId
    }
}

class CanvasserTaskDataObject{
    var userObj:UserDataObject!
    var assignmentObj:AssignmentDataObject!
    var locationObj:LocationDataObject!
    var locationUnitObj:LocationUnitDataObject!
    var contactObj:ContactDataObject!
    
}


class DashboardViewController: BroadcastReceiverViewController {

    @IBOutlet weak var btnLogin: UIButton!
    
    var viewModel:DashboardViewModel!
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    var isFirstTimeLoad:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    
    @IBAction func btnLoginUserNamePressed(_ sender: Any) {
        Utility.openNavigationItem(btnLoginUserName: self.btnLogin, vc: self,isDashboard: true)
    }
   
    // MARK: Class Methods
    
    func setupView() {
        
        //self.navigationController?.isNavigationBarHidden = true
       
        // Adding notification reciever for Sync
        CustomNotificationCenter.registerReceiver(receiver: self.broadcastReceiver, notificationName: SF_NOTIFICATION.DASHBOARD_SYNC)

        if(isFirstTimeLoad){
            RefreshAll.sharedInstance.refreshFullData()
        }
        else{
            self.bindView()
        }
        
   
        
    }
    
    func bindDashboard() {

        //ATUtility.showActivityHUD(onView: self.view)
        DispatchQueue.global(qos: .userInitiated).async {
            self.viewModel.populateDashboard()
            DispatchQueue.main.async {
                
                if let userObject = UserDetailAPI.shared.getUserDetail(){
                    
                    self.canvasserTaskDataObject = CanvasserTaskDataObject()
                    self.canvasserTaskDataObject.userObj = UserDataObject(userId:  userObject.userId!,contactId:userObject.contactId!, userName:  userObject.contactName!)
                    self.btnLogin.setTitle(userObject.contactName, for: .normal)
                    
                }
               
                self.reloadDashboard()
                //ATUtility.hideActivityHUD(onView: self.view)
            }
        }
    }
    
    
    func reloadDashboard() {
        
        for childVC in self.childViewControllers{
            
            // Chart Panel
            if let chartPanel = childVC as? ChartsViewController{
                chartPanel.dashboardInfo = self.viewModel.dashboardInfo
            }
            
            // Assignment Panel
            if let assignmentPanel = childVC as? AssignmentsViewController{
                assignmentPanel.dashboardInfo = self.viewModel.dashboardInfo
                assignmentPanel.canvasserTaskDataObject = self.canvasserTaskDataObject
            }
        }
    }
    
    // MARK: - NSNotification action
    override func onReceive(notification: NSNotification) {
        super.onReceive(notification: notification)
        
        if (notification.name.rawValue == SF_NOTIFICATION.DASHBOARD_SYNC.rawValue)
        {
            Utility.startBackgroundSyncing()
            self.bindView()
        }
    }
    
   
    
    
    //If connected through seque then use this
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        if segue.identifier == "navPopoverIdentifier"{
//
//            if let popoverPresentationController = segue.destination.popoverPresentationController {
//                popoverPresentationController.sourceView = self.lblLoginUserName
//                popoverPresentationController.sourceRect = self.lblLoginUserName.bounds
//
//                if let controller = segue.destination as? ListingPopoverTableViewController{
//                    controller.delegate = self
//                }
//            }
//        }
//    }
    

}

extension DashboardViewController{
    
    func bindView() {
        
        self.viewModel = DashboardViewModel.getViewModel()
        self.bindDashboard()
        
    }
}

extension DashboardViewController : ListingPopoverDelegate{
    func selectedItem(withObj obj: ListingPopOverDO, selectedIndex index: Int, popOverType type: PopoverType) {
         Utility.selectedNavigationItem(obj: obj, vc: self)
    }
}
