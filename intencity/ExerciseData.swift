//
//  ExerciseData.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/21/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.
//

import Foundation

class ExerciseData
{
    static var instance: ExerciseData!
    
    var exerciseList = [Exercise]()
    var exerciseIndex = 0
    
    static func getInstance() -> ExerciseData
    {
        if instance == nil
        {
            instance = ExerciseData.init()
        }
        
        return instance
    }
}