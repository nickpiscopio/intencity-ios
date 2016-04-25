//
//  RoutineSection.swift
//  Intencity
//
//  The struct for each section in the routine screen.
//
//  Created by Nick Piscopio on 4/22/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

struct RoutineSection
{
    var title: String
    // This is the int equivalents to what dot is being shown for each menu item,
    // which will correlate to the routine key.
    var keys: [Int]
    var rows: [RoutineRow]    
}