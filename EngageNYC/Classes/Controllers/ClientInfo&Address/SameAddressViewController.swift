//
//  SameAddressViewController.swift
//  EngageNYCDev
//
//  Created by Kamal on 10/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class SameAddressViewController: UIViewController {
    @IBOutlet weak var btnAptNo: UIButton!
    @IBOutlet weak var btnNewUnit: UIButton!
    
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    var viewModel:AddressInfoViewModel!
    var newContactObj:NewContactDO!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        btnAptNo.layer.cornerRadius = 7.0
        btnAptNo.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        btnAptNo.layer.borderWidth = 1.0
        btnAptNo.clipsToBounds = true
        
        Utility.makeButtonBorder(btn: btnNewUnit)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnAptNoPressed(_ sender: Any) {
        
        
        //get unitlisting
        if let popoverContent = ListingPopOverStoryboard().instantiateViewController(withIdentifier: "ListingPopoverTableViewController") as? ListingPopoverTableViewController{
            popoverContent.modalPresentationStyle = .popover
            popoverContent.popoverPresentationController?.sourceView = btnAptNo
            popoverContent.popoverPresentationController?.sourceRect = btnAptNo.bounds
            popoverContent.type = .unitsList
            
            //popoverContent.iOSselectedId = self.newContactObj.sameLocUnitId
            popoverContent.selectedId = self.newContactObj.sameLocUnitId
            
            popoverContent.arrList = self.viewModel.getAllLocationUnitsWithoutVirtualUnit(assignmentId: canvasserTaskDataObject.assignmentObj.assignmentId, assignmentLocId: canvasserTaskDataObject.locationObj.objMapLocation.assignmentLocId)
            popoverContent.delegate = self
            self.present(popoverContent, animated: true, completion: nil)
        }
        
        
    }
    
    
    @IBAction func btnAddNewUnitPressed(_ sender: Any) {
        
        if let newUnitVC = NewUnitStoryboard().instantiateViewController(withIdentifier: "NewUnitViewController") as? NewUnitViewController
        {
            newUnitVC.canvassserTaskDataObject = canvasserTaskDataObject
            newUnitVC.isFromUnitListing = false
            let completionHandler:(NewUnitViewController)->Void = { newUnitVC in
                
                if let unitName = newUnitVC.txtUnit.text{
                    self.btnAptNo.setTitle(unitName, for: .normal)
                    self.newContactObj.sameUnitName = unitName
                    self.newContactObj.sameLocUnitId = newUnitVC.locUnitId
                    self.newContactObj.assignmentLocUnitid = newUnitVC.assignmentLocUnitId
                }
            }
            
            newUnitVC.completionHandler = completionHandler
            newUnitVC.modalPresentationStyle = UIModalPresentationStyle.formSheet
            self.navigationController?.pushViewController(newUnitVC, animated: true)
        }
        
    }
    
}

extension SameAddressViewController : ListingPopoverDelegate{
    func selectedItem(withObj obj: ListingPopOverDO, selectedIndex index: Int, popOverType type: PopoverType) {
        
        btnAptNo.setTitle(obj.name, for: .normal)

        self.newContactObj.sameUnitName = obj.name
        self.newContactObj.sameLocUnitId = obj.id
        self.newContactObj.assignmentLocUnitid = obj.additionalId
    }
}
