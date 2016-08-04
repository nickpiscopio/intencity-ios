//
//  IndexedExercise.swift
//  Intencity
//
//  Created by Nick on 8/3/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.
//

import Foundation

class IndexedExercise: NSObject
{
    var index: Int!
    var exercise: Exercise!
    
    init(index: Int, exercise: Exercise)
    {
        self.index = index
        self.exercise = exercise
    }
}