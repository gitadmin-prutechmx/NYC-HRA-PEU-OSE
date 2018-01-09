//
//  PopOverListCell.swift
//

import UIKit

class PopOverListCell: UITableViewCell {

    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var leadingSpaceConstraint: NSLayoutConstraint!
    
    func setupCell(title : String) {
        self.lblTitle.text = title
    }
    
    func adjustTitleAlignment() {
        
        leadingSpaceConstraint.constant = 30
    }
}
