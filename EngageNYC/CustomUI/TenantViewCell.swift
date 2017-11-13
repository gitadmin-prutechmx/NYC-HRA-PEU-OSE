//
//  TenantViewCell.swift
//  Knock
//
//  Created by Kamal on 22/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class TenantViewCell: UITableViewCell {
    @IBOutlet weak var tenantView: UIView!
    
    @IBOutlet weak var email: UILabel!
    
    @IBOutlet weak var phone: UILabel!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var tenantId: UILabel!
    
    @IBOutlet weak var age: UILabel!
     @IBOutlet weak var sourceList: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
