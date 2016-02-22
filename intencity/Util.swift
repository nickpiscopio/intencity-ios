//
//  Util.swift
//  Intencity
//
//  This is the Utility class that holds all of the functions that may be used in the app.
//
//  Created by Nick Piscopio on 2/10/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import RNCryptor

class Util
{
    /**
     * Displays a standard alert to the user.
     *
     * @param controller      The UIViewController that called this function.
     * @param title           The title of the alert to display.
     * @param message         The message of the alert to display.
     */
    static func displayAlert(controller: UIViewController, title: String, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: UIAlertActionStyle.Default,handler: nil))
        
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
     * Displays an alert that has actions.
     *
     * @param controller    The controller that is displaying the alert.
     * @param title         The title of the alert.
     * @param message       The message of the alert.
     * @param actions       The array of callbacks for the alert.
     */
    static func displayActionableAlert(controller: UIViewController, title: String, message: String, actions: [UIAlertAction])
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        
        for action in actions
        {
            alert.addAction(action)
        }
        
        // Support display in iPad
        let view = controller.view
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRectMake(view.bounds.size.width / 2.0, view.bounds.size.height / 2.0, 1.0, 1.0)
        
        controller.presentViewController(alert, animated: true, completion: nil)
    }

    /**
     * Saves the login information to NSUserDefaults.
     */
    static func loadIntencity(controller: UIViewController, email: String, accountType: String, createdDate: Double)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let emailAsData = email.dataUsingEncoding(NSUTF8StringEncoding)
        
        // Documentation: https://github.com/RNCryptor/RNCryptor
        let encryptedEmail = RNCryptor.encryptData(emailAsData!, password: Key.key)
        
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

    /**
     * Validates a string of text against a regular expression.
     */
    static func isFieldValid(str : String, regEx: String) -> Bool
    {
        let regex = try! NSRegularExpression(pattern: regEx, options: [])
        
        return regex.numberOfMatchesInString(str, options: [], range: NSMakeRange(0, str.characters.count)) > 0
    }

    /**
     * Checks if the user has entered text in the edit text.
     *
     * @param text      The edit text to check.
     * @param length    The value the edit text string should be greater than.
     *
     * @return Boolean value of if the user has entered text in the edit text.
     */
    static func checkStringLength(text: String, length: Int) -> Bool
    {
        return text.characters.count >= length;
    }
    
    /**
     * Decrypts and returns the email from the defaults.
     *
     * Documentation: https://github.com/RNCryptor/RNCryptor
     */
    static func getEmailFromDefaults() -> String
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let encryptedEmail = defaults.dataForKey(Constant.USER_ACCOUNT_EMAIL)
        
        do
        {
            let originalData = try RNCryptor.decryptData(encryptedEmail!, password: Key.key)
            return String(data: originalData, encoding: NSUTF8StringEncoding)!
            
        }
        catch
        {
            return ""
        }
    }
    
    /**
     * Initializes a specified tableview.
     *
     * @param table                 The UITableView to add the cell.
     * @param removeSeparators      Boolean on whether to remove the cell separators or not.
     */
    static func initTableView(table: UITableView, removeSeparators: Bool)
    {
        table.backgroundColor = Color.transparent
        
        if (removeSeparators)
        {
            // Removes the cel separators.
            table.separatorStyle = UITableViewCellSeparatorStyle.None
        }
        
        // Sets the height of the cell to be automatic.
        table.rowHeight = UITableViewAutomaticDimension;
        // Set to whatever your "average" cell
        table.estimatedRowHeight = 10.0;
    }
    
    /**
     * Adds the cell associated with the table.
     *
     * @param table         The UITableView to add the cell.
     * @param nibNamed      The XIB file to load.
     * @param cellNamed     The cell identifier.
     */
    static func addUITableViewCell(table: UITableView, nibNamed: String, cellName: String)
    {
        let nib = UINib(nibName: nibNamed, bundle: nil)
        table.registerNib(nib, forCellReuseIdentifier: cellName)
    }
}