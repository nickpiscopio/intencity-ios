//
//  AddRoutineViewController.swift
//  Intencity
//
//  The view controller for adding a custom routine.
//
//  Created by Nick Piscopio on 4/16/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class AddRoutineViewController: UIViewController, ServiceDelegate
{
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addRoutineDescription: UILabel!
    
    var muscleGroups = [String]()
    
    var routine = [String]()
    
    var email = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        addRoutineDescription.text = NSLocalizedString("add_routines_description", comment: "")
        addRoutineDescription.textColor = Color.secondary_light
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("add_routines_title", comment: "")
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: 0, emptyTableStringRes: "")

        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.CHECKBOX_CELL, cellName: Constant.CHECKBOX_CELL)
        
        initLoadingView()
        showLoading()
        
        email = Util.getEmailFromDefaults()
        
        _ = ServiceTask(event: ServiceEvent.GET_LIST, delegate: self,
                                serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                                params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_CUSTOM_ROUTINE_MUSCLE_GROUP, variables: [] ))
        
        let saveButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(CustomRoutineViewController.savePressed(_:)))
        
        self.navigationItem.rightBarButtonItem = saveButtonItem
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return muscleGroups.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.CHECKBOX_CELL) as! CheckboxCellController
        cell.titleLabel.text = muscleGroups[index]
        cell.setChecked(false)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let index = indexPath.row
        
        let muscleGroup = muscleGroups[index]
        
        onCheckboxChecked(muscleGroup)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! CheckboxCellController
        cell.setChecked(!cell.isChecked())
        
        // Deselects the row.
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
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
                
                for retrievedMuscleGroups in json as! NSArray
                {
                    let muscleGroup = retrievedMuscleGroups[Constant.COLUMN_DISPLAY_NAME] as! String
                    muscleGroups.append(muscleGroup)
                }
                
                tableView.reloadData();
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
    
    /**
     * The function for when the save button is pressed.
     */
    func savePressed(sender:UIBarButtonItem)
    {
        let count = routine.count
        if (count > 2)
        {
            Util.displayAlert(self,
                              title: NSLocalizedString("muscle_group_limit_title", comment: ""),
                              message: NSLocalizedString("muscle_group_limit_description", comment: ""),
                              actions: [ UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .Default, handler: nil) ])

        }
        else if (count < 1)
        {
            Util.displayAlert(self,
                              title: NSLocalizedString("muscle_group_limit_title", comment: ""),
                              message: NSLocalizedString("add_routines_description", comment: ""),
                              actions: [ UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .Default, handler: nil) ])
        }
        else
        {
            showLoading()
            //Save the routine
            _ = ServiceTask(event: ServiceEvent.UPDATE_LIST, delegate: self,
                            serviceURL: Constant.SERVICE_SET_USER_MUSCLE_GROUP_ROUTINE,
                            params: Constant.generateServiceListVariables(email, variables: routine, isInserting: true))
        }
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
    
    func onCheckboxChecked(name: String)
    {
        // Add or remove equipment from the user's list of equipment
        // if he or she clicks on a list item.
        if (routine.contains(name))
        {
            routine.removeAtIndex(routine.indexOf(name)!)
        }
        else
        {
            routine.append(name)
        }
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