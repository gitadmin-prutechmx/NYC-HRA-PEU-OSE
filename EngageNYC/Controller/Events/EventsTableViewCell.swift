//
//  EventsTableViewCell.swift
//  EngageNYCDev
//
//  Created by MTX on 1/3/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class EventsTableViewCell: UITableViewCell
{
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var address: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupView(forCellObject object : EventDO, index: IndexPath) {
        
        // Set Backgroung Color
        if index.row % 2 == 0{
            // White Row
            self.contentView.backgroundColor = UIColor.init(red: 240.0, green: 240.0, blue: 240.0, alpha: 1.0)
        }
        else{
            // Gray Row
            self.contentView.backgroundColor = UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1.000)

        }
        
        eventName.text = object.name
        startTime.text = object.startTime
        endTime.text = object.endTime
        date.text = object.date
        type.text = object.type
        address.text = object.address
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
