//
//  MapViewCollout.swift
//  Knock
//
//  Created by Cloudzeg Laptop on 6/28/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class MapViewCollout: UIView
{
    @IBOutlet weak var lblStreet: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    var nibView: UIView!
    @IBOutlet weak var lblZip: UILabel!
    @IBOutlet weak var lblState: UILabel!
    @IBOutlet weak var lblBorough: UILabel!
    @IBOutlet weak var lbllattitude: UILabel!
    @IBOutlet weak var lblLogitude: UILabel!
    @IBOutlet weak var btnArrow:UIButton!
    @IBOutlet weak var lblAdress: UILabel!
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        print("infinite loop")
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
