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
    var id = Constant.CODE_FAILED
    var followingId = Constant.CODE_FAILED
    var earnedPoints = Constant.CODE_FAILED
    var totalBadges = Constant.CODE_FAILED
    
    var firstName = ""
    var lastName = ""
}