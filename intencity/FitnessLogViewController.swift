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

class FitnessLogViewController: UIViewController, ServiceDelegate, ExerciseDelegate, ExerciseSearchDelegate, RoutineDelegate
{    
    enum ActiveButtonState
    {
        case SEARCH
        case INTENCITY
    }
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inactiveButton: IntencityButtonRoundLight!
    @IBOutlet weak var activeButton: UIButton!
    
    let CONTINUE_STRING = NSLocalizedString("routine_continue", comment: "")
    let WARM_UP_NAME = NSLocalizedString("warm_up", comment: "")
    let STRETCH_NAME = NSLocalizedString("stretch", comment: "")
    let MORE_PRIORITY_STRING = NSLocalizedString("more_priority_string", comment: "")
    let LESS_PRIORITY_STRING = NSLocalizedString("less_priority_string", comment: "")
    let NO_LOGIN_ACCCOUNT_TITLE = NSLocalizedString("no_login_account_title", comment: "")
    let FACEBOOK_BUTTON = NSLocalizedString("facebook_button", comment: "")
    let TWEET_BUTTON = NSLocalizedString("tweet_button", comment: "")

    let DEFAULTS = NSUserDefaults.standardUserDefaults()
    
    let EXERCISE_MINIMUM_THRESHOLD = 3
    
    var viewDelegate: ViewDelegate!
    
    var notificationHandler: NotificationHandler!
    
    var exerciseListHeader: ExerciseListHeaderController!
    var routineFooter: RoutineCellFooterController!

    var insertIntoWebSetsIndex: Int!
    var totalExercises = 7
    
    var displayMuscleGroups = [String]()
    var recommended = 0
    
    var email = ""
    
    var currentExercises = [Exercise]()
    
    var exerciseData: ExerciseData!
    
    var savedExercises: SavedExercise!
    
    var awards = [String: String]()
    
    var routineState: Int!
    var activeButtonState = ActiveButtonState.INTENCITY
    
    var textField: UITextField!
    
    var result: String!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        email = Util.getEmailFromDefaults()
        
        notificationHandler = NotificationHandler.getInstance(nil)
        
        initConnectionViews()
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: Dimention.TABLE_FOOTER_HEIGHT_NORMAL, emptyTableStringRes: "")

        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: "ExerciseCard", cellName: Constant.EXERCISE_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.EXERCISE_LIST_HEADER, cellName: Constant.EXERCISE_LIST_HEADER)
        
        textField = UITextField(frame: CGRectMake(0, 0, 10, 10))
        
        exerciseData = ExerciseData.getInstance()
        exerciseData.routineState = routineState
        
        loadTableViewItems(result)
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
        viewDelegate.onLoadView(View.ROUTINE_VIEW, result: "", savedExercises: nil, state: RoutineState.NONE)
    }
    
    /**
     * Initializes the connection views.
     */
    func initConnectionViews()
    {
        loadingView.backgroundColor = Color.page_background
        
        loadingView.hidden = true
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.hidden = true
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
    
    func onRetrievalSuccessful(event: Int, result: String)
    {
        switch (event)
        {
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
            case ServiceEvent.SAVE_ROUTINE:
                
                hideLoading()
                
                // Displays a toast to the user telling them they will see an exercise more or less.
                self.tabBarController?.view.makeToast(String(format: NSLocalizedString("routine_saved", comment: ""), arguments: [ textField.text! ]))
                
                break;
            default:
                break
        }
    }
    
    func onRetrievalFailed(event: Int)
    {
        switch (event)
        {
            case ServiceEvent.SAVE_ROUTINE:
                
                displaySaveAlert(SaveState.SAME_NAME_ERROR)
            
                break;
            default:
                
                //SHOW CONNECTION ISSUE
                viewDelegate.onLoadView(View.ROUTINE_VIEW, result: "", savedExercises: nil, state: RoutineState.NONE)
                
                break
        }
        
        hideLoading()
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
     * Sets the next button images.
     */
    func setButtons()
    {
        var inactiveButtonImage: String!
        var activeButtonImage: String!
        
        switch activeButtonState
        {
            case .INTENCITY:
                inactiveButtonImage = "search_button_small"                
                activeButtonImage = "next_button"
                break
            case .SEARCH:
                
                activeButtonImage = "search_button_large"
                inactiveButtonImage = "next_button_small"
                break
        }

        inactiveButton.setImage(UIImage(named:inactiveButtonImage), forState: .Normal)
        activeButton.setImage(UIImage(named:activeButtonImage), forState: .Normal)
    }
    
    @IBAction func inactiveButtonClicked(sender: AnyObject)
    {
        switch activeButtonState
        {
            case .INTENCITY:
                activeButtonState = .SEARCH
                break
            case .SEARCH:
                activeButtonState = .INTENCITY
                break
        }
        
        setButtons()
    }
    
    @IBAction func activeButtonClicked(sender: AnyObject)
    {
        switch activeButtonState
        {
            case .INTENCITY:
                nextExerciseClicked()
                break
            case .SEARCH:
                searchClicked()
                break
        }

    }
    
    /**
     * Opens the search screen.
     */
    func searchClicked()
    {
        let viewController = storyboard!.instantiateViewControllerWithIdentifier(Constant.SEARCH_VIEW_CONTROLLER) as! SearchViewController
        viewController.state = ServiceEvent.SEARCH_FOR_EXERCISE
        viewController.exerciseSearchDelegate = self
        viewController.currentExercises = currentExercises
        
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    /**
     * The button click to get the next exercise.
     */
    func nextExerciseClicked()
    {
        if (currentExercises.count != exerciseData.exerciseList.count)
        {
            addExercise(false, fromSearch: false)
        }
        else
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
    
            // Custom alert: https://github.com/danny-source/DYAlertPickerViewDemo
//            let awards = notificationHandler.awards
            
            let finisherAward = Awards(awardImageName: Badge.FINISHER_IMAGE_NAME, awardDescription: finisherDescription)
            if (!notificationHandler.hasAward(finisherAward))
            {
                Util.grantPointsToUser(email, points: Constant.POINTS_COMPLETING_WORKOUT, description: NSLocalizedString("award_finisher_description", comment: ""))
                Util.grantBadgeToUser(email, badgeName: Badge.FINISHER, content: finisherAward, onlyAllowOne: true)
            }
            
            displayFinishAlert()
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
        
        let lastExerciseTime = DEFAULTS.floatForKey(Constant.USER_LAST_EXERCISE_TIME)
        let now = Float(NSDate().timeIntervalSince1970 * 1000)
        
        if ((now - lastExerciseTime) >= Float(Constant.EXERCISE_POINTS_THRESHOLD))
        {
            DEFAULTS.setFloat(now, forKey: Constant.USER_LAST_EXERCISE_TIME)
            
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
        
        // The first exercise is the warm-up.
        // We only want to show the save button if a user has an exercise showing.
        let currentExerciseCount = currentExercises.count
        exerciseListHeader.saveButton.hidden = currentExerciseCount < 2 || (currentExerciseCount == 2 && currentExercises[currentExerciseCount - 1].exerciseName == STRETCH_NAME)
        
        exerciseListHeader.setExerciseTotalLabel(currentExercises.count, totalExercises: totalExercises)
    }
    
    /**
     * Loads the table views.
     *
     * @param result    The results to parse from the webservice.
     */
    func loadTableViewItems(result: String)
    {
        // This gets saved as NSDictionary, so there is no order
        let json: AnyObject? = result.parseJSONString
        
        var indexToLoad = 1
        
        // This means we got the results from the iOS database.
        if (result == CONTINUE_STRING)
        {
            exerciseData.routineName = savedExercises.routineName
            exerciseData.exerciseList = savedExercises.exercises
                
            indexToLoad = savedExercises.index
        }
        // This means we got results back from the web database.
        else if (result != "" && result != Constant.RETURN_NULL)
        {
            do
            {
                exerciseData.exerciseList.appendContentsOf(try ExerciseDao().parseJson(json, searchString: ""))
                exerciseData.addStretch()
            }
            catch
            {
                // SHOW CONNECTION ISSUE
                viewDelegate.onLoadView(View.ROUTINE_VIEW, result: "", savedExercises: nil, state: RoutineState.NONE)
            }
        }
        // Custom state
        else
        {
            exerciseData.routineName = NSLocalizedString("title_custom_routine", comment: "")
        }
        
        switch routineState
        {
            case RoutineState.CUSTOM:
            
                activeButtonState = .SEARCH
                inactiveButton.hidden = true
                activeButton.hidden = false
                
                setButtons()
            
                animateTable(indexToLoad)
            
                break
        
            default:
            
                if (exerciseData.exerciseList.count >= EXERCISE_MINIMUM_THRESHOLD)
                {
                    activeButton.hidden = false
                    inactiveButton.hidden = false
                
                    animateTable(indexToLoad)
                }
            
                break
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
            viewController.routineName = exerciseListHeader.routineName
                
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
                        
                    Util.grantBadgeToUser(email, badgeName: badge, content: Awards(awardImageName: Badge.LEFT_IT_ON_THE_FIELD_IMAGE_NAME, awardDescription: NSLocalizedString("award_left_it_on_the_field_description", comment: "")), onlyAllowOne: false)
                        
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
     * The callback for clicking on the routine name.
     */
    func onRoutineNameClicked()
    {
        Util.displayAlert(self, title: exerciseData.routineName, message: "", actions: [])
    }
    
    /**
     * The callback for when the save button is pressed.
     */
    func onSaveRoutine()
    {
        displaySaveAlert(SaveState.NORMAL)
    }
    
    /**
     * The callback for when the finish button is pressed.
     */
    func onFinishRoutine()
    {
        displayFinishAlert()
    }
    
    func configurationTextField(textField: UITextField!)
    {
        self.textField = textField!
    }
    
    func displaySaveAlert(saveState: Int)
    {
        var title: String!
        var description: String!
        
        switch saveState
        {
            case SaveState.SAME_NAME_ERROR:
                title = "routine_saved_title_error"
                description = "routine_saved_description_error"
                break
            case SaveState.REG_EX_ERROR:
                title = "routine_saved_title_error"
                description = "routine_saved_description_reg_ex_error"
                break
            default: // SaveState.NORMAL
                title = "routine_saved_title"
                description = "routine_saved_description"
                break
        }
        
        let alert = UIAlertController(title: NSLocalizedString(title, comment: ""), message: NSLocalizedString(description, comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("save", comment: ""), style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
            
            self.showLoading()
            
            let text = self.textField.text!
            let textWithoutSpace = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            if (Util.isFieldValid(text, regEx: Constant.REGEX_SAVE_ROUTINE_NAME_FIELD) && Util.checkStringLength(textWithoutSpace, length: 1))
            {
                _ = ServiceTask(event: ServiceEvent.SAVE_ROUTINE,
                    delegate: self,
                    serviceURL: Constant.SERVICE_SET_ROUTINE,
                    params: Constant.generateRoutineListVariables(self.email, routineName: self.textField.text!, exercises: self.currentExercises))
            }
            else
            {
                self.hideLoading()
                
                //Display save alert with new message.
                self.displaySaveAlert(SaveState.REG_EX_ERROR)
            }
        }))
        
        self.navigationController!.presentViewController(alert, animated: true, completion: nil)
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
        let isDuration = !duration.isEmpty && duration.rangeOfString(":") != nil && Util.convertToInt(duration) > 0
    
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
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesInRange: range)
            
        tableView.reloadSections(sections, withRowAnimation: .Top)

        for _ in 0 ..< indexToLoad
        {
            addExercise(true, fromSearch: false)
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
        return currentExercises.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (exerciseListHeader == nil)
        {
            exerciseListHeader = tableView.dequeueReusableCellWithIdentifier(Constant.EXERCISE_LIST_HEADER) as! ExerciseListHeaderController
            exerciseListHeader.routineName = exerciseData.routineName
            exerciseListHeader.navigationController = self.navigationController
            exerciseListHeader.routineDelegate = self
        }
        
        return exerciseListHeader.contentView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 65
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.item
        let exercise = exerciseData.exerciseList[index]
        let description = exercise.exerciseDescription
        let sets = exercise.sets
        let set = sets[sets.count - 1]
        let exerciseFromIntencity = exercise.fromIntencity

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
            cell.setAsExercise(exerciseFromIntencity)
        }
            
        return cell
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
        
//        if ((exerciseName != STRETCH_NAME || fromSearch) && currentExercises[currentExercises.count - 1].exerciseName != STRETCH_NAME)
//        {
//            addExercise(false, fromSearch: fromSearch)
//        }
        
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