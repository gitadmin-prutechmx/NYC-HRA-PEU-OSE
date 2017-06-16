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
    
    @IBOutlet weak var dataUnit: UILabel!
    @IBOutlet weak var dataUnitId: UILabel!
    @IBOutlet weak var dataFloor: UILabel!
    @IBOutlet weak var pendingIcon: UIImageView!
    
    @IBOutlet weak var dataSyncDate: UILabel!
    @IBOutlet weak var dataSyncStatus: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}


extension UITableViewCell {
    /*func shake(duration: CFTimeInterval = 0.3, pathLength: CGFloat = 15) {
        let position: CGPoint = self.center
        
        let path: UIBezierPath = UIBezierPath()
        path.move(to: CGPointMake(position.x, position.y))
        path.addLine(to: CGPointMake(position.x-pathLength, position.y))
        path.addLineToPoint(CGPointMake(position.x+pathLength, position.y))
        path.addLineToPoint(CGPointMake(position.x-pathLength, position.y))
        path.addLineToPoint(CGPointMake(position.x+pathLength, position.y))
        path.addLineToPoint(CGPointMake(position.x, position.y))
        
        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        
        positionAnimation.path = path.CGPath
        positionAnimation.duration = duration
        positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        CATransaction.begin()
        self.layer.addAnimation(positionAnimation, forKey: nil)
        CATransaction.commit()
    }
 */
}
