//
//  MainViewController.swift
//  Intencity
//
//  The view controller for the Fitness Log.
//
//  Created by Nick Piscopio on 2/8/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import SSSnackbar

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

    let DEFAULTS = UserDefaults.standard
    
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
    
    var snackbar: SSSnackbar!
    
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
        
        textField = UITextField(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        
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
        
        loadingView.isHidden = true
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = true
    }
    
    /**
     * Shows the task is in progress.
     */
    func showLoading()
    {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        loadingView.isHidden = false
    }
    
    /**
     * Shows the task is in finished.
     */
    func hideLoading()
    {
        loadingView.isHidden = true
        
        activityIndicator.stopAnimating()
    }

    func onHideLoading()
    {
        hideLoading()
    }
    
    func onRetrievalSuccessful(_ event: Int, result: String)
    {
        switch (event)
        {
            case ServiceEvent.INSERT_EXERCISES_TO_WEB_DB:
                
                // Remove the first and last character because they are "[" and "]";
                var response = result
                response.remove(at: response.startIndex)
                response.remove(at: response.index(before: response.endIndex))
                
                var ids =  response.components(separatedBy: Constant.PARAMETER_DELIMITER)
                
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
    
    func onRetrievalFailed(_ event: Int)
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
    func onExerciseAdded(_ exercise: Exercise)
    {
        var exercises = exerciseData.exerciseList
        let exerciseCount = exercises.count
        
        for i in 0 ..< exerciseCount - 1
        {
            if (exercise.exerciseName == exercises[i].exerciseName)
            {
                exercises.remove(at: i)
            }
        }
        
        let currentExerciseCount = currentExercises.count
        var removeStretch = false
        
        if (currentExercises[currentExerciseCount - 1].exerciseName == STRETCH_NAME)
        {
            removeStretch = true
        }
        
        exercises.insert(exercise, at: removeStretch ? currentExerciseCount - 1 : currentExerciseCount)
        
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
            searchDirectionsLabel.font = UIFont.boldSystemFont(ofSize: Dimention.FONT_SIZE_XX_SMALL)
            searchDirectionsLabel.text = NSLocalizedString("action_button_search_directions", comment: "")
            
            searchDirections.isHidden = false
        }
        else
        {
            searchDirections.isHidden = true
        }
    }
    
    @IBAction func addExerciseButtonClicked(_ sender: AnyObject)
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
    
    @objc func longClick(_ sender: AnyObject)
    {
        if (sender.state == .began)
        {
            removeSnackBar()

            searchClicked()
        }
    }
    
    /**
     * Opens the search screen.
     */
    func searchClicked()
    {
        let viewController = storyboard!.instantiateViewController(withIdentifier: Constant.SEARCH_VIEW_CONTROLLER) as! SearchViewController
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
//            showLoading()
//            
//            displayOverview()
            
            displayFinishAlert()
        }
    }
    
    /**
     * Displays the Overview screen.
     */
//    func displayOverview()
//    {
//        let vc = storyboard!.instantiateViewController(withIdentifier: Constant.OVERVIEW_VIEW_CONTROLLER) as! OverviewViewController
//        vc.viewDelegate = viewDelegate
//        vc.fitnessLogDelegate = self
//        self.navigationController!.pushViewController(vc, animated: true)
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
    func setExerciseSkipped(_ skipped: Bool)
    {
        DEFAULTS.set(skipped, forKey: Constant.BUNDLE_EXERCISE_SKIPPED)
    }
    
    /**
     * Adds an exercise to the currentExercises.
     */
    func addExercise(_ initialLoad: Bool, fromSearch: Bool)
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
        
        let lastExerciseTime = DEFAULTS.float(forKey: Constant.USER_LAST_EXERCISE_TIME)
        let now = Float(Date().timeIntervalSince1970 * 1000)
        
        if ((now - lastExerciseTime) >= Float(Constant.EXERCISE_POINTS_THRESHOLD))
        {
            DEFAULTS.set(now, forKey: Constant.USER_LAST_EXERCISE_TIME)
            
            // Reward the user for exercising.
            // We use a relaxed system for giving points, so we only try to make it so they can't game the system.
            Util.grantPointsToUser(email, awardType: AwardType.next_EXERCISE, points: Constant.POINTS_EXERCISE, description: NSLocalizedString("award_exercise_description", comment: ""))
        }
        
        let position = currentExerciseCount - 1
        
        if (fromSearch && currentExercises[position].exerciseName == STRETCH_NAME)
        {
            let indexPath = IndexPath(row: position, section: 0)
            
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
        exerciseListHeader.saveButton.isHidden = currentExerciseCount < 2 || (currentExerciseCount == 2 && currentExercises[currentExerciseCount - 1].exerciseName == STRETCH_NAME)
        
        exerciseListHeader.setExerciseTotalLabel(currentExercises.count, totalExercises: totalExercises)
    }
    
    /**
     * Loads the table views.
     *
     * @param result    The results to parse from the webservice.
     */
    func loadTableViewItems(_ result: String)
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
                exerciseData.exerciseList.append(contentsOf: try ExerciseDao().parseJson(json as? [AnyObject], searchString: ""))
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
    func onExerciseClicked(_ name: String)
    {
        if (name == WARM_UP_NAME || name == STRETCH_NAME)
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: Constant.EXERCISE_SEARCH_VIEW_CONTROLLER) as! ExerciseSearchViewController
            vc.searchType = name
            vc.routineName = exerciseListHeader.routineName
                
            self.navigationController!.pushViewController(vc, animated: true)
        }
        else
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: Constant.DIRECTION_VIEW_CONTROLLER) as! DirectionViewController
            vc.exerciseName = name
                
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    /**
     * The callback for when the hide button is clicked on an exercise card.
     *
     * @param indexPath     The indexPath of the exercise to hide.
     */
    func onHideClicked(_ indexPath: IndexPath)
    {
        hideExercise(indexPath, fromSearch: false)
    }
    
    /**
     * The callback for when the edit button is clicked.
     *
     * @param index     The index of the exercise that was clicked.
     */
    func onEditClicked(_ index: Int)
    {
        let statViewController = self.storyboard?.instantiateViewController(withIdentifier: "StatViewController") as! StatViewController
        statViewController.delegate = self
        statViewController.index = index
        
        self.navigationController!.pushViewController(statViewController, animated: true)
    }
    
    /**
     * The callback for when the sets are updated.
     */
    func onSetUpdated(_ index: Int)
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
                        
                    Util.grantBadgeToUser(email, badgeName: badge, content: Awards(awardType: AwardType.left_IT_ON_THE_FIELD, awardImageName: Badge.LEFT_IT_ON_THE_FIELD_IMAGE_NAME, awardDescription: NSLocalizedString("award_left_it_on_the_field_description", comment: "")), onlyAllowOne: false)
                        
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
                            params: updateString as NSString)
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
                            params: insertString as NSString)
        }
    }
    
    /**
     * The callback for when an exercise priority is set.
     *
     * @param index         The index of the exercise we are setting.
     * @param morePriority  The more priority button resource.
     * @param lessPriority  The less priority button resource.
     * @param increment     Boolean value of whether or not we are incresing or decreasing the priority of the exercise.
     */
    func onSetExercisePriority(_ indexPath: IndexPath, morePriority: UIButton, lessPriority: UIButton, increment: Bool)
    {
        let index = (indexPath as NSIndexPath).row
        
        let exercise = currentExercises[index]
        
        let exerciseName = exercise.exerciseName
        
        let priority = ExercisePriorityUtil.getExercisePriority(exercise.priority, increment: increment)
        exercise.priority = priority
        ExercisePriorityUtil.setPriorityButtons(priority, morePriority: morePriority, lessPriority: lessPriority);
        
        let incrementVal = increment ? 1 : 0
        
        // Set the exercise priority on the web server.
        // The ServiceListener is null because we don't care if it reached the server.
        // The worst that will happen is a user will have to click the exercise priority again.
        _ = ServiceTask(event: ServiceEvent.NO_RETURN, delegate: nil,
            serviceURL: Constant.SERVICE_STORED_PROCEDURE,
            params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_SET_EXERCISE_PRIORITY, variables: [ email, exerciseName, String(incrementVal) ]) as NSString)
        
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
//        if (currentExercises.count > 1)
//        {
//            displayOverview()
//        }
//        else
//        {
            displayFinishAlert()
//        }
    }
    
    /**
     * Configures the textfield for saving a routine.
     */
    func configurationTextField(_ textField: UITextField!)
    {
        self.textField = textField!
    }
    
    /**
     * Displays the save alert.
     * 
     * @param saveState     The state in which we already came.
     */
    func displaySaveAlert(_ saveState: Int)
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
        
        let alert = UIAlertController(title: NSLocalizedString(title, comment: ""), message: NSLocalizedString(description, comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("save", comment: ""), style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            
            self.showLoading()
            
            let text = self.textField.text!
            let textWithoutSpace = text.trimmingCharacters(in: CharacterSet.whitespaces)
            
            // We add 1 to the name length because we don't want it to equal 31 characters.
            if (Util.isFieldValid(text, regEx: Constant.REGEX_SAVE_ROUTINE_NAME_FIELD) && Util.checkStringLength(textWithoutSpace, length: 1) && !Util.checkStringLength(textWithoutSpace, length: Integer.NAME_LENGTH + 1))
            {
                _ = ServiceTask(event: ServiceEvent.SAVE_ROUTINE,
                    delegate: self,
                    serviceURL: Constant.SERVICE_SET_ROUTINE,
                    params: Constant.generateRoutineListVariables(self.email, routineName: self.textField.text!, exercises: self.currentExercises) as NSString)
            }
            else
            {
                self.hideLoading()
                
                //Display save alert with new message.
                self.displaySaveAlert(SaveState.REG_EX_ERROR)
            }
        }))
        
        self.navigationController!.present(alert, animated: true, completion: nil)
    }
    
    /**
     * Constructs a snippet of the parameter query sent to the service for updating.
     *
     * @param index     The index of the sets we are updating.
     * @param set       The set we are updating.
     *
     * @return  The constructed snippet of the complex update parameter String.
     */
    func generateComplexUpdateParameters(_ index: Int, set: Set) -> String
    {
        let equals = "="
        let setParam = "set"
        let whereParam = "where"
        let nullString = "NULL"
    
        let weight = set.weight
        let duration = set.duration
        let notes = set.notes
        let isDuration = !duration.isEmpty && duration.range(of: ":") != nil
    
        let weightParam = Constant.COLUMN_EXERCISE_WEIGHT + equals + String(weight) + Constant.PARAMETER_DELIMITER;
        // Choose whether we are inserting reps or duration.
        let durationParam = isDuration ?
                                Constant.COLUMN_EXERCISE_DURATION + equals + "'" + duration + "'" + Constant.PARAMETER_DELIMITER
                                    + Constant.COLUMN_EXERCISE_REPS + equals + nullString + Constant.PARAMETER_DELIMITER :
                                Constant.COLUMN_EXERCISE_DURATION + equals + nullString + Constant.PARAMETER_DELIMITER
                                    + Constant.COLUMN_EXERCISE_REPS + equals + String(set.reps) + Constant.PARAMETER_DELIMITER
    
        let notesParam = !notes.isEmpty && notes.count > 0 ? "'" + notes + "'" : nullString
    
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
    func generateComplexInsertParameters(_ index: Int, name: String, set: Set) -> String
    {
        let columns = "columns"
        let inserts = "inserts"
    
        let curDate = "CURDATE()"
        let now = "NOW()"
    
        let weight = set.weight
        let duration = set.duration
        let hasWeight = weight > 0
        let isDuration = !duration.isEmpty && duration.range(of: ":") != nil && Util.convertToInt(duration) > 0
    
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
    func getParameterTitle(_ name: String, index: Int) -> String
    {
        return Constant.PARAMETER_AMPERSAND + name + String(index) + "=";
    }
    
    /**
     * Animates the table being added to the screen.
     *
     * @param loadNextExercise  A boolean value of whether to load the next exercise or not.
     */
    func animateTable(_ indexToLoad: Int)
    {
        let range = 0..<self.tableView.numberOfSections
        let sections = IndexSet(integersIn: range)
            
        tableView.reloadSections(sections, with: .top)

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
    func tableViewScrollToBottom(_ animated: Bool)
    {
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections - 1)
            
            if numberOfRows > 0
            {
                let indexPath = IndexPath(row: numberOfRows - 1, section: (numberOfSections - 1))
                self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: animated)
            }
            
        })
    }
    
    /**
     * Animates a row being added to the screen.
     */
    func insertRow()
    {
        let indexPath = IndexPath(row: currentExercises.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        tableViewScrollToBottom(true)
    }
    
    // http://stackoverflow.com/questions/31870206/how-to-insert-new-cell-into-uitableview-in-swift
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return currentExercises.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (exerciseListHeader == nil)
        {
            exerciseListHeader = tableView.dequeueReusableCell(withIdentifier: Constant.EXERCISE_LIST_HEADER) as! ExerciseListHeaderController
            exerciseListHeader.routineName = exerciseData.routineName.uppercased()
            exerciseListHeader.navigationController = self.navigationController
            exerciseListHeader.routineDelegate = self
        }
        
        return exerciseListHeader.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let index = (indexPath as NSIndexPath).item
        let exercise = exerciseData.exerciseList[index]
        let description = exercise.exerciseDescription
        let sets = exercise.sets
        let set = sets[sets.count - 1]
        let exerciseFromIntencity = exercise.fromIntencity

        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.EXERCISE_CELL) as! ExerciseCellController
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.delegate = self
        cell.tableView = tableView
        cell.exerciseButton.setTitle(exercise.exerciseName, for: UIControlState())
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
        
        exerciseData.exerciseList.insert(exercise!, at: index!)
        currentExercises.insert(exercise!, at: index!)
        
        let indexPath = IndexPath(row: index!, section: 0)
        
        tableView.insertRows(at: [indexPath], with: .right)
        
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
            snackbar.dismiss(animated: true)
        }
    }
    
    /**
     * Hides an exercise in the exercise list.
     *
     * @param indexPath     The index path for the exercise to hide.
     * @param fromSearch    A boolean value of whether the exercise was hidden from search.
     */
    func hideExercise(_ indexPath: IndexPath, fromSearch: Bool)
    {
        tableView.beginUpdates()
        
        let index = (indexPath as NSIndexPath).row
        let exerciseToRemove = currentExercises[index]
        
        currentExercises.remove(at: index)
        
        let exerciseName = exerciseToRemove.exerciseName
        if (exerciseName != STRETCH_NAME)
        {
            exerciseData.exerciseList.remove(at: index)
        }
        
        exerciseData.exerciseIndex -= 1
        
        updateExerciseTotal()
        
        // Note that indexPath is wrapped in an array: [indexPath]
        tableView.deleteRows(at: [indexPath], with: .right)
        
        if (fromSearch)
        {
            addExercise(false, fromSearch: fromSearch)
        }
        else
        {
            indexedExercise = IndexedExercise.init(index: index, exercise: exerciseToRemove)
            
            let title = String(format: NSLocalizedString("undo_hide_exercise_title", comment: ""), exerciseName)
            
            removeSnackBar()
            
            snackbar = SSSnackbar(message: title, actionText: UNDO_STRING, duration: TimeInterval(20), actionBlock: {snackbar in
                                    self.insertExercise()
                                    
                                    self.removeSnackBar()
            }, dismissalBlock: nil)
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
                          actions: [ UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil),
                                     UIAlertAction(title: NSLocalizedString("title_finish", comment: ""), style: .destructive, handler: finishExercising) ])
    }
    
    /**
     * The action for the finish button being clicked when the user is viewing the finish exercise alert.
     */
    func finishExercising(_ alertAction: UIAlertAction!) -> Void
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
