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
    var sessionId: Int
    var exerciseName = ""
    var exerciseDescription = ""
    var priority: Int
    var sets: [Set] = []
    var fromIntencity: Bool
    
    init(sessionId: Int, exerciseName: String, exerciseDescription: String, priority: Int, sets: [Set], fromIntencity: Bool)
    {
        self.sessionId = sessionId
        self.exerciseName = exerciseName
        self.exerciseDescription = exerciseDescription
        self.priority = priority
        self.sets = sets
        self.fromIntencity = fromIntencity
    }
}
