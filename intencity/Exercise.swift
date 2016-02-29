//
//  Exercise.swift
//  Intencity
//
//  The class for the exercises the user does.
//
//  Created by Nick Piscopio on 2/14/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

class Exercise: NSObject
{
    var exerciseName = ""
    var exerciseDescription = ""
    var sets: [Set] = []
    
    init(exerciseName: String, exerciseDescription: String, sets: [Set])
    {
        self.exerciseName = exerciseName
        self.exerciseDescription = exerciseDescription
        self.sets = sets
    }
}