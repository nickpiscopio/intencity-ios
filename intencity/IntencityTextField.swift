//
//  TextField.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/9/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.
//

import UIKit
import QuartzCore

class IntencityTextField: UITextField
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        self.layer.backgroundColor = Color.white.CGColor
        self.layer.borderColor = Color.white.CGColor
        self.layer.borderWidth = Dimention.borderWidth
        self.layer.cornerRadius = Dimention.radius
        self.layer.masksToBounds = false
        self.layer.shadowColor = Color.shadow.CGColor
        self.layer.shadowOffset = CGSizeMake(Dimention.shadow, Dimention.shadow)
        self.layer.shadowOpacity = Dimention.shadowOpacity
        self.layer.shadowRadius = Dimention.shadow
    }
}