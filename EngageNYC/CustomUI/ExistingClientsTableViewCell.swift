//
//  ExistingClientsTableViewCell.swift
//  Knock
//
//  Created by Kamal on 17/09/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class ExistingClientsTableViewCell: UITableViewCell {

    @IBOutlet weak var existingClientView: UIView!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var clientId: UILabel!
    @IBOutlet weak var age: UILabel!
     @IBOutlet weak var sourceList: UILabel!
    @IBOutlet weak var unit: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
