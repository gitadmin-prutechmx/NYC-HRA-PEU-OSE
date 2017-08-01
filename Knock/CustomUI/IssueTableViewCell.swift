//
//  IssueTableViewCell.swift
//  Knock
//
//  Created by Cloudzeg Laptop on 7/31/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class IssueTableViewCell: UITableViewCell
{
    @IBOutlet weak var lblIssueNo:UILabel!
    @IBOutlet weak var lblIssueType:UILabel!
    
    @IBOutlet weak var lblIssueId: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
