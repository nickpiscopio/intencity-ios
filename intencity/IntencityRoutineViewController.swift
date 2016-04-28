//
//  MainViewController.swift
//  Intencity
//
//  The view controller for the default and custom Intencity routines.
//
//  Created by Nick Piscopio on 2/8/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class IntencityRoutineViewController: UIViewController, ServiceDelegate, ButtonDelegate, IntencityRoutineDelegate
{
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var connectionView: UIView!
    @IBOutlet weak var noConnectionLabel: UILabel!
    @IBOutlet weak var tryAgainButton: UIButton!
    
    @IBOutlet weak var routineTitle: UILabel!
    @IBOutlet weak var routineDescription: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var startButton: IntencityButtonRoundDark!
    
    let DEFAULT_ROUTINE_TITLE = NSLocalizedString("title_default_routines", comment: "")
    
    let NO_CUSTOM_ROUTINE_STRING = NSLocalizedString("no_custom_routines", comment: "")
    
    var intencityRoutineDelegate: IntencityRoutineDelegate?
    
    var viewDelegate: ViewDelegate!
    
    var routineFooter: RoutineCellFooterController!
    
    var email = ""

    var recommended = 0
    
    var savedExercises: SavedExercise!
    
    var exerciseData: ExerciseData!
    
    var routines = [RoutineRow]()
    var selectedRoutineSection: Int!
    var selectedRoutine: Int!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("title_intencity_routines", comment: "")
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.hidden = true
        
        initConnectionViews()
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: Dimention.TABLE_FOOTER_HEIGHT_NORMAL, emptyTableStringRes: "")

        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.GENERIC_HEADER_CELL, cellName: Constant.GENERIC_HEADER_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.CHECKBOX_CELL, cellName: Constant.CHECKBOX_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.NO_ITEM_CELL, cellName: Constant.NO_ITEM_CELL)
        
        email = Util.getEmailFromDefaults()
        
        routineTitle.text = NSLocalizedString("title_routine", comment: "")
        routineTitle.textColor = Color.secondary_light
        
        routineDescription.text = NSLocalizedString("intencity_routine_description", comment: "")
        routineDescription.textColor = Color.secondary_light
        
        initRoutines(false)
        
        let editButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: #selector(SavedRoutineViewController.editPressed(_:)))
        
        self.navigationItem.rightBarButtonItem = editButton
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /**
     * Calls the service to get the display muscle groups for the routine card.
     */
    func initRoutines(reset: Bool)
    {
        startButton.hidden = true
        
        // Creates the instance of the exercise data so we can store the exercises in the database later.
        exerciseData = ExerciseData.getInstance()
        
        if (reset)
        {
            routines.removeAll()
        }        
        
        if (routines.count > 0)
        {
            tableView.reloadData()
        }
        else
        {
            showLoading()
            
            _ = ServiceTask(event: ServiceEvent.GET_ALL_DISPLAY_MUSCLE_GROUPS, delegate: self,
                            serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                            params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_ALL_DISPLAY_MUSCLE_GROUPS, variables: [ email ]))
        }
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
        initRoutines(true)
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
                    viewDelegate.onLoadView(View.FITNESS_LOG_VIEW, result: result, savedExercises: nil, state: RoutineState.INTENCITY)
                    
                    goBack()
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
     * Loads the table views.
     *
     * @param result    The results to parse from the webservice.
     */
    func loadTableViewItems(result: String)
    {
        let json = result.parseJSONString!
        
        // This means we got results back from the web database.
        if (result != "" && result != Constant.RETURN_NULL)
        {
            do
            {
                routines.removeAll()
                routines = try IntencityRoutineDao().parseJson(json)
                
                intencityRoutineDelegate!.onRoutineUpdated(routines)
                
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
        
        tableView.reloadData()
        
        hideLoading()
    }
    
    @IBAction func startExercisingClicked(sender: AnyObject)
    {
        exerciseData.routineName = routines[selectedRoutineSection].rows[self.selectedRoutine]
            
        showLoading()
        
        let selectedRoutine = selectedRoutineSection > 0 ? routines[0].rows.count - 1 + selectedRoutineSection + self.selectedRoutine : self.selectedRoutine
            
        // We add 1 because the routines start at 1 on the server.
        _ = ServiceTask(event: ServiceEvent.SET_CURRENT_MUSCLE_GROUP, delegate: self,
                            serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                            params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_SET_CURRENT_MUSCLE_GROUP, variables: [ email, String(selectedRoutine + 1)]))
    }
    
    func onButtonClicked()
    {
        let vc = storyboard!.instantiateViewControllerWithIdentifier(Constant.CUSTOM_ROUTINE_VIEW_CONTROLLER) as! CustomRoutineViewController
        vc.delegate = self
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func onRoutineSaved()
    {
        initRoutines(true)
    }
    
    func onRoutineUpdated(routineRows: [RoutineRow]) { }

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
        let routine = routines[section]
        
        if (routine.rows.count > 0)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constant.GENERIC_HEADER_CELL) as! GenericHeaderCellController
            cell.title.text = routine.title
            
            return cell
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return routines[section].rows.count > 0 ? Constant.GENERIC_HEADER_HEIGHT : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        // Gets the row in the section.
        let title = routines[indexPath.section].rows[indexPath.row]
        if (title == NO_CUSTOM_ROUTINE_STRING)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constant.NO_ITEM_CELL) as! NoItemCellController
            cell.selectionStyle = .None
            cell.titleLabel.text = title
            cell.userInteractionEnabled = false
            
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constant.CHECKBOX_CELL) as! CheckboxCellController
            cell.setCheckboxImage(Constant.RADIO_BUTTON_MARKED, uncheckedImage: Constant.RADIO_BUTTON_UNMARKED)
            cell.selectionStyle = .None
            cell.titleLabel.text = title
            cell.setChecked(false)
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        selectedRoutineSection = indexPath.section
        selectedRoutine = indexPath.row

        let cell = tableView.cellForRowAtIndexPath(indexPath) as! CheckboxCellController
        cell.setChecked(true)
        
        startButton.hidden = false
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! CheckboxCellController
        cell.setChecked(false)
    }
    
    /**
     * Navigates the user back to the previous screen.
     */
    func goBack()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /**
     * The function for when the edit button is pressed.
     */
    func editPressed(sender:UIBarButtonItem)
    {
        let vc = storyboard!.instantiateViewControllerWithIdentifier(Constant.CUSTOM_ROUTINE_VIEW_CONTROLLER) as! CustomRoutineViewController
        vc.delegate = self
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
}