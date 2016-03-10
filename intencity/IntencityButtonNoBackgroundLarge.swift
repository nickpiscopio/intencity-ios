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

class IntencityButtonNoBackgroundLarge: IntencityButtonNoBackground
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)

        self.contentEdgeInsets = UIEdgeInsetsMake(Dimention.LAYOUT_MARGIN, Dimention.LAYOUT_MARGIN, Dimention.LAYOUT_MARGIN, Dimention.LAYOUT_MARGIN)
    }
}