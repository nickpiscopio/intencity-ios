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
import SSSnackbar

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
    static let FEATURED_ROUTINE_TITLE = NSLocalizedString("title_featured_routines", comment: "")
    static let DEFAULT_ROUTINE_TITLE = NSLocalizedString("title_default_routines", comment: "")
    static let SAVED_ROUTINE_TITLE = NSLocalizedString("title_saved_routines", comment: "")
    static let CUSTOM_ROUTINE_DESCRIPTION = NSLocalizedString("description_custom_routines", comment: "")
    static let DEFAULT_ROUTINE_DESCRIPTION = NSLocalizedString("description_default_routine", comment: "")
    static let DEFAULT_ROUTINES_DESCRIPTION = NSLocalizedString("description_default_routines", comment: "")

    let DEFAULTS = UserDefaults.standard
    
    var viewDelegate: ViewDelegate!
    
    var email = ""

    var recommended = 0
    
    var savedExercises: SavedExercise!
    
    var exerciseData: ExerciseData!
    
    var sectionMap = [Int : RoutineSection]()
    var sections = [RoutineSection]()
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
        
        displayAppAlert()
        
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
        showLoading()

        // Creates the instance of the exercise data so we can store the exercises in the database later.
        ExerciseData.reset()
        exerciseData = ExerciseData.getInstance()
        
        // Clear the entire map because we are reinitializing it.
        sectionMap.removeAll()
        
        let size = sections.count
        if (size > 0 && sections[RoutineType.CONTINUE].routineType == RoutineType.CONTINUE)
        {
            // Only reinsert the first section because it is the CONTINUE card.
        
            sectionMap[RoutineType.CONTINUE] = sections[RoutineType.CONTINUE]
        }
    
        // Clear the entire section array because we are reinstantiating it.
        sections.removeAll()
   
        insertSection(RoutineType.CUSTOM, routineSection: RoutineSection(routineType: RoutineType.CUSTOM, title:RoutineViewController.CUSTOM_ROUTINE_TITLE, routineGroups: []), notifyChange: true)

        // Get the Featured Routines
        _ = ServiceTask(event: ServiceEvent.GET_ALL_DISPLAY_MUSCLE_GROUPS, delegate: self,
                        serviceURL: Constant.SERVICE_EXECUTE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_ALL_DISPLAY_MUSCLE_GROUPS, variables: [ email ]) as NSString)
        
        // Get the Saved Routines
        _ = ServiceTask(event: ServiceEvent.GET_LIST, delegate: self,
                        serviceURL: Constant.SERVICE_EXECUTE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_USER_ROUTINE, variables: [ email ]) as NSString)
    }
    
    /**
     * Initializes the connection views.
     */
    func initConnectionViews()
    {
        loadingView.backgroundColor = Color.page_background
        connectionView.backgroundColor = Color.page_background
        
        loadingView.isHidden = true
        connectionView.isHidden = true
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = true
        
        noConnectionLabel.textColor = Color.secondary_light
        noConnectionLabel.text = NSLocalizedString("generic_error", comment: "")
        tryAgainButton.setTitle(NSLocalizedString("try_again", comment: ""), for: UIControlState())
    }
    
    /**
     * Shows the task is in progress.
     */
    func showLoading()
    {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        loadingView.isHidden = false
    }
    
    /**
     * Shows the task is in finished.
     */
    func hideLoading()
    {
        loadingView.isHidden = true
        
        activityIndicator.stopAnimating()
    }
    /**
     * Shows there was a connection issue.
     */
    func showConnectionIssue()
    {
        connectionView.isHidden = false
    }
    
    /**
     * Hides the connection issue.
     */
    func hideConnectionIssue()
    {
        connectionView.isHidden = true
    }
    
    /**
     * Inserts a routine section into the map and then into the section ArrayList.
     * We do this so we can give an order to the sections.
     *
     * @param routineType       The RoutineType of the section. This will be it's index.
     * @param routineSection    The RoutineSection we are adding.
     * @param notifyChange      Boolean value of whether we are notifying the adapter that we've added an item.
     */
    func insertSection(_ routineType: Int, routineSection: RoutineSection, notifyChange: Bool)
    {
        sectionMap[routineType] = routineSection
        let sectionArr = sectionMap.sorted{ $1.0 > $0.0 }

        // sort and add to sections.
        sections.removeAll()
        
        for (_, section) in sectionArr
        {
            sections.append(section)
        }

        if (notifyChange)
        {
            tableView.reloadData()
        }
    }

    @IBAction func tryAgainClick(_ sender: AnyObject)
    {
        initRoutineCard()
    }
    
    func onRetrievalSuccessful(_ event: Int, result: String)
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
    
    func onRetrievalFailed(_ event: Int)
    {
        showConnectionIssue()
        
        loadTableViewItems(ServiceEvent.NO_RETURN, result: "")
        
        hideLoading()
    }
    
    func onRoutineSaved(_ hasMoreRoutines: Bool) { }
    
    func onRoutineUpdated(_ groups: [RoutineGroup])
    {
        let groupCount = groups.count
        let routine = sections[selectedRoutineSection].title
        sections.remove(at: selectedRoutineSection)
        
        switch routine
        {
            case RoutineViewController.FEATURED_ROUTINE_TITLE:
                sections.insert(RoutineSection(routineType: RoutineType.FEATURED, title: RoutineViewController.FEATURED_ROUTINE_TITLE, routineGroups: groups), at: selectedRoutineSection)
                break
            case RoutineViewController.SAVED_ROUTINE_TITLE:
                if (groupCount > 0)
                {
                    sections.insert(RoutineSection(routineType: RoutineType.SAVED, title: RoutineViewController.SAVED_ROUTINE_TITLE, routineGroups: groups), at: selectedRoutineSection)
                }                
                break
            default:
                break
        }        
        
        let indexPath = IndexPath(row: 0, section: selectedRoutineSection)
        
        if (groupCount > 0)
        {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        else
        {
            tableView.reloadData()
        }
    }
    
    /**
     * Shows the welcome alert to the user if needed.
     */
    func displayAppAlert()
    {
        let lastLogin = DEFAULTS.float(forKey: Constant.USER_LAST_LOGIN)
        
        if (Util.getEmailFromDefaults() != "" && lastLogin == 0)
        {
            Util.displayAlert(self,
                title: NSLocalizedString("welcome_title", comment: ""),
                message: NSLocalizedString("welcome_description", comment: ""),
                actions: [ UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: showEditEquipmentAlert) ])
        }
        else
        {
            showEditEquipmentAlert()
        }
    }
    
    /**
     * The action for showing the edit equipment alert.
     */
    func showEditEquipmentAlert(_ alertAction: UIAlertAction!) -> Void
    {
        showEditEquipmentAlert()
    }
    
    /**
     * Displays the edit equipment alert.
     */
    func showEditEquipmentAlert()
    {
        let hasSetEquipment = DEFAULTS.bool(forKey: Constant.USER_SET_EQUIPMENT)
        if (!hasSetEquipment)
        {
            let sb = SSSnackbar(message:NSLocalizedString("edit_equipment_alert_description", comment: ""), actionText: NSLocalizedString("edit_equipment_alert_title", comment: ""), duration : TimeInterval(5),
                       actionBlock: {snackbar in
                        self.setEquipment()
            }, dismissalBlock:nil)
        
            sb?.show()
        }
    }
    
    /**
     * The action for showing the edit equipment alert.
     */
    func setEquipment(_ alertAction: UIAlertAction!) -> Void
    {
        setEquipment()
    }
    
    /**
     * Opens the edit equipment screen.
     */
    func setEquipment()
    {
        let viewController = storyboard!.instantiateViewController(withIdentifier: Constant.EDIT_EQUIPMENT_VIEW_CONTROLLER)
        
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    /**
     * Loads the table views.
     *
     * @param result    The results to parse from the webservice.
     */
    func loadTableViewItems(_ event: Int, result: String)
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
                    case ServiceEvent.GET_ALL_DISPLAY_MUSCLE_GROUPS:
                        rows = try IntencityRoutineDao().parseJson(json as? [AnyObject])
                        break
                    
                    case ServiceEvent.GET_LIST:
                        rows = try UserRoutineDao().parseJson(json as? [AnyObject])
                        break
                    
                    default:
                        break
                }
                    
                hideConnectionIssue()
            }
            catch
            {
                if (event == ServiceEvent.GET_ALL_DISPLAY_MUSCLE_GROUPS)
                {
                   showConnectionIssue()
                }
            }
        }
        else
        {
            if (event == ServiceEvent.GET_ALL_DISPLAY_MUSCLE_GROUPS)
            {
                showConnectionIssue()
            }
        }
            
        switch event
        {
            case ServiceEvent.NO_RETURN:
                
                getContinueExerciseRoutine()
                
                break
        
            case ServiceEvent.GET_ALL_DISPLAY_MUSCLE_GROUPS:
                
                getContinueExerciseRoutine()
                
                section = RoutineSection(routineType: RoutineType.FEATURED, title: RoutineViewController.FEATURED_ROUTINE_TITLE, routineGroups: rows)
                
                break
            
            case ServiceEvent.GET_LIST:
            
                section = RoutineSection(routineType: RoutineType.SAVED, title: RoutineViewController.SAVED_ROUTINE_TITLE, routineGroups: rows)
            
                break
            
            default:
                break
        }
            
        if (rows.count > 0)
        {
            switch section.routineType
            {
                case RoutineType.FEATURED:
                    
                    insertSection(RoutineType.FEATURED, routineSection: RoutineSection(routineType: RoutineType.FEATURED, title: RoutineViewController.FEATURED_ROUTINE_TITLE, routineGroups: rows), notifyChange: true)
                    
                    break
                    
                case RoutineType.SAVED:
                    
                    insertSection(RoutineType.SAVED, routineSection: RoutineSection(routineType: RoutineType.SAVED, title: RoutineViewController.SAVED_ROUTINE_TITLE, routineGroups: rows), notifyChange: true)
                    
                    break
                    
                default:
                    break
            }
        }
        
//            animateTable()
        tableView.reloadData()
        
        hideLoading()
    }
    
    /**
     * Returns the continue string.
     */
    func getContinueString() -> String
    {
        return savedExercises != nil ? String(format: CONTINUE_STRING, arguments: [savedExercises.routineName.uppercased()]) : Constant.RETURN_NULL
    }
    
    /**
     * Gets the routine from the database if they exist and if they haven't already been added to the list.
     */
    func getContinueExerciseRoutine()
    {
        // We get routine[0] because the saved routines are always added to the first element of the list.
        if (sections[0].title != getContinueString())
        {
            savedExercises = DBHelper().getRecords()
            
            if (savedExercises.routineName != "")
            {
                insertSection(RoutineType.CONTINUE, routineSection: RoutineSection(routineType: RoutineType.CONTINUE, title: String(format: CONTINUE_STRING, arguments: [ savedExercises.routineName.uppercased() ]), routineGroups: []), notifyChange: true)
            }
        }
    }

    /**
     * Animates the table being added to the screen.
     */
    func animateTable()
    {
        let range = 0..<self.tableView.numberOfSections
        let sections = IndexSet(integersIn: range)
            
        tableView.reloadSections(sections, with: .top)
    }
    
    // http://stackoverflow.com/questions/31870206/how-to-insert-new-cell-into-uitableview-in-swift
    @objc func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        return sections.count
    }
    
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    @objc func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        // Gets the row in the section.
        let routine = sections[(indexPath as NSIndexPath).section]
        let title = routine.title
        
        if (savedExercises != nil && title == getContinueString())
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.ROUTINE_CONTINUE_CELL) as! RoutineContinueCellController
            cell.selectionStyle = .none
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
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.ROUTINE_CELL) as! RoutineCellController
            cell.selectionStyle = .none
            cell.routineTitle.text = title
            cell.setDescription(totalIntencityRoutines)
            cell.setCard()
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
    {
        // This is so we know which routine section to remove from the routines array when we update the RoutineGroups
        selectedRoutineSection = (indexPath as NSIndexPath).section
        
        let routine = sections[selectedRoutineSection]
        let title = routine.title
        switch title
        {
            case getContinueString():
            
                viewDelegate.onLoadView(View.FITNESS_LOG_VIEW, result: CONTINUE_STRING, savedExercises: savedExercises, state: savedExercises.routineState)
                
                break
            case RoutineViewController.CUSTOM_ROUTINE_TITLE:
                
                viewDelegate.onLoadView(View.FITNESS_LOG_VIEW, result: "", savedExercises: nil, state: RoutineState.CUSTOM)
                
                break
            case RoutineViewController.FEATURED_ROUTINE_TITLE:
                
                let vc = storyboard!.instantiateViewController(withIdentifier: Constant.INTENCITY_ROUTINE_VIEW_CONTROLLER) as! IntencityRoutineViewController
                vc.viewDelegate = viewDelegate
                vc.intencityRoutineDelegate = self
                vc.routines = routine.routineGroups
                
                self.navigationController!.pushViewController(vc, animated: true)
                
                break
            case RoutineViewController.SAVED_ROUTINE_TITLE:
                
                let vc = storyboard!.instantiateViewController(withIdentifier: Constant.SAVED_ROUTINE_VIEW_CONTROLLER) as! SavedRoutineViewController
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
