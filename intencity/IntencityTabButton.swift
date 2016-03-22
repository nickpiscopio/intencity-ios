//
//  IntencityButtonNoBackground.swift
//  Intencity
//
//  This class is Intencity's version of a button that doesn't have a background until selected.
//
//  Created by Nick Piscopio on 2/9/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import QuartzCore

class IntencityTabButton: UIButton
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        // The default parameters for the button.
        self.layer.backgroundColor = Color.transparent.CGColor
        self.layer.borderColor = Color.transparent.CGColor
        self.setTitleColor(Color.secondary_dark, forState: .Normal)
        self.setTitleColor(Color.secondary_dark, forState: .Highlighted)
        
        self.layer.borderWidth = Dimention.BORDER_WIDTH
        
        self.contentEdgeInsets = UIEdgeInsetsMake(Dimention.TAB_PADDING_TOP_BOTTOM, Dimention.TAB_PADDING_SIDES, Dimention.TAB_PADDING_TOP_BOTTOM, Dimention.TAB_PADDING_SIDES)
        
        // The callbacks for the button states.
        self.addTarget(self, action: #selector(IntencityTabButton.buttonUp), forControlEvents: .TouchUpInside)
        self.addTarget(self, action: #selector(IntencityTabButton.buttonUp), forControlEvents: .TouchUpOutside)
        self.addTarget(self, action: #selector(IntencityTabButton.buttonUp), forControlEvents: .TouchCancel)
        self.addTarget(self, action: #selector(IntencityTabButton.buttonDown), forControlEvents: .TouchDown)
    }
    
    /*
     * The function for when the button has been released.
     */
    func buttonUp()
    {
        self.layer.backgroundColor = Color.transparent.CGColor
    }
    
    /*
     * The function for when the button is being pressed.
     */
    func buttonDown()
    {
        self.layer.backgroundColor = Color.shadow.CGColor
    }
}