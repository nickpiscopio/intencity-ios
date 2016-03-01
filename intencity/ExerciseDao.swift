//
//  ExerciseDao.swift
//  Intencity
//
//  The data access object for exercise.
//
//  Created by Nick Piscopio on 2/14/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

struct ExerciseDao
{
    func parseJson(json: AnyObject?) -> [Exercise]
    {
        var exercises = [Exercise]()
        
        for exercise in json as! NSArray
        {
            let exerciseName = exercise[Constant.COLUMN_EXERCISE_NAME] as! String
            let weight = exercise[Constant.COLUMN_EXERCISE_WEIGHT]
            let reps = exercise[Constant.COLUMN_EXERCISE_REPS]
            let duration = exercise[Constant.COLUMN_EXERCISE_DURATION]
            let difficulty = exercise[Constant.COLUMN_EXERCISE_DIFFICULTY]
            let notes = exercise[Constant.COLUMN_NOTES]
            
            let sets = [ Set(webId: Int(Constant.CODE_FAILED),
                weight: !(weight is NSNull) ? Float(weight as! String)! : Float(Constant.CODE_FAILED),
                reps: !(reps is NSNull) ? Int(reps as! String)! : Int(Constant.CODE_FAILED),
                duration: !(duration is NSNull) ? duration as! String : Constant.RETURN_NULL,
                difficulty: !(difficulty is NSNull) ? Int(difficulty as! String)! : 10,
                notes: !(notes is NSNull) ? notes as! String : "") ]
            
            let exercise = Exercise(exerciseName: exerciseName, exerciseDescription: "", sets: sets)
            
            exercises.append(exercise)
        }
        
        return exercises
    }
}