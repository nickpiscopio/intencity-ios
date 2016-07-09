//
//  ExerciseData.swift
//  Intencity
//
//  The singleton class which houses the exercises so we can store them in the database if the app closes.
//
//  Created by Nick Piscopio on 2/21/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

class ExerciseData
{
    static var instance: ExerciseData!
    
    var routineName: String
    var exerciseIndex: Int
    var routineState: Int
    
    var exerciseList = [Exercise]()
    
    static func getInstance() -> ExerciseData
    {
        if instance == nil
        {
            instance = ExerciseData.init()
        }
        
        return instance
    }
    
    /**
     * Resets the instance so we can reinitialize it later.
     */
    static func reset()
    {
        instance = nil
    }
    
    /**
     * Initializes the ExerciseData.
     */
    init()
    {
        routineName = ""
        exerciseIndex = 0
        routineState = RoutineState.NONE
        
        addWarmUp()
    }
    
    /**
     * Adds the warm-up exercise to the exercise list.
     */
    func addWarmUp()
    {
        exerciseList.append(Exercise(exerciseName: NSLocalizedString("warm_up", comment: ""), exerciseDescription: NSLocalizedString("warm_up_description", comment: ""), priority: Int(Constant.CODE_FAILED), sets: getDefaultSet(), fromIntencity: false))
    }
    
    /**
     * Adds the stretch exercise to the exercise list.
     */
    func addStretch()
    {
        exerciseList.append(Exercise(exerciseName: NSLocalizedString("stretch", comment: ""), exerciseDescription: NSLocalizedString("stretch_description", comment: ""), priority: Int(Constant.CODE_FAILED), sets: getDefaultSet(), fromIntencity: false))
    }
    
    /**
     * Gets a set with zero values in it for the warm-up and stretch cards.
     */
    func getDefaultSet() -> [Set]
    {
        return [ Set(webId: Int(Constant.CODE_FAILED), weight: Float(Constant.CODE_FAILED), reps: Int(Constant.CODE_FAILED), duration: Constant.RETURN_NULL, difficulty: Int(Constant.CODE_FAILED), notes: Constant.RETURN_NULL) ]
    }
}