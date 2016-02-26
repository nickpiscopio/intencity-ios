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

class IntencityButtonRound: UIButton
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        // The default parameters for the button.
        self.layer.borderColor = Color.transparent.CGColor
        self.layer.borderWidth = Dimention.BORDER_WIDTH
        self.layer.masksToBounds = false
        self.layer.shadowColor = Color.shadow.CGColor
        self.layer.shadowOffset = CGSizeMake(Dimention.SHADOW, Dimention.SHADOW)
        self.layer.shadowOpacity = Dimention.SHADOW_OPACITY
        self.layer.shadowRadius = Dimention.SHADOW
        self.layer.cornerRadius = Dimention.RADIUS_ROUNDED_BUTTON
        self.layer.backgroundColor = Color.secondary_dark.CGColor
        
        // The callbacks for the button states.
        self.addTarget(self, action: "buttonUp", forControlEvents: .TouchUpInside)
        self.addTarget(self, action: "buttonUp", forControlEvents: .TouchUpOutside)
        self.addTarget(self, action: "buttonDown", forControlEvents: .TouchDown)
    }
    
    /*
        The function for when the button has been released.
    */
    func buttonUp()
    {
        self.layer.backgroundColor = Color.secondary_dark.CGColor
    }
    
    /*
        The function for when the button is being pressed.
    */
    func buttonDown()
    {
        self.layer.backgroundColor = Color.secondary_light.CGColor
    }
}