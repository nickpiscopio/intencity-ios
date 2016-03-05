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
        self.layer.backgroundColor = Color.white.CGColor
        self.layer.borderColor = Color.white.CGColor
        self.layer.borderWidth = Dimention.BORDER_WIDTH
        self.layer.cornerRadius = Dimention.RADIUS
        self.layer.masksToBounds = false
        self.layer.shadowColor = Color.shadow.CGColor
        self.layer.shadowOffset = CGSizeMake(Dimention.SHADOW, Dimention.SHADOW)
        self.layer.shadowOpacity = Dimention.SHADOW_OPACITY
        self.layer.shadowRadius = Dimention.SHADOW
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect
    {
        return CGRectMake(bounds.origin.x + Dimention.TEXTFIELD_MARGIN,
                          bounds.origin.y + Dimention.TEXTFIELD_PADDING,
                          bounds.size.width - Dimention.TEXTFIELD_MARGIN,
                          bounds.size.height - Dimention.TEXTFIELD_PADDING);
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect
    {
        return self.textRectForBounds(bounds);
    }
}