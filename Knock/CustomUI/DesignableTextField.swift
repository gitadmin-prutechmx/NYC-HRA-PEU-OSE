//
//  DesignableTextField.swift
//  MTXIOSDesign
//
//  Created by Kamal on 04/02/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableTextField: UITextField {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
           
        }
    }
    
    @IBInspectable var leftImage: UIImage?{
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var leftPadding: CGFloat = 0 {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        
        if let image = leftImage {
            
            leftViewMode = .always
            
            let imageView = UIImageView(frame:CGRect(x: leftPadding, y: 0, width: 17, height: 17))
            
            imageView.image = image
            
            let width = leftPadding + 20
            
            let view = UIView(frame: CGRect(x: 0, y: 0 , width: width, height: 17))
            view.addSubview(imageView)
                
            leftView = view
            
           
            
            
        } else {
            //image is nill
            
            leftViewMode = .never
        }
        
    }

}
