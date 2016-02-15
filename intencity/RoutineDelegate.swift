//
//  RoutineDelegate.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/13/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

@objc protocol RoutineDelegate
{
    func onStartExercising(routine: Int)
}