//
//  AtemptTableViewCell.swift
//  Knock
//
//  Created by Cloudzeg Laptop on 7/9/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class EditLocAttemptTableViewCell: UITableViewCell
{
    
    @IBOutlet weak var attemptRdb: UISwitch!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
