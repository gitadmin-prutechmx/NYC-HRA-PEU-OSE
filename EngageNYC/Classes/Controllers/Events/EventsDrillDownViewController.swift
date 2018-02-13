//
//  EventsDrillDownViewController.swift
//  EngageNYCDev
//
//  Created by Kamal on 08/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

enum DrillDown: String{
    case detail = "Detail"
    case registration = "Registration"
}

class EventsDrillDownViewController: UIViewController {
    
    var objEvent:EventDO!
    @IBOutlet weak var lblEventName: UILabel!
    @IBOutlet weak var rightBarButton: UIButton!
    
    @IBOutlet weak var segmentCtrl: UISegmentedControl!
    
    @IBOutlet weak var btnNewEventReg:UIButton!
    
    var isFromSurveyScreen:Bool!
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblEventName.text = objEvent.name  //Event Name
        
        if(isFromSurveyScreen){
            btnNewEventReg.isHidden = false
        }
        else{
             btnNewEventReg.isHidden = true
        }
       
        Utility.makeButtonBorder(btn: rightBarButton)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let controller = segue.destination as? EventsDetailViewController
        {
            controller.objEvent = self.objEvent
        }
    }
    

    func prepareDrillDownPanelsInfo(viewCtrlType:String){
        DispatchQueue.main.async {
            
            var panelCtrl:UIViewController?
            
            if(viewCtrlType == DrillDown.detail.rawValue){
                
                if let eventDetail = EventsDetailStoryboard().instantiateViewController(withIdentifier: "EventsDetailViewController") as? EventsDetailViewController{
                    eventDetail.objEvent = self.objEvent
                    panelCtrl = eventDetail
                }
                
            }
            else if(viewCtrlType == DrillDown.registration.rawValue){
                
                if let eventReg = EventsRegistrationStoryboard().instantiateViewController(withIdentifier: "EventsRegistrationViewController") as? EventsRegistrationViewController{
                     eventReg.objEvent = self.objEvent
                     panelCtrl = eventReg
                }
                
            }
            
            if let containerView = panelCtrl{
                
                for childVC in self.childViewControllers{
                    
                    if childVC.isKind(of: EventsDetailViewController.self){
                        Utility.switchBetweenViewControllers(senderVC: self, fromVC: childVC, toVC: containerView)
                    }
                    else if childVC.isKind(of: EventsRegistrationViewController.self){
                        Utility.switchBetweenViewControllers(senderVC: self, fromVC: childVC, toVC: containerView)
                    }
                    
                }
            }
        }
        
    }
    
    @IBAction func btnRegistrationClick(_ sender: Any)
    {
        if  let newRegistrationVC =
            NewEventRegistrationStoryboard().instantiateViewController(withIdentifier: "NewEventRegistration") as? NewEventRegistrationViewController
        {
            newRegistrationVC.canvasserTaskDataObject = self.canvasserTaskDataObject
            
            newRegistrationVC.newEventRegObj = NewEventRegDO()
            newRegistrationVC.newEventRegObj.objEvent = objEvent
           
            newRegistrationVC.newEventRegObj.newEventRegVC = newRegistrationVC
            
            self.navigationController?.pushViewController(newRegistrationVC, animated: true)
        }
    }
    
    @IBAction func segmentCtrlPressed(_ sender: Any) {
        
        switch segmentCtrl.selectedSegmentIndex
        {
        case 0:
            prepareDrillDownPanelsInfo(viewCtrlType: DrillDown.detail.rawValue)
            
        case 1:
            prepareDrillDownPanelsInfo(viewCtrlType: DrillDown.registration.rawValue)
            
        default:
            break;
        }
        
    }
    
    @IBAction func closeBtnAction(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func backBtnAction(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
}
