//
//  DHelper.swift
//  Intencity
//
//  The database helper class.
//
//  Documentation: http://ccgus.github.io/fmdb/
//
//  Created by Nick Piscopio on 2/21/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation
import FMDB

class DBHelper
{
    let DATABASE_NAME = "intencity.sqlite"
    
    let DB_COMMA_SEP = ","
    
    func openDb() -> FMDatabase
    {
        let documents = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        let fileURL = documents.URLByAppendingPathComponent(DATABASE_NAME)
        let database = FMDatabase(path: fileURL.path)
        
        if !database.open()
        {
            print("Unable to open database")
        }
        
        return database
    }
    
    /**
     *  Creates the database on the device.
     */
    func createDB()
    {
        let textType = " TEXT"
        let integerType = " INTEGER"
        let realType = " REAL"
        let notNull = " NOT NULL"
        
        let SQL_CREATE_ENTRIES = "CREATE TABLE IF NOT EXISTS " + ExerciseTable.TABLE_NAME + " (" +
            ExerciseTable.COLUMN_INDEX + integerType + DB_COMMA_SEP +
            ExerciseTable.COLUMN_ROUTINE_NAME + textType + DB_COMMA_SEP +
            ExerciseTable.COLUMN_WEB_ID + integerType + DB_COMMA_SEP +
            ExerciseTable.COLUMN_NAME + textType + notNull + DB_COMMA_SEP +
            ExerciseTable.COLUMN_DESCRIPTION + textType + DB_COMMA_SEP +
            ExerciseTable.COLUMN_WEIGHT + realType + DB_COMMA_SEP +
            ExerciseTable.COLUMN_REP + integerType + DB_COMMA_SEP +
            ExerciseTable.COLUMN_DURATION + textType + DB_COMMA_SEP +
            ExerciseTable.COLUMN_DIFFICULTY + integerType + DB_COMMA_SEP +
            ExerciseTable.COLUMN_NOTES + textType +
        " );"
        
        let database = openDb()
        
        do
        {
            try database.executeUpdate(SQL_CREATE_ENTRIES, values: nil)
        }
        catch let error as NSError
        {
            print("FAILED to created database: \(error.localizedDescription)")
        } 
        
        database.close()
    }
    
    /**
     *  Resets the database.
     */
    func resetDb(database: FMDatabase)
    {
        do
        {
            try database.executeUpdate("DELETE FROM " + ExerciseTable.TABLE_NAME, values: nil)
        }
        catch let error as NSError
        {
            print("FAILED to reset the database: \(error.localizedDescription)")
        }
    }
    
    /**
     *  Inserts records into the database.
     */
    func insertIntDb(exercises: Array<Exercise>, index: Int, routineName: String)
    {
        let database = openDb()
        
        resetDb(database)
        
        for exercise in exercises
        {
            let sets = exercise.sets
            for set in sets
            {
                let webId = set.webId
                let weight = set.weight
                let reps = set.reps
                let duration = set.duration
                let difficulty = set.difficulty
                let notes = set.notes
                
                let webIdInsert = webId > 0 ? ExerciseTable.COLUMN_WEB_ID + DB_COMMA_SEP : ""
                let weightInsert = weight > 0 ? ExerciseTable.COLUMN_WEIGHT + DB_COMMA_SEP : ""
                let repsInsert = reps > 0 ? ExerciseTable.COLUMN_REP + DB_COMMA_SEP : ""
                let durationInsert = !duration.isEmpty && duration != Constant.RETURN_NULL ? ExerciseTable.COLUMN_DURATION + DB_COMMA_SEP : ""
                let difficultyInsert = difficulty > 0 ? ExerciseTable.COLUMN_DIFFICULTY : ""
                let notesInsert = !notes.isEmpty ? DB_COMMA_SEP + ExerciseTable.COLUMN_NOTES : ""
                
                let webIdValue = webId > 0 ? String(webId) + DB_COMMA_SEP : ""
                let weightValue = weight > 0 ? String(weight) + DB_COMMA_SEP : ""
                let repsValue = reps > 0 ? String(reps) + DB_COMMA_SEP : ""
                let durationValue = !duration.isEmpty && duration != Constant.RETURN_NULL ? "'" + duration + "'" + DB_COMMA_SEP : ""
                let difficultyValue = difficulty > 0 ? String(difficulty) : ""
                let notesValue = !notes.isEmpty ? DB_COMMA_SEP + "'" + notes + "'" : ""
                
                let columns = "(" + ExerciseTable.COLUMN_ROUTINE_NAME + DB_COMMA_SEP +
                                    ExerciseTable.COLUMN_INDEX + DB_COMMA_SEP +
                                    ExerciseTable.COLUMN_NAME + DB_COMMA_SEP +
                                    webIdInsert +
                                    weightInsert +
                                    repsInsert +
                                    durationInsert +
                                    difficultyInsert +
                                    notesInsert + ")"
                
                let values = "'" + routineName + "'" + DB_COMMA_SEP +
                                String(index) + DB_COMMA_SEP +
                                "'" + exercise.name + "'" + DB_COMMA_SEP + 
                                webIdValue +
                                weightValue +
                                repsValue +
                                durationValue +
                                difficultyValue +
                                notesValue
                do
                {
                    try database.executeUpdate("INSERT INTO " + ExerciseTable.TABLE_NAME + columns + "VALUES(" + values + ")", values: nil)
                }
                catch let error as NSError
                {
                    print("FAILED to insert exercise records: \(error.localizedDescription)")
                }
            }
        }
        
        database.close()
    }
}