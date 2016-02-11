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
    static func loadIntencity(controller: UIViewController, email: String, accountType: String, createdDate: Double)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let encryptedEmail = try! email.aesEncrypt(Key.key, iv: Key.iv)
        
        defaults.setObject(encryptedEmail, forKey: Constant.USER_ACCOUNT_EMAIL)
        defaults.setObject(accountType, forKey: Constant.USER_ACCOUNT_TYPE)
        
        if (createdDate > 0)
        {
            defaults.setObject(String(format:"%f", createdDate), forKey: Constant.USER_TRIAL_CREATED_DATE)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let initialViewController = storyboard.instantiateViewControllerWithIdentifier("IntencityTabView")
        
        controller.presentViewController(initialViewController, animated: true, completion: nil)
    }
    
    /*
        Validates a string of text against a regular expression.
    */
    static func isFieldValid(str : String, regEx: String) -> Bool
    {
        let regex = try! NSRegularExpression(pattern: regEx, options: [])
        
        return regex.numberOfMatchesInString(str, options: [], range: NSMakeRange(0, str.characters.count)) > 0
    }
    
    /*
        Checks if the user has entered text in the edit text.
    
        text      The edit text to check.
        length    The value the edit text string should be greater than.
    
        return Boolean value of if the user has entered text in the edit text.
    */
    static func checkStringLength(text: String, length: Int) -> Bool
    {
        return text.characters.count >= length;
    }
}