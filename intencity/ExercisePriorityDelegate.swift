//
//  ExercisePriorityDelegate.swift
//  Intencity
//
//  The delegate for when an exercise priority is set.
//
//  Created by Nick Piscopio on 3/22/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

protocol ExercisePriorityDelegate: class
{
    func onSetExercisePriority(_ index: Int, priority: Int)
}
