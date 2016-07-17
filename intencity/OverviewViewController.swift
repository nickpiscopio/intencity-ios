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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var routineTitle: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var exerciseCardIcon: UIImageView!
    @IBOutlet weak var exerciseTitle: UILabel!
    @IBOutlet weak var exerciseItemStackView: UIStackView!
    
    @IBOutlet weak var awardCard: IntencityCardView!
    @IBOutlet weak var awardCardIcon: UIImageView!
    @IBOutlet weak var awardTitle: UILabel!
    @IBOutlet weak var awardItemStackView: UIStackView!
    
    @IBOutlet weak var websiteView: UIView!
    @IBOutlet weak var websitePrefix: UILabel!
    @IBOutlet weak var websiteSuffix: UILabel!
    @IBOutlet weak var websiteEnd: UILabel!
    
    let FINISH_ICON_NAME = "icon_finish"

    let WARM_UP_NAME = NSLocalizedString("warm_up", comment: "")
    let STRETCH_NAME = NSLocalizedString("stretch", comment: "")
    let NO_LOGIN_ACCCOUNT_TITLE = NSLocalizedString("no_login_account_title", comment: "")

    let DEFAULTS = NSUserDefaults.standardUserDefaults()
    
    var email = ""
    
    var exerciseData: ExerciseData!
    
    var notificationHandler: NotificationHandler!
    
    var viewDelegate: ViewDelegate!
    var fitnessLogDelegate: FitnessLogDelegate!
    
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
        
        contentView.backgroundColor = Color.page_background
        
        // Header
        routineTitle.font = UIFont.boldSystemFontOfSize(Dimention.FONT_SIZE_NORMAL)
        dateLabel.font = dateLabel.font.fontWithSize(Dimention.FONT_SIZE_SMALL)
        
        routineTitle.textColor = Color.secondary_light
        dateLabel.textColor = Color.secondary_light
        
        // Exercise card
        exerciseTitle.font = UIFont.boldSystemFontOfSize(Dimention.FONT_SIZE_SMALL)
        exerciseTitle.textColor = Color.secondary_light
        exerciseItemStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Award card
        awardTitle.font = UIFont.boldSystemFontOfSize(Dimention.FONT_SIZE_SMALL)
        awardTitle.textColor = Color.secondary_light
        awardItemStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Footer
        websiteView.backgroundColor = Color.page_background
        
        websitePrefix.font = websitePrefix.font.fontWithSize(Dimention.FONT_SIZE_SMALL)
        websiteSuffix.font = UIFont.boldSystemFontOfSize(Dimention.FONT_SIZE_SMALL)
        websiteEnd.font = websiteEnd.font.fontWithSize(Dimention.FONT_SIZE_SMALL)
        
        websitePrefix.textColor = Color.secondary_light
        websiteSuffix.textColor = Color.secondary_light
        websiteEnd.textColor = Color.secondary_light
        
        websitePrefix.text = NSLocalizedString("app_name_prefix", comment: "")
        websiteSuffix.text = NSLocalizedString("app_name_suffix", comment: "")
        websiteEnd.text = NSLocalizedString("website_suffix", comment: "")
        
        addHeader()
        
        initMenuButtons()
        
        awardFinishAward()
        
        // We only want the completed exercises, so we filter out the incompleted ones.
        let completedExercises = Array(exerciseData.exerciseList[0...exerciseData.exerciseIndex - 1])
        addExercises(completedExercises)
        addAwards(notificationHandler.awards)
        
        fitnessLogDelegate.onHideLoading()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
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
     * Adds exercises to the exercise stack view.
     *
     * @param exercises    The awards to add.
     */
    func addExercises(exercises: [Exercise])
    {
        exerciseCardIcon.image = UIImage(named: "icon_fitness_log")
        exerciseTitle.text = NSLocalizedString("title_exercises", comment: "")
        
        var exercisesToDisplay = exercises
        
        var count = exercisesToDisplay.count
        
        // Remove the last exercise from the list if it is a stretch.
        if (exercisesToDisplay[count - 1].exerciseName == STRETCH_NAME)
        {
            exercisesToDisplay.removeLast()
            
            count -= 1
        }
        
        var lastCellIndex = count
        for i in 0 ..< count
        {
            let exercise = exercisesToDisplay[i]
            let exerciseName = exercise.exerciseName
            
            if (exerciseName != WARM_UP_NAME)
            {
                let view = Util.loadNib(Constant.OVERVIEW_EXERCISE_CELL) as! OverviewExerciseCellController
                view.title.text = exercise.exerciseName
                view.title.textColor = exercise.fromIntencity ? Color.primary : Color.secondary_dark
                
                // We only hide the last divider.
                // We only round the last corner radius.
                if (i == lastCellIndex)
                {
                    view.divider.hidden = true
                    view.layer.cornerRadius = Dimention.RADIUS
                }
                
                // Margins + ExerciseName height
                var exerciseCellHeight = (Dimention.LAYOUT_MARGIN * 2) + Dimention.FONT_SIZE_NORMAL
                // Add the diver height
                exerciseCellHeight += (i == count - 1) ? 1 : 0
                
                exerciseCellHeight += 12

                let sets = exercise.sets
                let setCount = sets.count
                
                for z in 0 ..< setCount
                {
                    let set = sets[z]
                
                    let weight = set.weight
                    let reps = set.reps
                    let duration = set.duration
                    
                    let isReps = reps > 0
                    
                    let exerciseSet = ExerciseSet.getSetText(weight, duration: isReps ? String(reps) : duration, isReps: isReps)
                    if (exerciseSet.hasValue)
                    {
                        var setCellHeight: CGFloat = 0
                        
                        if (z == 0)
                        {
                            setCellHeight += Dimention.RELATED_ITEM_MARGIN
                        }
                        else if (z != setCount)
                        {
                            setCellHeight += Dimention.OVERVIEW_SET_MARGIN
                        }
                        
                        setCellHeight += Dimention.FONT_SIZE_MEDIUM
                        
                        exerciseCellHeight += setCellHeight
                        
                        let setView = Util.loadNib(Constant.OVERVIEW_SET_CELL) as! OverviewSetCellController
                        setView.heightAnchor.constraintEqualToConstant(setCellHeight).active = true
                        setView.numberLabel.text = "\(z + 1)."
                        setView.setEditText(exerciseSet.mutableString)
                        
                        view.setStackView.addArrangedSubview(setView)
                    }
                }
                
                // Add padding between the sets and the exercise name if there are sets.
                if (view.setStackView.arrangedSubviews.count > 0)
                {
                    exerciseCellHeight += 2
                }
                
                view.heightAnchor.constraintEqualToConstant(exerciseCellHeight).active = true
                
                exerciseItemStackView.addArrangedSubview(view)
            }
            else
            {
                // Subtract 1 from the total because we have found a warm-up or stretch.
                // This will make surew e remove the divider on the last cell.
                lastCellIndex -= 1
            }
        }
    }
    
    /**
     * Adds awards to the award stack view.
     *
     * @param awards    The awards to add.
     */
    func addAwards(awards: [Awards])
    {
        let count = awards.count        
        if (count > 0)
        {
            awardCardIcon.image = UIImage(named: "ranking_badge")
            awardTitle.text = NSLocalizedString("awards_title", comment: "").uppercaseString
            
            for i in 0 ..< count
            {
                let view = Util.loadNib(Constant.NOTIFICATION_CELL) as! NotificationCellViewController
                view.heightAnchor.constraintEqualToConstant(view.bounds.size.height).active = true
                
                let award = awards[i]
                let imageName = award.awardImageName
                
                if (imageName != "")
                {
                    view.initCellWithImage(imageName)
                }
                else
                {
                    view.initCellWithTitle(award.awardTitle)
                }
                
                view.setAwardAmounts(award.amount)
                view.awardDescription.text = award.awardDescription
                
                // We only hide the last divider.
                // We only round the last corner radius.
                if (i == count - 1)
                {
                    view.divider.hidden = true
                    view.layer.cornerRadius = Dimention.RADIUS
                }
                
                awardItemStackView.addArrangedSubview(view)
            }
        }
        else
        {
            awardCard.removeFromSuperview()
        }
    }
    
    /**
     * The share overview bar button item method to share an image and text with and "intent."
     */
    func shareOverview(sender: UIBarButtonItem)
    {
        shareOverview()
    }
    
    /**
     * The share alert button method to share an image and text with and "intent."
     */
    func shareOverviewAlertButtonClicked(alertAction: UIAlertAction!) -> Void
    {
        shareOverview()
    }
    
    /**
     * Shares an image and text with and "intent."
     */
    func shareOverview()
    {
        var image: UIImage!
        
        // Scrolls the tableview so we can take a screenshot of it to share.
        scrollView.screenshot(1.0) { (screenshot) -> Void in
            
            image = screenshot
            
            var objectsToShare = [AnyObject]()
            
            if let shareTextObj = self.generateShareMessage()
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
                
                self.presentViewController(activityViewController, animated: true, completion: nil)
            }
            else
            {
                print("There is nothing to share")
            }
        }
    }
    
    /**
     * Awards the finish award to the user if he or she didn't already receive it.
     */
    func awardFinishAward()
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
        if (notificationHandler.getAwardIndex(finisherAward) == Int(Constant.CODE_FAILED))
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
        
        routineTitle.text = String(format: NSLocalizedString("header_overview", comment: ""), exerciseData.routineName).uppercaseString
        dateLabel.text = dateString
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
                            UIAlertAction(title: NSLocalizedString("title_share", comment: ""), style: .Default, handler: shareOverviewAlertButtonClicked),
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