//
//  ClientCustomTableViewCell.swift
//  Knock
//
//  Created by Cloudzeg Laptop on 7/23/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class ClientCustomTableViewCell: UITableViewCell
{
    @IBOutlet weak var unit: UILabel!
    @IBOutlet weak var lblFirst: UILabel!
    @IBOutlet weak var lblLast: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var sync: UIImageView!
    @IBOutlet weak var lblNoCase: UILabel!
    @IBOutlet weak var unitId: UILabel!
   
    


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
