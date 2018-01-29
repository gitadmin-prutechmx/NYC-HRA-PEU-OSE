//
//  ClientCustomTableViewCell.swift
//  Knock
//
//  Created by Cloudzeg Laptop on 7/23/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class ClientCustomTableViewCell: UITableViewCell
{
    @IBOutlet weak var unit: UILabel!
    @IBOutlet weak var lblFirst: UILabel!
    @IBOutlet weak var lblLast: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var sync: UIImageView!
    @IBOutlet weak var lblNoCase: UILabel!
    @IBOutlet weak var unitId: UILabel!
    @IBOutlet weak var syncDate: UILabel!   
    @IBOutlet weak var editBtn: UIButton!
    


    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView(forCellObject object : ContactDO, index: IndexPath) {
        
        // Set Background Color
        if index.row % 2 == 0{
            // White Row
            self.contentView.backgroundColor = UIColor.init(red: 240.0, green: 240.0, blue: 240.0, alpha: 1.0)
        }
        else{
            // Gray Row
            self.contentView.backgroundColor = UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1.000)
            
        }
        
        unit.text = object.unit
        lblFirst.text = object.firstName
        lblLast.text = object.lastName
        lblPhone.text = object.phone
        lblNoCase.text = object.totalCases
        syncDate.text = object.syncDate
        
        if(object.syncDate.isEmpty){
            sync.image = UIImage()
        }
        else{
            sync.image = UIImage(named: "Sync")
        }
        
         editBtn.tag = index.row
       
        //sync.image = UIImage()
    }

}
