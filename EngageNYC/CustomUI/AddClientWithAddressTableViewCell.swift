//
//  AddClientWithAddressTableViewCell.swift
//  EngageNYC
//
//  Created by Cloudzeg Laptop on 10/6/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class AddClientWithAddressTableViewCell: UITableViewCell
{
    @IBOutlet weak var AddClientWithAddressView: UIView!
    
    @IBOutlet weak var email: UILabel!
    
    @IBOutlet weak var phone: UILabel!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address:UILabel!
   // @IBOutlet weak var tenantId: UILabel!
    
    @IBOutlet weak var tenantId: UILabel!
    @IBOutlet weak var age: UILabel!


    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
