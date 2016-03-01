//
//  Exercise.swift
//  Intencity
//
//  The class for the exercises the user does.
//
//  Created by Nick Piscopio on 2/14/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

class User: NSObject
{
    var id = Int(Constant.CODE_FAILED)
    var followingId = Int(Constant.CODE_FAILED)
    var earnedPoints = Int(Constant.CODE_FAILED)
    var totalBadges = Int(Constant.CODE_FAILED)
    
    var firstName = ""
    var lastName = ""
    
    /**
     * Concatinates the user's first and last name.
     *
     * @return The user's name.
     */
    func getName() -> String
    {
        return firstName + " " + lastName
    }
}