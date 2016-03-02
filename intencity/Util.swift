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
     * Displays an alert that has actions.
     *
     * @param controller    The controller that is displaying the alert.
     * @param title         The title of the alert.
     * @param message       The message of the alert.
     * @param actions       The array of callbacks for the alert.
     */
    static func displayAlert(controller: UIViewController, title: String, message: String, actions: [UIAlertAction])
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        if actions.count > 0
        {
            for action in actions
            {
                alert.addAction(action)
            }
        }
        else
        {
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .Default, handler: nil))
        }
        
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
        
        let storyboard = UIStoryboard(name: Constant.MAIN_STORYBOARD, bundle: nil)
        
        let viewController = storyboard.instantiateViewControllerWithIdentifier("IntencityTabView")
        
        controller.presentViewController(viewController, animated: true, completion: nil)
    }
    
    /**
     * Logs the user out.
     */
    static func logOut(controller: UIViewController)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(Constant.USER_ACCOUNT_EMAIL)
        defaults.removeObjectForKey(Constant.USER_ACCOUNT_TYPE)
        defaults.removeObjectForKey(Constant.USER_TRIAL_CREATED_DATE)
        // NEED last exercise time

        let storyboard = UIStoryboard(name: Constant.LOGIN_STORYBOARD, bundle: nil)
        
        let viewController = storyboard.instantiateViewControllerWithIdentifier(Constant.LOGIN_NAV_CONTROLLER)
        
        controller.presentViewController(viewController, animated: true, completion: nil)
        
        // Remove all the exercises from the exercise list.
        ExerciseData.getInstance().exerciseList.removeAll()
        
        // Reset the database.
        let dbHelper = DBHelper()
        dbHelper.resetDb(dbHelper.openDb())
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
     * Gets the account type from the defaults.
     *
     * @return Boolean if the account type is a mobile trial.
     */
    static func isAccountTypeTrial() -> Bool
    {
        return NSUserDefaults.standardUserDefaults().stringForKey(Constant.USER_ACCOUNT_TYPE) == Constant.ACCOUNT_TYPE_MOBILE_TRIAL
    }
    
    /**
     * Initializes a specified tableview.
     *
     * @param table                 The UITableView to add the cell.
     * @param removeSeparators      Boolean on whether to remove the cell separators or not.
     * @param addFooter             Adds a footer to the table.
     */
    static func initTableView(table: UITableView, removeSeparators: Bool, addFooter: Bool)
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
        
        if (addFooter)
        {
            let footerView = UIView()
            footerView.frame = CGRectMake(0, 0, table.frame.size.width, Dimention.TABLE_FOOTER_HEIGHT)
            footerView.backgroundColor = Color.transparent
            table.tableFooterView = footerView
        }
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
    
    /**
     * Converts the duration to an integer.
     *
     * @param duration      The duration to convert.
     *
     * @return  The converted value.
     */
    static func convertToInt(duration: String) -> Int
    {
        return duration != "" && duration != Constant.RETURN_NULL && duration != String(Constant.CODE_FAILED) ? Int(duration.stringByReplacingOccurrencesOfString(":", withString: ""))! : Int(Constant.CODE_FAILED)
    }
    
    /**
     * Converts the duration to an integer.
     *
     * @param duration      The duration to convert.
     *
     * @return  The converted value.
     */
    static func convertToTime(reps: Int) -> String
    {
        let time = String(format: "%06d", reps)
        
        var duration = ""
        
        if let regex = try? NSRegularExpression(pattern: "..(?!$)", options: .CaseInsensitive)
        {
            duration = regex.stringByReplacingMatchesInString(time, options: .WithTransparentBounds, range: NSMakeRange(0, time.characters.count), withTemplate: "$0:")
        }
        
        return duration
    }
    
    static func showActivityIndicatory(view: UIView) -> UIActivityIndicatorView
    {
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
        view.addSubview(activityIndicator)
        
        return activityIndicator
    }
    
    static func stopActivityIndicator(activityIndicator: UIActivityIndicatorView)
    {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
}