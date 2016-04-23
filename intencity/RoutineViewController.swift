//
//  MainViewController.swift
//  Intencity
//
//  The view controller for the Fitness Log.
//
//  Created by Nick Piscopio on 2/8/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import Social

class RoutineViewController: UIViewController, ServiceDelegate
{
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var connectionView: UIView!
    @IBOutlet weak var noConnectionLabel: UILabel!
    @IBOutlet weak var tryAgainButton: UIButton!
    
    @IBOutlet weak var routineTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var startButton: IntencityButtonRoundDark!
    
    let CONTINUE_STRING = NSLocalizedString("routine_continue", comment: "")
    let DEFAULT_ROUTINE_TITLE = NSLocalizedString("title_default_routines", comment: "")

    let DEFAULTS = NSUserDefaults.standardUserDefaults()
    
    var viewDelegate: ViewDelegate!
    
    var routineFooter: RoutineCellFooterController!
    
    var email = ""

    var recommended = 0
    
    var savedExercises: SavedExercise!
    
    var exerciseData: ExerciseData!
    
    var routines = [RoutineSection]()
    var selectedRoutineSection: Int!
    var selectedRoutine: Int!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        email = Util.getEmailFromDefaults()
        
        initConnectionViews()
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: 0, emptyTableStringRes: "")

        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.ROUTINE_HEADER_CELL, cellName: Constant.ROUTINE_HEADER_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.CHECKBOX_CELL, cellName: Constant.CHECKBOX_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.ROUTINE_CELL_FOOTER, cellName: Constant.ROUTINE_CELL_FOOTER)
        
        showWelcome()
        
        email = Util.getEmailFromDefaults()
        
        routineTitle.text = NSLocalizedString("title_routine", comment: "")
        routineTitle.textColor = Color.secondary_light
        
        initRoutineCard()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /**
     * Calls the service to get the display muscle groups for the routine card.
     */
    func initRoutineCard()
    {
        startButton.hidden = true
        
        routines.removeAll()
        routines.append(RoutineSection(title: RoutineHeaderRow(title: NSLocalizedString("title_custom_routines", comment: ""), titleKeys: [ RoutineKeys.RANDOM, RoutineKeys.USER_SELECTED ], includeAssociatedButton: true), rows: []))
        routines.append(RoutineSection(title: RoutineHeaderRow(title: NSLocalizedString("title_saved_routines", comment: ""), titleKeys: [ RoutineKeys.USER_SELECTED, RoutineKeys.CONSECUTIVE ], includeAssociatedButton: true), rows: []))
        
        showLoading()

        // Creates the instance of the exercise data so we can store the exercises in the database later.
        ExerciseData.reset()
        exerciseData = ExerciseData.getInstance()

        _ = ServiceTask(event: ServiceEvent.GET_ALL_DISPLAY_MUSCLE_GROUPS, delegate: self,
                        serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_ALL_DISPLAY_MUSCLE_GROUPS, variables: [ email ]))
    }
    
    /**
     * Initializes the connection views.
     */
    func initConnectionViews()
    {
        loadingView.backgroundColor = Color.page_background
        connectionView.backgroundColor = Color.page_background
        
        loadingView.hidden = true
        connectionView.hidden = true
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.hidden = true
        
        noConnectionLabel.textColor = Color.secondary_light
        noConnectionLabel.text = NSLocalizedString("generic_error", comment: "")
        tryAgainButton.setTitle(NSLocalizedString("try_again", comment: ""), forState: .Normal)
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
    /**
     * Shows there was a connection issue.
     */
    func showConnectionIssue()
    {
        connectionView.hidden = false
    }
    
    /**
     * Hides the connection issue.
     */
    func hideConnectionIssue()
    {
        connectionView.hidden = true
    }
    
    @IBAction func tryAgainClick(sender: AnyObject)
    {
        initRoutineCard()
    }
    
    func onRetrievalSuccessful(event: Int, result: String)
    {
        switch (event)
        {
            case ServiceEvent.GET_ALL_DISPLAY_MUSCLE_GROUPS:
                
                loadTableViewItems(result)
                
                break
            case ServiceEvent.SET_CURRENT_MUSCLE_GROUP:
                
                showLoading()
                
                _ = ServiceTask(event: ServiceEvent.GET_EXERCISES_FOR_TODAY, delegate: self,
                                serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                                params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_EXERCISES_FOR_TODAY, variables:  [ email ]))
                
                break
            
            case ServiceEvent.GET_EXERCISES_FOR_TODAY:
                
                if (result != "" && result != Constant.RETURN_NULL)
                {
                    viewDelegate.onLoadView(View.FITNESS_LOG_VIEW, result: result, savedExercises: nil)
                }
                else
                {
                    // We couldn't get data from the server, so we show the connection issue.
                    showConnectionIssue()
                    
                    hideLoading()
                }
                
                break
            default:
                break
        }
    }
    
    func onRetrievalFailed(event: Int)
    {
        showConnectionIssue()
        
        loadTableViewItems("")
        
        hideLoading()
    }
    
    /**
     * Shows the welcome alert to the user if needed.
     */
    func showWelcome()
    {
        let lastLogin = DEFAULTS.floatForKey(Constant.USER_LAST_LOGIN)
        
        if (Util.getEmailFromDefaults() != "" && lastLogin == 0)
        {
            Util.displayAlert(self,
                title: NSLocalizedString("welcome_title", comment: ""),
                message: NSLocalizedString("welcome_description", comment: ""),
                actions: [ UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .Default, handler: nil) ])
        }
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
        
        var defaultRoutineRows = [String]()
        defaultRoutineRows.removeAll()
        
        var recommended: String?
        
        if (json != nil)
        {
            for muscleGroups in json as! NSArray
            {
                let muscleGroup = muscleGroups[Constant.COLUMN_DISPLAY_NAME] as! String
                recommended = muscleGroups[Constant.COLUMN_CURRENT_MUSCLE_GROUP] as? String
                
                defaultRoutineRows.append(muscleGroup)
            }
            
            hideConnectionIssue()
        }
        else
        {
            routines.removeAll()
            
            startButton.hidden = true
        }
            
        // Get the saved exercises from the local database.
        savedExercises = DBHelper().getRecords()
            
        if (savedExercises.routineName != "")
        {
            defaultRoutineRows.append(CONTINUE_STRING)
            
            self.recommended = defaultRoutineRows.count - 1
        }
        else if (json != nil)
        {
            self.recommended = (recommended == nil || recommended! == "") ? 0 : defaultRoutineRows.indexOf(recommended!)!
        }
            
        if (defaultRoutineRows.count > 0)
        {
            routines.append(RoutineSection(title: RoutineHeaderRow(title: DEFAULT_ROUTINE_TITLE, titleKeys: [ RoutineKeys.RANDOM, RoutineKeys.USER_SELECTED ], includeAssociatedButton: false), rows: defaultRoutineRows))
//            animateTable()
            tableView.reloadData()
        }
        
        hideLoading()
    }
    
    @IBAction func startExercisingClicked(sender: AnyObject)
    {
        let routineName = routines[selectedRoutineSection].rows[selectedRoutine]
        if (routineName == CONTINUE_STRING)
        {
            exerciseData.routineName = savedExercises.routineName
            
            // LOAD FITNESS LOG
            viewDelegate.onLoadView(View.FITNESS_LOG_VIEW, result: CONTINUE_STRING, savedExercises: savedExercises)
        }
        else
        {
            exerciseData.routineName = routineName
            
            showLoading()
            
            // We add 1 because the routines start at 1 on the server.
            let selectedRoutine = String(self.selectedRoutine + 1)
            _ = ServiceTask(event: ServiceEvent.SET_CURRENT_MUSCLE_GROUP, delegate: self,
                            serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                            params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_SET_CURRENT_MUSCLE_GROUP, variables: [ email,  selectedRoutine]))
        }
    }

    /**
     * Animates the table being added to the screen.
     */
    func animateTable()
    {
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesInRange: range)
            
        tableView.reloadSections(sections, withRowAnimation: .Top)
    }
    
    // http://stackoverflow.com/questions/31870206/how-to-insert-new-cell-into-uitableview-in-swift
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return routines.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return routines[section].rows.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let title = routines[section].title
        let titleKeysCount = title.titleKeys.count

        let headerCell = tableView.dequeueReusableCellWithIdentifier(Constant.ROUTINE_HEADER_CELL) as! RoutineHeaderCellController
        headerCell.title.text = title.title
        headerCell.navigationController = self.navigationController
        headerCell.setClickEnabled(title.includeAssociatedButton)
        
        for i in 0..<titleKeysCount
        {
            switch title.titleKeys[i]
            {
                case RoutineKeys.RANDOM:
                    headerCell.randomInputIndicator.hidden = false
                    break
                case RoutineKeys.USER_SELECTED:
                    headerCell.userInputIndicator.hidden = false
                    break
                case RoutineKeys.CONSECUTIVE:
                    headerCell.constantInputIndicator.hidden = false
                    break
                default:
                    break
            }
        }
        
        return headerCell
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        if (section == routines.count - 1)
        {
            routineFooter = tableView.dequeueReusableCellWithIdentifier(Constant.ROUTINE_CELL_FOOTER) as! RoutineCellFooterController
            
            return routineFooter != nil ? routineFooter.contentView : nil
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return Constant.GENERIC_HEADER_HEIGHT
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if (section == routines.count - 1)
        {
            return routineFooter != nil ? routineFooter.view.frame.height : 100
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        // Gets the row in the section.
        let row = routines[indexPath.section].rows[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.CHECKBOX_CELL) as! CheckboxCellController
        cell.setCheckboxImage(Constant.RADIO_BUTTON_MARKED, uncheckedImage: Constant.RADIO_BUTTON_UNMARKED)
        cell.selectionStyle = .None
        cell.titleLabel.text = row
        cell.setChecked(false)
        
        return cell
        
//        let routineCellController = tableView.dequeueReusableCellWithIdentifier(Constant.ROUTINE_CELL) as! RoutineCellController
//        routineCellController.selectionStyle = UITableViewCellSelectionStyle.None
//        routineCellController.delegate = self
//        routineCellController.dataSource = displayMuscleGroups
//        // Need to add 1 to the routine so we get back the correct value when setting the muscle group for today.
//        // CompletedMuscleGroup starts at 1.
//        routineCellController.selectedRoutineNumber = recommended + 1
//        routineCellController.setDropDownDataSource(recommended)
//        routineCellController.setDropDownWidth(displayMuscleGroups.contains(CONTINUE_STRING))
//        return routineCellController
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        selectedRoutineSection = indexPath.section
        selectedRoutine = indexPath.row
//
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! CheckboxCellController
        cell.setChecked(true)
        
//        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
        
        // Deselects the row.
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        startButton.hidden = false
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    {
        // Deselects the row.
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        //        // Gets the row in the section.
        //        let row = routines[indexPath.section].rows[indexPath.row]
        //
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! CheckboxCellController
                cell.setChecked(false)
        
//        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
    }
}