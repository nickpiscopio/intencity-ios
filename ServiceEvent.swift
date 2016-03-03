//
//  ServiceEvent.swift
//  Intencity
//
//  Intencity's constants for events a service may do.
//
//  Created by Nick Piscopio on 2/11/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

struct ServiceEvent
{
    static let GENERIC = 0
    static let TRIAL = 1
    static let LOGIN = 2
    static let GET_ALL_DISPLAY_MUSCLE_GROUPS = 3
    static let SET_CURRENT_MUSCLE_GROUP = 4
    static let GET_EXERCISES_FOR_TODAY = 5
    static let VALIDATE_USER_CREDENTIALS = 6
    static let REMOVE_ACCOUNT = 7
    static let SEARCH_FOR_EXERCISE = 8
    static let SEARCH_FOR_USER = 9
    static let GET_FOLLOWING = 10
    static let UNFOLLOW = 11
    static let HIDE_EXERCISE_FOREVER = 12
    static let INSERT_EXERCISES_TO_WEB_DB = 13
    static let UPDATE_EXERCISES_TO_WEB_DB = 14
    static let GET_EXCLUSION_LIST = 15
    static let SAVE_EXCLUSION_LIST = 16
}