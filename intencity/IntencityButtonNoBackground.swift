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

class IntencityButtonNoBackground: UIButton
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        // The default parameters for the button.
        self.layer.backgroundColor = Color.transparent.CGColor
        self.layer.borderColor = Color.transparent.CGColor
        self.setTitleColor(Color.primary, forState: .Normal)
        self.setTitleColor(Color.primary, forState: .Highlighted)
        
        self.layer.borderWidth = Dimention.BORDER_WIDTH
        self.layer.cornerRadius = Dimention.RADIUS
        self.contentEdgeInsets = UIEdgeInsetsMake(Dimention.LAYOUT_MARGIN, Dimention.LAYOUT_MARGIN, Dimention.LAYOUT_MARGIN, Dimention.LAYOUT_MARGIN)
        
        // The callbacks for the button states.
        self.addTarget(self, action: #selector(IntencityButtonNoBackground.buttonUp), forControlEvents: .TouchUpInside)
        self.addTarget(self, action: #selector(IntencityButtonNoBackground.buttonUp), forControlEvents: .TouchUpOutside)
        self.addTarget(self, action: #selector(IntencityButtonNoBackground.buttonUp), forControlEvents: .TouchCancel)
        self.addTarget(self, action: #selector(IntencityButtonNoBackground.buttonDown), forControlEvents: .TouchDown)
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