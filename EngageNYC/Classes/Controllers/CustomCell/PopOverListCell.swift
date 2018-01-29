//
//  PopOverListCell.swift
//  EngageNYC
//
//  Created by Kamal on 07/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

import UIKit

class PopOverListCell: UITableViewCell {
    
    @IBOutlet weak var lblImage: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var leadingSpaceConstraint: NSLayoutConstraint!
    
    func setupCell(title : String) {
        self.lblTitle.text = title
       // self.lblImage.image = UIImage("checked.png")
    }
    
    func adjustTitleAlignment() {
        
        leadingSpaceConstraint.constant = 30
    }
}
