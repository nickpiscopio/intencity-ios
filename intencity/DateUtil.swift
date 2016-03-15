//
//  DateUtil.swift
//  Intencity
//
//  The date util class for Intencity.
//
//  Created by Nick Piscopio on 3/15/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

class DateUtil
{
    /**
     * Gets the next Monday at 12 AM.
     *
     * @return  Monday's date string.
     *          ex. Mon, Mar 21 12:00 AM
     *              Mon, Mar 21 00:00
     */
    func getMondayAt12AM() -> String
    {
        let dateFormat = NSDateFormatter.dateFormatFromTemplate("j", options: 0, locale: NSLocale.currentLocale())!
        
        let is24HourFormat = dateFormat.rangeOfString("a") == nil
        
        let calendar = NSCalendar.currentCalendar()
        
        let today = NSDate()
        
        let currentDayOfWeek = getDayOfWeek(today)
        
        // This is the numerical version of Monday for the calendar.
        // The calendar starts at Sunday (1)
        let MONDAY = 2
        let DAYS_IN_WEEK = 7
        
        // If Sunday,
        // Subtract the current numerical day of the week to get the number of days needed to get to Monday.
        // Else
        // Subtract today's date from the number of days in the week (7), then add Monday (2).
        // This gets us how many days we need to add to get to monday.
        let daysToAdd = currentDayOfWeek < MONDAY ? MONDAY - currentDayOfWeek : DAYS_IN_WEEK - currentDayOfWeek + MONDAY
        
        // Add the number of days we need to get to Monday.
        let monday = calendar.dateByAddingUnit(.Day, value: daysToAdd, toDate: today, options: NSCalendarOptions(rawValue: 0))
        
        // Get the start of the day.
        let startOfMonday = calendar.startOfDayForDate(monday!)
        
        let formatter = NSDateFormatter()
        // We set the timezone to New York because this is where the server is located.
        formatter.timeZone = NSTimeZone(name: "America/New_York")
        formatter.dateFormat = "EEE, MMM d " + (is24HourFormat ? "HH:mm" : "h:mm a")
        
        return formatter.stringFromDate(startOfMonday)
    }
    
    /**
     * Gets the day of the week
     *
     * @return  The day of the week as an integer.
     *          ex. (1-7)
     */
    func getDayOfWeek(today: NSDate) -> Int
    {
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents = myCalendar.components(.Weekday, fromDate: today)
        let weekDay = myComponents.weekday
        
        return weekDay
    }
}