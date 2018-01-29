//
//  ATPlanningTextCell.swift
//  aligntech-stpe
//
//  Created by Anmol Mathur on 25/07/17.
//  Copyright © 2017 Align Technology Inc. All rights reserved.
//

import UIKit


protocol SortingTextCellDelegate {
    
    func sortHeaderView(forObject object: SortingHeaderCell, inDirection direction : ArrowDirection)
}

@IBDesignable
class SortingTextCell: NibDesignable {

    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblArrow: UILabel!
    @IBOutlet var titleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var btnSort: UIButton!
    
    
    @IBInspectable public var title: String = "" {
        didSet {
            self.lblTitle.text = title
        }
    }
    
    public var headerBgColor: UIColor?{
        didSet{
            self.btnSort.backgroundColor = headerBgColor
        }
    }
    
    var delegate : SortingTextCellDelegate?
    
    public var direction: ArrowDirection = .none {
        didSet {
            
            switch direction {
            case .none:
                self.lblArrow.isHidden = true
                break
            case .up:
                self.lblArrow.isHidden = false
                self.lblArrow.text = "▲"
                break
            case .down:
                self.lblArrow.isHidden = false
                self.lblArrow.text = "▼"
                break
            }
        }
    }
    
    public var alignment: NSTextAlignment = .center{
        didSet {
            if alignment == .left{
                titleLeadingConstraint.constant = 8
            }
            else if alignment == .center{
                titleLeadingConstraint.constant = 3
            }
            self.lblTitle.textAlignment = alignment
        }
    }
    
    public var headerObject :SortingHeaderCell? {
        didSet {
            self.updateView()
        }
    }
    
    //MARK: Class Function
    
    
    
    func updateView() {
        if let header = headerObject{
            
            self.alignment = header.textAllignment
            self.direction = header.arrowPosition
            self.btnSort.isEnabled = header.canSort
            if header.headerBgColor != nil{
                self.headerBgColor = header.headerBgColor
            }
            
           
            let title = NSMutableAttributedString(string: header.title, attributes: [NSFontAttributeName:UIFont(name: "NHaasGroteskDSPro-55Rg", size: 16.0)!])
            
             self.lblTitle.attributedText = title
            
          /*  // Setup Fonts
            if header.subTitle != "" {
                
                let combination = NSMutableAttributedString()
                    let title = NSMutableAttributedString(string: header.title, attributes: [NSFontAttributeName:UIFont(name: "Arial", size: 12.0)!])
                    combination.append(title)
                
                
               
                    let subTitle = NSMutableAttributedString(string: header.subTitle, attributes: [NSFontAttributeName:UIFont(name: "NHaasGroteskDSPro-45Lt", size: 12.0)!])
                    combination.append(subTitle)
                
                self.lblTitle.attributedText = combination
               
                
            }
            else{
                self.title = header.title
            }
 */
        }
    }

    @IBAction func sortButtonClick(_ sender: UIButton) {
        
        var arrow : ArrowDirection = .none
        
        self.lblArrow.isHidden = false
        
        switch direction {
        case .none:
            arrow = .down
            break
        case .up:
            arrow = .down
            break
        case .down:
            arrow = .up
            break
        }
        
        if let header = headerObject{
            header.arrowPosition = self.direction
            
            if delegate != nil{
                delegate!.sortHeaderView(forObject: header, inDirection: arrow)
            }
        }
        
    }
}
