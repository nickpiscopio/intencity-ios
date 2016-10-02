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
        self.layer.backgroundColor = Color.transparent.cgColor
        self.layer.borderColor = Color.transparent.cgColor
        self.setTitleColor(Color.secondary_dark, for: UIControlState())
        self.setTitleColor(Color.secondary_dark, for: .highlighted)
        
        self.layer.borderWidth = Dimention.BORDER_WIDTH
        
        self.contentEdgeInsets = UIEdgeInsetsMake(Dimention.TAB_PADDING_TOP_BOTTOM, Dimention.TAB_PADDING_SIDES, Dimention.TAB_PADDING_TOP_BOTTOM, Dimention.TAB_PADDING_SIDES)
        
        // The callbacks for the button states.
        self.addTarget(self, action: #selector(IntencityTabButton.buttonUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(IntencityTabButton.buttonUp), for: .touchUpOutside)
        self.addTarget(self, action: #selector(IntencityTabButton.buttonUp), for: .touchCancel)
        self.addTarget(self, action: #selector(IntencityTabButton.buttonDown), for: .touchDown)
    }
    
    /*
     * The function for when the button has been released.
     */
    func buttonUp()
    {
        self.layer.backgroundColor = Color.transparent.cgColor
    }
    
    /*
     * The function for when the button is being pressed.
     */
    func buttonDown()
    {
        self.layer.backgroundColor = Color.shadow.cgColor
    }
}
