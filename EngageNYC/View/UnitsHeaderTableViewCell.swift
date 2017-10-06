//
//  UnitsHeaderTableViewCell.swift
//  Knock
//
//  Created by Biju rajan on 16/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class UnitsHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var SyncDateleading: NSLayoutConstraint!
    @IBOutlet weak var ClientLeading: NSLayoutConstraint!
    @IBOutlet weak var SurveyLeading: NSLayoutConstraint!
    @IBOutlet weak var ContactLeading: NSLayoutConstraint!
    @IBOutlet weak var SyncLeading: NSLayoutConstraint!
    @IBOutlet weak var AttemptLeading: NSLayoutConstraint!
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    func viewWillTransitionToSize(_ size: CGSize,withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator)
    {
     setUp()
    }
    func setUp()
    {
        if UIDevice.current.orientation.isLandscape
        {
            AttemptLeading.constant = 80.0
            ContactLeading.constant = 20.0
           SurveyLeading.constant = 10.0
            ClientLeading.constant = 30.0
            SyncLeading.constant = 10.0
           SyncDateleading.constant = 10.0
            print("Landscape")
        } else
        {
           AttemptLeading.constant = 30.0
            ContactLeading.constant = 10.0
        SurveyLeading.constant = 10.0
           ClientLeading.constant = 10.0
         SyncLeading.constant = 10.0
           SyncDateleading.constant = 10.0
            print("Portrait")
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
       // print("infinite loop")
        super.init(coder: aDecoder)
         //setUp()
    }
    

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
