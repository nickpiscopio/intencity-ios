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
    
    let FINISH_ICON_NAME = "icon_finish"

    let WARM_UP_NAME = NSLocalizedString("wvar_up", comment: "")
    let STRETCH_NAME = NSLocalizedString("stretch", comment: "")
    let NO_LOGIN_ACCCOUNT_TITLE = NSLocalizedString("no_login_account_title", comment: "")

    let DEFAULTS = NSUserDefaults.standardUserDefaults()
    
    var email = ""
    
    var exerciseData: ExerciseData!
    var exercises = [Exercise]()
    
    var notificationHandler: NotificationHandler!
    
    var viewDelegate: ViewDelegate!
    
    var cards = [OverviewCard]()
    
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
        exerciseData = ExerciseData.getInstance()
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: 0, emptyTableStringRes: "")

        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.OVERVIEW_CARD_HEADER, cellName: Constant.OVERVIEW_CARD_HEADER)
        Util.addUITableViewCell(tableView, nibNamed: Constant.OVERVIEW_EXERCISE_CELL, cellName: Constant.OVERVIEW_EXERCISE_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.OVERVIEW_AWARD_CELL, cellName: Constant.OVERVIEW_AWARD_CELL)
        
        addHeader()
        addFooter()
        
        initCards()
        
        initMenuButtons()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /**
     * Initializes the overview cards.
     */
    func initCards()
    {
        exercises.appendContentsOf(exerciseData.exerciseList)
        
        // We remove the WARM-UP exercise.
        exercises.removeAtIndex(0)
        
        let lastExercise = exercises.count - 1
        if (exercises[lastExercise].exerciseName == STRETCH_NAME)
        {
            exercises.removeAtIndex(lastExercise)
        }
        
        cards.append(OverviewCard.init(type: OverviewRowType.HEADER, icon: UIImage(named: "icon_fitness_log")!, title: NSLocalizedString("title_exercises", comment: "")))
        cards.append(OverviewCard.init(type: OverviewRowType.EXERCISES, rows: exercises))
        cards.append(OverviewCard.init(type: OverviewRowType.HEADER, icon: UIImage(named: "ranking_badge")!, title: NSLocalizedString("awards_title", comment: "").uppercaseString))
        cards.append(OverviewCard.init(type: OverviewRowType.AWARDS, rows: notificationHandler.awards))
    }
    
    /**
     * Initializes the menu buttons.
     */
    func initMenuButtons()
    {
        let menu = [ UIBarButtonItem.init(image: UIImage(named: FINISH_ICON_NAME), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(OverviewViewController.finishOverview(_:))),
                     UIBarButtonItem.init(barButtonSystemItem:.Action, target: self, action: #selector(OverviewViewController.shareOverview(_:))) ]
        
        self.navigationItem.rightBarButtonItems = menu
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
        }
        else
        {
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
    
    /**
     * Remove the exercises from the database.
     */
    func removeExercisesFromDatabase()
    {
        // Remove all the exercises from the exercise list.
        ExerciseData.reset()
        
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
    func finishOverview(sender: UIBarButtonItem)
    {
        displayFinishAlert()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return cards.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let card = cards[section]
        
        return card.type == OverviewRowType.HEADER ? 1 : card.rows.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let section = indexPath.section
        
        let card = cards[section]
        
        let index = indexPath.row
        
        switch card.type
        {
            case OverviewRowType.HEADER:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(Constant.OVERVIEW_CARD_HEADER) as! OverviewCardHeaderController
                cell.cardIcon.image = card.icon
                cell.title.text = card.title
                
                return cell
            
            case OverviewRowType.EXERCISES:
                
                let exercise = card.rows[index] as! Exercise              
                
                let cell = tableView.dequeueReusableCellWithIdentifier(Constant.OVERVIEW_EXERCISE_CELL) as! OverviewExerciseCellController
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.title.text = exercise.exerciseName
                cell.title.textColor = exercise.fromIntencity ? Color.primary : Color.secondary_dark
                
                cell.sets = exercise.sets
                cell.initializeTableView()
                
                return cell
            
            default:
                
                let awards = card.rows as! [Awards]
                
                return AwardCell.getCell(tableView, cellName: Constant.OVERVIEW_AWARD_CELL, index: index, awards: awards)
        }
    }
    
    /**
     * Adds the header to the tableview.
     */
    func addHeader()
    {
        // The date formatter based on the locale of the device.
        let formatter = NSDateFormatter()
        formatter.dateStyle = .FullStyle
        formatter.timeStyle = .NoStyle
        
        let dateString = formatter.stringFromDate(NSDate())
        
        let view = Util.loadNib(Constant.OVERVIEW_HEADER_CELL) as! OverviewHeaderCellController
        view.routineTitle.text = String(format: NSLocalizedString("header_overview", comment: ""), exerciseData.routineName).uppercaseString
        view.dateLabel.text = dateString
        
        tableView.tableHeaderView = view.contentView
    }
    
    /**
     * Adds the footer to the tableview.
     */
    func addFooter()
    {
        let view = Util.loadNib(Constant.OVERVIEW_FOOTER_CELL) as! OverviewFooterCellController
        tableView.tableFooterView = view.contentView
    }
    
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
     * Displays an alert to ask the user if he or she wants to finish exercising.
     */
    func displayFinishAlert()
    {
        Util.displayAlert(self, title: NSLocalizedString("title_finish_routine", comment: ""),
                          message: NSLocalizedString("description_finish_routine", comment: ""),
                          actions: [ UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .Cancel, handler: nil),
                            UIAlertAction(title: NSLocalizedString("title_finish", comment: ""), style: .Destructive, handler: finishExercising) ])
    }
    
    /**
     * The action for the finish button being clicked when the user is viewing the finish exercise alert.
     */
    func finishExercising(alertAction: UIAlertAction!) -> Void
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
        
        initRoutineCard()
    }
    
    /**
     * Tells the callback to load the routine view again, and pops the view controller back.
     */
    func initRoutineCard()
    {
        viewDelegate.onLoadView(View.ROUTINE_VIEW, result: "", savedExercises: nil, state: RoutineState.NONE)
        
        self.navigationController?.popViewControllerAnimated(true)
    }
}