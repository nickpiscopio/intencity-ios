//
//  MainViewController.swift
//  Intencity
//
//  The view controller for the Fitness Log.
//
//  Created by Nick Piscopio on 2/8/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class FitnessLogViewController: UIViewController, ServiceDelegate, RoutineDelegate
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
        
        tableView.backgroundColor = Color.transparent
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 10.0; // set to whatever your "average" cell
        
        state = Constant.ROUTINE_CELL

        // Load the cells we are going to use in the tableview.
        setNib("HeaderCard", cellName: Constant.HEADER_CELL)
        setNib("RoutineCard", cellName: Constant.ROUTINE_CELL)
        setNib("ExerciseCard", cellName: Constant.EXERCISE_CELL)
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
            nextExerciseButton.hidden = true
            var recommended = ""
            
            for muscleGroups in json as! NSArray
            {
                let muscleGroup = muscleGroups[Constant.COLUMN_DISPLAY_NAME] as! String
                recommended = muscleGroups[Constant.COLUMN_CURRENT_MUSCLE_GROUP] as! String
                
                displayMuscleGroups.append(muscleGroup)
            }
            
            self.recommended = (recommended == "") ? 0 : displayMuscleGroups.indexOf(recommended)!
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
        print("selected delegate value: \"\(routine)\"")
        
        let variables = Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_SET_CURRENT_MUSCLE_GROUP, variables:  [ email,  String(routine)])
        
        print("variables \"\(variables)\"")
        
        ServiceTask(event: ServiceEvent.SET_CURRENT_MUSCLE_GROUP, delegate: self,
            serviceURL: Constant.SERVICE_STORED_PROCEDURE,
            params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_SET_CURRENT_MUSCLE_GROUP, variables:  [ email,  String(routine)]))
        
    }
    
    func setNib(nibNamed: String, cellName: String) ->String
    {
        let nib = UINib(nibName: nibNamed, bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: cellName)
        
        return nibNamed
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
    }
    
    /**
     * Animates a row being added to the screen.
    */
    func insertRow()
    {
        var currentExerciseCount = currentExercises.count
        
//        var indexPaths = [NSIndexPath]()
//        
//        if (currentExerciseCount % 2 != 1)
//        {
//            let indexPath = NSIndexPath(forRow: currentExerciseCount - 1, inSection: 0)
//            
//            indexPaths.append(NSIndexPath(forRow: currentExerciseCount - 1, inSection: 0))
//            
//            tableView.beginUpdates()
//            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
//            tableView.endUpdates()
//        }
//        else
//        {
//            currentExerciseCount--
//        }
        
        
        let indexPath = NSIndexPath(forRow: currentExercises.count - 1, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
        
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }
    
    // http://stackoverflow.com/questions/31870206/how-to-insert-new-cell-into-uitableview-in-swift
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return Dimention.LAYOUT_MARGIN
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let returnedView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, Dimention.LAYOUT_MARGIN)) //set these values as necessary
        returnedView.backgroundColor = Color.transparent
        
        return returnedView
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
//        let exerciseCount = currentExercises.count
//        var sections = 1
//        
//        if (state == Constant.EXERCISE_CELL && exerciseCount > 0)
//        {
//            sections = exerciseCount
//        }
        
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        let exerciseCount = currentExercises.count
//        var sections = 0
//        
//        if (state == Constant.EXERCISE_CELL && exerciseCount > 0)
//        {
//            sections = exerciseCount
//        }
//        else if state == Constant.ROUTINE_CELL
//        {
//            sections = 1
//        }
        
        // Return the number of rows in the section.
        return state == Constant.ROUTINE_CELL ? numberOfCells : currentExercises.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
//        let index = indexPath.row;
//        if (index % 2 == 1)
//        {
//            let cell = tableView.dequeueReusableCellWithIdentifier(Constant.HEADER_CELL) as! HeaderCellController
//            cell.selectionStyle = UITableViewCellSelectionStyle.None
//            return cell
//        }
        
        if (state == Constant.ROUTINE_CELL)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constant.ROUTINE_CELL) as! RoutineCellController
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.delegate = self
            cell.pickerDataSource = displayMuscleGroups
            // Need to add 1 to the routine so we get back the correct value when setting the muscle group for today.
            // CompletedMuscleGroup starts at 1.
            cell.selectedRoutineNumber = recommended + 1
            cell.routinePickerView.selectRow(recommended, inComponent: 0, animated: false)
            return cell
        }
        else
        {
            let exercise = currentExercises[indexPath.item]
            let cell = tableView.dequeueReusableCellWithIdentifier(Constant.EXERCISE_CELL) as! ExerciseCellController
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.exerciseName.text = exercise.name
            return cell
        }
    }
    
    //    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return "Section \(section)"
    //    }
}