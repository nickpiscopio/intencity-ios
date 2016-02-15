//
//  IntencityCardView.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/14/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.
//

import UIKit
import QuartzCore

class IntencityCardView: UIView
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
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
}