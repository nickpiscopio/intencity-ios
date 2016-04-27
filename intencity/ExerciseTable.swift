//
//  ExerciseTable.swift
//  Intencity
//
//  The Exercise table in the database.
//
//  In SQLite, table rows normally have a 64-bit signed integer ROWID which is unique among all
//  rows in the same table.
//
//  You can access the ROWID of an SQLite table using one of the special column names
//  ROWID, _ROWID_, or OID.
//
//  https://www.sqlite.org/autoinc.html
//
//  Created by Nick Piscopio on 2/21/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

struct ExerciseTable
{
    static let TABLE_NAME = "Exercise";
    
    static let COLUMN_ROUTINE_STATE = "RoutineState";
    static let COLUMN_ROUTINE_NAME = "RoutineName";
    // The last exercise we left off at.
    static let COLUMN_INDEX = "LastExerciseIndex";
    static let COLUMN_NAME = "ExerciseName";
    static let COLUMN_DESCRIPTION = "ExerciseDescription";
    static let COLUMN_WEB_ID = "WebId";
    static let COLUMN_WEIGHT = "ExerciseWeight";
    static let COLUMN_REP = "ExerciseRep";
    static let COLUMN_DURATION = "ExerciseDuration";
    static let COLUMN_DIFFICULTY = "ExerciseDifficulty";
    static let COLUMN_NOTES = "Notes";
    // Whether a search result is from Intencity or the user typed it in.
    static let COLUMN_FROM_INTENCITY = "FromIntencity";
}