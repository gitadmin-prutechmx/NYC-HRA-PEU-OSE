//
//  EventSelectContactTableViewCell.swift
//  EngageNYC
//
//  Created by Kamal on 23/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class EventSelectContactTableViewCell: UITableViewCell {
    @IBOutlet weak var selectContact: UILabel!
    
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
        
        if(object.clientId.isEmpty){
            
            selectContact.text = "Select Contact"
        }
        else{
            
            selectContact.text = object.clientName
        }
        
        
    }

}
