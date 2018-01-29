//
//  UnitsCustomViewCell.swift
//  MTXGIS
//
//  Created by Kamal on 24/02/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class UnitsCustomTableViewCell: UITableViewCell {

    
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
    
    func setupView(forCellObject object : LocationUnitDO, index: IndexPath) {
        
        // Set Background Color
        if index.row % 2 == 0{
            // White Row
            self.contentView.backgroundColor = UIColor.init(red: 240.0, green: 240.0, blue: 240.0, alpha: 1.0)
        }
        else{
            // Gray Row
            self.contentView.backgroundColor = UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1.000)
            
        }
        
        unit.text = object.unitName
        noOfTenants.text = object.totalContacts
        
        syncDate.text = object.syncDate
        surveyStatus.image = UIImage()
        sync.image = UIImage()
        
        if(object.attempted == boolVal.yes.rawValue){
            attempt.image = UIImage(named: "Yes")
        }
        else if(object.attempted == boolVal.no.rawValue){
            attempt.image = UIImage(named: "No")
        }
        else{
            attempt.image = UIImage()
        }
        
        if(object.contacted == boolVal.yes.rawValue){
            contact.image = UIImage(named: "Yes")
        }
        else if(object.contacted == boolVal.no.rawValue){
            contact.image = UIImage(named: "No")
        }
        else{
            contact.image = UIImage()
        }
        
        if(object.surveyStatus == actionStatus.completeSurvey.rawValue){
            surveyStatus.image = UIImage(named: "Yes")
        }
        else if(object.surveyStatus == actionStatus.inProgressSurvey.rawValue){
            surveyStatus.image = UIImage(named: "SurveyInProgress")
        }
        else{
            if(object.surveySyncDate.isEmpty){
                surveyStatus.image = UIImage()
            }
            else{
                surveyStatus.image = UIImage(named: "Yes")
            }
        }
        
        
        
        if(object.syncDate.isEmpty){
            sync.image = UIImage()
        }
        else{
             sync.image = UIImage(named: "Sync")
        }
        
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
