//
//  IntencityRoutineDao.swift
//  Intencity
//
//  The data access object for the Intencity Routines.
//
//  Created by Nick Piscopio on 2/14/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

struct IntencityRoutineDao
{
    func parseJson(json: AnyObject?) throws -> [RoutineGroup]
    {
        var group = [RoutineGroup]()
        
        var i = 0
        
        var defaultRoutines = [RoutineRow]()
        var customRoutines = [RoutineRow]()
        
//        var recommended: String?
        
        if let jsonArray = json as? NSArray
        {
            for routines in jsonArray
            {
                let muscleGroup = routines[Constant.COLUMN_DISPLAY_NAME] as! String
                let exerciseDay = routines[Constant.COLUMN_EXERCISE_DAY] as! String
//                recommended = routines[Constant.COLUMN_CURRENT_MUSCLE_GROUP] as? String
                
                i += 1
                
                if (i > 6)
                {
                    customRoutines.append(RoutineRow(title: muscleGroup, rowNumber: Int(exerciseDay)!))
                }
                else
                {
                    defaultRoutines.append(RoutineRow(title: muscleGroup, rowNumber: Int(exerciseDay)!))
                }
            }
            
            group.append(RoutineGroup(title: RoutineViewController.DEFAULT_ROUTINE_TITLE, rows: defaultRoutines))
            group.append(RoutineGroup(title: RoutineViewController.CUSTOM_ROUTINE_TITLE, rows: customRoutines))

        }
        else
        {
            throw IntencityError.ParseError
        }
        
        return group
    }
}