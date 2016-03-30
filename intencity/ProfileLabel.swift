//
//  ProfileLabel.swift
//  Intencity
//  
//  This class is a label for the profile screen.
//
//  Created by Nick Piscopio on 3/28/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.
//

import UIKit
import QuartzCore

class ProfileLabel: UILabel
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        // The default parameters for the label.
        self.textColor = Color.white
        self.layer.shadowOffset = CGSizeMake(Dimention.SHADOW, Dimention.SHADOW)
        self.layer.shadowOpacity = Dimention.SHADOW_OPACITY
        self.layer.shadowColor = Color.shadow_dark.CGColor
        self.layer.shadowRadius = Dimention.SHADOW
    }
}