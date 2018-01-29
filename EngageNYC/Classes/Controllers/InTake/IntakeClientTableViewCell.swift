//
//  IntakeClientTableViewCell.swift
//  EngageNYC
//
//  Created by MTX on 1/20/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class IntakeClientTableViewCell: UITableViewCell {

    @IBOutlet weak var clientName: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var cases: UILabel!
    @IBOutlet weak var btnMore: UIButton!
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView(forCellObject object : ContactDO, isHighlight:Bool, index: IndexPath) {
        
        // Set Background Color
        if index.row % 2 == 0{
            // White Row
            self.contentView.backgroundColor = UIColor.init(red: 240.0, green: 240.0, blue: 240.0, alpha: 1.0)
        }
        else{
            // Gray Row
            self.contentView.backgroundColor = UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1.000)
            
        }
        
        if(isHighlight){
            
            self.contentView.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) //green
            
        }
        
       
        
        clientName.text = object.contactName
        email.text = object.email
        phone.text = object.phone
        age.text = object.age
        cases.text = object.totalCases
        btnMore.tag = index.row
       
        
    }

}
