//
//  IntencityCardButton.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/13/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.
//

import UIKit
import QuartzCore

class IntencityCardButton: IntencityButtonNoBackground
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        // The default parameters for the button.
        self.setTitleColor(Color.secondary_light, forState: .Normal)
        self.setTitleColor(Color.secondary_light, forState: .Highlighted)
    }
}