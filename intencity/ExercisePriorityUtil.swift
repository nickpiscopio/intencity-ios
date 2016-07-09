//
//  ExercisePriority.swift
//  Intencity
//
//  The class is a utility class for the Exercise Priorities.
//
//  Created by Nick Piscopio on 4/13/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

class ExercisePriorityUtil
{
    static let PRIORITY_LIMIT_UPPER = 40
    static let PRIORITY_LIMIT_LOWER = 0
    static let INCREMENTAL_VALUE = 10
    
    static let HIGH_PRIORITY = NSLocalizedString("high_priority", comment: "")
    static let MEDIUM_PRIORITY = NSLocalizedString("medium_priority", comment: "")
    static let NORMAL_PRIORITY = NSLocalizedString("normal_priority", comment: "")
    static let LOW_PRIORITY = NSLocalizedString("low_priority", comment: "")
    static let HIDDEN = NSLocalizedString("hidden_exercise", comment: "")
    
    /**
     * Sets the priority for the exercise.
     *
     * @param exercisePriority  The current priority we are changing.
     * @param increment         Boolean value of whether or not the exercise should increment or decrement the current priority.
     *
     * @return The new exercise priority.
     */
    static func getExercisePriority(exercisePriority: Int, increment: Bool) -> Int
    {
        var priority = exercisePriority
        
        if (priority < PRIORITY_LIMIT_UPPER && increment)
        {
            priority += INCREMENTAL_VALUE
        }
        else if (priority > PRIORITY_LIMIT_LOWER && !increment)
        {
            priority -= INCREMENTAL_VALUE
        }
        
        return priority
    }
}