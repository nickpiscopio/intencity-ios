//
//  MenuExerciseDelegate.swift
//  Intencity
//
//  The callback for the MenuExerciseDelegate.
//
//  Created by Nick Piscopio on 2/10/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

@objc protocol MenuExerciseDelegate
{    
    func onExerciseCheckboxChecked(exerciseName: String)
}