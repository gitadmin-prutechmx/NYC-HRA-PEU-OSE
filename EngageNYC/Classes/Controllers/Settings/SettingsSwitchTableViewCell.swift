//
//  SettingsSwitchTableViewCell.swift
//  EngageNYC
//
//  Created by MTX on 1/18/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

protocol SettingsSwitchDelegate{
    func setSwitchValue(switchVal:Bool)
}


class SettingsSwitchTableViewCell: UITableViewCell {
    
    var delegate:SettingsSwitchDelegate?
    @IBOutlet weak var autoSyncSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupView(autoSync:Bool) {
        autoSyncSwitch.isOn = autoSync
    }
    
    @IBAction func switchChanged(_ sender: Any) {
        if(delegate != nil){
            delegate?.setSwitchValue(switchVal: (sender as AnyObject).isOn)
        }
    }
}
