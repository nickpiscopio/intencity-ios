//
//  IntencityCardView.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/14/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import QuartzCore

class IntencityCardView: UIView
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        self.layer.backgroundColor = Color.white.cgColor
        self.layer.borderColor = Color.white.cgColor
        self.layer.borderWidth = 0
        self.layer.cornerRadius = Dimention.RADIUS
        self.layer.masksToBounds = false
        self.layer.shadowColor = Color.shadow.cgColor
        self.layer.shadowOffset = CGSize(width: Dimention.SHADOW, height: Dimention.SHADOW)
        self.layer.shadowOpacity = Dimention.SHADOW_OPACITY
        self.layer.shadowRadius = Dimention.SHADOW
    }
}
