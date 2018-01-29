//
//  LocationUnitViewController.swift
//  EngageNYC
//
//  Created by Kamal on 12/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

enum LocationUnits: String{
    case units = "Units"
    case clients = "Clients"
}

class LocationUnitViewController: UIViewController
{
    @IBOutlet weak var segmentCtrl: UISegmentedControl!
    @IBOutlet weak var lblAssignmentName: UILabel!
    @IBOutlet weak var btnUserLogin: UIButton!
    @IBOutlet weak var lblLocationName: UILabel!
    
    @IBOutlet weak var btnBAck: UIButton!
    
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblAssignmentName.text = canvasserTaskDataObject.assignmentObj.assignmentName
        lblLocationName.text = canvasserTaskDataObject.locationObj.objMapLocation.locName
        btnUserLogin.setTitle(canvasserTaskDataObject.userObj.userName, for: .normal)
        
        
    }
    
    @IBAction func btnLoginPressed(_ sender: Any) {
        Utility.openNavigationItem(btnLoginUserName: btnUserLogin, vc: self)
        
    }
    @IBAction func btnLeftBarPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnNewUnitPressed(_ sender: Any) {
        
        if let newUnitVC = NewUnitStoryboard().instantiateViewController(withIdentifier: "NewUnitViewController") as? NewUnitViewController{
            
            let navigationController = UINavigationController(rootViewController: newUnitVC)
            navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newUnitVC.isFromUnitListing = true
            newUnitVC.canvassserTaskDataObject = canvasserTaskDataObject
            
            self.present(navigationController, animated: true)
            
            
        }
        
        
    }
    @IBAction func btnNewContactPressed(_ sender: Any) {
        
        if let clientInfoVC = ClientInfoStoryboard().instantiateViewController(withIdentifier: "ClientInfoViewController") as? ClientInfoViewController{
            
            clientInfoVC.canvasserTaskDataObject = canvasserTaskDataObject
            let navigationController = UINavigationController(rootViewController: clientInfoVC)
            navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
            self.present(navigationController, animated: true)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let controller = segue.destination as? UnitListingViewController
        {
            controller.locationUnitVC = self
            controller.canvasserTaskDataObject = self.canvasserTaskDataObject
        }
    }
    
    
    
    func prepareLoctionUnitPanelsInfo(viewCtrlType:String){
        DispatchQueue.main.async {
            
            var panelCtrl:UIViewController?
            
            if(viewCtrlType == LocationUnits.units.rawValue){
                
                if let unitsList = LocationUnitStoryboard().instantiateViewController(withIdentifier: "UnitListingViewController") as? UnitListingViewController{
                    
                    unitsList.locationUnitVC = self
                    unitsList.canvasserTaskDataObject = self.canvasserTaskDataObject
                    panelCtrl = unitsList
                }
                
            }
            else if(viewCtrlType == LocationUnits.clients.rawValue){
                
                if let clientList = LocationUnitStoryboard().instantiateViewController(withIdentifier: "ClientListingViewController") as? ClientListingViewController{
                    
                    clientList.locationUnitVC = self
                    clientList.canvasserTaskDataObject = self.canvasserTaskDataObject
                    panelCtrl = clientList
                }
                
            }
            
            if let containerView = panelCtrl{
                
                for childVC in self.childViewControllers{
                    
                    if childVC.isKind(of: UnitListingViewController.self){
                        Utility.switchBetweenViewControllers(senderVC: self, fromVC: childVC, toVC: containerView)
                    }
                    else if childVC.isKind(of: ClientListingViewController.self){
                        Utility.switchBetweenViewControllers(senderVC: self, fromVC: childVC, toVC: containerView)
                    }
                    
                }
            }
        }
        
    }
    
    
    
    @IBAction func segmentCtrlPressed(_ sender: Any)
    {
        switch segmentCtrl.selectedSegmentIndex
        {
        case 0:
            prepareLoctionUnitPanelsInfo(viewCtrlType: LocationUnits.units.rawValue)
            
        case 1:
            prepareLoctionUnitPanelsInfo(viewCtrlType: LocationUnits.clients.rawValue)
            
        default:
            break;
        }
    }
    
    @IBAction func UnwindBackFromSurvey(segue:UIStoryboardSegue) {
        
        print("UnwindBackFromSurvey")
        
    }
    
}

extension LocationUnitViewController : ListingPopoverDelegate{
    func selectedItem(withObj obj: ListingPopOverDO, selectedIndex index: Int, popOverType type: PopoverType) {
        Utility.selectedNavigationItem(obj: obj, vc: self)
    }
 }


