//
//  SortingButton.swift
//  Knock
//
//  Created by Kamal on 26/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import Foundation


class SortingButton {
    
    class func setSelectedSortingBtn(btn:UIButton){
        
        btn.backgroundColor = UIColor(red: 0/255, green: 128/255, blue: 255/255, alpha: 1)
        btn.setTitleColor(UIColor.white, for: UIControlState.normal)
        
        btn.layer.borderColor = UIColor.clear.withAlphaComponent(0.5).cgColor
        btn.layer.borderWidth = 0
        
        
        
        
    }
    
    class func resetSortingBtn(btn:UIButton){
        btn.backgroundColor = UIColor.white
        btn.setTitleColor(UIColor.black, for: UIControlState.normal)
        
        btn.layer.borderColor = UIColor.clear.withAlphaComponent(0.5).cgColor
        btn.layer.borderWidth = 0.5
        
        btn.setImage(nil, for: .normal)
    }
    
    class func resetButtonImage(btn:UIButton){
        btn.setImage(nil, for: .normal)
        
    }
    
    
    
    class func getSortingType(btn:UIButton)->Bool{
        
        if let currentBtnImg =  btn.currentImage{
            
            if(currentBtnImg == UIImage(named: "SortingUp.png")){
                
                return true
            }
            else{
                return false
            }
        }
        else{
            return false
        }
        
    }
    
    
 
    class func setSortingType(btn:UIButton,type:Bool? = true){
        
        if let currentBtnImg =  btn.currentImage{
            
            if(currentBtnImg == UIImage(named: "SortingUp.png")){
                
                if let image = UIImage(named: "SortingDown.png") {
                    btn.setImage(image, for: .normal)
                    btn.tintColor = UIColor.white
                    
                }
            }
            else{
                if let image = UIImage(named: "SortingUp.png") {
                    btn.setImage(image, for: .normal)
                    btn.tintColor = UIColor.white
                }
            }
        }
        else{
            if(type == true){
                if let image = UIImage(named: "SortingUp.png") {
                    btn.setImage(image, for: .normal)
                    btn.tintColor = UIColor.white
                }
            }
            else{
                if let image = UIImage(named: "SortingDown.png") {
                    btn.setImage(image, for: .normal)
                    btn.tintColor = UIColor.white
                }
            }
        }
        
        
        
        
    }
}
