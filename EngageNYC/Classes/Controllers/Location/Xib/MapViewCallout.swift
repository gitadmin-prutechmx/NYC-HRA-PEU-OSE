//
//  MapViewCollout.swift
//  Knock
//
//  Created by Cloudzeg Laptop on 6/28/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class MapViewCallout: UIView
{
    var nibView: UIView!
    @IBOutlet weak var btnViewUnits: UIButton!
    @IBOutlet weak var btnEditLocation: UIButton!
    
    @IBOutlet weak var viewLocationStatus: UIView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblLocationStatus: UILabel!
    @IBOutlet weak var lblNoOfUnits: UILabel!
    
    @IBOutlet weak var lblNoClients: UILabel!
    
    @IBOutlet weak var lblAttemptPrecentage: UILabel!
    
    @IBOutlet weak var lblName: UILabel!
    
    //    @IBOutlet weak var lblNoOfUnits: UILabel!
    //
    //    @IBOutlet weak var lblNoClients: UILabel!
    //
    //    @IBOutlet weak var lblAttemptPrecentage: UILabel!
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
       // print("infinite loop")
        super.init(coder: aDecoder)
        // setup()
    }
    
    
    
    func setup() {
        nibView = loadViewFromNib()
        nibView.frame = bounds
        nibView.autoresizingMask = [UIViewAutoresizing.flexibleWidth ,UIViewAutoresizing.flexibleHeight]
        addSubview(nibView)
    }
    
    func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: "MapViewCollout", bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    
    
}
