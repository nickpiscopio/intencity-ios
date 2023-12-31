//
//  UserDao.swift
//  Intencity
//
//  The data access object for user.
//
//  Created by Nick Piscopio on 2/14/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

struct UserDao
{
    func parseJson(_ json: [AnyObject]?) throws -> [User]
    {
        var users = [User]()
        
        if let jsonArray = json
        {
            for jsonUser in jsonArray
            {
                let user = User()
                
                // Might not have a FollowingId
                if let followingId = jsonUser[Constant.COLUMN_FOLLOWING_ID] as? String
                {
                    user.followingId = Int(followingId)!
                }
                else
                {
                    user.followingId = Int(Constant.CODE_FAILED)
                }
                
                let id = jsonUser[Constant.COLUMN_ID] as! String
                let earnedPoints = jsonUser[Constant.COLUMN_EARNED_POINTS] as! String
                let totalBadges = jsonUser[Constant.COLUMN_TOTAL_BADGES] as! String
                let firstName = jsonUser[Constant.COLUMN_FIRST_NAME] as! String
                let lastName = jsonUser[Constant.COLUMN_LAST_NAME] as! String
                
                user.id = Int(id)!
                user.earnedPoints = Int(earnedPoints)!
                user.totalBadges = Int(totalBadges)!
                user.firstName = firstName
                user.lastName = lastName
                
                // Add the user to the array.
                users.append(user)
            }
        }
        else
        {
            throw IntencityError.parseError
        }
        
        return users
    }
}
