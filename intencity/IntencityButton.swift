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

class IntencityButton: UIButton
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        // The default parameters for the button.
        self.layer.borderColor = Color.transparent.cgColor
        self.setTitleColor(Color.page_background, for: UIControlState())
        self.setTitleColor(Color.page_background, for: .highlighted)
        self.layer.borderWidth = Dimention.BORDER_WIDTH
        self.layer.cornerRadius = Dimention.RADIUS
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: Dimention.SHADOW, height: Dimention.SHADOW)
        self.layer.shadowOpacity = Dimention.SHADOW_OPACITY
        self.layer.shadowColor = Color.shadow_dark.cgColor
        self.layer.backgroundColor = Color.accent.cgColor
        
        self.contentEdgeInsets = UIEdgeInsetsMake(Dimention.BUTTON_PADDING, Dimention.BUTTON_PADDING, Dimention.BUTTON_PADDING, Dimention.BUTTON_PADDING)
        
        buttonUp()
        
        // The callbacks for the button states.
        self.addTarget(self, action: #selector(IntencityButton.buttonUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(IntencityButton.buttonUp), for: .touchUpOutside)
        self.addTarget(self, action: #selector(IntencityButton.buttonUp), for: .touchCancel)
        self.addTarget(self, action: #selector(IntencityButton.buttonDown), for: .touchDown)
        
        self.setTitleColor(Color.white, for: UIControlState.highlighted)
        self.setTitleColor(Color.white, for: UIControlState.selected)
        self.setTitleColor(Color.white, for: UIControlState())
    }
    
    /**
     * The function for when the button has been released.
     */
    @objc func buttonUp()
    {
        self.layer.shadowRadius = Dimention.SHADOW
    }
    
    /**
     * The function for when the button is being pressed.
     */
    @objc func buttonDown()
    {
        self.layer.shadowRadius = Dimention.SHADOW * 2
    }
}
