//
//  UnitsCustomViewCell.swift
//  MTXGIS
//
//  Created by Kamal on 24/02/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class UnitsCustomViewCell: UITableViewCell {
    
    /*@IBOutlet weak var dataUnit: UILabel!
     @IBOutlet weak var dataSyncStatus: UILabel!
     @IBOutlet weak var dataSyncDate: UILabel!
     @IBOutlet weak var dataUnitId: UILabel!*/
    
    
    
    @IBOutlet weak var unit: UILabel!
    @IBOutlet weak var attempt: UIImageView!
    @IBOutlet weak var contact: UIImageView!
    @IBOutlet weak var surveyStatus: UIImageView!
    @IBOutlet weak var sync: UIImageView!
    @IBOutlet weak var syncDate: UILabel!
    @IBOutlet weak var unitId: UILabel!
    @IBOutlet weak var noOfTenants: UILabel!
    
    
    @IBOutlet weak var moreBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}


extension UITableViewCell {
    func shake(duration: CFTimeInterval = 0.3, pathLength: CGFloat = 15) {
        let position: CGPoint = self.center
        
        let path: UIBezierPath = UIBezierPath()
        
        
        path.move(to:  CGPoint(x: position.x, y: position.y))
        path.addLine(to: CGPoint(x:position.x-pathLength, y:position.y))
        path.addLine(to: CGPoint(x:position.x+pathLength, y:position.y))
        path.addLine(to: CGPoint(x:position.x-pathLength, y:position.y))
        path.addLine(to: CGPoint(x:position.x+pathLength, y:position.y))
        path.addLine(to: CGPoint(x:position.x, y:position.y))
        
        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        
        positionAnimation.path = path.cgPath
        positionAnimation.duration = duration
        positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        CATransaction.begin()
        self.layer.add(positionAnimation, forKey: nil)
        CATransaction.commit()
    }
    
}
