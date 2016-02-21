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
    
    static let DB_TEXT_TYPE = " TEXT"
    static let DB_INTEGER_TYPE = " INTEGER"
    static let DB_REAL_TYPE = " REAL"
    static let DB_NOT_NULL = " NOT NULL"
    static let DB_COMMA_SEP = ","
    
    let SQL_CREATE_ENTRIES = "CREATE TABLE IF NOT EXISTS " + ExerciseTable.TABLE_NAME + " (" +
                                ExerciseTable.COLUMN_INDEX + DB_INTEGER_TYPE + DB_COMMA_SEP +
                                ExerciseTable.COLUMN_ROUTINE_NAME + DB_TEXT_TYPE + DB_COMMA_SEP +
                                ExerciseTable.COLUMN_WEB_ID + DB_INTEGER_TYPE + DB_COMMA_SEP +
                                ExerciseTable.COLUMN_NAME + DB_TEXT_TYPE + DB_NOT_NULL + DB_COMMA_SEP +
                                ExerciseTable.COLUMN_DESCRIPTION + DB_TEXT_TYPE + DB_COMMA_SEP +
                                ExerciseTable.COLUMN_WEIGHT + DB_REAL_TYPE + DB_COMMA_SEP +
                                ExerciseTable.COLUMN_REP + DB_INTEGER_TYPE + DB_COMMA_SEP +
                                ExerciseTable.COLUMN_DURATION + DB_TEXT_TYPE + DB_COMMA_SEP +
                                ExerciseTable.COLUMN_DIFFICULTY + DB_INTEGER_TYPE + DB_COMMA_SEP +
                                ExerciseTable.COLUMN_NOTES + DB_TEXT_TYPE +
                                " );"
    
    func createDB()
    {
        let documents = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        let fileURL = documents.URLByAppendingPathComponent(DATABASE_NAME)
        let database = FMDatabase(path: fileURL.path)
        
        if !database.open()
        {
            print("Unable to open database")
            return
        }
        
        do
        {
            try database.executeUpdate(SQL_CREATE_ENTRIES, values: nil)
        }
        catch let error as NSError
        {
            print("failed: \(error.localizedDescription)") 
        } 
        
        database.close()
    }
}