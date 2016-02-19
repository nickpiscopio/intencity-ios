//
//  MainViewController.swift
//  Intencity
//
//  The view controller for the Fitness Log.
//
//  Created by Nick Piscopio on 2/8/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class FitnessLogViewController: UIViewController, ServiceDelegate, RoutineDelegate, ExerciseDelegate
{
    var numberOfCells = 0
    
    var displayMuscleGroups = [String]()
    var recommended = 0;
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextExerciseButton: UIButton!
    
    var email = "";
    
    var state = "";
    
    var currentExercises = [Exercise]()
    var allExercises = [Exercise]()
    
    var exerciseIndex = 0;
    
    var selectedRoutine: String!
    
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
        Util.initTableView(tableView, removeSeparators: true)

        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: "RoutineCard", cellName: Constant.ROUTINE_CELL)
        Util.addUITableViewCell(tableView, nibNamed: "ExerciseCard", cellName: Constant.EXERCISE_CELL)
        Util.addUITableViewCell(tableView, nibNamed: "ExerciseListHeader", cellName: Constant.EXERCISE_LIST_HEADER)
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
                
                let variables = Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_EXERCISES_FOR_TODAY, variables:  [ email ])
                print("variables2 \"\(variables)\"")
                
                ServiceTask(event: ServiceEvent.GET_EXERCISES_FOR_TODAY, delegate: self,
                    serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                    params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_EXERCISES_FOR_TODAY, variables:  [ email ]))
                break
            
            case ServiceEvent.GET_EXERCISES_FOR_TODAY:
                print("exercises for today: \"\(result)\"")
                    
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
     * The button click to get the next exercise.
     */
    @IBAction func nextExerciseClicked(sender: AnyObject)
    {
        addExercise()
    }
    
    /**
     * Adds an exercise to teh currentExercises.
     */
    func addExercise()
    {
        if (currentExercises.count < allExercises.count)
        {
            // Get the next exercise.
            currentExercises.append(allExercises[exerciseIndex++])
            
            insertRow()
        }
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
        
        if (state == Constant.ROUTINE_CELL)
        {
            var recommended: String?
            
            for muscleGroups in json as! NSArray
            {
                let muscleGroup = muscleGroups[Constant.COLUMN_DISPLAY_NAME] as! String
                recommended = muscleGroups[Constant.COLUMN_CURRENT_MUSCLE_GROUP] as? String
                
                displayMuscleGroups.append(muscleGroup)
            }
            
            self.recommended = (recommended == nil || recommended! == "") ? 0 : displayMuscleGroups.indexOf(recommended!)!
        }
        else
        {
            nextExerciseButton.hidden = false
            
            for muscleGroups in json as! NSArray
            {
                let exerciseName = muscleGroups[Constant.COLUMN_EXERCISE_NAME] as! String
//                let weight = muscleGroups[Constant.COLUMN_EXERCISE_WEIGHT] as! String
//                let reps = muscleGroups[Constant.COLUMN_EXERCISE_REPS] as! String
//                let duration = muscleGroups[Constant.COLUMN_EXERCISE_DURATION] as! String
//                let difficulty = muscleGroups[Constant.COLUMN_EXERCISE_DIFFICULTY] as! String
//                let notes = muscleGroups[Constant.COLUMN_NOTES] as! String
                
                let exercise = Exercise(name: exerciseName)
                
                allExercises.append(exercise)
            }
        }
        
        animateTable()
    }
    
    /**
     * The callback for when the user selects to start exercising.
     */
    func onStartExercising(routine: Int)
    {
        selectedRoutine = displayMuscleGroups[routine - 1]
        
        ServiceTask(event: ServiceEvent.SET_CURRENT_MUSCLE_GROUP, delegate: self,
            serviceURL: Constant.SERVICE_STORED_PROCEDURE,
            params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_SET_CURRENT_MUSCLE_GROUP, variables:  [ email,  String(routine)]))
    }
    
    /**
     * The callback for when an exercise is clicked in the exercise list.
     *
     * @param name  The name of the exercise clicked.
     */
    func onExerciseClicked(name: String)
    {
        let directionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DirectionViewController") as! DirectionViewController
        directionViewController.exerciseName = name
        
        self.navigationController!.pushViewController(directionViewController, animated: true)
    }
    
    /**
     * The callback for when the edit button is clicked.
     */
    func onEditClicked(name: String)
    {
        let directionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("StatViewController") as! StatViewController
        directionViewController.exerciseName = name
        
        self.navigationController!.pushViewController(directionViewController, animated: true)
    }
    
    /**
     * Animates the table being added to the screen.
    */
    func animateTable()
    {
        numberOfCells = 1
            
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesInRange: range)
            
        self.tableView.reloadSections(sections, withRowAnimation: .Top)
        
        if (state == Constant.EXERCISE_CELL)
        {
            // Start the view off by inserting a row
            addExercise()
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
    
    // MARK: - UITableViewDataSource
    
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
            let  headerCell = tableView.dequeueReusableCellWithIdentifier("ExerciseListHeader") as! ExerciseListHeaderController
            headerCell.routineNameLabel.text = selectedRoutine
            
            return headerCell.contentView
        }
    
        return nil       
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return state == Constant.EXERCISE_CELL ? 50 : 0
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
            return cell
        }
        else
        {
            let exercise = currentExercises[indexPath.item]
            let cell = tableView.dequeueReusableCellWithIdentifier(Constant.EXERCISE_CELL) as! ExerciseCellController
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.delegate = self
            cell.exerciseButton.setTitle(exercise.name, forState: .Normal)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
        }
    }
}