//
//  IntencityButton.swift
//  Intencity
//  
//  This class is Intencity's version of a button.
//
//  Created by Nick Piscopio on 2/9/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.
//

import UIKit
import QuartzCore

class IntencityButtonView: UIView
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        // The default parameters for the view.
        self.layer.cornerRadius = Dimention.RADIUS
        self.layer.backgroundColor = Color.shadow.CGColor
    }
}