//
//  AppDelegate.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/8/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import IQKeyboardManagerSwift
import DropDown

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: Color.white]
        
        // Sets the title bar color.
        UINavigationBar.appearance().barTintColor = Color.primary
        UINavigationBar.appearance().titleTextAttributes = titleDict as? [String : AnyObject]
        UINavigationBar.appearance().tintColor = Color.white
        UINavigationBar.appearance().translucent = false
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // Sets the tab bar colors.
        UITabBar.appearance().tintColor = Color.primary
        UITabBar.appearance().barTintColor = Color.page_background
        UITabBar.appearance().backgroundColor = Color.page_background

        var storyboardName: String
        var viewName: String
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.dataForKey(Constant.USER_ACCOUNT_EMAIL) != nil)
        {
            storyboardName = Constant.MAIN_STORYBOARD
            viewName = Constant.MAIN_VIEW
        }
        else
        {
            storyboardName = Constant.DEMO_STORYBOARD
            viewName = Constant.DEMO_VIEW
        }
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        
        let initialViewController = storyboard.instantiateViewControllerWithIdentifier(viewName)
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        // Moves the view up with the keyboard is active.
        IQKeyboardManager.sharedManager().enable = true
        
        // Starts the DropDown listening for the keyboard.
        // Documentation: https://cocoapods.org/pods/DropDown
        DropDown.startListeningToKeyboard()
        DropDown.appearance().textColor = Color.secondary_dark
        
        // Create the database if it doesn't exist.
        DBHelper().createDB()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication)
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        let exerciseData = ExerciseData.getInstance()
        let routineName = exerciseData.routineName
        if (routineName != "")
        {
            DBHelper().insertIntoDb(exerciseData.exerciseList, index: exerciseData.exerciseIndex, routineName: routineName)
        }
    }

    func applicationWillEnterForeground(application: UIApplication)
    {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        handleUserAccount()
    }

    func applicationWillTerminate(application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    /**
     * Handles the user's account accordingly depending upon what might need to be done.
     */
    func handleUserAccount()
    {
        let now = Float(NSDate().timeIntervalSince1970 * 1000)
        
        let viewController = self.window!.rootViewController!
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let trialAccountCreatedDate = defaults.floatForKey(Constant.USER_TRIAL_CREATED_DATE)
        if (trialAccountCreatedDate > 0 && ((now - trialAccountCreatedDate) >= Float(Constant.TRIAL_ACCOUNT_THRESHOLD)))
        {
            Util.displayAlert(viewController,
                title: NSLocalizedString("trial_account_done_title", comment: ""),
                message: NSLocalizedString("trial_account_done_message", comment: ""),
                actions: [ UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .Default, handler: self.logOut) ])
        }
        else
        {
            let lastLogin = defaults.floatForKey(Constant.USER_LAST_LOGIN)
            
            let email = Util.getEmailFromDefaults()
            
            // If the user has logged in.
            // If the user's last login time is after 12 hours.
            if (email != "" && ((now - lastLogin) >= Float(Constant.LOGIN_POINTS_THRESHOLD)))
            {
                // Rewards the user for using the app after 12 hours.
                Util.grantPointsToUser(email, points: Constant.POINTS_LOGIN, description: NSLocalizedString("award_login_description", comment: ""))

                defaults.setFloat(now, forKey: Constant.USER_LAST_LOGIN)
            }
        }
    }
    
    /**
     * The log out action from the alert notifying the user that his or her trial account has expired.
     */
    func logOut(alertAction: UIAlertAction!)
    {
        Util.logOut(self.window!.rootViewController!)
    }
}