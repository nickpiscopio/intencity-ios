//
//  MainViewController.swift
//  Intencity
//
//  The view controller for the Fitness Log.
//
//  Created by Nick Piscopio on 2/8/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import TTGSnackbar

class FitnessLogViewController: UIViewController, ServiceDelegate, ExerciseDelegate, ExerciseSearchDelegate, RoutineDelegate, FitnessLogDelegate
{
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addExerciseButton: UIButton!
    @IBOutlet weak var searchDirections: UIStackView!
    @IBOutlet weak var magnifyingGlassIcon: UIImageView!
    @IBOutlet weak var searchDirectionsLabel: UILabel!
    
    let CONTINUE_STRING = NSLocalizedString("routine_continue", comment: "")
    let WARM_UP_NAME = NSLocalizedString("warm_up", comment: "")
    let STRETCH_NAME = NSLocalizedString("stretch", comment: "")
    let MORE_PRIORITY_STRING = NSLocalizedString("more_priority_string", comment: "")
    let LESS_PRIORITY_STRING = NSLocalizedString("less_priority_string", comment: "")
    let UNDO_STRING = NSLocalizedString("undo_hide_button", comment: "")

    let DEFAULTS = NSUserDefaults.standardUserDefaults()
    
    let EXERCISE_MINIMUM_THRESHOLD = 3
    
    var viewDelegate: ViewDelegate!
    
    var notificationHandler: NotificationHandler!
    
    var exerciseListHeader: ExerciseListHeaderController!

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
    
    var textField: UITextField!
    
    var result: String!
    
    var snackbar: TTGSnackbar!
    
    var indexedExercise: IndexedExercise!
    
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
        
        setAddButtonDirections()
        
        loadTableViewItems(result)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /**
     * Tells the callback to load the routine view again.
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
    
    func onHideLoading()
    {
        hideLoading()
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
     * Sets the add button directions.
     */
    func setAddButtonDirections()
    {
        if (routineState != RoutineState.CUSTOM)
        {
            let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(FitnessLogViewController.longClick))
            addExerciseButton.addGestureRecognizer(longGesture)
            
            magnifyingGlassIcon.alpha = Integer.SEARCH_EXERCISE_DIRECTION_ALPHA
            
            searchDirectionsLabel.textColor = Color.grey_text_x_transparent
            searchDirectionsLabel.font = UIFont.boldSystemFontOfSize(Dimention.FONT_SIZE_XX_SMALL)
            searchDirectionsLabel.text = NSLocalizedString("action_button_search_directions", comment: "")
            
            searchDirections.hidden = false
        }
        else
        {
            searchDirections.hidden = true
        }
    }
    
    @IBAction func addExerciseButtonClicked(sender: AnyObject)
    {
        switch routineState
        {
            case RoutineState.CUSTOM:
                searchClicked()
                break
            default:
                nextExerciseClicked()
                break
        }
    }
    
    func longClick(sender: AnyObject)
    {
        if (sender.state == .Began)
        {
            searchClicked()
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
            showLoading()
            
            displayOverview()
        }
    }
    
    /**
     * Displays the Overview screen.
     */
    func displayOverview()
    {
        let vc = storyboard!.instantiateViewControllerWithIdentifier(Constant.OVERVIEW_VIEW_CONTROLLER) as! OverviewViewController
        vc.viewDelegate = viewDelegate
        vc.fitnessLogDelegate = self
        self.navigationController!.pushViewController(vc, animated: true)
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
        removeSnackBar()
        
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
            Util.grantPointsToUser(email, awardType: AwardType.NEXT_EXERCISE, points: Constant.POINTS_EXERCISE, description: NSLocalizedString("award_exercise_description", comment: ""))
        }
        
        let position = currentExerciseCount - 1
        
        if (fromSearch && currentExercises[position].exerciseName == STRETCH_NAME)
        {
            let indexPath = NSIndexPath(forRow: position, inSection: 0)
            
            hideExercise(indexPath, fromSearch: fromSearch)
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
            
                animateTable(indexToLoad)
            
                break
        
            default:
                
                if (routineState == RoutineState.SAVED)
                {
                    totalExercises = exerciseData.exerciseList.count
                }
            
                if (exerciseData.exerciseList.count >= EXERCISE_MINIMUM_THRESHOLD)
                {
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
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(Constant.EXERCISE_SEARCH_VIEW_CONTROLLER) as! ExerciseSearchViewController
            vc.searchType = name
            vc.routineName = exerciseListHeader.routineName
                
            self.navigationController!.pushViewController(vc, animated: true)
        }
        else
        {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(Constant.DIRECTION_VIEW_CONTROLLER) as! DirectionViewController
            vc.exerciseName = name
                
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    /**
     * The callback for when the hide button is clicked on an exercise card.
     *
     * @param indexPath     The indexPath of the exercise to hide.
     */
    func onHideClicked(indexPath: NSIndexPath)
    {
        hideExercise(indexPath, fromSearch: false)
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
                        
                    Util.grantBadgeToUser(email, badgeName: badge, content: Awards(awardType: AwardType.LEFT_IT_ON_THE_FIELD, awardImageName: Badge.LEFT_IT_ON_THE_FIELD_IMAGE_NAME, awardDescription: NSLocalizedString("award_left_it_on_the_field_description", comment: "")), onlyAllowOne: false)
                        
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
     * @param morePriority  The more priority button resource.
     * @param lessPriority  The less priority button resource.
     * @param increasing    Boolean value of whether or not we are incresing or decreasing the priority of the exercise.
     */
    func onSetExercisePriority(indexPath: NSIndexPath, morePriority: UIButton, lessPriority: UIButton, increment: Bool)
    {
        let index = indexPath.row
        
        let exercise = currentExercises[index]
        
        let exerciseName = exercise.exerciseName
        
        let priority = ExercisePriorityUtil.getExercisePriority(exercise.priority, increment: increment)
        exercise.priority = priority
        ExercisePriorityUtil.setPriorityButtons(priority, morePriority: morePriority, lessPriority: lessPriority);
        
        // Set the exercise priority on the web server.
        // The ServiceListener is null because we don't care if it reached the server.
        // The worst that will happen is a user will have to click the exercise priority again.
        _ = ServiceTask(event: ServiceEvent.NO_RETURN, delegate: nil,
            serviceURL: Constant.SERVICE_STORED_PROCEDURE,
            params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_SET_EXERCISE_PRIORITY, variables: [ email, exerciseName, String(increment ? 1 : 0) ]))
        
        // Remove the exercise if the user decremented it and it is less than 0.
        if (priority == ExercisePriorityUtil.PRIORITY_LIMIT_LOWER && !increment)
        {
            hideExercise(indexPath, fromSearch: false)
        }
        
        // Displays a toast to the user telling them they will see an exercise more or less.
        self.tabBarController?.view.makeToast(String(format: increment ? MORE_PRIORITY_STRING : LESS_PRIORITY_STRING, arguments: [ exerciseName ]))
    }
    
    /**
     * The callback for clicking on the routine name.
     */
    func onRoutineNameClicked()
    {
        let description = String(format: NSLocalizedString("routine_total_description", comment: ""), arguments: [String(currentExercises.count), String(totalExercises)])
        Util.displayAlert(self, title: exerciseData.routineName, message: description, actions: [])
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
        if (currentExercises.count > 1)
        {
            displayOverview()
        }
        else
        {
            displayFinishAlert()
        }
    }
    
    /**
     * Configures the textfield for saving a routine.
     */
    func configurationTextField(textField: UITextField!)
    {
        self.textField = textField!
    }
    
    /**
     * Displays the save alert.
     * 
     * @param saveState     The state in which we already came.
     */
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
            
            // We add 1 to the name length because we don't want it to equal 31 characters.
            if (Util.isFieldValid(text, regEx: Constant.REGEX_SAVE_ROUTINE_NAME_FIELD) && Util.checkStringLength(textWithoutSpace, length: 1) && !Util.checkStringLength(textWithoutSpace, length: Integer.NAME_LENGTH + 1))
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
            exerciseListHeader.routineName = exerciseData.routineName.uppercaseString
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
            cell.setAsExercise(exerciseFromIntencity, priority: exercise.priority, routineState: routineState)
        }
            
        return cell
    }
    
    /**
     * Insert an exercise back into the array.
     *
     * @param indexedExercise   The exercise with an index that is being inserted into the array.
     */
    func insertExercise()
    {
        tableView.beginUpdates()
        let exercise = indexedExercise.exercise
        let index = indexedExercise.index
        
        exerciseData.exerciseList.insert(exercise, atIndex: index)
        currentExercises.insert(exercise, atIndex: index)
        
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
        
        exerciseData.exerciseIndex += 1
        
        updateExerciseTotal()
        
        tableView.endUpdates()
    }
    
    /**
     * Removes the snackbar from the superview if it exists.
     */
    func removeSnackBar()
    {
        if (snackbar != nil)
        {
            snackbar.removeFromSuperview()
        }
    }
    
    /**
     * Hides an exercise in the exercise list.
     *
     * @param indexPath     The index path for the exercise to hide.
     * @param fromSearch    A boolean value of whether the exercise was hidden from search.
     */
    func hideExercise(indexPath: NSIndexPath, fromSearch: Bool)
    {
        tableView.beginUpdates()
        
        let index = indexPath.row
        let exerciseToRemove = currentExercises[index]
        
        currentExercises.removeAtIndex(index)
        
        let exerciseName = exerciseToRemove.exerciseName
        if (exerciseName != STRETCH_NAME)
        {
            exerciseData.exerciseList.removeAtIndex(index)
        }
        
        exerciseData.exerciseIndex -= 1
        
        updateExerciseTotal()
        
        // Note that indexPath is wrapped in an array: [indexPath]
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
        
        if (fromSearch)
        {
            addExercise(false, fromSearch: fromSearch)
        }
        else
        {
            indexedExercise = IndexedExercise.init(index: index, exercise: exerciseToRemove)
            
            let title = String(format: NSLocalizedString("undo_hide_exercise_title", comment: ""), exerciseName)
            
            removeSnackBar()
            
            snackbar = TTGSnackbar.init(message: title, duration: .Forever, actionText: UNDO_STRING) { (snackbar) -> Void in
                
                self.insertExercise()
                
                self.removeSnackBar()
            }
            
            snackbar.leftMargin = 0
            snackbar.rightMargin = 0;
            snackbar.bottomMargin = 0;
            snackbar.cornerRadius = 0;
            snackbar.actionTextColor = Color.accent
            snackbar.show()
            
            // Add that the user has skipped an exercise.
            // Can't get the Kept Swimming badge.
            setExerciseSkipped(true)

        }
        
        tableView.endUpdates()
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
}