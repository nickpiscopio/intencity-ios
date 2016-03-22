//
//  ExerciseDelegate.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/15/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

@objc protocol ExerciseDelegate
{
    func onExerciseClicked(name: String)
    func onHideClicked(indexPath: NSIndexPath)
    func onEditClicked(index: Int)
    func onSetUpdated(index: Int)
    func onSetExercisePriority(indexPath: NSIndexPath, increasing: Bool)
}