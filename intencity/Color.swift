//
//  Color.swift
//  Intencity
//
//  This is a struct for the Intencity's colors.
//
//  Created by Nick Piscopio on 2/8/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

struct Color
{
    static let transparent = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.0)
    
    static let white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    
    static let primary = UIColor(red: 48.0/255.0, green: 157.0/255.0, blue: 219.0/255.0, alpha: 1.0)
    static let primary_dark = UIColor(red: 36.0/255.0, green: 118.0/255.0, blue: 165.0/255.0, alpha: 1.0)
    static let accent  = UIColor(red: 69.0/255.0, green: 178.0/255.0, blue: 157.0/255.0, alpha: 1.0)
    static let active  = UIColor(red: 108.0/255.0, green: 242.0/255.0, blue: 145.0/255.0, alpha: 1.0)
    static let secondary_light  = UIColor(red: 100.0/255.0, green: 112.0/255.0, blue: 130.0/255.0, alpha: 1.0)
    static let secondary_dark  = UIColor(red: 65.0/255.0, green: 64.0/255.0, blue: 66.0/255.0, alpha: 1.0)
    static let page_background  = UIColor(red: 246.0/255.0, green: 246.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    static let shadow  = UIColor(red: 206.0/255.0, green: 206.0/255.0, blue: 206.0/255.0, alpha: 1.0)
    static let shadow_dark  = UIColor(red: 77.0/255.0, green: 86.0/255.0, blue: 101.0/255.0, alpha: 1.0)
    static let card_button_delete_select  = UIColor(red: 255.0/255.0, green: 1.0/255.0, blue: 1.0/255.0, alpha: 1.0)
    static let card_button_delete_deselect  = UIColor(red: 255.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 1.0)
    static let material_red = UIColor(red: 244.0/255.0, green: 67.0/255.0, blue: 54.0/255.0, alpha: 1.0)
    
    static let grey_text_x_transparent = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: Integer.SEARCH_EXERCISE_DIRECTION_ALPHA)
    static let grey_text_transparent = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: Integer.ROUTINE_LEVEL_ALPHA)
}
