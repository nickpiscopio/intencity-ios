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
    
    var hasNewNotifications = false
    
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
    
    /**
     * Add award to the award list.
     *
     * @param award     The award to add.
     */
    func addAward(award: Awards)
    {
        let index = getAwardIndex(award)
        if (index != Int(Constant.CODE_FAILED))
        {
            let awardAmount = awards[index].amount + 1
            
            awards.removeAtIndex(index)
            
            award.setAmountValue(awardAmount)
            
            awards.insert(award, atIndex: index)
        }
        else
        {
            // Adds the award to the first index so we can display them in reverse order.
            awards.insert(award, atIndex: 0)
        }
        
        hasNewNotifications = true
        
        if (delegate != nil)
        {
            delegate!.onNotificationAdded()
        }
    }
    
    /**
     * Tells the notification handler that the notifications have been viewed.
     */
    func setNotificationViewed()
    {
        hasNewNotifications = false
        
        if (delegate != nil)
        {
            delegate!.onNotificationsViewed()
        }
    }
    
    /**
    * Gets an award from the award list if it has one.
    *
    * @param award     The award to check.
    *
    * @return   The award.
    */
    func getAwardIndex(award: Awards) -> Int
    {
        for awd in awards
        {
            if (awd.awardType == award.awardType)
            {
                return awards.indexOf(awd)!
            }
        }
    
        return Int(Constant.CODE_FAILED)
    }
    
    /**
     * Clears the awards.
     */
    func clearAwards()
    {
        awards.removeAll()
    }
    
    /**
     * Gets the totoal number of awards.
     */
    func getAwardCount() -> Int
    {
        return awards.count
    }
}