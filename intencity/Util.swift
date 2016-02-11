//
//  Util.swift
//  Intencity
//
//  This is the Utility class that holds all of the functions that may be used in the app.
//
//  Created by Nick Piscopio on 2/10/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class Util
{
    /*
        Displays a standard alert to the user.
        
        controller      The UIViewController that called this function.
        title           The title of the alert to display.
        message         The message of the alert to display.
    */
    static func displayAlert(controller: UIViewController, title: String, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: UIAlertActionStyle.Default,handler: nil))
        
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /*
        Saves the login information to NSUserDefaults.
    */
    static func saveLoginData(email: String, accountType: String, createdDate: UInt32)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setObject(email, forKey: Constant.USER_ACCOUNT_EMAIL)
        defaults.setObject(accountType, forKey: Constant.USER_ACCOUNT_TYPE)
        
        if (createdDate > 0)
        {
            defaults.setObject(String(createdDate), forKey: Constant.USER_TRIAL_CREATED_DATE)
        }
    }
}