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
    var exerciseList = [Exercise]()
    var exerciseIndex: Int
    
    static func getInstance() -> ExerciseData
    {
        if instance == nil
        {
            instance = ExerciseData.init()
        }
        
        return instance
    }
    
    init()
    {
        routineName = ""
        exerciseIndex = 0
        
        addWarmUp()
    }
    
    /**
     * Adds the warm-up exercise to the exercise list.
     */
    func addWarmUp()
    {
        exerciseList.append(Exercise(name: NSLocalizedString("warm_up", comment: ""), description: NSLocalizedString("warm_up_description", comment: ""), sets: getDefaultSet()))
    }
    
    /**
     * Adds the stretch exercise to the exercise list.
     */
    func addStretch()
    {
        exerciseList.append(Exercise(name: NSLocalizedString("stretch", comment: ""), description: NSLocalizedString("stretch_description", comment: ""), sets: getDefaultSet()))
    }
    
    /**
     * Gets a set with zero values in it for the warm-up and stretch cards.
     */
    func getDefaultSet() -> [Set]
    {
        return [ Set(webId: Int(Constant.CODE_FAILED), weight: Float(Constant.CODE_FAILED), reps: Int(Constant.CODE_FAILED), duration: Constant.RETURN_NULL, difficulty: Int(Constant.CODE_FAILED), notes: Constant.RETURN_NULL) ]
    }
}