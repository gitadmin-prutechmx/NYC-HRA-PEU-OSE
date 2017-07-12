//
//  EventAssignmentViewCell.swift
//  Knock
//
//  Created by Kamal on 13/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class EventAssignmentViewCell: UITableViewCell {

    @IBOutlet weak var assignmentName: UILabel!
    
    @IBOutlet weak var eventName: UILabel!
    
    @IBOutlet weak var locations: UILabel!
    
    @IBOutlet weak var units: UILabel!
    
    @IBOutlet weak var completePercent: UILabel!
    
    @IBOutlet weak var noOfClients: UILabel!
    
    @IBOutlet weak var assignmentId: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
