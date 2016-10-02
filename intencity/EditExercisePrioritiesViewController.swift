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
        self.tabBarController?.tabBar.isHidden = true
        
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
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_EXERCISE_PRIORITIES, variables: [ email ]) as NSString)
        
        let saveButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(EditExercisePrioritiesViewController.savePressed(_:)))
        
        self.navigationItem.rightBarButtonItem = saveButtonItem
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        let showTable = priorityList.count > 0

        tableView.backgroundView?.isHidden = showTable
        priorityTitleView.isHidden = !showTable
        stackSeparator.isHidden = !showTable
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return priorityList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let index = (indexPath as NSIndexPath).row
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.EXERCISE_PRIORITY_CELL) as! ExercisePriorityCellController
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.index = index
        cell.setListItem(exerciseNameList[index], priority: Int(priorityList[index])!)
        cell.delegate = self
        
        return cell
    }
    
    func onRetrievalSuccessful(_ event: Int, result: String)
    {
        switch(event)
        {
            case ServiceEvent.GET_LIST:
               
                if (result != Constant.RETURN_NULL)
                {
                    // This gets saved as NSDictionary, so there is no order
                    let json: [AnyObject] = result.parseJSONString as! [AnyObject]
                    
                    for exercise in json
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
    
    func onRetrievalFailed(_ event: Int)
    {
        hideLoading()
        
        Util.displayAlert(self, title: NSLocalizedString("generic_error", comment: ""),
            message: NSLocalizedString("intencity_communication_error", comment: ""),
            actions: [ UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: goBack)])
    }
    
    func onSetExercisePriority(_ index: Int, priority: Int)
    {
        priorityList[index] = String(priority)
    }
    
    /**
     * The function for when the save button is pressed.
     */
    func savePressed(_ sender:UIBarButtonItem)
    {
        showLoading()
        
        _ = ServiceTask(event: ServiceEvent.UPDATE_LIST,
                        delegate: self,
                        serviceURL: Constant.SERVICE_UPDATE_EXERCISE_PRIORITY,
                        params: Constant.generateExercisePriorityListVariables(email, exercises: exerciseNameList, priorities: priorityList) as NSString)
    }
    
    /**
     * Navigates the user back to the previous screen.
     */
    func goBack()
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    /**
     * The action for the ok button being clicked when there was a communication error.
     */
    func goBack(_ alertAction: UIAlertAction!) -> Void
    {
        goBack()
    }
    
    /**
     * Initializes the loading view.
     */
    func initLoadingView()
    {
        loadingView.backgroundColor = Color.page_background
        
        loadingView.isHidden = true
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = true
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
}
