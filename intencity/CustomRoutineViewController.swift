//
//  CustomRoutineViewController.swift
//  Intencity
//
//  The view controller for editing custom routines.
//
//  Created by Nick Piscopio on 4/15/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class CustomRoutineViewController: UIViewController, ServiceDelegate
{
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var descriptionLabel1: UILabel!
    @IBOutlet weak var descriptionLabel2: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var email = ""
    
    var routines = [String]()
    var routinesToRemove = [String]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.hidden = true
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("edit_routines_title", comment: "")
        
        descriptionLabel1.text = NSLocalizedString("edit_routines_description1", comment: "")
        descriptionLabel2.text = NSLocalizedString("edit_routines_description2", comment: "")
        
        descriptionLabel1.textColor = Color.secondary_light
        descriptionLabel2.textColor = Color.secondary_light
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: 0, emptyTableStringRes: "")

        // Load the cells we are going to use in the tableview.
        Util.initTableView(tableView, footerHeight: 0, emptyTableStringRes: "no_custom_routines")
        Util.addUITableViewCell(tableView, nibNamed: Constant.CHECKBOX_CELL, cellName: Constant.CHECKBOX_CELL)
        
        initLoadingView()
        
        email = Util.getEmailFromDefaults()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        routines.removeAll()
        routinesToRemove.removeAll()
        
        showLoading()
        
        _ = ServiceTask(event: ServiceEvent.GET_LIST, delegate: self,
                        serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_USER_MUSCLE_GROUP_ROUTINE, variables: [ email ]))
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        if (routines.count > 0)
        {
            descriptionView.hidden = false
            tableView.backgroundView?.hidden = true
            
            let saveButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(CustomRoutineViewController.savePressed(_:)))
            
            self.navigationItem.rightBarButtonItem = saveButtonItem
        }
        else
        {
            descriptionView.hidden = true
            tableView.backgroundView?.hidden = false
        }
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return routines.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
        
        let routineName = routines[index]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.CHECKBOX_CELL) as! CheckboxCellController
        cell.setListItem(routineName, checked: true)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let index = indexPath.row
        
        let routineName = routines[index]
        
        onCheckboxChecked(routineName)
        
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
                
                for routines in json as! NSArray
                {
                    let routine = routines[Constant.COLUMN_DISPLAY_NAME] as! String
                
                    self.routines.append(routine)
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
        if (routinesToRemove.count > 0)
        {
            showLoading()
            
            _ = ServiceTask(event: ServiceEvent.UPDATE_LIST, delegate: self,
                            serviceURL: Constant.SERVICE_UPDATE_USER_MUSCLE_GROUP_ROUTINE,
                            params: Constant.generateServiceListVariables(email, variables: routinesToRemove, isInserting: false))

        }
        else
        {
            goBack()
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
    
    /**
     * Edits a list of items that is going to be sent to the server.
     */
    func onCheckboxChecked(name: String)
    {
        // Add or remove equipment from the user's routine list
        // if he or she clicks on a list item.
        if (routinesToRemove.contains(name))
        {
            routinesToRemove.removeAtIndex(routinesToRemove.indexOf(name)!)
        }
        else
        {
            routinesToRemove.append(name);
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