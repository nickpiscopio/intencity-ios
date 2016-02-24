//
//  IntencityPaddedLabel.swift
//  Intencity
//
//  This class is Intencity's version of a label with padding
//
//  Created by Nick Piscopio on 2/9/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import QuartzCore

class IntencityPaddedLabel: UILabel
{
    override func drawTextInRect(rect: CGRect)
    {
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, UIEdgeInsets(top: 0, left: Dimention.CARD_BUTTON_PADDING, bottom: 0, right: Dimention.CARD_BUTTON_PADDING)))
    }
}