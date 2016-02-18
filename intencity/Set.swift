//
//  Set.swift
//  Intencity
//
//  The struct for the sets of an exercise.
//
//  Created by Nick Piscopio on 2/18/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

struct Set
{
    // This is the auto generated webId set when inserting a record in the web database.
    var webId: Int
    var weight: Float
    var reps: Int
    
    // This will need to be converted to a long later to accept times.
    var duration: String;
    var difficulty: Int
    
    var notes: String
}
