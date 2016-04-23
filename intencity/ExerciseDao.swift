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
    func parseJson(json: AnyObject?, searchString: String) throws -> [Exercise]
    {
        var foundSearchResult = false
        
        var exercises = [Exercise]()
        
        if let jsonArray = json as? NSArray
        {
            for exercise in jsonArray
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
                
                let exercise = Exercise(exerciseName: exerciseName, exerciseDescription: "", sets: sets, fromIntencity: true)
                
                // This determines if what we searched for has been returned from the database.
                // This is not case sensitive.
                if (searchString != "" && !foundSearchResult && exerciseName.caseInsensitiveCompare(searchString) == NSComparisonResult.OrderedSame)
                {
                    foundSearchResult = true
                }
                
                exercises.append(exercise)
            }
            
            if (searchString != "" && !foundSearchResult)
            {
                exercises.append(getExercise(searchString))
            }
        }
        else
        {
            throw IntencityError.ParseError
        }
        
        return exercises
    }
    
    /**
     * Gets an exercise with default values.
     *
     * @param exerciseName  The name of teh exercise.
     *
     * @return The exercise.
     */
    func getExercise(exerciseName: String) -> Exercise
    {
        let set = Set(webId: Int(Constant.CODE_FAILED),
                      weight: Float(Constant.CODE_FAILED),
                      reps: Int(Constant.CODE_FAILED),
                      duration: Constant.RETURN_NULL,
                      difficulty: 10,
                      notes: "")
        
        return Exercise(exerciseName: exerciseName, exerciseDescription: "", sets: [ set ], fromIntencity: false)
    }
}