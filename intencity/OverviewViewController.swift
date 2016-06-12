//
//  MainViewController.swift
//  Intencity
//
//  The view controller for the Overview screen.
//
//  Created by Nick Piscopio on 6/12/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import Social

class OverviewViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!

    let WARM_UP_NAME = NSLocalizedString("warm_up", comment: "")
    let STRETCH_NAME = NSLocalizedString("stretch", comment: "")
    let NO_LOGIN_ACCCOUNT_TITLE = NSLocalizedString("no_login_account_title", comment: "")
    let FACEBOOK_BUTTON = NSLocalizedString("facebook_button", comment: "")
    let TWEET_BUTTON = NSLocalizedString("tweet_button", comment: "")

    let DEFAULTS = NSUserDefaults.standardUserDefaults()
    
    var email = ""
    
    var currentExercises = [Exercise]()
    
    var exerciseData: ExerciseData!
    
    var awards = [String: String]()
    
    var notificationHandler: NotificationHandler!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("title_overview", comment: "")
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.hidden = true
        
        email = Util.getEmailFromDefaults()
        
        notificationHandler = NotificationHandler.getInstance(nil)
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: 0, emptyTableStringRes: "")

        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.OVERVIEW_HEADER_CELL, cellName: Constant.OVERVIEW_HEADER_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.OVERVIEW_FOOTER_CELL, cellName: Constant.OVERVIEW_FOOTER_CELL)
        
        exerciseData = ExerciseData.getInstance()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func finish()
    {
        // Grant the user the "Kept Swimming" badge if he or she didn't skip an exercise.
        if (!DEFAULTS.boolForKey(Constant.BUNDLE_EXERCISE_SKIPPED))
        {
            let keptSwimmingAward = Awards(awardImageName: Badge.KEPT_SWIMMING_IMAGE_NAME, awardDescription: NSLocalizedString("award_kept_swimming_description", comment: ""))
            Util.grantBadgeToUser(email, badgeName: Badge.KEPT_SWIMMING, content: keptSwimmingAward, onlyAllowOne: true)
        }
        else
        {
            // Set the user has skipped an exercise to false for next time.
            setExerciseSkipped(false)
        }
        
        let finisherDescription = NSLocalizedString("award_finisher_description", comment: "")
        
        let finisherAward = Awards(awardImageName: Badge.FINISHER_IMAGE_NAME, awardDescription: finisherDescription)
        if (!notificationHandler.hasAward(finisherAward))
        {
            Util.grantPointsToUser(email, points: Constant.POINTS_COMPLETING_WORKOUT, description: finisherDescription)
            Util.grantBadgeToUser(email, badgeName: Badge.FINISHER, content: finisherAward, onlyAllowOne: true)
        }
    }
    
    /**
     * Displays the finish alert.
     */
    func displayFinishAlert()
    {
        let actions = [ UIAlertAction(title: FACEBOOK_BUTTON, style: .Default, handler: share),
                        UIAlertAction(title: TWEET_BUTTON, style: .Default, handler: share),
                        UIAlertAction(title: NSLocalizedString("finish_button", comment: ""), style: .Destructive, handler: finishExercising),
                        UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .Default, handler: nil) ]
        
        Util.displayAlert(self,
                          title: NSLocalizedString("completed_workout_title", comment: ""),
                          message: "",
                          actions: actions)
    }
    
    /**
     * Remove the exercises from the database.
     */
    func removeExercisesFromDatabase()
    {
        // Remove all the exercises from the exercise list.
        ExerciseData.reset()
        
        // Remove all the current exercises from the exercise list.
        currentExercises.removeAll()
        
        let dbHelper = DBHelper()
        dbHelper.resetDb(dbHelper.openDb())
    }
    
    /**
     * Sets whether the user has skipped an exercise for today.
     *
     * @param skipped   Boolean of if the user ahs skipped an exercise.
     */
    func setExerciseSkipped(skipped: Bool)
    {
        DEFAULTS.setBool(skipped, forKey: Constant.BUNDLE_EXERCISE_SKIPPED)
    }
    
    /**
     * The callback for when the finish button is pressed.
     */
    func onFinishRoutine()
    {
        displayFinishAlert()
    }
    
    /**
     * Animates the table being added to the screen.
     *
     * @param loadNextExercise  A boolean value of whether to load the next exercise or not.
     */
    func animateTable(indexToLoad: Int)
    {
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesInRange: range)
            
        tableView.reloadSections(sections, withRowAnimation: .Top)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 0
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        // The date formatter based on the locale of the device.
        let formatter = NSDateFormatter()
        formatter.dateStyle = .FullStyle
        formatter.timeStyle = .NoStyle
        
        let dateString = formatter.stringFromDate(NSDate())
        
        let view = tableView.dequeueReusableCellWithIdentifier(Constant.OVERVIEW_HEADER_CELL) as! OverviewHeaderCellController
        view.routineTitle.text = String(format: NSLocalizedString("header_overview", comment: ""), exerciseData.routineName).uppercaseString
        view.dateLabel.text = dateString
        
        return view.contentView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 75
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let view = tableView.dequeueReusableCellWithIdentifier(Constant.OVERVIEW_FOOTER_CELL) as! OverviewFooterCellController
        return view.contentView
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 50
    }

//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
//    {
//        let index = indexPath.item
//        let exercise = exerciseData.exerciseList[index]
//        let description = exercise.exerciseDescription
//        let sets = exercise.sets
//        let set = sets[sets.count - 1]
//        let exerciseFromIntencity = exercise.fromIntencity
//
//        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.EXERCISE_CELL) as! ExerciseCellController
//        cell.selectionStyle = UITableViewCellSelectionStyle.None
//        cell.delegate = self
//        cell.tableView = tableView
//        cell.exerciseButton.setTitle(exercise.exerciseName, forState: .Normal)
//        cell.setEditText(set)
//            
//        if (!description.isEmpty)
//        {
//            cell.setDescription(description)
//        }
//        else
//        {
//            cell.setAsExercise(exerciseFromIntencity, routineState: routineState)
//        }
//            
//        return cell
//    }
    
    /**
     * Randomly generates a message to share with social media.
     *
     * @param socialNetworkButton   The button that was pressed in the alert.
     *
     * @return  The generated tweet.
     */
    func generateShareMessage(socialNetworkButton: String) -> String
    {
        let shareMessage = ["I #dominated my #workout with #Intencity! #WOD #Fitness",
                                "I #finished my #workout of the day with #Intencity! #WOD #Fitness",
                                "I made it through #Intencity's #routine! #Fitness",
                                "Making #gains with #Intencity! #WOD #Fitness #Exercise #Gainz",
                                "#Finished my #Intencity #workout! #Retweet if you've #exercised today. #WOD #Fitness",
                                "I #lifted with #Intencity today! #lift #lifting",
                                "#Intencity #trained me today!",
                                "Getting #strong with #Intencity! #GetStrong #DoWork #Fitness",
                                "Getting that #BeachBody with #Intencity! #Lift #Exercise #Fitness",
                                "Nothing feels better than finishing a great #workout!"]
        
        let intencityUrl = " www.Intencity.fit"
        let via = " @Intencity" + (socialNetworkButton == TWEET_BUTTON ? "App" : "")
    
        let message = Int(arc4random_uniform(UInt32(shareMessage.count)))
    
        return shareMessage[message] + via + intencityUrl
    }
    
    /**
     * The finish exercise alert button click.
     */
    func finishExercising(alertAction: UIAlertAction!)
    {
        finishExercising()
    }
    
    /**
     * The function to reset to the routine card.
     */
    func finishExercising()
    {
        // We remove the exercises from the database here, so when we go back to
        // the fitness log, it doesn't ask if we want to continue where we left off.
        removeExercisesFromDatabase()
        
//        initRoutineCard()
    }
    
    /**
     * Opens an alert for a user to share finishing Intencity's workout with social media.
     *
     * TUTORIAL: http://www.brianjcoleman.com/tutorial-share-facebook-twitter-swift/
     */
    func share(alertAction: UIAlertAction!) -> Void
    {
        let serviceType: String!
        let loginMessageRes: String!
        
        let alertTitle = alertAction.title
        
        if (alertTitle == TWEET_BUTTON)
        {
            serviceType = SLServiceTypeTwitter
            
            loginMessageRes = "twitter_login_message"
        }
        else
        {
            serviceType = SLServiceTypeFacebook
            
            loginMessageRes = "facebook_login_message"
        }
        
        if SLComposeViewController.isAvailableForServiceType(serviceType)
        {
            let sheet: SLComposeViewController = SLComposeViewController(forServiceType: serviceType)
            sheet.setInitialText(generateShareMessage(alertTitle!))
            
            self.presentViewController(sheet, animated: true, completion: nil)
            
            // There will be no way we can know if they actually tweeted or not, so we will
            // Grant points to the user for at least opening up twitter and thinking about tweeting.
            Util.grantPointsToUser(email, points: Constant.POINTS_SHARING, description: NSLocalizedString("award_sharing_description", comment: ""))
            
            finishExercising()
        }
        else
        {
            let alert = UIAlertController(title: NO_LOGIN_ACCCOUNT_TITLE, message: NSLocalizedString(loginMessageRes, comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("open_settings", comment: ""), style: UIAlertActionStyle.Default, handler:
            {
                (alert: UIAlertAction!) in
                
                let shareUrl = NSURL(string:"prefs:root=" + (alertTitle == self.TWEET_BUTTON ? "TWITTER" : "FACEBOOK"))
                
                UIApplication.sharedApplication().openURL(shareUrl!)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}