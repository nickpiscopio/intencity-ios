//
//  EditExercisePrioritiesViewController.swift
//  Intencity
//
//  The view controller for the edit hidden exercises screen.
//
//  Created by Nick Piscopio on 2/23/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class EditExercisePrioritiesViewController: UIViewController, ServiceDelegate, ExercisePriorityDelegate
{
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var priorityTitleView: UIView!
    @IBOutlet weak var priorityTitle: UILabel!
    @IBOutlet weak var priorityDescription: UILabel!
    @IBOutlet weak var stackSeparator: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var exerciseNameList = [String]()
    var priorityList = [String]()
    
    var email = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.hidden = true
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("edit_priority", comment: "")
        
        priorityTitle.text = NSLocalizedString("edit_priority_title", comment: "")
        priorityTitle.textColor = Color.secondary_light
        
        priorityDescription.text = NSLocalizedString("edit_priority_description", comment: "")
        priorityDescription.textColor = Color.secondary_light
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: 0, emptyTableStringRes: "no_priorities")
        
        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.EXERCISE_PRIORITY_CELL, cellName: Constant.EXERCISE_PRIORITY_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.DESCRIPTION_FOOTER_CELL, cellName: Constant.DESCRIPTION_FOOTER_CELL)
        
        initLoadingView()
        showLoading()
        
        email = Util.getEmailFromDefaults()
        
        _ = ServiceTask(event: ServiceEvent.GET_LIST,
                        delegate: self,
                        serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_EXERCISE_PRIORITIES, variables: [ email ]))
        
        let saveButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(EditExercisePrioritiesViewController.savePressed(_:)))
        
        self.navigationItem.rightBarButtonItem = saveButtonItem
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        let showTable = priorityList.count > 0

        tableView.backgroundView?.hidden = showTable
        priorityTitleView.hidden = !showTable
        stackSeparator.hidden = !showTable
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return priorityList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.EXERCISE_PRIORITY_CELL) as! ExercisePriorityCellController
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.index = index
        cell.setListItem(exerciseNameList[index], priority: Int(priorityList[index])!)
        cell.delegate = self
        
        return cell
    }
    
    func onRetrievalSuccessful(event: Int, result: String)
    {
        switch(event)
        {
            case ServiceEvent.GET_LIST:
               
                if (result != Constant.RETURN_NULL)
                {
                    // This gets saved as NSDictionary, so there is no order
                    let json: AnyObject? = result.parseJSONString
                    
                    for exercise in json as! NSArray
                    {
                        let exerciseName = exercise[Constant.COLUMN_EXERCISE_NAME] as! String
                        let priority = exercise[Constant.COLUMN_PRIORITY] as! String
                        
                        exerciseNameList.append(exerciseName)
                        priorityList.append(priority)
                    }
                    
                    tableView.reloadData()
                }

                break
            case ServiceEvent.UPDATE_LIST:
                
                goBack()
                
                break
            default:
                break
        }
        
        hideLoading()
    }
    
    func onRetrievalFailed(event: Int)
    {
        hideLoading()
        
        Util.displayAlert(self, title: NSLocalizedString("generic_error", comment: ""),
            message: NSLocalizedString("intencity_communication_error", comment: ""),
            actions: [ UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .Default, handler: goBack)])
    }
    
    func onSetExercisePriority(index: Int, priority: Int)
    {
        priorityList[index] = String(priority)
    }
    
    /**
     * The function for when the save button is pressed.
     */
    func savePressed(sender:UIBarButtonItem)
    {
        _ = ServiceTask(event: ServiceEvent.UPDATE_LIST,
                        delegate: self,
                        serviceURL: Constant.SERVICE_UPDATE_EXERCISE_PRIORITY,
                        params: Constant.generateExercisePriorityListVariables(email, exercises: exerciseNameList, priorities: priorityList))
    }
    
    /**
     * Navigates the user back to the previous screen.
     */
    func goBack()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /**
     * The action for the ok button being clicked when there was a communication error.
     */
    func goBack(alertAction: UIAlertAction!) -> Void
    {
        goBack()
    }
    
    /**
     * Initializes the loading view.
     */
    func initLoadingView()
    {
        loadingView.backgroundColor = Color.page_background
        
        loadingView.hidden = true
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.hidden = true
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
}