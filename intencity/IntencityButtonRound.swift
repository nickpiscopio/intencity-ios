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
        self.layer.shadowOffset = CGSizeMake(Dimention.SHADOW, Dimention.SHADOW)
        self.layer.shadowOpacity = Dimention.SHADOW_OPACITY
        self.layer.shadowRadius = Dimention.SHADOW
        self.layer.shadowColor = Color.shadow_dark.CGColor
        
        buttonUp()
        
        // The callbacks for the button states.
        self.addTarget(self, action: #selector(IntencityButtonRound.buttonUp), forControlEvents: .TouchUpInside)
        self.addTarget(self, action: #selector(IntencityButtonRound.buttonUp), forControlEvents: .TouchUpOutside)
        self.addTarget(self, action: #selector(IntencityButtonRound.buttonUp), forControlEvents: .TouchCancel)
        self.addTarget(self, action: #selector(IntencityButtonRound.buttonDown), forControlEvents: .TouchDown)
        
        self.setTitleColor(Color.white, forState: UIControlState.Highlighted)
        self.setTitleColor(Color.white, forState: UIControlState.Selected)
        self.setTitleColor(Color.white, forState: UIControlState.Normal)
    }
    
    /**
     * The function for when the button has been released.
     */
    func buttonUp()
    {
        self.layer.shadowRadius = Dimention.SHADOW
    }
    
    /**
     * The function for when the button is being pressed.
     */
    func buttonDown()
    {
        self.layer.shadowRadius = Dimention.SHADOW * 2
    }
}