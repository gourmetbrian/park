//
//  CustomTextView.swift
//  Park
//
//  Created by Brian Lane on 11/28/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import UIKit

@IBDesignable
class CustomTextView: UITextView {
    
    @IBInspectable var inset: CGFloat = 0
    
    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet {
            setupView()
        }
    }
    
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5.0
    }
    
    override func prepareForInterfaceBuilder()
    {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    func setupView()
    {
        self.layer.cornerRadius = cornerRadius
        
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.text.removeAll()
//    }



}
