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
        
        let shareBar: UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem:.Action, target: self, action: #selector(OverviewViewController.shareOverview(_:)))
        
        self.navigationItem.rightBarButtonItem = shareBar
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /**
     * Shares an image and text with and "intent."
     */
    func shareOverview(sender: UIBarButtonItem)
    {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        var objectsToShare = [AnyObject]()
        
        if let shareTextObj = generateShareMessage()
        {
            objectsToShare.append(shareTextObj)
        }
        
        if let shareImageObj = image
        {
            objectsToShare.append(shareImageObj)
        }
        
        if image != nil
        {
            let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            presentViewController(activityViewController, animated: true, completion: nil)
        }else{
            print("There is nothing to share")
        }
    }
    
    func finish()
    {
        // Grant the user the "Kept Swimming" badge if he or she didn't skip an exercise.
        if (!DEFAULTS.boolForKey(Constant.BUNDLE_EXERCISE_SKIPPED))
        {
            let keptSwimmingAward = Awards(awardType: AwardType.KEPT_SWIMMING, awardImageName: Badge.KEPT_SWIMMING_IMAGE_NAME, awardDescription: NSLocalizedString("award_kept_swimming_description", comment: ""))
            Util.grantBadgeToUser(email, badgeName: Badge.KEPT_SWIMMING, content: keptSwimmingAward, onlyAllowOne: true)
        }
        else
        {
            // Set the user has skipped an exercise to false for next time.
            setExerciseSkipped(false)
        }
        
        let finisherDescription = NSLocalizedString("award_finisher_description", comment: "")

        let finisherAward = Awards(awardType: AwardType.BADGE_FINISHER, awardImageName: Badge.FINISHER_IMAGE_NAME, awardDescription: finisherDescription)
        if (notificationHandler.getAwardIndex(finisherAward) != Int(Constant.CODE_FAILED))
        {
            Util.grantPointsToUser(email, awardType: AwardType.POINTS_FINISHER, points: Constant.POINTS_COMPLETING_WORKOUT, description: finisherDescription)
            Util.grantBadgeToUser(email, badgeName: Badge.FINISHER, content: finisherAward, onlyAllowOne: true)
        }
    }
    
//    /**
//     * Displays the finish alert.
//     */
//    func displayFinishAlert()
//    {
//        let actions = [ UIAlertAction(title: FACEBOOK_BUTTON, style: .Default, handler: share),
//                        UIAlertAction(title: TWEET_BUTTON, style: .Default, handler: share),
//                        UIAlertAction(title: NSLocalizedString("finish_button", comment: ""), style: .Destructive, handler: finishExercising),
//                        UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .Default, handler: nil) ]
//        
//        Util.displayAlert(self,
//                          title: NSLocalizedString("completed_workout_title", comment: ""),
//                          message: "",
//                          actions: actions)
//    }
    
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
//        displayFinishAlert()
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
    func generateShareMessage() -> String?
    {
        let text = [ "#Dominated my #workout! #fitness",
                        "Finished my #workout of the day!",
                        "Made it through #Intencity!",
                        "Making #gains with #Intencity!",
                        "#Exercising completed! #WOD",
                        "Share if you've #exercised today",
                        "#Lifted with #Intencity! #lift",
                        "#Intencity #trained me today!",
                        "Getting #strong with #Intencity!",
                        "Getting that #BeachBody! #fit",
                        "#Hurt so good! #FitnessPain" ]
        
        let url = " www.Intencity.fit"
        let via = " @IntencityApp"
    
        let index = Int(arc4random_uniform(UInt32(text.count)))
    
        return text[index] + via + url
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
}