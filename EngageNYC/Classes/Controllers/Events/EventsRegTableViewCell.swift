//
//  EventsRegTableViewCell.swift
//  EngageNYCDev
//
//  Created by Kamal on 09/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class EventsRegTableViewCell: UITableViewCell {

    @IBOutlet weak var clientName: UILabel!
    @IBOutlet weak var regDate: UILabel!
    @IBOutlet weak var atendeeStatus: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupView(forCellObject object : EventRegDO, index: IndexPath) {
        
        // Set Background Color
        if index.row % 2 == 0{
            // White Row
            self.contentView.backgroundColor = UIColor.init(red: 240.0, green: 240.0, blue: 240.0, alpha: 1.0)
        }
        else{
            // Gray Row
            self.contentView.backgroundColor = UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1.000)
            
        }
        
        clientName.text = object.clientName
        regDate.text = object.regDate
        atendeeStatus.text = object.attendeeStatus
        

        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
