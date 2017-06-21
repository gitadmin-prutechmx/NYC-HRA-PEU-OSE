//
//  LocationCustomViewCell.swift
//  MTXGIS
//
//  Created by Kamal on 23/02/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class LocationCustomViewCell: UITableViewCell {

    @IBOutlet weak var dataLocation: UILabel!
    @IBOutlet weak var dataFullAddress: UILabel!
    @IBOutlet weak var dataLocId: UILabel!
    
    @IBOutlet weak var editLocBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
