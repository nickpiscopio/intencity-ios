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
        tableView.estimatedRowHeight = 44.0; // set to whatever your "average" cell
        
        let nib = UINib(nibName: "RoutineCard", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "RoutineCell")
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
                // This gets saved as NSDictionary, so there is no order
                let json: AnyObject? = result.parseJSONString
                
                var recommended = ""
                
                for muscleGroups in json as! NSArray
                {
                    let muscleGroup = muscleGroups[Constant.COLUMN_DISPLAY_NAME] as! String
                    recommended = muscleGroups[Constant.COLUMN_CURRENT_MUSCLE_GROUP] as! String
                    
                    displayMuscleGroups.append(muscleGroup)
                }
                
                self.recommended = (recommended == "") ? 0 : displayMuscleGroups.indexOf(recommended)!
                
                animateTable()

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
    
    func animateTable()
    {
        numberOfCells = 1
        
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
        return numberOfCells
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("RoutineCell") as! RoutineViewController
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.delegate = self
        cell.pickerDataSource = displayMuscleGroups
        // Need to add 1 to the routine so we get back the correct value when setting the muscle group for today.
        // CompletedMuscleGroup starts at 1.
        cell.selectedRoutineNumber = recommended + 1
        cell.routinePickerView.selectRow(recommended, inComponent: 0, animated: false)
        
        return cell
    }
    
    //    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return "Section \(section)"
    //    }
}