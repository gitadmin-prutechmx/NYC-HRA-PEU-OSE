//
//  SettingsSliderTableViewCell.swift
//  EngageNYC
//
//  Created by MTX on 1/19/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

protocol SettingsSliderDelegate{
    func setSliderValue(sliderValue:Int)
}

class SettingsSliderTableViewCell: UITableViewCell {
    
    var delegate:SettingsSliderDelegate?
    
    @IBOutlet weak var syncTimeLabelText: UILabel!
    @IBOutlet weak var syncTimeSlider: UISlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView(syncTime:String) {
       syncTimeLabelText.text = syncTime
       syncTimeSlider.value = Float(syncTime)!
    }
    
    @IBAction func syncTimeSlider(_ sender: UISlider) {
        
        let currentValue = Int(sender.value)
        syncTimeLabelText.text = "\(currentValue)"
        
        if delegate != nil{
            delegate?.setSliderValue(sliderValue: currentValue)
        }
    }

}
