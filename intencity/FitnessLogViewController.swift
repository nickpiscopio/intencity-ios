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
    
    var exerciseData: ExerciseData!
    
    var isSwipeOpen = false
    
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
        if (currentExercises.count < exerciseData.exerciseList.count)
        {
            // Get the next exercise.
            currentExercises.append(exerciseData.exerciseList[exerciseData.exerciseIndex++])
            
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
                let weight = muscleGroups[Constant.COLUMN_EXERCISE_WEIGHT]
                let reps = muscleGroups[Constant.COLUMN_EXERCISE_REPS]
                let duration = muscleGroups[Constant.COLUMN_EXERCISE_DURATION]
                let difficulty = muscleGroups[Constant.COLUMN_EXERCISE_DIFFICULTY]
                let notes = muscleGroups[Constant.COLUMN_NOTES]

                let sets = [ Set(webId: Int(Constant.CODE_FAILED),
                                weight: !(weight is NSNull) ? Float(weight as! String)! : Float(Constant.CODE_FAILED),
                                reps: !(reps is NSNull) ? Int(reps as! String)! : Int(Constant.CODE_FAILED),
                                duration: !(duration is NSNull) ? duration as! String : Constant.RETURN_NULL,
                                difficulty: !(difficulty is NSNull) ? Int(difficulty as! String)! : 10,
                                notes: !(notes is NSNull) ? notes as! String : "") ]
                
                let exercise = Exercise(name: exerciseName, sets: sets)
                
                exerciseData.exerciseList.append(exercise)
            }
        }
        
        animateTable()
    }
    
    /**
     * The callback for when the user selects to start exercising.
     */
    func onStartExercising(routine: Int)
    {
        exerciseData.routineName = displayMuscleGroups[routine - 1]
        
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
            statViewController.index = index
        
            self.navigationController!.pushViewController(statViewController, animated: true)
        }
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
            let  headerCell = tableView.dequeueReusableCellWithIdentifier(Constant.EXERCISE_LIST_HEADER) as! ExerciseListHeaderController
            headerCell.routineNameLabel.text = exerciseData.routineName
            
            return headerCell.contentView
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
            return cell
        }
        else
        {
            let index = indexPath.item
            let exercise = currentExercises[index]
            let cell = tableView.dequeueReusableCellWithIdentifier(Constant.EXERCISE_CELL) as! ExerciseCellController
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.delegate = self
            cell.index = index
            cell.exerciseButton.setTitle(exercise.name, forState: .Normal)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?
    {
        isSwipeOpen = true
        
        let remove = UITableViewRowAction(style: .Normal, title: NSLocalizedString("hide", comment: "")) { action, index in
            
            let exerciseName = self.exerciseData.exerciseList[indexPath.row].name
            let actions = [ UIAlertAction(title: NSLocalizedString("hide_for_now", comment: ""), style: .Default, handler: self.hideExercise),
                            UIAlertAction(title: NSLocalizedString("hide_forever", comment: ""), style: .Destructive, handler: self.hideExercise),
                            UIAlertAction(title: NSLocalizedString("do_not_hide", comment: ""), style: .Cancel, handler: self.cancelRemoval) ]
            Util.displayAlert(self, title: String(format: NSLocalizedString("hide_exercise", comment: ""), exerciseName), message: "", actions: actions)
        }
        
        remove.backgroundColor = Color.card_button_delete_select
        
        return [remove]
    }
    
    func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath)
    {
        self.isSwipeOpen = false
    }

    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
        }
        
        self.isSwipeOpen = false
    }
    
    func hideExercise(alertAction: UIAlertAction!) -> Void
    {
        print("hide clicked")
//        if let indexPath = deletePlanetIndexPath {
//            tableView.beginUpdates()
//            
//            planets.removeAtIndex(indexPath.row)
//            
//            // Note that indexPath is wrapped in an array:  [indexPath]
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//            
//            deletePlanetIndexPath = nil
//            
//            tableView.endUpdates()
//        }
    }
    
    func cancelRemoval(alertAction: UIAlertAction!)
    {
        print("cancel clicked")
//        deletePlanetIndexPath = nil
    }
}