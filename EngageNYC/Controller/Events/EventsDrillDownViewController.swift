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
    
    @IBOutlet weak var segmentCtrl: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblEventName.text = objEvent.name
        //Event Name
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
                        Utilities.switchBetweenViewControllers(senderVC: self, fromVC: childVC, toVC: containerView)
                    }
                    else if childVC.isKind(of: EventsRegistrationViewController.self){
                        Utilities.switchBetweenViewControllers(senderVC: self, fromVC: childVC, toVC: containerView)
                    }
                    
                }
            }
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
