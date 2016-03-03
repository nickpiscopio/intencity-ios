//
//  EditHiddenExercisesViewController.swift
//  Intencity
//
//  The view controller for the edit hidden exercises screen.
//
//  Created by Nick Piscopio on 2/23/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class EditExclusionViewController: UIViewController, ServiceDelegate, MenuExerciseDelegate
{
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var exclusionList = [String]()
    var newExclusionList = [String]()
    
    var email = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.hidden = true
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("edit_exclusion", comment: "")
        
        // Initialize the tableview.
        Util.initTableView(tableView, removeSeparators: true, addFooter: false)
        
        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.MENU_EXERCISE_CELL, cellName: Constant.MENU_EXERCISE_CELL)
        
        initLoadingView()
        showLoading()
        
        email = Util.getEmailFromDefaults()
        
        ServiceTask(event: ServiceEvent.GET_EXCLUSION_LIST,
                    delegate: self,
                    serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                    params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_EXCLUSION,
                                variables: [ email ]))
        
        // The save button.
        let saveButton: UIButton = UIButton(type: UIButtonType.Custom) as UIButton
        saveButton.addTarget(self, action: "savePressed:", forControlEvents: UIControlEvents.TouchUpInside)
        saveButton.setTitle(NSLocalizedString("save", comment: ""), forState: UIControlState.Normal)
        saveButton.setTitleColor(Color.white, forState: UIControlState.Normal)
        saveButton.sizeToFit()
        let saveButtonItem:UIBarButtonItem = UIBarButtonItem(customView: saveButton)
        self.navigationItem.rightBarButtonItem  = saveButtonItem
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        if (exclusionList.count <= 0)
        {
            let emptyTableLabel = UILabel(frame: CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height))
            emptyTableLabel.text = NSLocalizedString("no_items", comment: "")
            emptyTableLabel.textColor = Color.secondary_light
            emptyTableLabel.font = emptyTableLabel.font.fontWithSize(Dimention.FONT_SIZE_NORMAL)
            emptyTableLabel.textAlignment = .Center
            emptyTableLabel.sizeToFit()
            
            tableView.backgroundView = emptyTableLabel
            
            return 0
        }
        else
        {
            tableView.backgroundView = nil
            
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return exclusionList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.MENU_EXERCISE_CELL) as! MenuExerciseCellController
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.setName(exclusionList[index])
        cell.delegate = self
        return cell
    }
    
    func onRetrievalSuccessful(event: Int, result: String)
    {
        switch(event)
        {
            case ServiceEvent.GET_EXCLUSION_LIST:
               
                if (result != Constant.RETURN_NULL)
                {
                    // This gets saved as NSDictionary, so there is no order
                    let json: AnyObject? = result.parseJSONString
                    
                    for exercise in json as! NSArray
                    {
                        let exerciseName = exercise[Constant.COLUMN_EXCLUSION_NAME] as! String
                        
                        exclusionList.append(exerciseName)
                    }
                    
                    newExclusionList = exclusionList
                    
                    tableView.backgroundView = nil
                    
                    tableView.reloadData();
                }

                break
            case ServiceEvent.SAVE_EXCLUSION_LIST:
                
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
        ServiceTask(event: ServiceEvent.SAVE_EXCLUSION_LIST,
            delegate: self,
            serviceURL: Constant.SERVICE_UPDATE_EXCLUSION,
            params: Constant.generateListVariables(email, variables: newExclusionList))
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
    
    func onExerciseCheckboxChecked(exerciseName: String)
    {
        // Add or remove equipment from the user's list of equipment
        // if he or she clicks on a list item.
        if (newExclusionList.contains(exerciseName))
        {
            newExclusionList.removeAtIndex(newExclusionList.indexOf(exerciseName)!)
        }
        else
        {
            newExclusionList.append(exerciseName);
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