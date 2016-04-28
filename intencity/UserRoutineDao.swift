//
//  UserRoutineDao.swift
//  Intencity
//
//  The data access object for the Intencity Routines.
//
//  Created by Nick Piscopio on 2/28/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

struct UserRoutineDao
{
    func parseJson(json: AnyObject?) throws -> [RoutineRow]
    {
        var routineRows = [RoutineRow]()

        var routineNames = [String]()
        
        if let jsonArray = json as? NSArray
        {
            for routines in jsonArray
            {
                let routine = routines[Constant.COLUMN_ROUTINE_NAME] as! String

                routineNames.append(routine)
            }
            
            routineRows.append(RoutineRow(title: "", rows: routineNames))
        }
        else
        {
            throw IntencityError.ParseError
        }
        
        return routineRows
    }
}