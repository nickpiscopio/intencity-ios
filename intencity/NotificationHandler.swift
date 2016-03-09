//
//  NotificationHandler.swift
//  Intencity
//
//  The singleton class which houses notifications.
//
//  Created by Nick Piscopio on 3/9/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

class NotificationHandler
{
    static var instance: NotificationHandler!
    
    weak var delegate: NotificationDelegate?
    
    var awards = [Awards]()
    
    static func getInstance(delegate: NotificationDelegate?) -> NotificationHandler
    {
        if instance == nil
        {
            instance = NotificationHandler.init(delegate: delegate)
        }
        
        return instance
    }
    
    /**
     * Resets the instance so we can reinitialize it later.
     */
    static func reset()
    {
        instance = nil
    }
    
    /**
     * Constructor for the NotificationHandler.
     *
     * @param listener  The notification listener to call later to notify of new awards.
     */
    init(delegate: NotificationDelegate?)
    {
        self.delegate = delegate
    }
    
    func addAward(award: Awards)
    {
        // Adds the award to the first index so we can display them in reverse order.
        awards.insert(award, atIndex: 0)
        
        if (delegate != nil)
        {
            delegate!.onNotificationAdded()
        }       
    }
    
    /**
    * Checks to see if the award is already granted to the user.
    *
    * @param award     The award to check.
    *
    * @return  Boolean value if the user has already received a certain award.
    */
    func hasAward(award: Awards) -> Bool
    {
        let awardDescription = award.description
    
        for awd in awards
        {
            let description = awd.description
    
            if (awardDescription == description)
            {
                return true
            }
        }
    
        return false
    }
    
    func clearAwards()
    {
        awards.removeAll()
    }
    
    func getAwardCount() -> Int
    {
        return awards.count
    }
}