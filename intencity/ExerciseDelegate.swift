//
//  ExerciseDelegate.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/15/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import Foundation

@objc protocol ExerciseDelegate
{
    func onExerciseClicked(_ name: String)
    func onHideClicked(_ indexPath: IndexPath)
    func onEditClicked(_ index: Int)
    func onSetUpdated(_ index: Int)
    func onSetExercisePriority(_ indexPath: IndexPath, morePriority: UIButton, lessPriority: UIButton, increment: Bool)
}
