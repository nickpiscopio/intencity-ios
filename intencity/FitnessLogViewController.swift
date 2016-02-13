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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Sets the title for the screen.
        self.navigationController?.navigationBar.topItem!.title = NSLocalizedString("app_name", comment: "")
        
        let variables = [ Util.getEmailFromDefaults() ]

        ServiceTask(event: ServiceEvent.GENERIC, delegate: self,
            serviceURL: Constant.SERVICE_STORED_PROCEDURE,
            params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_ALL_DISPLAY_MUSCLE_GROUPS, variables:  variables))
        
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
        if (event == ServiceEvent.GENERIC)
        {
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
        }
    }
    
    func onRetrievalFailed(event: Int)
    {
        // Add code for when we can't get the muscle groups.
    }
    
    /**
     * The callback for when the user selects to start exercising.
     */
    func onStartExercising(routine: String)
    {
        print("selected delegate value: \"\(routine)\"")
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
    
//    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
//    {
//        cell.contentView.backgroundColor = Color.page_background
//        
//        let whiteRoundedView : UIView = UIView(frame: CGRectMake(Dimention.LAYOUT_MARGIN, Dimention.LAYOUT_MARGIN, cell.contentView.frame.size.width - Dimention.LAYOUT_MARGIN * 2, cell.contentView.frame.size.height - Dimention.LAYOUT_MARGIN * 2))
//
//        whiteRoundedView.layer.backgroundColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [1.0, 1.0, 1.0, 1.0])
//        whiteRoundedView.layer.masksToBounds = false
//        whiteRoundedView.layer.cornerRadius = Dimention.RADIUS
//        whiteRoundedView.layer.shadowOffset = CGSizeMake(Dimention.SHADOW, Dimention.SHADOW)
//        whiteRoundedView.layer.shadowOpacity = Dimention.SHADOW_OPACITY
//        
//        cell.contentView.addSubview(whiteRoundedView)
//        cell.contentView.sendSubviewToBack(whiteRoundedView)
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("RoutineCell") as! RoutineViewController
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.delegate = self
        cell.pickerDataSource = displayMuscleGroups
        cell.selectedRoutine = displayMuscleGroups[recommended]
        cell.routinePickerView.selectRow(recommended, inComponent: 0, animated: false)
        
        return cell
    }
    
    //    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return "Section \(section)"
    //    }
}