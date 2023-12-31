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

class IntencityButtonRoundDark: IntencityButtonRound
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        self.layer.backgroundColor = Color.accent.cgColor
        self.layer.cornerRadius = Dimention.RADIUS_ROUNDED_BUTTON_DARK
    }
}
