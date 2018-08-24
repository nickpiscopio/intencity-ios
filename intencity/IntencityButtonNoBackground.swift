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
        self.layer.backgroundColor = Color.transparent.cgColor
        self.layer.borderColor = Color.transparent.cgColor
        self.setTitleColor(Color.primary, for: UIControlState())
        self.setTitleColor(Color.primary, for: .highlighted)
        
        self.layer.borderWidth = Dimention.BORDER_WIDTH
        self.layer.cornerRadius = Dimention.RADIUS
        self.contentEdgeInsets = UIEdgeInsetsMake(Dimention.LAYOUT_MARGIN, Dimention.LAYOUT_MARGIN, Dimention.LAYOUT_MARGIN, Dimention.LAYOUT_MARGIN)
        
        // The callbacks for the button states.
        self.addTarget(self, action: #selector(IntencityButtonNoBackground.buttonUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(IntencityButtonNoBackground.buttonUp), for: .touchUpOutside)
        self.addTarget(self, action: #selector(IntencityButtonNoBackground.buttonUp), for: .touchCancel)
        self.addTarget(self, action: #selector(IntencityButtonNoBackground.buttonDown), for: .touchDown)
    }
    
    /*
    * The function for when the button has been released.
    */
    @objc func buttonUp()
    {
        self.layer.backgroundColor = Color.transparent.cgColor
    }
    
    /*
    * The function for when the button is being pressed.
    */
    @objc func buttonDown()
    {
        self.layer.backgroundColor = Color.shadow.cgColor
    }
}
