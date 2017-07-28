//
//  UnitTableViewCell.swift
//  Knock
//
//  Created by Cloudzeg Laptop on 7/27/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class UnitDataTableViewCell: UITableViewCell {

    @IBOutlet weak var unit: UILabel!
    
    @IBOutlet weak var attempt: UIImageView!
    
    @IBOutlet weak var contact: UIImageView!
    
    @IBOutlet weak var surveyStatus: UIImageView!
    
    @IBOutlet weak var sync: UIImageView!
    
    @IBOutlet weak var syncDate: UILabel!
    
    @IBOutlet weak var noOfTenants: UILabel!
    
    @IBOutlet weak var unitId: UILabel!

    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
