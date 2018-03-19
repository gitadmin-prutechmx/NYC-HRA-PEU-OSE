//
//  LocationCustomViewCell.swift
//  MTXGIS
//
//  Created by Kamal on 23/02/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblStreet: UILabel!
    @IBOutlet weak var lblAdditionalAddress: UILabel!
    @IBOutlet weak var imgLocStatus: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupView(forCellObject object : MapLocationDO, index: IndexPath) {
        
        let selectionView = UIView()
        selectionView.backgroundColor = UIColor.init(red: 76.0/255.0, green: 76.0/255.0, blue: 76.0/255.0, alpha: 1) //gray
        
        self.selectedBackgroundView = selectionView
        
        lblStreet.text = object.street
        lblAdditionalAddress.text = object.additionalAddress

        lblStreet.textColor = UIColor.white
        lblAdditionalAddress.textColor = UIColor.white
        
        if(object.locStatus == locationStatus.pending.rawValue){
            imgLocStatus.isHidden = false
            imgLocStatus.image = UIImage(named: "Planned")
        }
        else if(object.locStatus == locationStatus.completed.rawValue){
            imgLocStatus.isHidden = false
            imgLocStatus.image = UIImage(named: "Complete")
        }
        else if(object.locStatus == locationStatus.inprogress.rawValue){
             imgLocStatus.isHidden = false
             imgLocStatus.image = UIImage(named: "InProgress")
        }
        else if( object.locStatus == locationStatus.addressNotExist.rawValue || object.locStatus == locationStatus.vacant.rawValue || object.locStatus == locationStatus.temporarilyInaccessible.rawValue || object.locStatus == locationStatus.permanentlyInaccessible.rawValue || object.locStatus == locationStatus.doNotWalk.rawValue || object.locStatus == locationStatus.nonResidential.rawValue){
            imgLocStatus.isHidden = false
            imgLocStatus.image = UIImage(named: "Blocked")
            
            lblStreet.textColor = UIColor.red
            lblAdditionalAddress.textColor = UIColor.red
            
        }
        else{
            imgLocStatus.isHidden = true
        }
        
        
    }
    
    
    
}
