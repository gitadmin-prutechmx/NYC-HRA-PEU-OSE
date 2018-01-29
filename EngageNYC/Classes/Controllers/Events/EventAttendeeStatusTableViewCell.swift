//
//  EventAttendeeStatusTableViewCell.swift
//  EngageNYC
//
//  Created by Kamal on 23/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class EventAttendeeStatusTableViewCell: UITableViewCell {

    @IBOutlet weak var attendeeStatus: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView(forCellObject object : NewEventRegDO, index: IndexPath) {
        
        self.backgroundColor = UIColor.clear
        
        self.accessoryType = .disclosureIndicator
        
        if(object.attendeeStatusId.isEmpty){
            
            attendeeStatus.text = "Select Attendee Status"
        }
        else{
            
            attendeeStatus.text = object.attendeeStatusName
        }
        
        
    }

}
