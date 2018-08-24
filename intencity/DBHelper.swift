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
    
    let DATABASE_VERSION: UInt32 = 2;
    
    let DB_COMMA_SEP = ","
    
    func openDb() -> FMDatabase
    {
        let documents = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileURL = documents.appendingPathComponent(DATABASE_NAME)
        let database = FMDatabase(path: fileURL.path)
        
        if !(database.open())
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
            ExerciseTable.COLUMN_ROUTINE_STATE + integerType + DB_COMMA_SEP +
            ExerciseTable.COLUMN_ROUTINE_NAME + textType + DB_COMMA_SEP +
            ExerciseTable.COLUMN_WEB_ID + integerType + DB_COMMA_SEP +
            ExerciseTable.COLUMN_NAME + textType + notNull + DB_COMMA_SEP +
            ExerciseTable.COLUMN_DESCRIPTION + textType + DB_COMMA_SEP +
            ExerciseTable.COLUMN_FROM_INTENCITY + integerType + DB_COMMA_SEP +
            ExerciseTable.COLUMN_WEIGHT + realType + DB_COMMA_SEP +
            ExerciseTable.COLUMN_REP + integerType + DB_COMMA_SEP +
            ExerciseTable.COLUMN_DURATION + textType + DB_COMMA_SEP +
            ExerciseTable.COLUMN_DIFFICULTY + integerType + DB_COMMA_SEP +
            ExerciseTable.COLUMN_PRIORITY + integerType + DB_COMMA_SEP +
            ExerciseTable.COLUMN_NOTES + textType +
        " );"
        
        let database = openDb()

        let version = database.userVersion
        if (version < DATABASE_VERSION)
        {
            database.userVersion = DATABASE_VERSION
                
            updateDB(database)
        }
        else
        {
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
    }
    
    /**
     * Drops the table so we can recreate it.
     */
    func deleteDB(_ database: FMDatabase)
    {
        let SQL_CREATE_ENTRIES = "DROP TABLE IF EXISTS " + ExerciseTable.TABLE_NAME + ";"
        
        do
        {
            try database.executeUpdate(SQL_CREATE_ENTRIES, values: nil)
        }
        catch let error as NSError
        {
            print("FAILED to delete table: \(error.localizedDescription)")
        }
        
        database.close()
    }
    
    /**
     * Updates the database with new columns,
     */
    func updateDB(_ database: FMDatabase)
    {
        deleteDB(database)
        createDB()
    }
    
    /**
     *  Resets the database.
     */
    func resetDb(_ database: FMDatabase)
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
    func insertIntoDb(_ exercises: Array<Exercise>, index: Int, routineName: String, state: String)
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
                let priority = exercise.priority
                let fromIntencity = exercise.fromIntencity ? "1" : "0"
                let notes = set.notes
                
                let webIdInsert = webId > 0 ? DB_COMMA_SEP + ExerciseTable.COLUMN_WEB_ID : ""
                let weightInsert = weight > 0 ? DB_COMMA_SEP + ExerciseTable.COLUMN_WEIGHT : ""
                let repsInsert = reps > 0 ? DB_COMMA_SEP + ExerciseTable.COLUMN_REP : ""
                let durationInsert = !duration.isEmpty && duration != Constant.RETURN_NULL ? DB_COMMA_SEP + ExerciseTable.COLUMN_DURATION : ""
                let difficultyInsert = difficulty > 0 ? DB_COMMA_SEP + ExerciseTable.COLUMN_DIFFICULTY : ""
                let notesInsert = notes != Constant.RETURN_NULL && notes != "" ? DB_COMMA_SEP + ExerciseTable.COLUMN_NOTES : ""
                
                let webIdValue = webId > 0 ? DB_COMMA_SEP + String(webId) : ""
                let weightValue = weight > 0 ? DB_COMMA_SEP + String(weight) : ""
                let repsValue = reps > 0 ? DB_COMMA_SEP + String(reps) : ""
                let durationValue = !duration.isEmpty && duration != Constant.RETURN_NULL ? DB_COMMA_SEP + "'" + duration + "'" : ""
                let difficultyValue = difficulty > 0 ? DB_COMMA_SEP + String(difficulty) : ""
                let notesValue = notes != Constant.RETURN_NULL && notes != "" ? DB_COMMA_SEP + "'" + notes + "'" : ""
                
                let columns = "(" + ExerciseTable.COLUMN_ROUTINE_STATE + DB_COMMA_SEP +
                                    ExerciseTable.COLUMN_ROUTINE_NAME + DB_COMMA_SEP +
                                    ExerciseTable.COLUMN_INDEX + DB_COMMA_SEP +
                                    ExerciseTable.COLUMN_NAME + DB_COMMA_SEP +
                                    ExerciseTable.COLUMN_DESCRIPTION + DB_COMMA_SEP +
                                    ExerciseTable.COLUMN_PRIORITY + DB_COMMA_SEP +
                                    ExerciseTable.COLUMN_FROM_INTENCITY +
                                    webIdInsert +
                                    weightInsert +
                                    repsInsert +
                                    durationInsert +
                                    difficultyInsert +
                                    notesInsert + ")"
                
                let values = state + DB_COMMA_SEP +
                                "'" + routineName + "'" + DB_COMMA_SEP +
                                String(index) + DB_COMMA_SEP +
                                "'" + exercise.exerciseName + "'" + DB_COMMA_SEP +
                                "'" + exercise.exerciseDescription + "'" + DB_COMMA_SEP +
                                String(priority) + DB_COMMA_SEP +
                                fromIntencity +
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
    
    /**
     *  Gets the records from the database.
     */
    func getRecords() -> SavedExercise
    {
        var state = 0
        var routineName = ""
        var exercises = [Exercise]()
        var index = 0
        
        let database = openDb()
        
        // Get the list of exercises from the database that were saved.
        // These are exercises the user might want to continue with later.
        let getExercises = "SELECT * FROM " + ExerciseTable.TABLE_NAME + ";";
        
        do
        {
            let result = try database.executeQuery(getExercises, values: nil)
            
            var lastExerciseName = ""
            
            var exerciseIndex = 0
            
            while result.next()
            {                
                var exercise: Exercise!

                if (index <= 0)
                {
                    index = Int(result.string(forColumn: ExerciseTable.COLUMN_INDEX)!)!
                }
                
                state = Int(result.string(forColumn: ExerciseTable.COLUMN_ROUTINE_STATE)!)!
                routineName = result.string(forColumn: ExerciseTable.COLUMN_ROUTINE_NAME)!
                
                // Exercise
                let name = result.string(forColumn: ExerciseTable.COLUMN_NAME)
                let description = result.string(forColumn: ExerciseTable.COLUMN_DESCRIPTION)
                let priority = result.string(forColumn: ExerciseTable.COLUMN_PRIORITY)
                let fromIntencity = result.bool(forColumn: ExerciseTable.COLUMN_FROM_INTENCITY);
                
                // If the last exercise name is equal to the last exercise we just got,
                // or if the exercise is the first in the list,
                // then we want to create a new exercise object.
                if (lastExerciseName != name)
                {
                    lastExerciseName = name!
                    
                    exercise = Exercise(exerciseName: name!, exerciseDescription: description != nil ? description! : "", priority: priority != nil ? Int(priority!)! : Int(Constant.CODE_FAILED), sets: [], fromIntencity: fromIntencity)
                    
                    exercises.append(exercise)

                    exerciseIndex = exercises.count - 1
                }
                
                // Sets
                let webId = result.string(forColumn: ExerciseTable.COLUMN_WEB_ID)
                let weight = result.string(forColumn: ExerciseTable.COLUMN_WEIGHT)
                let reps = result.string(forColumn: ExerciseTable.COLUMN_REP)
                let duration = result.string(forColumn: ExerciseTable.COLUMN_DURATION)
                let difficulty = result.string(forColumn: ExerciseTable.COLUMN_DIFFICULTY)
                let notes = result.string(forColumn: ExerciseTable.COLUMN_NOTES)
                
                let set = Set(webId: webId != nil ? Int(webId!)! : Int(Constant.CODE_FAILED),
                                 weight: weight != nil ? Float(weight!)! : 0.0,
                                 reps: reps != nil ? Int(reps!)! : Int(Constant.CODE_FAILED),
                                 duration: duration != nil ? duration! : Constant.RETURN_NULL,
                                 difficulty: difficulty != nil ? Int(difficulty!)! : Int(Constant.CODE_FAILED),
                                 notes: notes != nil ? notes! : Constant.RETURN_NULL)
                
                var sets = exercises[exerciseIndex].sets
                sets.append(set)
                
                exercises[exerciseIndex].sets = sets
            }
        }
        catch let error as NSError
        {
            print ("Failed to get records from the database: \(error)")
        }
        
        database.close()
        
        return SavedExercise(routineName: routineName, exercises: exercises, index: index, routineState: state)
    }
}
