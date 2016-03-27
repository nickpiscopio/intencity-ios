//
//  MainViewController.swift
//  Intencity
//
//  The view controller for the Fitness Log.
//
//  Created by Nick Piscopio on 2/8/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import Social

class FitnessLogViewController: UIViewController, ServiceDelegate, RoutineDelegate, ExerciseDelegate, ExerciseSearchDelegate, NotificationDelegate
{
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var connectionView: UIView!
    @IBOutlet weak var noConnectionLabel: UILabel!
    @IBOutlet weak var tryAgainButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextExerciseButton: UIButton!
    
    let CONTINUE_STRING = NSLocalizedString("routine_continue", comment: "")
    let WARM_UP_NAME = NSLocalizedString("warm_up", comment: "")
    let STRETCH_NAME = NSLocalizedString("stretch", comment: "")
    let MORE_PRIORITY_STRING = NSLocalizedString("more_priority_string", comment: "")
    let LESS_PRIORITY_STRING = NSLocalizedString("less_priority_string", comment: "")
    let NO_LOGIN_ACCCOUNT_TITLE = NSLocalizedString("no_login_account_title", comment: "")
    let FACEBOOK_BUTTON = NSLocalizedString("facebook_button", comment: "")
    let TWEET_BUTTON = NSLocalizedString("tweet_button", comment: "")

    let defaults = NSUserDefaults.standardUserDefaults()
    
    var notificationHandler: NotificationHandler!

    var totalExercises: Int!
    
    var numberOfCells = 0
    
    var displayMuscleGroups = [String]()
    var recommended = 0
    
    var email = ""
    var state = ""
    
    var currentExercises = [Exercise]()
    
    var exerciseData: ExerciseData!
    
    var exerciseListHeader: ExerciseListHeaderController!
    
    var savedExercises: SavedExercise!
    
    var insertIntoWebSetsIndex: Int!

    var routineCellController: RoutineCellController!
    
    var awards = [String: String]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("app_name", comment: "")
        
        email = Util.getEmailFromDefaults()
        
        notificationHandler = NotificationHandler.getInstance(self)
        
        initConnectionViews()
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: Dimention.TABLE_FOOTER_HEIGHT_PADDED, emptyTableStringRes: "")

        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: "RoutineCard", cellName: Constant.ROUTINE_CELL)
        Util.addUITableViewCell(tableView, nibNamed: "ExerciseCard", cellName: Constant.EXERCISE_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.EXERCISE_LIST_HEADER, cellName: Constant.EXERCISE_LIST_HEADER)
        
        showWelcome()
        
        initRoutineCard()
        
        setMenuButton(Constant.MENU_INITIALIZED)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        // Shows the tab bar again.
        self.tabBarController?.tabBar.hidden = false
    }
    
    /**
     * Sets the menu button animation.
     */
    func stopAnimation()
    {
        setMenuButton(Constant.MENU_NOTIFICATION_PRESENT)
    }
    
    /**
     * Sets the menu button.
     *
     * @param type  The button type to set.
     */
    func setMenuButton(type: Int)
    {
        var icon: UIImage!
        
        switch(type)
        {
            case Constant.MENU_INITIALIZED:
                icon = UIImage(named: Constant.MENU_INITIALIZED_IMAGE)!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                break
            case Constant.MENU_NOTIFICATION_FOUND:
                
                let duration = 0.5
                
                NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: #selector(FitnessLogViewController.stopAnimation), userInfo: nil, repeats: false)
                
                icon = UIImage.animatedImageNamed(Constant.MENU_NOTIFICATION_FOUND_IMAGE, duration: duration)!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                
                break
            case Constant.MENU_NOTIFICATION_PRESENT:
                icon = UIImage(named: Constant.MENU_NOTIFICATION_PRESENT_IMAGE)!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                break
            default:
                break
        }

        let iconSize = CGRect(origin: CGPointZero, size: CGSizeMake(Constant.MENU_IMAGE_WIDTH, Constant.MENU_IMAGE_HEIGHT))

        let iconButton = UIButton(frame: iconSize)
        iconButton.setImage(icon, forState: .Normal)
        iconButton.addTarget(self, action: #selector(FitnessLogViewController.menuClicked), forControlEvents: .TouchUpInside)
        
        self.navigationItem.rightBarButtonItem?.customView = iconButton
    }
    
    /**
     * Opens the menu.
     */
    func menuClicked()
    {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier(Constant.MENU_VIEW_CONTROLLER) as! MenuViewController
        
        self.navigationController!.pushViewController(vc, animated: true)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /**
     * Calls the service to get the display muscle groups for the routine card.
     */
    func initRoutineCard()
    {
        nextExerciseButton.hidden = true
        
        showLoading()
        
        totalExercises = 7
        
        numberOfCells = 0
        
        // Creates the instance of the exercise data so we can store the exercises in the database later.
        ExerciseData.reset()
        exerciseData = ExerciseData.getInstance()
        
        state = Constant.ROUTINE_CELL
        
        tableView.reloadData()
        
        _ = ServiceTask(event: ServiceEvent.GET_ALL_DISPLAY_MUSCLE_GROUPS, delegate: self,
                        serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_ALL_DISPLAY_MUSCLE_GROUPS, variables: [ email ]))
    }
    
    /**
     * Initializes the connection views.
     */
    func initConnectionViews()
    {
        loadingView.backgroundColor = Color.page_background
        connectionView.backgroundColor = Color.page_background
        
        loadingView.hidden = true
        connectionView.hidden = true
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.hidden = true
        
        noConnectionLabel.textColor = Color.secondary_light
        noConnectionLabel.text = NSLocalizedString("generic_error", comment: "")
        tryAgainButton.setTitle(NSLocalizedString("try_again", comment: ""), forState: .Normal)
    }
    
    /**
     * Shows the task is in progress.
     */
    func showLoading()
    {
        activityIndicator.startAnimating()
        activityIndicator.hidden = false
        
        loadingView.hidden = false
    }
    
    /**
     * Shows the task is in finished.
     */
    func hideLoading()
    {
        loadingView.hidden = true
        
        activityIndicator.stopAnimating()
    }
    /**
     * Shows there was a connection issue.
     */
    func showConnectionIssue()
    {
        connectionView.hidden = false
    }
    
    /**
     * Hides the connection issue.
     */
    func hideConnectionIssue()
    {
        connectionView.hidden = true
    }
    
    @IBAction func tryAgainClick(sender: AnyObject)
    {
        initRoutineCard()
    }
    
    func onRetrievalSuccessful(event: Int, result: String)
    {
        switch (event)
        {
            case ServiceEvent.GET_ALL_DISPLAY_MUSCLE_GROUPS:
                
                loadTableViewItems(state, result: result)
                
                break
            case ServiceEvent.SET_CURRENT_MUSCLE_GROUP:
                
                showLoading()
                
                _ = ServiceTask(event: ServiceEvent.GET_EXERCISES_FOR_TODAY, delegate: self,
                                serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                                params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_EXERCISES_FOR_TODAY, variables:  [ email ]))
                
                break
            
            case ServiceEvent.GET_EXERCISES_FOR_TODAY:
                    
                state = Constant.EXERCISE_CELL
                    
                loadTableViewItems(state, result: result)
                
                break
            case ServiceEvent.INSERT_EXERCISES_TO_WEB_DB:
                
                // Remove the first and last character because they are "[" and "]";
                var response = result
                response.removeAtIndex(response.startIndex)
                response.removeAtIndex(response.endIndex.predecessor())
                
                var ids =  response.componentsSeparatedByString(Constant.PARAMETER_DELIMITER)
                
                var sets = exerciseData.exerciseList[insertIntoWebSetsIndex].sets
                let setCount = sets.count
                
                for i in 0 ..< setCount
                {
                    if (sets[i].webId > 0)
                    {
                        continue;
                    }
                    
                    // Set the web id to the first id in the list.
                    sets[i].webId = Int(ids[0])!
                    
                    // Remove the first index since we used it already.
                    ids.removeFirst()
                }
                
                exerciseData.exerciseList[insertIntoWebSetsIndex].sets = sets

                break;
            default:
                break
        }
    }
    
    func onRetrievalFailed(event: Int)
    {
        showConnectionIssue()
        
        hideLoading()
        
        if (state == Constant.ROUTINE_CELL)
        {
           loadTableViewItems(state, result: "")
        }
    }
    
    func onNotificationAdded()
    {
        setMenuButton(Constant.MENU_NOTIFICATION_FOUND)
    }
    
    func onNotificationsViewed()
    {
        setMenuButton(Constant.MENU_INITIALIZED)
    }
    
    /**
     * Shows the welcome alert to the user if needed.
     */
    func showWelcome()
    {
        let lastLogin = defaults.floatForKey(Constant.USER_LAST_LOGIN)
        
        if (Util.getEmailFromDefaults() != "" && lastLogin == 0)
        {
            Util.displayAlert(self,
                title: NSLocalizedString("welcome_title", comment: ""),
                message: NSLocalizedString("welcome_description", comment: ""),
                actions: [ UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .Default, handler: nil) ])
        }
    }
    
    /**
     * The callback for when an exercise is added from searching.
     */
    func onExerciseAdded(exercise: Exercise)
    {
        var exercises = exerciseData.exerciseList
        let exerciseCount = exercises.count
        
        for i in 0 ..< exerciseCount - 1
        {
            if (exercise.exerciseName == exercises[i].exerciseName)
            {
                exercises.removeAtIndex(i)
            }
        }
        
        let currentExerciseCount = currentExercises.count
        var removeStretch = false
        
        if (currentExercises[currentExerciseCount - 1].exerciseName == STRETCH_NAME)
        {
            removeStretch = true
        }
        
        exercises.insert(exercise, atIndex: removeStretch ? currentExerciseCount - 1 : currentExerciseCount)
        
        exerciseData.exerciseList = exercises

        addExercise(false, fromSearch: true)
    }
    
    /**
     * The button click to get the next exercise.
     */
    @IBAction func nextExerciseClicked(sender: AnyObject)
    {
        if (currentExercises.count != exerciseData.exerciseList.count)
        {
            addExercise(false, fromSearch: false)
        }
        else
        {
            // Grant the user the "Kept Swimming" badge if he or she didn't skip an exercise.
            if (!defaults.boolForKey(Constant.BUNDLE_EXERCISE_SKIPPED))
            {
                let keptSwimmingAward = Awards(awardImageName: "badge_keep_swimming", awardDescription: NSLocalizedString("award_kept_swimming_description", comment: ""))
                Util.grantBadgeToUser(email, badgeName: Badge.KEPT_SWIMMING, content: keptSwimmingAward, onlyAllowOne: true)
            }
            else
            {
                // Set the user has skipped an exercise to false for next time.
                setExerciseSkipped(false)
            }
            
            let finisherDescription = NSLocalizedString("award_finisher_description", comment: "")
    
            // Custom alert: https://github.com/danny-source/DYAlertPickerViewDemo
//            let awards = notificationHandler.awards
            
            let finisherAward = Awards(awardImageName: "badge_finisher", awardDescription: finisherDescription)
            if (!notificationHandler.hasAward(finisherAward))
            {
                Util.grantPointsToUser(email, points: Constant.POINTS_COMPLETING_WORKOUT, description: NSLocalizedString("award_finisher_description", comment: ""))
                Util.grantBadgeToUser(email, badgeName: Badge.FINISHER, content: finisherAward, onlyAllowOne: true)
            }
            
            let actions = [ UIAlertAction(title: FACEBOOK_BUTTON, style: .Default, handler: share),
                            UIAlertAction(title: TWEET_BUTTON, style: .Default, handler: share),
                            UIAlertAction(title: NSLocalizedString("finish_button", comment: ""), style: .Destructive, handler: finishExercising),
                            UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .Default, handler: nil) ]
            
            Util.displayAlert(self,
                title: NSLocalizedString("completed_workout_title", comment: ""),
                message: "",
                actions: actions)
        }
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
        defaults.setBool(skipped, forKey: Constant.BUNDLE_EXERCISE_SKIPPED)
    }
    
    /**
     * Adds an exercise to the currentExercises.
     */
    func addExercise(initialLoad: Bool, fromSearch: Bool)
    {
        let currentExerciseCount = currentExercises.count
        // If there is 1 exercise left, we want to display the stretch.
        // We remove all the unnecessary exercises.
        if (!initialLoad && !fromSearch && totalExercises - currentExerciseCount <= 1)
        {
            let stretch = exerciseData.exerciseList[exerciseData.exerciseList.count - 1]
            
            exerciseData.exerciseList.removeAll()
            exerciseData.exerciseList = currentExercises
            exerciseData.exerciseList.append(stretch)
        }
        
        let lastExerciseTime = defaults.floatForKey(Constant.USER_LAST_EXERCISE_TIME)
        let now = Float(NSDate().timeIntervalSince1970 * 1000)
        
        if ((now - lastExerciseTime) >= Float(Constant.EXERCISE_POINTS_THRESHOLD))
        {
            defaults.setFloat(now, forKey: Constant.USER_LAST_EXERCISE_TIME)
            
            // Reward the user for exercising.
            // We use a relaxed system for giving points, so we only try to make it so they can't game the system.
            Util.grantPointsToUser(email, points: Constant.POINTS_EXERCISE, description: NSLocalizedString("award_exercise_description", comment: ""))
        }
        
        let position = currentExerciseCount - 1
        
        if (fromSearch && currentExercises[position].exerciseName == STRETCH_NAME)
        {
            let indexPath = NSIndexPath(forRow: position, inSection: 0)
            
            hideExercise(indexPath, fromSearch: fromSearch, forever: false)
        }
        else
        {            
            currentExercises.append(exerciseData.exerciseList[exerciseData.exerciseIndex])
            
            // Get the next exercise.
            exerciseData.exerciseIndex += 1
            
            insertRow()
            
            updateExerciseTotal()
        }
        
        // Set the current exercises in the exercise list header so we can exclude adding exercises that we already have when searching.
        exerciseListHeader.currentExercises = currentExercises
    }
    
    /**
     * Updates the number of exercises left.
     */
    func updateExerciseTotal()
    {
        let totalExerciseCount = exerciseData.exerciseList.count
        
        if (totalExerciseCount < totalExercises)
        {
            totalExercises = totalExerciseCount
        }
        
        exerciseListHeader.exerciseTotalLabel.text = "\(currentExercises.count) / \(totalExercises)"
    }
    
    /**
     * Loads the table views.
     * 
     * @param state     The state of the fitness log.
     * @param result    The results to parse from the webservice.
     */
    func loadTableViewItems(state: String, result: String)
    {
        // This gets saved as NSDictionary, so there is no order
        let json: AnyObject? = result.parseJSONString
        
        var indexToLoad = 1
        
        if (state == Constant.ROUTINE_CELL)
        {
            displayMuscleGroups.removeAll()
            
            var recommended: String?
            
            if (json != nil)
            {
                for muscleGroups in json as! NSArray
                {
                    let muscleGroup = muscleGroups[Constant.COLUMN_DISPLAY_NAME] as! String
                    recommended = muscleGroups[Constant.COLUMN_CURRENT_MUSCLE_GROUP] as? String
                    
                    displayMuscleGroups.append(muscleGroup)
                }
                
                hideConnectionIssue()
            }
            
            // Get the saved exercises from the local database.
            savedExercises = DBHelper().getRecords()
            
            if (savedExercises.routineName != "")
            {
                displayMuscleGroups.append(CONTINUE_STRING)
                
                self.recommended = displayMuscleGroups.count - 1
            }
            else if (json != nil)
            {
                self.recommended = (recommended == nil || recommended! == "") ? 0 : displayMuscleGroups.indexOf(recommended!)!
            }
            
            if (displayMuscleGroups.count > 0)
            {
               animateTable(indexToLoad)
            }
            else
            {
                initRoutineCard()
            }
        }
        else
        {
            nextExerciseButton.hidden = false

            // This means we got results back from the web database.
            if (result != "" && result != Constant.RETURN_NULL)
            {
                do
                {
                    exerciseData.exerciseList.appendContentsOf(try ExerciseDao().parseJson(json))
                    exerciseData.addStretch()
                }
                catch
                {
                    showConnectionIssue()
                }
                
            }
            // This means we got the results from the iOS database.
            else
            {
                exerciseData.exerciseList = savedExercises.exercises
                
                indexToLoad = savedExercises.index
            }
            
            hideConnectionIssue()
            
            animateTable(indexToLoad)
        }
        
        hideLoading()
    }
    
    /**
     * The callback for when the user selects to start exercising.
     */
    func onStartExercising(routine: Int)
    {
        let routineName = displayMuscleGroups[routine - 1]
        
        if (routineName == CONTINUE_STRING)
        {
            exerciseData.routineName = savedExercises.routineName
            
            state = Constant.EXERCISE_CELL
            
            loadTableViewItems(state, result: "")
        }
        else
        {
            exerciseData.routineName = routineName
            
            showLoading()
            
            _ = ServiceTask(event: ServiceEvent.SET_CURRENT_MUSCLE_GROUP, delegate: self,
                            serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                            params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_SET_CURRENT_MUSCLE_GROUP, variables: [ email, String(routine) ]))
        }
    }
    
    /**
     * The callback for when an exercise is clicked in the exercise list.
     *
     * @param name  The name of the exercise clicked.
     */
    func onExerciseClicked(name: String)
    {
        if (name == WARM_UP_NAME || name == STRETCH_NAME)
        {
            let viewController = self.storyboard?.instantiateViewControllerWithIdentifier(Constant.EXERCISE_SEARCH_VIEW_CONTROLLER) as! ExerciseSearchViewController
            viewController.searchType = name
            viewController.routineName = exerciseListHeader.routineNameLabel.text
                
            self.navigationController!.pushViewController(viewController, animated: true)
        }
        else
        {
            let viewController = self.storyboard?.instantiateViewControllerWithIdentifier(Constant.DIRECTION_VIEW_CONTROLLER) as! DirectionViewController
            viewController.exerciseName = name
                
            self.navigationController!.pushViewController(viewController, animated: true)
        }
    }
    
    /**
     * The callback for when the hide button is clicked on an exercise card.
     *
     * @param indexPath     The indexPath of the exercise to hide.
     */
    func onHideClicked(indexPath: NSIndexPath)
    {
        hideExercise(indexPath, fromSearch: false, forever: false)
    }
    
    /**
     * The callback for when the edit button is clicked.
     *
     * @param index     The index of the exercise that was clicked.
     */
    func onEditClicked(index: Int)
    {
        let statViewController = self.storyboard?.instantiateViewControllerWithIdentifier("StatViewController") as! StatViewController
        statViewController.delegate = self
        statViewController.index = index
        
        self.navigationController!.pushViewController(statViewController, animated: true)
    }
    
    /**
     * The callback for when the sets are updated.
     */
    func onSetUpdated(index: Int)
    {
        // We notify the data set changed just in case something changed in the stat activity.
        // This will update the last set the user did.
        tableView.reloadData()
        
        let exercise = exerciseData.exerciseList[index]
        
        let exerciseName = exercise.exerciseName
        let sets = exercise.sets
        
        let setSize = sets.count
        let statements = "statements="
        var updateString = statements + String(setSize) + Constant.PARAMETER_AMPERSAND + Constant.PARAMETER_EMAIL + email
        var insertString = statements + String(setSize) + Constant.PARAMETER_AMPERSAND + Constant.PARAMETER_EMAIL + email
        
        // The update and insert Strings already starts out with a value in it,
        // so we need this boolean to decide if we are going to conduct these actions.
        var conductUpdate = false
        var conductInsert = false
        
        let badge = Badge.LEFT_IT_ON_THE_FIELD
        var setsWithRepsGreaterThan10 = 0
        
        // we need our own indexes here or the services won't work properly.
        var updateIndex = 0
        var insertIndex = 0
        
        // Sort through the sets to determine if we are updating or inserting.
        for i in 0 ..< setSize
        {
            let set = sets[i]
            
            var containsBadge = false
            
            for (badgeName, exerciseAwardName) in awards
            {
                if (badgeName == badge && exerciseAwardName == exerciseName)
                {
                    containsBadge = true
                    
                    break
                }
            }
            
            // Checks to see if the user deserves the "Left it on the Field" badge.
            if (!containsBadge && set.reps >= 10 || !containsBadge && Util.convertToInt(set.duration) >= 100)
            {
                setsWithRepsGreaterThan10 += 1
                    
                if (setsWithRepsGreaterThan10 >= 2)
                {
                    let email = Util.getEmailFromDefaults()
                        
                    Util.grantBadgeToUser(email, badgeName: badge, content: Awards(awardImageName: "badge_field", awardDescription: NSLocalizedString("award_left_it_on_the_field_description", comment: "")), onlyAllowOne: false)
                        
                    awards[badge] = exerciseName
                }
            }
            
            if (set.webId > 0)
            {
                // Call update
                updateString += generateComplexUpdateParameters(updateIndex, set: set);
                conductUpdate = true
                updateIndex += 1
            }
            else
            {
                // Concatenate the insert parameter String.
                insertString += generateComplexInsertParameters(insertIndex, name: exerciseName, set: set);
                conductInsert = true
                insertIndex += 1
            }
        }
        
        if (conductUpdate)
        {
            // Update the exercise on the web.
            _ = ServiceTask(event: ServiceEvent.UPDATE_EXERCISES_TO_WEB_DB,
                            delegate: self,
                            serviceURL: Constant.SERVICE_COMPLEX_UPDATE,
                            params: updateString)
        }
        
        if (conductInsert)
        {
            insertIntoWebSetsIndex = index
            
            // Save the exercise to the web.
            // The service listener was placed in here so we can update the sets of the exercise
            // with the auto incremented ids from the web.
            _ = ServiceTask(event: ServiceEvent.INSERT_EXERCISES_TO_WEB_DB,
                            delegate: self,
                            serviceURL: Constant.SERVICE_COMPLEX_INSERT,
                            params: insertString)
        }
    }
    
    /**
     * The callback for when an exercise priority is set.
     *
     * @param index         The index of the exercise we are setting.
     * @param increasing    Boolean value of whether or not we are incresing or decreasing the priority of the exercise.
     */
    func onSetExercisePriority(indexPath: NSIndexPath, increasing: Bool)
    {
        let index = indexPath.row
        
        let exerciseName = currentExercises[index].exerciseName
        
        _ = ServiceTask(event: ServiceEvent.NO_RETURN, delegate: nil,
            serviceURL: Constant.SERVICE_STORED_PROCEDURE,
            params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_SET_EXERCISE_PRIORITY, variables: [ email, exerciseName, String(increasing ? 1 : 0) ]))
        
        if (!increasing)
        {
            hideExercise(indexPath, fromSearch: false, forever: false)
        }
        
        // Displays a toast to the user telling them they will see an exercise more or less.
        self.tabBarController?.view.makeToast(String(format: increasing ? MORE_PRIORITY_STRING : LESS_PRIORITY_STRING, arguments: [ exerciseName ]))
    }
    
    /**
     * Constructs a snippet of the parameter query sent to the service for updating.
     *
     * @param index     The index of the sets we are updating.
     * @param set       The set we are updating.
     *
     * @return  The constructed snippet of the complex update parameter String.
     */
    func generateComplexUpdateParameters(index: Int, set: Set) -> String
    {
        let equals = "="
        let setParam = "set"
        let whereParam = "where"
        let nullString = "NULL"
    
        let weight = set.weight
        let duration = set.duration
        let notes = set.notes
        let isDuration = !duration.isEmpty && duration.rangeOfString(":") != nil
    
        let weightParam = Constant.COLUMN_EXERCISE_WEIGHT + equals + String(weight) + Constant.PARAMETER_DELIMITER;
        // Choose whether we are inserting reps or duration.
        let durationParam = isDuration ?
                                Constant.COLUMN_EXERCISE_DURATION + equals + "'" + duration + "'" + Constant.PARAMETER_DELIMITER
                                    + Constant.COLUMN_EXERCISE_REPS + equals + nullString + Constant.PARAMETER_DELIMITER :
                                Constant.COLUMN_EXERCISE_DURATION + equals + nullString + Constant.PARAMETER_DELIMITER
                                    + Constant.COLUMN_EXERCISE_REPS + equals + String(set.reps) + Constant.PARAMETER_DELIMITER
    
        let notesParam = !notes.isEmpty && notes.characters.count > 0 ? "'" + notes + "'" : nullString
    
        return getParameterTitle(Constant.PARAMETER_TABLE, index: index) + Constant.TABLE_COMPLETED_EXERCISE
                + getParameterTitle(setParam, index: index)
                + weightParam
                + durationParam
                + Constant.COLUMN_EXERCISE_DIFFICULTY + equals + String(set.difficulty) + Constant.PARAMETER_DELIMITER
                + Constant.COLUMN_NOTES + equals + notesParam
                + getParameterTitle(whereParam, index: index)
                + Constant.COLUMN_ID + equals + String(set.webId)
    }
    /**
     * Constructs a snippet of the parameter query sent to the service to insert.
     *
     * @param index     The index of the sets we are inserting.
     * @param name      The name of the exercise we are inserting.
     * @param set       The set we are inserting.
     *
     * @return  The constructed snippet of the complex insert parameter String.
     */
    func generateComplexInsertParameters(index: Int, name: String, set: Set) -> String
    {
        let columns = "columns"
        let inserts = "inserts"
    
        let curDate = "CURDATE()"
        let now = "NOW()"
    
        let weight = set.weight
        let duration = set.duration
        let hasWeight = weight > 0
        let isDuration = !duration.isEmpty && duration.rangeOfString(":") != nil
    
        let weightParam = hasWeight ? Constant.COLUMN_EXERCISE_WEIGHT + Constant.PARAMETER_DELIMITER : ""
        let weightValue = hasWeight ? String(weight) + Constant.PARAMETER_DELIMITER : ""
        
        // Choose whether we are inserting reps or duration.
        let durationParam = isDuration ? Constant.COLUMN_EXERCISE_DURATION + Constant.PARAMETER_DELIMITER :
                                Constant.COLUMN_EXERCISE_REPS + Constant.PARAMETER_DELIMITER
        let durationValue = isDuration ? duration : String(set.reps)
    
        return getParameterTitle(Constant.PARAMETER_TABLE, index: index)
                + Constant.TABLE_COMPLETED_EXERCISE
                + getParameterTitle(columns, index: index) + Constant.COLUMN_DATE + Constant.PARAMETER_DELIMITER
                + Constant.COLUMN_TIME + Constant.PARAMETER_DELIMITER
                + Constant.COLUMN_EXERCISE_NAME + Constant.PARAMETER_DELIMITER
                + weightParam
                + durationParam
                + Constant.COLUMN_EXERCISE_DIFFICULTY + Constant.PARAMETER_DELIMITER
                + Constant.COLUMN_NOTES
                + getParameterTitle(inserts, index: index) + curDate + Constant.PARAMETER_DELIMITER
                + now + Constant.PARAMETER_DELIMITER
                + name + Constant.PARAMETER_DELIMITER
                + weightValue
                + durationValue + Constant.PARAMETER_DELIMITER
                + String(set.difficulty) + Constant.PARAMETER_DELIMITER
                + set.notes
    }
    
    /**
     * Constructs the parameter title.
     *
     * @param name      The name of the parameter to use.
     * @param index     The index of the parameter to use.
     *
     * @return  The formatted parameter to send to the service.
     *          i.e. &columns0=
     */
    func getParameterTitle(name: String, index: Int) -> String
    {
        return Constant.PARAMETER_AMPERSAND + name + String(index) + "=";
    }
    
    /**
     * Animates the table being added to the screen.
     *
     * @param loadNextExercise  A boolean value of whether to load the next exercise or not.
     */
    func animateTable(indexToLoad: Int)
    {
        numberOfCells = 1
        
        if (state == Constant.ROUTINE_CELL && routineCellController != nil)
        {
            tableView.reloadData()
        }
        else
        {
            let range = NSMakeRange(0, self.tableView.numberOfSections)
            let sections = NSIndexSet(indexesInRange: range)
            
            tableView.reloadSections(sections, withRowAnimation: .Top)
        }
        
        if (state == Constant.EXERCISE_CELL)
        {
            for _ in 0 ..< indexToLoad
            {
                addExercise(true, fromSearch: false)
            }
        }
    }
    
    /**
     * Scrolls to the bottom of the table view.
     *
     * This does hide the white space behind the tab view.
     */
    func tableViewScrollToBottom(animated: Bool)
    {
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue(), {
            
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRowsInSection(numberOfSections - 1)
            
            if numberOfRows > 0
            {
                let indexPath = NSIndexPath(forRow: numberOfRows - 1, inSection: (numberOfSections - 1))
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
            }
            
        })
    }
    
    /**
     * Animates a row being added to the screen.
     */
    func insertRow()
    {
        let indexPath = NSIndexPath(forRow: currentExercises.count - 1, inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        tableViewScrollToBottom(true)
    }
    
    // http://stackoverflow.com/questions/31870206/how-to-insert-new-cell-into-uitableview-in-swift
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        // Return the number of rows in the section.
        return state == Constant.ROUTINE_CELL ? numberOfCells : currentExercises.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (state == Constant.EXERCISE_CELL)
        {
            exerciseListHeader = tableView.dequeueReusableCellWithIdentifier(Constant.EXERCISE_LIST_HEADER) as! ExerciseListHeaderController
            exerciseListHeader.routineNameLabel.text = exerciseData.routineName
            exerciseListHeader.navigationController = self.navigationController
            exerciseListHeader.exerciseSearchDelegate = self
            return exerciseListHeader.contentView
        }
    
        return nil       
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return state == Constant.EXERCISE_CELL ? 65 : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if (state == Constant.ROUTINE_CELL)
        {
            routineCellController = tableView.dequeueReusableCellWithIdentifier(Constant.ROUTINE_CELL) as! RoutineCellController
            routineCellController.selectionStyle = UITableViewCellSelectionStyle.None
            routineCellController.delegate = self
            routineCellController.dataSource = displayMuscleGroups
            // Need to add 1 to the routine so we get back the correct value when setting the muscle group for today.
            // CompletedMuscleGroup starts at 1.
            routineCellController.selectedRoutineNumber = recommended + 1
            routineCellController.setDropDownDataSource(recommended)
            routineCellController.setDropDownWidth(displayMuscleGroups.contains(CONTINUE_STRING))
            return routineCellController
        }
        else
        {
            let index = indexPath.item
            let exercise = exerciseData.exerciseList[index]
            let description = exercise.exerciseDescription
            let sets = exercise.sets
            let set = sets[sets.count - 1]

            let cell = tableView.dequeueReusableCellWithIdentifier(Constant.EXERCISE_CELL) as! ExerciseCellController
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.delegate = self
            cell.tableView = tableView
            cell.exerciseButton.setTitle(exercise.exerciseName, forState: .Normal)
            cell.setEditText(set)
            
            if (!description.isEmpty)
            {
                cell.setDescription(description)
            }
            else
            {
                cell.setAsExercise()
            }
            
            return cell
        }
    }
    
    /**
     * Randomly generates a message to share with social media.
     *
     * @param socialNetworkButton   The button that was pressed in the alert.
     *
     * @return  The generated tweet.
     */
    func generateShareMessage(socialNetworkButton: String) -> String
    {
        let routineName = exerciseListHeader.routineNameLabel.text!
        let routine = routineName.stringByReplacingOccurrencesOfString(" ", withString: "").stringByReplacingOccurrencesOfString(Constant.PARAMETER_AMPERSAND, withString: " & #")
        
        let shareMessage = ["I #dominated my #workout with #Intencity! #WOD #Fitness",
                                "I #finished my #workout of the day with #Intencity! #WOD #Fitness",
                                "I made it through #Intencity's #routine! #Fitness",
                                "I #completed #" + routine + " with #Intencity! #WOD #Fitness",
                                "#Finished my #Intencity #workout! #Retweet if you've #exercised today. #WOD #Fitness",
                                "I #lifted with #Intencity today! #lift #lifting" ]
        
        let intencityUrl = " www.Intencity.fit"
        let via = " @Intencity" + (socialNetworkButton == TWEET_BUTTON ? "App" : "")
    
        let message = Int(arc4random_uniform(UInt32(shareMessage.count)))
    
        return shareMessage[message] + via + intencityUrl
    }
    
    /**
     * Hides an exercise in the exercise list.
     *
     * @param indexPath The index path for the exercise to hide.
     * @param forever       Whether to call the stored proceedure to hide the exercise forever.
     */
    func hideExercise(indexPath: NSIndexPath, fromSearch: Bool, forever: Bool)
    {
        tableView.beginUpdates()
        
        let index = indexPath.row
        
        let exerciseName = currentExercises[index].exerciseName
        
        currentExercises.removeAtIndex(index)
        
        if (exerciseName != STRETCH_NAME)
        {
            exerciseData.exerciseList.removeAtIndex(index)
        }
        
        exerciseData.exerciseIndex -= 1
        
        updateExerciseTotal()
        
        // Note that indexPath is wrapped in an array: [indexPath]
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
        
        if ((exerciseName != STRETCH_NAME || fromSearch) && currentExercises[currentExercises.count - 1].exerciseName != STRETCH_NAME)
        {
            addExercise(false, fromSearch: fromSearch)
        }
        
        // Add that the user has skipped an exercise.
        // Can't get the Kept Swimming badge.
        setExerciseSkipped(true)
        
        if (forever && exerciseName != WARM_UP_NAME && exerciseName != STRETCH_NAME)
        {
            // Hide the exercise on the web server.
            // The delegate is nil because we don't care if it reached the server.
            // The worst that will happen is a user will have to hide the exercise again.
            _ = ServiceTask(event: ServiceEvent.NO_RETURN, delegate: nil,
                            serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                            params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_EXCLUDE_EXERCISE, variables: [ email, exerciseName ]))
        }
        
        tableView.endUpdates()
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
        
        initRoutineCard()
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