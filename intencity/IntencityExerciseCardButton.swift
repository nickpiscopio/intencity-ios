//
//  IntencityExerciseCardButton.swift
//  Intencity
//
//  Created by Nick Piscopio on 3/28/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import QuartzCore

class IntencityExerciseCardButton: IntencityButtonNoBackground
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        // The default parameters for the button.
        self.setTitleColor(Color.secondary_light, for: UIControlState())
        self.setTitleColor(Color.secondary_light, for: .highlighted)
        
        self.contentEdgeInsets = UIEdgeInsetsMake(Dimention.EXERCISE_CARD_BUTTON_LAYOUT_MARGIN, Dimention.EXERCISE_CARD_BUTTON_LAYOUT_MARGIN, Dimention.EXERCISE_CARD_BUTTON_LAYOUT_MARGIN, Dimention.EXERCISE_CARD_BUTTON_LAYOUT_MARGIN)
    }
}
