//
//  IntencityCircleView.swift
//  Intencity
//  
//  This class makes a view a circle.
//
//  Created by Nick Piscopio on 3/31/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import QuartzCore

class IntencityCircleView: UIView
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        // The default parameters for the button.
        self.layer.borderColor = Color.transparent.CGColor
        self.layer.cornerRadius = Dimention.RADIUS_ROUNDED_BUTTON_RANKING_USER
        self.layer.backgroundColor = Color.accent.CGColor
    }
}