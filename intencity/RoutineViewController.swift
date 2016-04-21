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

class RoutineViewController: UIViewController, ServiceDelegate, RoutineDelegate
{
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var connectionView: UIView!
    @IBOutlet weak var noConnectionLabel: UILabel!
    @IBOutlet weak var tryAgainButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    let CONTINUE_STRING = NSLocalizedString("routine_continue", comment: "")

    let DEFAULTS = NSUserDefaults.standardUserDefaults()
    
    weak var viewDelegate: ViewDelegate!
    
    var routineFooter: RoutineCellFooterController!
    
    var routineCellController: RoutineCellController!
    
    var email = ""
    
    var displayMuscleGroups = [String]()
    var recommended = 0
    var numberOfCells = 0
    
    var savedExercises: SavedExercise!
    
    var exerciseData: ExerciseData!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        email = Util.getEmailFromDefaults()
        
        initConnectionViews()
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: Dimention.TABLE_FOOTER_HEIGHT_NORMAL, emptyTableStringRes: "")

        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: "RoutineCard", cellName: Constant.ROUTINE_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.ROUTINE_CELL_FOOTER, cellName: Constant.ROUTINE_CELL_FOOTER)
        
        showWelcome()
        
        email = Util.getEmailFromDefaults()
        
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
        
        tableView.reloadData()
        
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
                    
//                loadTableViewItems(result)
                
                // LOAD FITNESS LOG                
                viewDelegate.onLoadView(View.FITNESS_LOG_VIEW, result: result)
                
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
        
        let indexToLoad = 1

        displayMuscleGroups.removeAll()
            
        var recommended: String?
            
        if (json != nil)
        {
            for muscleGroups in json as! NSArray
            {
                let muscleGroup = muscleGroups[Constant.COLUMN_DISPLAY_NAME] as! String
                recommended = muscleGroups[Constant.COLUMN_CURRENT_MUSCLE_GROUP] as? String
                    
                displayMuscleGroups.append(muscleGroup)
            }
                
            hideConnectionIssue()
        }
            
        // Get the saved exercises from the local database.
        savedExercises = DBHelper().getRecords()
            
        if (savedExercises.routineName != "")
        {
            displayMuscleGroups.append(CONTINUE_STRING)
                
            self.recommended = displayMuscleGroups.count - 1
        }
        else if (json != nil)
        {
            self.recommended = (recommended == nil || recommended! == "") ? 0 : displayMuscleGroups.indexOf(recommended!)!
        }
            
        if (displayMuscleGroups.count > 0)
        {
            animateTable(indexToLoad)
        }
        else
        {
            initRoutineCard()
        }
            
        hideLoading()
    }
    
    /**
     * The callback for when the user selects to start exercising.
     */
    func onStartExercising(routine: Int)
    {
        let routineName = displayMuscleGroups[routine - 1]
        
        if (routineName == CONTINUE_STRING)
        {
            exerciseData.routineName = savedExercises.routineName
            
            // LOAD FITNESS LOG
            viewDelegate.onLoadView(View.FITNESS_LOG_VIEW, result:CONTINUE_STRING)
        }
        else
        {
            exerciseData.routineName = routineName
            
            showLoading()
            
            _ = ServiceTask(event: ServiceEvent.SET_CURRENT_MUSCLE_GROUP, delegate: self,
                            serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                            params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_SET_CURRENT_MUSCLE_GROUP, variables: [ email, String(routine) ]))
        }
    }
    
    
       /**
     * Animates the table being added to the screen.
     *
     * @param loadNextExercise  A boolean value of whether to load the next exercise or not.
     */
    func animateTable(indexToLoad: Int)
    {
        numberOfCells = 1
        
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesInRange: range)
            
        tableView.reloadSections(sections, withRowAnimation: .Top)
    }
    
    // http://stackoverflow.com/questions/31870206/how-to-insert-new-cell-into-uitableview-in-swift
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return numberOfCells
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
//        let exerciseListHeader = tableView.dequeueReusableCellWithIdentifier(Constant.EXERCISE_LIST_HEADER) as! ExerciseListHeaderController
//        exerciseListHeader.routineNameLabel.text = exerciseData.routineName
//        exerciseListHeader.navigationController = self.navigationController
//        exerciseListHeader.saveDelegate = self
//        return exerciseListHeader.contentView
    
        return nil       
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
//        let routineFooter = tableView.dequeueReusableCellWithIdentifier(Constant.ROUTINE_CELL_FOOTER) as! RoutineCellFooterController
//        routineFooter.navigationController = self.navigationController
//        
//        return routineFooter != nil ? routineFooter.contentView : nil
        return nil
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 65
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let routineCellController = tableView.dequeueReusableCellWithIdentifier(Constant.ROUTINE_CELL) as! RoutineCellController
        routineCellController.selectionStyle = UITableViewCellSelectionStyle.None
        routineCellController.delegate = self
        routineCellController.dataSource = displayMuscleGroups
        // Need to add 1 to the routine so we get back the correct value when setting the muscle group for today.
        // CompletedMuscleGroup starts at 1.
        routineCellController.selectedRoutineNumber = recommended + 1
        routineCellController.setDropDownDataSource(recommended)
        routineCellController.setDropDownWidth(displayMuscleGroups.contains(CONTINUE_STRING))
        return routineCellController
    }
}