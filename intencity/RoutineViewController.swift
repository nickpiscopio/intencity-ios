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
    
    let CONTINUE_STRING = NSLocalizedString("routine_continue", comment: "")
    static let CUSTOM_ROUTINE_TITLE = NSLocalizedString("title_custom_routines", comment: "")
    static let INTENCITY_ROUTINE_TITLE = NSLocalizedString("title_intencity_routines", comment: "")
    static let DEFAULT_ROUTINE_TITLE = NSLocalizedString("title_default_routines", comment: "")
    static let SAVED_ROUTINE_TITLE = NSLocalizedString("title_saved_routines", comment: "")
    static let CUSTOM_ROUTINE_DESCRIPTION = NSLocalizedString("description_custom_routines", comment: "")
    static let DEFAULT_ROUTINE_DESCRIPTION = NSLocalizedString("description_default_routines", comment: "")

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
        Util.addUITableViewCell(tableView, nibNamed: Constant.ROUTINE_CONTINUE_CELL, cellName: Constant.ROUTINE_CONTINUE_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.ROUTINE_CELL, cellName: Constant.ROUTINE_CELL)
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
        routines.removeAll()
        routines.append(RoutineSection(title:RoutineViewController.CUSTOM_ROUTINE_TITLE, keys: [ RoutineKeys.USER_SELECTED ], rows: []))
        routines.append(RoutineSection(title: RoutineViewController.SAVED_ROUTINE_TITLE, keys: [ RoutineKeys.USER_SELECTED, RoutineKeys.CONSECUTIVE ], rows: []))
        
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
                                params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_EXERCISES_FOR_TODAY, variables: [ email ]))
                
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
        
        var defaultRoutineRows = [RoutineRow]()
        var defaultRoutines = [String]()
        var customRoutines = [String]()
        
        var recommended: String?
        
        var i = 0
        
        if (json != nil)
        {
            for muscleGroups in json as! NSArray
            {
                let muscleGroup = muscleGroups[Constant.COLUMN_DISPLAY_NAME] as! String
                recommended = muscleGroups[Constant.COLUMN_CURRENT_MUSCLE_GROUP] as? String

                i += 1
                
                if (i > 6)
                {
                    customRoutines.append(muscleGroup)
                }
                else
                {
                    defaultRoutines.append(muscleGroup)
                }
            }
            
            defaultRoutineRows.append(RoutineRow(title: RoutineViewController.DEFAULT_ROUTINE_TITLE, rows: defaultRoutines, showAssociatedImage: false))
            defaultRoutineRows.append(RoutineRow(title: RoutineViewController.DEFAULT_ROUTINE_TITLE, rows: customRoutines, showAssociatedImage: true))
            
            hideConnectionIssue()
        }
        else
        {
            routines.removeAll()
        }
            
        // Get the saved exercises from the local database.
        savedExercises = DBHelper().getRecords()
            
        if (savedExercises.routineName != "")
        {
            self.routines.insert(RoutineSection(title: String(format: CONTINUE_STRING, arguments: [ savedExercises.routineName.uppercaseString ]), keys: [], rows: []), atIndex: 0)
//            defaultRoutineRows.append(CONTINUE_STRING)
//            
//            self.recommended = defaultRoutineRows.count - 1
        }
        else if (json != nil)
        {
//            self.recommended = (recommended == nil || recommended! == "") ? 0 : defaultRoutineRows.indexOf(recommended!)!
        }
            
        if (defaultRoutineRows.count > 0)
        {
            self.routines.append(RoutineSection(title: RoutineViewController.INTENCITY_ROUTINE_TITLE, keys: [ RoutineKeys.USER_SELECTED, RoutineKeys.RANDOM ], rows: defaultRoutineRows))
//            animateTable()
            tableView.reloadData()
        }
        
        hideLoading()
    }
    
    @IBAction func startExercisingClicked(sender: AnyObject)
    {
//        let routineName = routines[selectedRoutineSection].rows[selectedRoutine]
//        if (routineName == CONTINUE_STRING)
//        {
//            exerciseData.routineName = savedExercises.routineName
//            
//            // LOAD FITNESS LOG
//            viewDelegate.onLoadView(View.FITNESS_LOG_VIEW, result: CONTINUE_STRING, savedExercises: savedExercises)
//        }
//        else
//        {
//            exerciseData.routineName = routineName
//            
//            showLoading()
//            
//            // We add 1 because the routines start at 1 on the server.
//            let selectedRoutine = String(self.selectedRoutine + 1)
//            _ = ServiceTask(event: ServiceEvent.SET_CURRENT_MUSCLE_GROUP, delegate: self,
//                            serviceURL: Constant.SERVICE_STORED_PROCEDURE,
//                            params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_SET_CURRENT_MUSCLE_GROUP, variables: [ email,  selectedRoutine]))
//        }
    }
    
    /**
     * Returns the continue string.
     */
    func getContinueString() -> String
    {
        return String(format: CONTINUE_STRING, arguments: [savedExercises.routineName.uppercaseString])
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
        return 1
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
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if (section == routines.count - 1)
        {
            return routineFooter != nil ? routineFooter.view.frame.height : 80
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        // Gets the row in the section.
        let routine = routines[indexPath.section]
        let title = routine.title
        
        if (savedExercises != nil && title == getContinueString())
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constant.ROUTINE_CONTINUE_CELL) as! RoutineContinueCellController
            cell.selectionStyle = .None
            cell.routineTitle.text = title
            return cell
        }
        else
        {
            let rows = routine.rows
            let count = rows.count
            var totalIntencityRoutines = 0
            for i in 0..<count
            {
                totalIntencityRoutines += rows[i].rows.count
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier(Constant.ROUTINE_CELL) as! RoutineCellController
            cell.selectionStyle = .None
            cell.routineTitle.text = title
            cell.setDescription(totalIntencityRoutines)
            cell.setKeys(routine.keys)
            cell.setBackground()
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let routine = routines[indexPath.section]
        let title = routine.title
        switch title
        {
        case getContinueString():
            
                viewDelegate.onLoadView(View.FITNESS_LOG_VIEW, result: CONTINUE_STRING, savedExercises: savedExercises)
                
                break
            case RoutineViewController.CUSTOM_ROUTINE_TITLE:
                
                viewDelegate.onLoadView(View.FITNESS_LOG_VIEW, result: "", savedExercises: nil)
                
                break
            case RoutineViewController.INTENCITY_ROUTINE_TITLE:
                
                let vc = storyboard!.instantiateViewControllerWithIdentifier(Constant.INTENCITY_ROUTINE_VIEW_CONTROLLER) as! IntencityRoutineViewController
                vc.viewDelegate = viewDelegate
                vc.routines = routine.rows
                
                self.navigationController!.pushViewController(vc, animated: true)
                
                break
            case RoutineViewController.SAVED_ROUTINE_TITLE:
                
//                let vc = storyboard!.instantiateViewControllerWithIdentifier(Constant.CUSTOM_ROUTINE_VIEW_CONTROLLER) as! CustomRoutineViewController
//                    
//                self.navigationController!.pushViewController(vc, animated: true)

                break
            default:
                break
        }
//        selectedRoutineSection = indexPath.section
//        selectedRoutine = indexPath.row
////
//        let cell = tableView.cellForRowAtIndexPath(indexPath) as! CheckboxCellController
//        cell.setChecked(true)
//        
////        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
//        
//        // Deselects the row.
////        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    {
//        // Deselects the row.
////        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        
//        //        // Gets the row in the section.
//        //        let row = routines[indexPath.section].rows[indexPath.row]
//        //
//                let cell = tableView.cellForRowAtIndexPath(indexPath) as! CheckboxCellController
//                cell.setChecked(false)
//        
////        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
    }
}