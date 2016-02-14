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
    
    var email = "";
    
    var state = "";
    
    var exercises = [Exercise]()
    
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
    
    func loadTableViewItems(state: String, result: String)
    {
        // This gets saved as NSDictionary, so there is no order
        let json: AnyObject? = result.parseJSONString
        
        if (state == Constant.ROUTINE_CELL)
        {
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
            for muscleGroups in json as! NSArray
            {
                let exerciseName = muscleGroups[Constant.COLUMN_EXERCISE_NAME] as! String
//                let weight = muscleGroups[Constant.COLUMN_EXERCISE_WEIGHT] as! String
//                let reps = muscleGroups[Constant.COLUMN_EXERCISE_REPS] as! String
//                let duration = muscleGroups[Constant.COLUMN_EXERCISE_DURATION] as! String
//                let difficulty = muscleGroups[Constant.COLUMN_EXERCISE_DIFFICULTY] as! String
//                let notes = muscleGroups[Constant.COLUMN_NOTES] as! String
                
                let exercise = Exercise(name: exerciseName)
                
                exercises.append(exercise)
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
    
    func animateTable()
    {
        numberOfCells = state == Constant.ROUTINE_CELL ? 1 : exercises.count
        
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesInRange: range)
        self.tableView.reloadSections(sections, withRowAnimation: .Top)
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
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        // Later make this the array count.
        // We will make an array of classes.
        return state == Constant.ROUTINE_CELL ? numberOfCells : exercises.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row;
        if (index % 2 == 1)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constant.HEADER_CELL) as! HeaderCellController
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }
        
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
            let exercise = exercises[indexPath.item]
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