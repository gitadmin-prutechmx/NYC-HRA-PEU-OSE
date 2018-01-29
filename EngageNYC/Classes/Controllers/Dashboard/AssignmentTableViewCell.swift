//
//  AssignmentTableViewCell.swift
//  EngageNYC
//
//  Created by MTX on 1/8/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class AssignmentTableViewCell: UITableViewCell {

    @IBOutlet weak var assignmentName: UILabel!
    
    @IBOutlet weak var eventName: UILabel!
    
    @IBOutlet weak var totalLocations: UILabel!
    
    @IBOutlet weak var totalUnits: UILabel!
    
    @IBOutlet weak var completePercent: UILabel!
    
    @IBOutlet weak var totalContacts: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView(forCellObject object : AssignmentDO, index: IndexPath) {
        
        // Set Background Color
        if index.row % 2 == 0{
            // White Row
            self.contentView.backgroundColor = UIColor.init(red: 240.0, green: 240.0, blue: 240.0, alpha: 1.0)
        }
        else{
            // Gray Row
            self.contentView.backgroundColor = UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1.000)
            
        }
        
        eventName.text = object.eventName
        assignmentName.text = object.assignmentName
        totalLocations.text = object.totalLocations
        totalContacts.text = object.totalContacts
        totalUnits.text = object.totalUnits
        completePercent.text = object.completePercent
        
    }
    
    

}
