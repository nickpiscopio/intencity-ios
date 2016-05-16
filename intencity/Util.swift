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
        
        let emailAsData = replacePlus(email).dataUsingEncoding(NSUTF8StringEncoding)
        
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
     *
     * We don't clear the user's last login time because we only want to show the welcome once per app install.
     */
    static func logOut(controller: UIViewController)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(Constant.USER_ACCOUNT_EMAIL)
        defaults.removeObjectForKey(Constant.USER_ACCOUNT_TYPE)
        defaults.removeObjectForKey(Constant.USER_TRIAL_CREATED_DATE)
        defaults.removeObjectForKey(Constant.USER_LAST_EXERCISE_TIME)

        let storyboard = UIStoryboard(name: Constant.LOGIN_STORYBOARD, bundle: nil)
        
        let viewController = storyboard.instantiateViewControllerWithIdentifier(Constant.LOGIN_NAV_CONTROLLER)
        
        controller.presentViewController(viewController, animated: true, completion: nil)
        
        // Remove all the exercises from the exercise list.
        ExerciseData.reset()
        
        // Resets the notifcations.
        NotificationHandler.reset()
        
        // Reset the database.
        let dbHelper = DBHelper()
        dbHelper.resetDb(dbHelper.openDb())
    }

    /**
     * Validates a string of text against a regular expression.
     */
    static func isFieldValid(str: String, regEx: String) -> Bool
    {
        return NSPredicate(format:"SELF MATCHES %@", regEx).evaluateWithObject(str)
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
        
        if (encryptedEmail != nil)
        {
            do
            {
                let originalData = try RNCryptor.decryptData(encryptedEmail!, password: Key.key)
                return String(data: originalData, encoding: NSUTF8StringEncoding)!
                
            }
            catch
            {
                print("No email found in defaults.")
            }
        }
        
        return ""
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
     * @param tableView             The UITableView to add the cell.
     * @param addFooter             Adds a footer to the table.
     * @param emptyTableStringRes   The resource of the string that will tell the user there isn't any data.
     */
    static func initTableView(tableView: UITableView, footerHeight: CGFloat, emptyTableStringRes: String)
    {
        tableView.backgroundColor = Color.transparent

        // Removes the cell separators.
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // Sets the height of the cell to be automatic.
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Set to whatever your "average" cell
        tableView.estimatedRowHeight = tableView.frame.height
        
        if (emptyTableStringRes != "")
        {
            // Adds a label to the background view if we can't find data.
            tableView.backgroundView = getEmptyTableLabel(tableView, emptyTableStringRes: emptyTableStringRes)
            tableView.backgroundView?.hidden = true
        }        
        
        if (footerHeight > 0)
        {
            let footerView = UIView()
            footerView.frame = CGRectMake(0, 0, tableView.frame.size.width, footerHeight)
            footerView.backgroundColor = Color.transparent
            tableView.tableFooterView = footerView
        }
    }
    
    /**
     * Creates a table that we can use to tell the user there isn't any information to display.
     *
     * @param tableView             The UITableView to add the cell.
     * @param emptyTableStringRes   The resource of the string that will tell the user there isn't any data.
     * 
     * @return  The label telling the user there isn't information to display.
     */
    static func getEmptyTableLabel(tableView: UITableView, emptyTableStringRes: String) -> UILabel
    {
        let label = UILabel(frame: CGRectMake(0, 0, tableView.bounds.size.width, 50))
        label.text = NSLocalizedString(emptyTableStringRes, comment: "")
        label.textColor = Color.secondary_light
        label.font = label.font.fontWithSize(Dimention.FONT_SIZE_MEDIUM)
        label.textAlignment = .Center
        label.sizeToFit()
        
        return label
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
    
    /**
     * Converts the value to a decimaled value for the weight textfield.
     *
     * @param weight    The weight to convert.
     *
     * @return  The converted value.
     */
    static func convertToWeight(weight: String) -> String
    {
        let decimal = "."
        let weightInt = Int(weight.stringByReplacingOccurrencesOfString(decimal, withString: ""))!
        var padded = String(format: "%02d", weightInt)

        let index = padded.endIndex.predecessor()
        padded.insert(Character(decimal), atIndex: index)
        
        return padded
    }
    
    /**
     * Calls the service to grant points to the user.
     *
     * @param email         The email of the user to grant points.
     * @param points        The amount of points that will be granted.
     * @param description   The description of why points are being granted.
     */
    static func grantPointsToUser(email: String, points: Int, description: String)
    {
        _ = ServiceTask(event: ServiceEvent.NO_RETURN, delegate: nil,
                        serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GRANT_POINTS, variables: [ email, String(points) ]))
    
        // Add an award to the notification handler.
        NotificationHandler.getInstance(nil).addAward(Awards(awardTitle: "+\(points)", awardDescription: description));
    }
    
    /**
     * Calls the service to grant a badge to the user.
     *
     * @param email         The email of the user to grant points.
     * @param badgeName     The name of the badge that is being awarded.
     * @param content       The content that will be displayed to the user.
     */
    static func grantBadgeToUser(email: String, badgeName: String, content: Awards)
    {
        // We won't display the date anywhere, so we probably don't need this in local time.
        let now = String(format:"%.0f", NSDate().timeIntervalSince1970 * 1000)
        
        _ = ServiceTask(event: ServiceEvent.NO_RETURN, delegate: nil,
                        serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GRANT_BADGE, variables: [ email, now, badgeName ]))
        
        // Add an award to the notification handler.
        NotificationHandler.getInstance(nil).addAward(content);
    }
    
    /**
     * Calls the service to grant a badge to the user.
     *
     * @param email         The email of the user to grant points.
     * @param badgeName     The name of the badge that is being awarded.
     * @param content       The content that will be displayed to the user.
     * @param onlyAllowOne  Boolean value to only allow one instance of a specifed badge.
     */
    static func grantBadgeToUser(email: String, badgeName: String, content: Awards, onlyAllowOne: Bool)
    {
        let notificationHandler = NotificationHandler.getInstance(nil);
    
        // Only grant the badge to the user if he or she doesn't have it
        if (onlyAllowOne)
        {
            if (!notificationHandler.hasAward(content))
            {
                grantBadgeToUser(email, badgeName: badgeName, content: content)
            }
        }
        else
        {
            grantBadgeToUser(email, badgeName: badgeName, content: content)
        }
    }
    
    /**
     *  Replaces the '+' character in a String of text.
     *  This is so we can create an account on the server with an email that has a '+' in it.
     *
     *  @param text  The text to search.
     *
     *  return  The new String with its replaced character.
     */
    static func replacePlus(text: String) -> String
    {
        return text.stringByReplacingOccurrencesOfString("+", withString: "%2B")
    }
    
    /**
     *  Replaces the '+' character in a String of text.
     *  This is so we can create an account on the server with an email that has a '+' in it.
     *
     *  @param text  The text to search.
     *
     *  return  The new String with its replaced character.
     */
    static func replaceApostrophe(text: String) -> String
    {
        return text.stringByReplacingOccurrencesOfString("'", withString: "%27")
    }
    
    /**
     * Returns a mutable string for labels and buttons.
     *
     * @param string    The string we are mutating.
     * @param fontSize  The font size of the string.
     * @param color     The color the text should be.
     * @param isBold    Whether or not the text should be bold.
     */
    static func getMutableString(string: String, fontSize: CGFloat, color: UIColor, isBold: Bool) -> NSMutableAttributedString
    {
        let attributes = isBold ? UIFont.boldSystemFontOfSize(fontSize) : UIFont.systemFontOfSize(fontSize)
        
        var mutableString = NSMutableAttributedString()
        mutableString = NSMutableAttributedString(string: string, attributes: [ NSFontAttributeName:  attributes])
        mutableString.addAttribute(NSForegroundColorAttributeName, value: color, range: NSRange(location: 0, length: string.characters.count))
        
        return mutableString
    }
}