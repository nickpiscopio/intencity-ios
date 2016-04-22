//
//  RoutineHeaderRow.swift
//  Intencity
//
//  The struct a header row in the RoutineSection
//
//  Created by Nick Piscopio on 4/22/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

struct RoutineHeaderRow
{
    var title: String
    // This is the int equivalents to what dot is being shown for each menu item,
    // which will correlate to the routine key.
    var titleKeys: [Int]
    var includeAssociatedButton: Bool
}