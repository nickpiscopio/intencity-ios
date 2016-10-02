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

class IntencityRoundView: UIView
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        // The default parameters for the button.
        self.layer.borderColor = Color.transparent.cgColor
        self.layer.borderWidth = Dimention.BORDER_WIDTH
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: Dimention.SHADOW_SMALL, height: Dimention.SHADOW_SMALL)
        self.layer.shadowOpacity = Dimention.SHADOW_OPACITY
        self.layer.shadowRadius = Dimention.SHADOW_SMALL
        self.layer.shadowColor = Color.shadow_dark.cgColor
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.backgroundColor = Color.card_button_delete_deselect.cgColor
    }
}
