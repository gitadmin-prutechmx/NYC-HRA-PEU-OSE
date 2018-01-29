//
//  AssignmentLocationHistoryTableViewCell.swift
//  EngageNYC
//
//  Created by MTX on 1/13/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class AssignmentLocationHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var notes: UILabel!
    @IBOutlet weak var outcomes: UILabel!
    @IBOutlet weak var date: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView(forCellObject object : AssignmentLocationNotesDO, index: IndexPath) {
        
        // Set Background Color
        if index.row % 2 == 0{
            // White Row
            self.contentView.backgroundColor = UIColor.init(red: 240.0, green: 240.0, blue: 240.0, alpha: 1.0)
        }
        else{
            // Gray Row
            self.contentView.backgroundColor = UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1.000)
            
        }
        
        name.text = object.canvasserName
        notes.text = object.notes
        outcomes.text = object.locStatus
        date.text = object.createdDate
        
    }

}
