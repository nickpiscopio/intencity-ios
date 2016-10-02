//
//  TextField.swift
//  Intencity
//
//  This is Intencity's TextField class.
//
//  Created by Nick Piscopio on 2/9/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import QuartzCore

class IntencityTextField: UITextField
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        self.textColor = Color.secondary_dark
        self.layer.backgroundColor = Color.white.cgColor
        self.layer.borderColor = Color.white.cgColor
        self.layer.borderWidth = Dimention.BORDER_WIDTH
        self.layer.cornerRadius = Dimention.RADIUS
        self.layer.masksToBounds = false
        self.layer.shadowColor = Color.shadow.cgColor
        self.layer.shadowOffset = CGSize(width: Dimention.SHADOW, height: Dimention.SHADOW)
        self.layer.shadowOpacity = Dimention.SHADOW_OPACITY
        self.layer.shadowRadius = Dimention.SHADOW
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect
    {
        return CGRect(x: bounds.origin.x + Dimention.TEXTFIELD_MARGIN,
                          y: bounds.origin.y + Dimention.TEXTFIELD_PADDING,
                          width: bounds.size.width - Dimention.TEXTFIELD_MARGIN,
                          height: bounds.size.height - Dimention.TEXTFIELD_PADDING);
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect
    {
        return self.textRect(forBounds: bounds);
    }
}
