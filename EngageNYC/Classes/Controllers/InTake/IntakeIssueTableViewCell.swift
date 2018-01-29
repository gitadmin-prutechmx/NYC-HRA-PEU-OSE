//
//  IntakeIssueTableViewCell.swift
//  EngageNYC
//
//  Created by MTX on 1/20/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class IntakeIssueTableViewCell: UITableViewCell {
    @IBOutlet weak var issueNo: UILabel!
    @IBOutlet weak var issueType: UILabel!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupView(forCellObject object : IssueDO, index: IndexPath) {
        
        // Set Background Color
        if index.row % 2 == 0{
            // White Row
            self.contentView.backgroundColor = UIColor.init(red: 240.0, green: 240.0, blue: 240.0, alpha: 1.0)
        }
        else{
            // Gray Row
            self.contentView.backgroundColor = UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1.000)
            
        }
        
        if(object.dbActionStatus == actionStatus.temp.rawValue){
            self.contentView.backgroundColor = UIColor.yellow
        }
        
        issueType.text = object.issueType
        issueNo.text = object.issueNo
        contactName.text = object.contactName
        
        moreBtn.tag = index.row
        
    }
    
}
