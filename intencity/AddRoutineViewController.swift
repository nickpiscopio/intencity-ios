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
    
    var delegate: IntencityRoutineDelegate?
    
    var muscleGroups = [String]()
    
    var routines = [String]()
    
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
        
        setSaveButtonVisibility()
        
        _ = ServiceTask(event: ServiceEvent.GET_LIST, delegate: self,
                                serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                                params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_CUSTOM_ROUTINE_MUSCLE_GROUP, variables: [] ) as NSString)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /**
     * Sets the save button visibility.
     */
    func setSaveButtonVisibility()
    {
        if (routines.count > 0)
        {
            let saveButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(CustomRoutineViewController.savePressed(_:)))
            
            self.navigationItem.rightBarButtonItem = saveButtonItem
        }
        else
        {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return muscleGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let index = (indexPath as NSIndexPath).row
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.CHECKBOX_CELL) as! CheckboxCellController
        cell.titleLabel.text = muscleGroups[index]
        cell.setCheckboxImage(Constant.CHECKBOX_CHECKED, uncheckedImage: Constant.CHECKBOX_UNCHECKED)
        cell.setChecked(false)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
    {
        let index = (indexPath as NSIndexPath).row
        
        let muscleGroup = muscleGroups[index]
        
        onCheckboxChecked(muscleGroup)
        
        let cell = tableView.cellForRow(at: indexPath) as! CheckboxCellController
        cell.setChecked(!cell.isChecked())
        
        setSaveButtonVisibility()
        
        // Deselects the row.
        tableView.deselectRow(at: indexPath, animated: false)
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
                
                for retrievedMuscleGroups in json
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
    
    func onRetrievalFailed(_ event: Int)
    {
        hideLoading()
        
        Util.displayAlert(self, title: NSLocalizedString("generic_error", comment: ""),
            message: NSLocalizedString("intencity_communication_error", comment: ""),
            actions: [ UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: goBack)])
    }
    
    /**
     * The function for when the save button is pressed.
     */
    func savePressed(_ sender:UIBarButtonItem)
    {
        showLoading()
        
        routines = routines.sorted()

        // Save the routine
        _ = ServiceTask(event: ServiceEvent.UPDATE_LIST, delegate: self,
                        serviceURL: Constant.SERVICE_SET_USER_MUSCLE_GROUP_ROUTINE,
                        params: Constant.generateServiceListVariables(email, variables: routines, isInserting: true) as NSString)
    }
    
    /**
     * Navigates the user back to the previous screen.
     */
    func goBack()
    {
        delegate!.onRoutineSaved(true)
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    /**
     * The action for the ok button being clicked when there was a communication error.
     */
    func goBack(_ alertAction: UIAlertAction!) -> Void
    {
        goBack()
    }
    
    func onCheckboxChecked(_ name: String)
    {
        // Add or remove equipment from the user's list of equipment
        // if he or she clicks on a list item.
        if (routines.contains(name))
        {
            routines.remove(at: routines.index(of: name)!)
        }
        else
        {
            routines.append(name)
        }
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
