//
//  ExerciseDelegate.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/29/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

@objc protocol ExerciseSearchDelegate
{
    func onExerciseAdded(_ exercise: Exercise)
    func onExerciseClicked(_ exerciseName: String)
}
