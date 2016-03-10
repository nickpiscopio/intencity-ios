//
//  IntencityButtonNoBackgroundLarge.swift
//  Intencity
//
//  This class is Intencity's version of a button that doesn't have a background until selected.
//
//  Created by Nick Piscopio on 2/9/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import QuartzCore

class IntencityButtonNoBackgroundSmall: IntencityButtonNoBackground
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        let padding = Dimention.LAYOUT_MARGIN / 2

        self.contentEdgeInsets = UIEdgeInsetsMake(padding, padding, padding, padding)
    }
}