//
// SortingHeaderViewController.swift
//  aligntech-stpe
//
//  Created by Anmol Mathur on 25/07/17.
//  Copyright © 2017 Align Technology Inc. All rights reserved.
//

import UIKit

class SortingHeaderViewController: UIViewController {

    var arrSortingHeader = [SortingHeaderCell](){
        didSet {
            self.reloadView()
        }
    }
    
    var parentVC : UIViewController?
    var tableHeader : SortingHeaderViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Class Function
    func reloadView() {
        
        for index in 1...arrSortingHeader.count {
            if let vwPlanning = self.view.viewWithTag(index) as? SortingTextCell{
                
                vwPlanning.delegate = self
                
                let objPlanning = arrSortingHeader[index-1]
                objPlanning.index = index
                vwPlanning.headerObject = objPlanning
                
            }
        }
    }
}

// MARK: Extension SortingHeaderViewController for ATPlanningTextCellDelegate
extension SortingHeaderViewController : SortingTextCellDelegate{
    
    func sortHeaderView(forObject object: SortingHeaderCell, inDirection direction: ArrowDirection) {
        
        for header in arrSortingHeader {
            header.arrowPosition = ArrowDirection.none
        }
        object.arrowPosition = direction
        self.reloadView()
        if parentVC != nil{
            if let assignmentVc = parentVC as? AssignmentsViewController{
                assignmentVc.sortData(forHeaderIndex: object.index, direction: direction)
            }
            else if let unitVc = parentVC as? UnitListingViewController{
                unitVc.sortDirection = direction
                unitVc.sortData(forHeaderIndex: object.index, direction: direction)
            }
            
            else if let clientVc = parentVC as? ClientListingViewController{
                clientVc.sortDirection = direction
                clientVc.sortData(forHeaderIndex: object.index, direction: direction)
            }
        }
    }
}
