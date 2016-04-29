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

class RoutineViewController: UIViewController, ServiceDelegate, IntencityRoutineDelegate
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
        routines.append(RoutineSection(title:RoutineViewController.CUSTOM_ROUTINE_TITLE, keys: [ RoutineKeys.USER_SELECTED ], routineGroups: []))
        
        showLoading()

        // Creates the instance of the exercise data so we can store the exercises in the database later.
        ExerciseData.reset()
        exerciseData = ExerciseData.getInstance()

        _ = ServiceTask(event: ServiceEvent.GET_ALL_DISPLAY_MUSCLE_GROUPS, delegate: self,
                        serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_ALL_DISPLAY_MUSCLE_GROUPS, variables: [ email ]))
        
        _ = ServiceTask(event: ServiceEvent.GET_LIST, delegate: self,
                        serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_USER_ROUTINE, variables: [ email ]))
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
            case ServiceEvent.GET_LIST:
            
                loadTableViewItems(ServiceEvent.GET_LIST, result: result)
            
                break
            case ServiceEvent.GET_ALL_DISPLAY_MUSCLE_GROUPS:
                
                loadTableViewItems(ServiceEvent.GET_ALL_DISPLAY_MUSCLE_GROUPS, result: result)
                
                break
            default:
                break
        }
    }
    
    func onRetrievalFailed(event: Int)
    {
        showConnectionIssue()
        
        loadTableViewItems(ServiceEvent.NO_RETURN, result: "")
        
        hideLoading()
    }
    
    func onRoutineSaved(hasMoreRoutines: Bool) { }
    
    func onRoutineUpdated(groups: [RoutineGroup])
    {
        let groupCount = groups.count
        let routine = routines[selectedRoutineSection].title
        routines.removeAtIndex(selectedRoutineSection)
        
        switch routine
        {
            case RoutineViewController.INTENCITY_ROUTINE_TITLE:
                routines.insert(RoutineSection(title: RoutineViewController.INTENCITY_ROUTINE_TITLE, keys: [ RoutineKeys.USER_SELECTED, RoutineKeys.RANDOM ], routineGroups: groups), atIndex: selectedRoutineSection)
                break
            case RoutineViewController.SAVED_ROUTINE_TITLE:
                if (groupCount > 0)
                {
                    routines.insert(RoutineSection(title: RoutineViewController.SAVED_ROUTINE_TITLE, keys: [ RoutineKeys.USER_SELECTED, RoutineKeys.CONSECUTIVE ], routineGroups: groups), atIndex: selectedRoutineSection)
                }                
                break
            default:
                break
        }        
        
        let indexPath = NSIndexPath(forRow: 0, inSection: selectedRoutineSection)
        
        if (groupCount > 0)
        {
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        else
        {
            tableView.reloadData()
        }
        
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
    func loadTableViewItems(event: Int, result: String)
    {
        var section: RoutineSection!
        var rows = [RoutineGroup]()

        // This means we got results back from the web database.
        if (result != "" && result != Constant.RETURN_NULL)
        {
            let json = result.parseJSONString!
                
            do
            {
                switch event
                {
                    case ServiceEvent.GET_LIST:
                        rows = try UserRoutineDao().parseJson(json)
                        break
                    case ServiceEvent.GET_ALL_DISPLAY_MUSCLE_GROUPS:
                        rows = try IntencityRoutineDao().parseJson(json)
                        break
                    default:
                        break
                }
                    
                hideConnectionIssue()
            }
            catch
            {
                showConnectionIssue()
            }
        }
        else
        {
            showConnectionIssue()
        }
            
        switch event
        {
            case ServiceEvent.GET_LIST:
                
                section = RoutineSection(title: RoutineViewController.SAVED_ROUTINE_TITLE, keys: [ RoutineKeys.USER_SELECTED, RoutineKeys.CONSECUTIVE ], routineGroups: rows)
                
                break
            case ServiceEvent.GET_ALL_DISPLAY_MUSCLE_GROUPS:
                
                // This doesn't really belong in here because it is not a muscle group, but we only want to get this one.
                // Get the saved exercises from the local database.
                savedExercises = DBHelper().getRecords()
                
                if (savedExercises.routineName != "")
                {
                    self.routines.insert(RoutineSection(title: String(format: CONTINUE_STRING, arguments: [ savedExercises.routineName.uppercaseString ]), keys: [], routineGroups: []), atIndex: 0)
                    
                    //            self.recommended = defaultRoutineRows.count - 1
                }
                //        else if (json != nil)
                //        {
                ////            self.recommended = (recommended == nil || recommended! == "") ? 0 : defaultRoutineRows.indexOf(recommended!)!
                //        }
                
                
                section = RoutineSection(title: RoutineViewController.INTENCITY_ROUTINE_TITLE, keys: [ RoutineKeys.USER_SELECTED, RoutineKeys.RANDOM ], routineGroups: rows)
                
                break
            default:
                break
        }
            
        if (rows.count > 0)
        {
            routines.append(section)
            //            animateTable()
            tableView.reloadData()
        }
        
        hideLoading()
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
            let rows = routine.routineGroups
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
        // This is so we know which routine section to remove from the routines array when we update the RoutineGroups
        selectedRoutineSection = indexPath.section
        
        let routine = routines[selectedRoutineSection]
        let title = routine.title
        switch title
        {
            case getContinueString():
            
                viewDelegate.onLoadView(View.FITNESS_LOG_VIEW, result: CONTINUE_STRING, savedExercises: savedExercises, state: savedExercises.routineState)
                
                break
            case RoutineViewController.CUSTOM_ROUTINE_TITLE:
                
                viewDelegate.onLoadView(View.FITNESS_LOG_VIEW, result: "", savedExercises: nil, state: RoutineState.CUSTOM)
                
                break
            case RoutineViewController.INTENCITY_ROUTINE_TITLE:
                
                let vc = storyboard!.instantiateViewControllerWithIdentifier(Constant.INTENCITY_ROUTINE_VIEW_CONTROLLER) as! IntencityRoutineViewController
                vc.viewDelegate = viewDelegate
                vc.intencityRoutineDelegate = self
                vc.routines = routine.routineGroups
                
                self.navigationController!.pushViewController(vc, animated: true)
                
                break
            case RoutineViewController.SAVED_ROUTINE_TITLE:
                
                let vc = storyboard!.instantiateViewControllerWithIdentifier(Constant.SAVED_ROUTINE_VIEW_CONTROLLER) as! SavedRoutineViewController
                vc.viewDelegate = viewDelegate
                vc.intencityRoutineDelegate = self
                vc.routines = routine.routineGroups
                    
                self.navigationController!.pushViewController(vc, animated: true)

                break
            default:
                break
        }
    }
}