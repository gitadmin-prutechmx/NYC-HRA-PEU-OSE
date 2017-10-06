//
//  ClientDataTableViewCell.swift
//  Knock
//
//  Created by Cloudzeg Laptop on 7/28/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class ClientDataTableViewCell: UITableViewCell
{
  
    @IBOutlet weak var lblUnitId: UILabel!
    @IBOutlet weak var lblUnitName: UILabel!
    @IBOutlet weak var lblFirstName: UILabel!
    @IBOutlet weak var lblUnverifiedunit:UILabel!
    @IBOutlet weak var lblSyncDate: UILabel!
    @IBOutlet weak var btnSyncimg: UIButton!
    @IBOutlet weak var lblCase: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblLastName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
