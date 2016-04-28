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
    func parseJson(json: AnyObject?) throws -> [RoutineRow]
    {
        var routineRows = [RoutineRow]()
        
        var i = 0
        
        var defaultRoutines = [String]()
        var customRoutines = [String]()
        
//        var recommended: String?
        
        if let jsonArray = json as? NSArray
        {
            for routines in jsonArray
            {
                let muscleGroup = routines[Constant.COLUMN_DISPLAY_NAME] as! String
//                recommended = routines[Constant.COLUMN_CURRENT_MUSCLE_GROUP] as? String
                
                i += 1
                
                if (i > 6)
                {
                    customRoutines.append(muscleGroup)
                }
                else
                {
                    defaultRoutines.append(muscleGroup)
                }
            }
            
            routineRows.append(RoutineRow(title: RoutineViewController.DEFAULT_ROUTINE_TITLE, rows: defaultRoutines))
            routineRows.append(RoutineRow(title: RoutineViewController.CUSTOM_ROUTINE_TITLE, rows: customRoutines))

        }
        else
        {
            throw IntencityError.ParseError
        }
        
        return routineRows
    }
}