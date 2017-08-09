//
//  CaseTableViewCell.swift
//  Knock
//
//  Created by Kamal on 28/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class CaseTableViewCell: UITableViewCell {

    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var caseNo: UILabel!
    @IBOutlet weak var caseId: UILabel!
    
  
    @IBOutlet weak var viewImg: UIImageView!
    @IBOutlet weak var btnView: UIButton!
    
    @IBOutlet weak var editImg: UIImageView!
    @IBOutlet weak var btnEdit: UIButton!
    
    @IBOutlet weak var caseView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
