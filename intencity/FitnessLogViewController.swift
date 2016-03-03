//
//  MainViewController.swift
//  Intencity
//
//  The view controller for the Fitness Log.
//
//  Created by Nick Piscopio on 2/8/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class FitnessLogViewController: UIViewController, ServiceDelegate, RoutineDelegate, ExerciseDelegate, ExerciseSearchDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextExerciseButton: UIButton!
    
    let CONTINUE_STRING = NSLocalizedString("routine_continue", comment: "")
    let WARM_UP_NAME = NSLocalizedString("warm_up", comment: "")
    let STRETCH_NAME = NSLocalizedString("stretch", comment: "")
    
    // THIS WILL CHANGE TO 7 LATER WHEN ADDING WARM UP AND STRETCH.
    var totalExercises = 7
    
    var numberOfCells = 0
    
    var displayMuscleGroups = [String]()
    var recommended = 0;
    
    var email = "";
    
    var state = "";
    
    var currentExercises = [Exercise]()
    
    var exerciseData: ExerciseData!
    
    var isSwipeOpen = false
    
    var exerciseListHeader: ExerciseListHeaderController!
    
    var savedExercises: SavedExercise!
    
    var activityIndicator: UIActivityIndicatorView!
    
    var insertIntoWebSetsIndex: Int!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Sets the title for the screen.
        self.navigationController?.navigationBar.topItem!.title = NSLocalizedString("app_name", comment: "")
        
        email = Util.getEmailFromDefaults()
        
        activityIndicator = Util.showActivityIndicatory(self.view)
        activityIndicator.startAnimating()

        ServiceTask(event: ServiceEvent.GET_ALL_DISPLAY_MUSCLE_GROUPS, delegate: self,
            serviceURL: Constant.SERVICE_STORED_PROCEDURE,
            params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_ALL_DISPLAY_MUSCLE_GROUPS, variables: [ email ]))
        
        state = Constant.ROUTINE_CELL
        
        // Initialize the tableview.
        Util.initTableView(tableView, removeSeparators: true, addFooter: true)

        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: "RoutineCard", cellName: Constant.ROUTINE_CELL)
        Util.addUITableViewCell(tableView, nibNamed: "ExerciseCard", cellName: Constant.EXERCISE_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.EXERCISE_LIST_HEADER, cellName: Constant.EXERCISE_LIST_HEADER)
        
        // Creates the instance of the exercise data so we can store the exercises in the database later.
        exerciseData = ExerciseData.getInstance()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func onRetrievalSuccessful(event: Int, result: String)
    {
        switch (event)
        {
            case ServiceEvent.GET_ALL_DISPLAY_MUSCLE_GROUPS:
                
                loadTableViewItems(state, result: result)
                
                break
            case ServiceEvent.SET_CURRENT_MUSCLE_GROUP:
                
                ServiceTask(event: ServiceEvent.GET_EXERCISES_FOR_TODAY, delegate: self,
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
                
                for (var i = 0; i < setCount; i++)
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
        // Add code for when we can't get the muscle groups.
        
        activityIndicator.stopAnimating()
    }
    
    /**
     * The callback for when an exercise is added from searching.
     */
    func onExerciseAdded(exercise: Exercise)
    {
        var exercises = exerciseData.exerciseList
        let exerciseCount = exercises.count
        
        for (var i = 0; i < exerciseCount - 1; i++)
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

        addExercise(true)
    }
    
    /**
     * The button click to get the next exercise.
     */
    @IBAction func nextExerciseClicked(sender: AnyObject)
    {
        if (currentExercises.count != exerciseData.exerciseList.count)
        {
            addExercise(false)
        }
    }
    
    /**
     * Adds an exercise to the currentExercises.
     */
    func addExercise(fromSearch: Bool)
    {
        let currentExerciseCount = currentExercises.count
        // If there is 1 exercise left, we want to display the stretch.
        // We remove all the unnecessary exercises.
        if (!fromSearch && totalExercises - currentExerciseCount <= 1)
        {
            let stretch = exerciseData.exerciseList[exerciseData.exerciseList.count - 1]
            
            exerciseData.exerciseList.removeAll()
            exerciseData.exerciseList = currentExercises
            exerciseData.exerciseList.append(stretch)
        }
        
        let position = currentExerciseCount - 1
        
        if (fromSearch && currentExercises[position].exerciseName == STRETCH_NAME)
        {
            let indexPath = NSIndexPath(forRow: position, inSection: 0)

            hideExercise(indexPath, fromSearch: true, forever: false)
        }
        else
        {
            // Get the next exercise.
            currentExercises.append(exerciseData.exerciseList[exerciseData.exerciseIndex++])
            
            insertRow()
            
            updateExerciseTotal()
        }
        
        // Set the current exercises in the exercise list header so we can exclude adding exercises that we already have when searching.
        exerciseListHeader.currentExercises = currentExercises
        
        // Scrolls to the bottom of the tableview.
        tableView.scrollRectToVisible(tableView.tableFooterView!.frame, animated: true)
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
            var recommended: String?
            
            for muscleGroups in json as! NSArray
            {
                let muscleGroup = muscleGroups[Constant.COLUMN_DISPLAY_NAME] as! String
                recommended = muscleGroups[Constant.COLUMN_CURRENT_MUSCLE_GROUP] as? String
                
                displayMuscleGroups.append(muscleGroup)
            }
            
            // Get the saved exercises from the local database.
            savedExercises = DBHelper().getRecords()
            
            if (savedExercises.routineName != "")
            {
                displayMuscleGroups.append(CONTINUE_STRING)
                
                self.recommended = displayMuscleGroups.count - 1
            }
            else
            {
                self.recommended = (recommended == nil || recommended! == "") ? 0 : displayMuscleGroups.indexOf(recommended!)!
            }
        }
        else
        {
            nextExerciseButton.hidden = false

            // This means we got results back from the web database.
            if (result != "" && result != Constant.RETURN_NULL)
            {
                exerciseData.exerciseList.appendContentsOf(ExerciseDao().parseJson(json))
                exerciseData.addStretch()
            }
            // This means we got the results from the iOS database.
            else
            {
                exerciseData.exerciseList = savedExercises.exercises
                
                indexToLoad = savedExercises.index
            }
        }
        
        animateTable(indexToLoad)
        
        activityIndicator.stopAnimating()
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
            
            activityIndicator.startAnimating()
            
            ServiceTask(event: ServiceEvent.SET_CURRENT_MUSCLE_GROUP, delegate: self,
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
        if (!isSwipeOpen)
        {
            let directionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DirectionViewController") as! DirectionViewController
            directionViewController.exerciseName = name
            
            self.navigationController!.pushViewController(directionViewController, animated: true)
        }
    }
    
    /**
     * The callback for when the edit button is clicked.
     *
     * @param index     The index of the exercise that was clicked.
     */
    func onEditClicked(index: Int)
    {
        if (!isSwipeOpen)
        {
            let statViewController = self.storyboard?.instantiateViewControllerWithIdentifier("StatViewController") as! StatViewController
            statViewController.delegate = self
            statViewController.index = index
        
            self.navigationController!.pushViewController(statViewController, animated: true)
        }
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
        
//        String badge = Badge.LEFT_IT_ON_THE_FIELD;
//        int setsWithRepsGreaterThan10 = 0;
        
        // we need our own indexes here or the services won't work properly.
        var updateIndex = 0
        var insertIndex = 0
        
        // Sort through the sets to determine if we are updating or inserting.
        for (var i = 0; i < setSize; i++)
        {
            let set = sets[i]
            
            // Checks to see if the user deserves the "Left it on the Field" badge.
//            if (!awards.containsKey(badge) && set.getReps() >= 10)
//            {
//                setsWithRepsGreaterThan10++;
//                
//                if (setsWithRepsGreaterThan10 >= 2)
//                {
//                    SecurePreferences securePreferences = new SecurePreferences(context);
//                    String email = securePreferences.getString(Constant.USER_ACCOUNT_EMAIL, "");
//                    
//                    Util.grantBadgeToUser(email, badge,
//                        new AwardDialogContent(R.mipmap.left_it_on_the_field,
//                            context.getString(R.string.award_left_it_on_the_field_description)), false);
//                    
//                    awards.put(badge, exerciseName);
//                }
//            }
            
            if (set.webId > 0)
            {
                // Call update
                updateString += generateComplexUpdateParameters(updateIndex, set: set);
                conductUpdate = true;
                updateIndex++;
            }
            else
            {
                // Concatenate the insert parameter String.
                insertString += generateComplexInsertParameters(insertIndex, name: exerciseName, set: set);
                conductInsert = true;
                insertIndex++;
            }
        }
        
        if (conductUpdate)
        {
            // Update the exercise on the web.
            ServiceTask(event: ServiceEvent.UPDATE_EXERCISES_TO_WEB_DB,
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
            ServiceTask(event: ServiceEvent.INSERT_EXERCISES_TO_WEB_DB,
                        delegate: self,
                        serviceURL: Constant.SERVICE_COMPLEX_INSERT,
                        params: insertString)
        }
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
        
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesInRange: range)
        
        self.tableView.reloadSections(sections, withRowAnimation: .Top)
        
        if (state == Constant.EXERCISE_CELL)
        {
            for (var i = 0; i < indexToLoad; i++)
            {
                addExercise(false)
            }
        }
    }
    
    /**
     * Animates a row being added to the screen.
     */
    func insertRow()
    {
        let indexPath = NSIndexPath(forRow: currentExercises.count - 1, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Bottom)
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
            let cell = tableView.dequeueReusableCellWithIdentifier(Constant.ROUTINE_CELL) as! RoutineCellController
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.delegate = self
            cell.dataSource = displayMuscleGroups
            // Need to add 1 to the routine so we get back the correct value when setting the muscle group for today.
            // CompletedMuscleGroup starts at 1.
            cell.selectedRoutineNumber = recommended + 1
            cell.setDropDownDataSource(recommended)
            cell.setDropDownWidth(displayMuscleGroups.contains(CONTINUE_STRING))
            return cell
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
            cell.index = index
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
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?
    {
        isSwipeOpen = true
        
        let remove = UITableViewRowAction(style: .Normal, title: NSLocalizedString("hide", comment: "")) { action, index in
            
            let exerciseName = self.exerciseData.exerciseList[indexPath.row].exerciseName
            let actions = [ UIAlertAction(title: NSLocalizedString("hide_for_now", comment: ""), style: .Default, handler: self.hideExerciseFromAlert(indexPath, forever: false)),
                            UIAlertAction(title: NSLocalizedString("hide_forever", comment: ""), style: .Destructive, handler: self.hideExerciseFromAlert(indexPath, forever: true)),
                            UIAlertAction(title: NSLocalizedString("do_not_hide", comment: ""), style: .Cancel, handler: self.cancelRemoval(indexPath)) ]
            Util.displayAlert(self, title: String(format: NSLocalizedString("hide_exercise", comment: ""), exerciseName), message: "", actions: actions)
        }
        
        remove.backgroundColor = Color.card_button_delete_select
        
        return [remove]
    }
    
    func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath)
    {
        self.isSwipeOpen = false
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        // Only edit the cells if the user is exercising and if it isn't the warm-up.
        return indexPath.row > 0 && state == Constant.EXERCISE_CELL
    }
    
    /**
     * Hides an exercise in the exercise list.
     *
     * @param indexPath     The index path for the exercise to hide.
     * @param forever       Whether to call the stored proceedure to hide the exercise forever.
     */
    func hideExerciseFromAlert(indexPath: NSIndexPath, forever: Bool)(alertAction: UIAlertAction!) -> Void
    {
        self.hideExercise(indexPath, fromSearch: false, forever: forever)
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
        
        exerciseData.exerciseIndex--
        
        updateExerciseTotal()
        
        // Note that indexPath is wrapped in an array: [indexPath]
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        if (exerciseName != STRETCH_NAME || fromSearch)
        {
            addExercise(fromSearch)
        }
        
        if (forever && exerciseName != WARM_UP_NAME && exerciseName != STRETCH_NAME)
        {
            // Hide the exercise on the web server.
            // The ServiceListener is null because we don't care if it reached the server.
            // The worst that will happen is a user will have to hide the exercise again.
            ServiceTask(event: ServiceEvent.HIDE_EXERCISE_FOREVER,
                        delegate: self,
                        serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_EXCLUDE_EXERCISE,
                                    variables: [ email, exerciseName ]))
        }
        
        tableView.endUpdates()
    }
    
    func cancelRemoval(indexPath: NSIndexPath)(alertAction: UIAlertAction!) { }
}