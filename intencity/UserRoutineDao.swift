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
    func parseJson(_ json: [AnyObject]?) throws -> [RoutineGroup]
    {
        var groups = [RoutineGroup]()

        var routineNames = [RoutineRow]()
        
        if let jsonArray = json
        {
            for routines in jsonArray
            {
                let routine = routines[Constant.COLUMN_ROUTINE_NAME] as! String
                let routineNumber = routines[Constant.COLUMN_EXERCISE_DAY] as! String

                routineNames.append(RoutineRow(title: routine, rowNumber: Int(routineNumber)!))
            }
            
            groups.append(RoutineGroup(title: "", rows: routineNames))
        }
        else
        {
            throw IntencityError.parseError
        }
        
        return groups
    }
}
