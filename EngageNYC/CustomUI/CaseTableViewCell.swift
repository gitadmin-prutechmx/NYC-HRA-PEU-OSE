//
//  CaseTableViewCell.swift
//  Knock
//
//  Created by Kamal on 28/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class CaseTableViewCell: UITableViewCell {

    
    @IBOutlet weak var caseNo: UILabel!
    @IBOutlet weak var caseId: UILabel!
    
    @IBOutlet weak var ownerName: UILabel!
  
    @IBOutlet weak var dateOfIntake: UILabel!
    
    @IBOutlet weak var caseView: UIView!
    @IBOutlet weak var caseStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
