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
    static func displayAlert(_ controller: UIViewController, title: String, message: String, actions: [UIAlertAction])
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if actions.count > 0
        {
            for action in actions
            {
                alert.addAction(action)
            }
        }
        else
        {
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil))
        }
        
        controller.present(alert, animated: true, completion: nil)
    }

    /**
     * Saves the login information to NSUserDefaults.
     
     * @param controller            The view that called this method, so we know what is pushing the next screen.
     * @param email                 The email of the user.
     * @param accountType           The account type of the user.
     * @param trialCreatedDate      The long value of the date the trial account was created.
     */
    static func loadIntencity(_ controller: UIViewController, email: String, accountType: String, createdDate: Double)
    {
        let defaults = UserDefaults.standard
        
        let emailAsData = replacePlus(email).data(using: String.Encoding.utf8)
        
        // Documentation: https://github.com/RNCryptor/RNCryptor
        let encryptedEmail = RNCryptor.encrypt(data: emailAsData!, withPassword: Key.key)
        
        defaults.set(encryptedEmail, forKey: Constant.USER_ACCOUNT_EMAIL)
        defaults.set(accountType, forKey: Constant.USER_ACCOUNT_TYPE)
        
        if (createdDate > 0)
        {
            defaults.set(String(format:"%f", createdDate), forKey: Constant.USER_TRIAL_CREATED_DATE)
        }
        
        loadIntencity(controller);
    }
    
    /**
     * Loads the Main view from the beginning.
     *
     * @param controller      The view that called this method, so we know what is pushing the next screen.
     */
    static func loadIntencity(_ controller: UIViewController)
    {
        let storyboard = UIStoryboard(name: Constant.MAIN_STORYBOARD, bundle: nil)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "IntencityTabView")
        
        controller.present(viewController, animated: true, completion: nil)
    }
    
    /**
     * Saves the user information for Intencity when converting to a full account.
     *
     * @param email         The email of the user.
     */
    static func convertAccount(_ email: String)
    {
        let defaults = UserDefaults.standard
        
        let emailAsData = replacePlus(email).data(using: String.Encoding.utf8)
        
        // Documentation: https://github.com/RNCryptor/RNCryptor
        let encryptedEmail = RNCryptor.encrypt(data: emailAsData!, withPassword: Key.key)
    
        defaults.set(encryptedEmail, forKey: Constant.USER_ACCOUNT_EMAIL)
        defaults.set(Constant.ACCOUNT_TYPE_NORMAL, forKey: Constant.USER_ACCOUNT_TYPE)
    
        defaults.removeObject(forKey: Constant.USER_TRIAL_CREATED_DATE)
    }
    
    /**
     * Logs the user out.
     *
     * We don't clear the user's last login time because we only want to show the welcome once per app install.
     */
    static func logOut(_ controller: UIViewController)
    {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Constant.USER_ACCOUNT_EMAIL)
        defaults.removeObject(forKey: Constant.USER_ACCOUNT_TYPE)
        defaults.removeObject(forKey: Constant.USER_TRIAL_CREATED_DATE)
        defaults.removeObject(forKey: Constant.USER_LAST_EXERCISE_TIME)
        defaults.removeObject(forKey: Constant.USER_SET_EQUIPMENT)

        let storyboard = UIStoryboard(name: Constant.LOGIN_STORYBOARD, bundle: nil)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: Constant.LOGIN_NAV_CONTROLLER)
        
        controller.present(viewController, animated: true, completion: nil)
        
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
    static func isFieldValid(_ str: String, regEx: String) -> Bool
    {
        return NSPredicate(format:"SELF MATCHES %@", regEx).evaluate(with: str)
    }

    /**
     * Checks if the user has entered text in the edit text.
     *
     * @param text      The edit text to check.
     * @param length    The value the edit text string should be greater than.
     *
     * @return Boolean value of if the user has entered text in the edit text.
     */
    static func checkStringLength(_ text: String, length: Int) -> Bool
    {
        return text.count >= length;
    }
    
    /**
     * Decrypts and returns the email from the defaults.
     *
     * Documentation: https://github.com/RNCryptor/RNCryptor
     */
    static func getEmailFromDefaults() -> String
    {
        let defaults = UserDefaults.standard
        let encryptedEmail = defaults.data(forKey: Constant.USER_ACCOUNT_EMAIL)
        
        if (encryptedEmail != nil)
        {
            do
            {
                let originalData = try RNCryptor.decrypt(data: encryptedEmail!, withPassword: Key.key)
                return String(data: originalData, encoding: String.Encoding.utf8)!
                
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
        return UserDefaults.standard.string(forKey: Constant.USER_ACCOUNT_TYPE) == Constant.ACCOUNT_TYPE_MOBILE_TRIAL
    }
    
    /**
     * Initializes a specified tableview.
     *
     * @param tableView             The UITableView to add the cell.
     * @param addFooter             Adds a footer to the table.
     * @param emptyTableStringRes   The resource of the string that will tell the user there isn't any data.
     */
    static func initTableView(_ tableView: UITableView, footerHeight: CGFloat, emptyTableStringRes: String)
    {
        tableView.backgroundColor = Color.transparent

        // Removes the cell separators.
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        // Sets the height of the cell to be automatic.
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Set to whatever your "average" cell
        tableView.estimatedRowHeight = tableView.frame.height
        
        if (emptyTableStringRes != "")
        {
            // Adds a label to the background view if we can't find data.
            tableView.backgroundView = getEmptyTableLabel(tableView, emptyTableStringRes: emptyTableStringRes)
            tableView.backgroundView?.isHidden = true
        }        
        
        if (footerHeight > 0)
        {
            let footerView = UIView()
            footerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: footerHeight)
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
    static func getEmptyTableLabel(_ tableView: UITableView, emptyTableStringRes: String) -> UILabel
    {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 50))
        label.text = NSLocalizedString(emptyTableStringRes, comment: "")
        label.textColor = Color.secondary_light
        label.font = label.font.withSize(Dimention.FONT_SIZE_MEDIUM)
        label.textAlignment = .center
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
    static func addUITableViewCell(_ table: UITableView, nibNamed: String, cellName: String)
    {
        let nib = UINib(nibName: nibNamed, bundle: nil)
        table.register(nib, forCellReuseIdentifier: cellName)
    }
    
    /**
     * Converts the duration to an integer.
     *
     * @param duration      The duration to convert.
     *
     * @return  The converted value.
     */
    static func convertToInt(_ duration: String) -> Int
    {
        return duration != "" && duration != Constant.RETURN_NULL && duration != String(Constant.CODE_FAILED) ? Int(duration.replacingOccurrences(of: ":", with: ""))! : Int(Constant.CODE_FAILED)
    }
    
    /**
     * Converts the duration to an integer.
     *
     * @param duration      The duration to convert.
     *
     * @return  The converted value.
     */
    static func convertToTime(_ reps: Int) -> String
    {
        let time = String(format: "%06d", reps)
        
        var duration = ""
        
        if let regex = try? NSRegularExpression(pattern: "..(?!$)", options: .caseInsensitive)
        {
            duration = regex.stringByReplacingMatches(in: time, options: .withTransparentBounds, range: NSMakeRange(0, time.count), withTemplate: "$0:")
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
    static func convertToWeight(_ weight: String) -> String
    {
        let decimal = "."
        let weightInt = Int(weight.replacingOccurrences(of: decimal, with: ""))!
        var padded = String(format: "%02d", weightInt)

        let index = padded.index(before: padded.endIndex)
        padded.insert(Character(decimal), at: index)
        
        return padded
    }
    
    /**
     * Calls the service to grant points to the user.
     *
     * @param email         The email of the user to grant points.
     * @param points        The amount of points that will be granted.
     * @param description   The description of why points are being granted.
     */
    static func grantPointsToUser(_ email: String, awardType: AwardType, points: Int, description: String)
    {
        _ = ServiceTask(event: ServiceEvent.NO_RETURN, delegate: nil,
                        serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GRANT_POINTS, variables: [ email, String(points) ]) as NSString)
    
        // Add an award to the notification handler.
        NotificationHandler.getInstance(nil).addAward(Awards(awardType: awardType, awardTitle: "+\(points)", awardDescription: description));
    }
    
    /**
     * Calls the service to grant a badge to the user.
     *
     * @param email         The email of the user to grant points.
     * @param badgeName     The name of the badge that is being awarded.
     * @param content       The content that will be displayed to the user.
     */
    static func grantBadgeToUser(_ email: String, badgeName: String, content: Awards)
    {
        // We won't display the date anywhere, so we probably don't need this in local time.
        let now = String(format:"%.0f", Date().timeIntervalSince1970 * 1000)
        
        _ = ServiceTask(event: ServiceEvent.NO_RETURN, delegate: nil,
                        serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GRANT_BADGE, variables: [ email, now, badgeName ]) as NSString)
        
        // Add an award to the notification handler.
        NotificationHandler.getInstance(nil).addAward(content)
    }
    
    /**
     * Calls the service to grant a badge to the user.
     *
     * @param email         The email of the user to grant points.
     * @param badgeName     The name of the badge that is being awarded.
     * @param content       The content that will be displayed to the user.
     * @param onlyAllowOne  Boolean value to only allow one instance of a specifed badge.
     */
    static func grantBadgeToUser(_ email: String, badgeName: String, content: Awards, onlyAllowOne: Bool)
    {
        let notificationHandler = NotificationHandler.getInstance(nil)
    
        // Only grant the badge to the user if he or she doesn't have it
        if (onlyAllowOne)
        {
            if (notificationHandler.getAwardIndex(content) == Int(Constant.CODE_FAILED))
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
    static func replacePlus(_ text: String) -> String
    {
        return text.replacingOccurrences(of: "+", with: "%2B")
    }
    
    /**
     *  Replaces the '+' character in a String of text.
     *  This is so we can create an account on the server with an email that has a '+' in it.
     *
     *  @param text  The text to search.
     *
     *  return  The new String with its replaced character.
     */
    static func replaceApostrophe(_ text: String) -> String
    {
        return text.replacingOccurrences(of: "'", with: "%27")
    }
    
    /**
     * Returns a mutable string for labels and buttons.
     *
     * @param string    The string we are mutating.
     * @param fontSize  The font size of the string.
     * @param color     The color the text should be.
     * @param isBold    Whether or not the text should be bold.
     */
    static func getMutableString(_ string: String, fontSize: CGFloat, color: UIColor, isBold: Bool) -> NSMutableAttributedString
    {
        let attributes = isBold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        
        var mutableString = NSMutableAttributedString()
        mutableString = NSMutableAttributedString(string: string, attributes: [ NSAttributedStringKey.font:  attributes])
        mutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: NSRange(location: 0, length: string.count))
        
        return mutableString
    }
    
    /**
     * Loads a nib with a specified name.
     *
     * @param nib   The name of the nib to load.
     *
     * @return The loaded nib as a UITableViewCell
     */
    static func loadNib(_ nib: String) -> UITableViewCell
    {
        return Bundle.main.loadNibNamed(nib, owner: nil, options: nil)![0] as! UITableViewCell
    }
}
