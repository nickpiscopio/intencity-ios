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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Sets the title for the screen.
        self.navigationController?.navigationBar.topItem!.title = NSLocalizedString("app_name", comment: "")
        
        email = Util.getEmailFromDefaults()

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
            default:
                break
            
        }
    }
    
    func onRetrievalFailed(event: Int)
    {
        // Add code for when we can't get the muscle groups.
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
        
        exercises.insert(exercise, atIndex: currentExercises.count)
        
        exerciseData.exerciseList = exercises
        
        addExercise()
    }
    
    /**
     * The button click to get the next exercise.
     */
    @IBAction func nextExerciseClicked(sender: AnyObject)
    {
        addExercise()
    }
    
    /**
     * Adds an exercise to the currentExercises.
     */
    func addExercise()
    {
        let currentExerciseCount = currentExercises.count
        // If there is 1 exercise left, we want to display the stretch.
        // We remove all the unnecessary exercises.
        if (totalExercises - currentExerciseCount <= 1)
        {
            let stretch = exerciseData.exerciseList[exerciseData.exerciseList.count - 1]
            
            exerciseData.exerciseList.removeAll()
            exerciseData.exerciseList = currentExercises
            exerciseData.exerciseList.append(stretch)
        }
        
        if (currentExerciseCount < totalExercises)
        {
            // Get the next exercise.
            currentExercises.append(exerciseData.exerciseList[exerciseData.exerciseIndex++])
            
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
    func onSetUpdated()
    {
        tableView.reloadData()
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
                addExercise()
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
        
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
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
            let actions = [ UIAlertAction(title: NSLocalizedString("hide_for_now", comment: ""), style: .Default, handler: self.hideExercise(indexPath)),
                            UIAlertAction(title: NSLocalizedString("hide_forever", comment: ""), style: .Destructive, handler: self.hideExercise(indexPath)),
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
        // Only edit the cells if the user is exercising.
        return state == Constant.EXERCISE_CELL
    }
    
    /**
     * Hides an exercise in the exercise list.
     *
     * @param indexPath The index path for the exercise to hide.
     */
    func hideExercise(indexPath: NSIndexPath)(alertAction: UIAlertAction!) -> Void
    {
        tableView.beginUpdates()
            
        let index = indexPath.row
            
        currentExercises.removeAtIndex(index)
        exerciseData.exerciseList.removeAtIndex(index)
        
        exerciseData.exerciseIndex--
        
        updateExerciseTotal()
        
        // Note that indexPath is wrapped in an array: [indexPath]
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        addExercise()
            
        tableView.endUpdates()
    }
    
    func cancelRemoval(indexPath: NSIndexPath)(alertAction: UIAlertAction!) { }
}