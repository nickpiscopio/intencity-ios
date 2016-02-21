//
//  ExerciseData.swift
//  Intencity
//
//  The singleton class which houses the exercises so we can store them in the database if the app closes.
//
//  Created by Nick Piscopio on 2/21/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

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
    }
}