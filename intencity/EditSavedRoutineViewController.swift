//
//  EditUserRoutineViewController.swift
//  Intencity
//
//  The view controller for editing a user's saved routines.
//
//  Created by Nick Piscopio on 4/15/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class EditSavedRoutineViewController: UIViewController, ServiceDelegate
{
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var descriptionLabel1: UILabel!
    @IBOutlet weak var descriptionLabel2: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: IntencityRoutineDelegate?
    
    var email = ""
    
    var routines = [RoutineRow]()
    var routinesToRemove = [String]()
    
    var saveButtonPressed = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("edit_saved_title", comment: "")
        
        descriptionLabel1.text = NSLocalizedString("edit_saved_description", comment: "")
        descriptionLabel2.text = NSLocalizedString("edit_routines_description2", comment: "")
        
        descriptionLabel1.textColor = Color.secondary_light
        descriptionLabel2.textColor = Color.secondary_light
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: 0, emptyTableStringRes: "")

        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.CHECKBOX_CELL, cellName: Constant.CHECKBOX_CELL)
        
        email = Util.getEmailFromDefaults()
        
        initLoadingView()
        
        setSaveButtonVisibility()
    }
    
    override func viewWillDisappear(_ animated : Bool)
    {
        if (self.isMovingFromParentViewController && saveButtonPressed)
        {
            delegate!.onRoutineSaved(routinesToRemove.count != routines.count)
        }
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
        if (routinesToRemove.count > 0)
        {
            let saveButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(CustomRoutineViewController.savePressed(_:)))
            
            self.navigationItem.rightBarButtonItem = saveButtonItem
        }
        else
        {
            self.navigationItem.rightBarButtonItem = nil
        }
    }

    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return routines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let index = (indexPath as NSIndexPath).row
        
        let routineName = routines[index].title
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.CHECKBOX_CELL) as! CheckboxCellController
        cell.setCheckboxImage(Constant.CHECKBOX_CHECKED, uncheckedImage: Constant.CHECKBOX_UNCHECKED)
        cell.setListItem(routineName, checked: true)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
    {
        let index = (indexPath as NSIndexPath).row
        
        let routineName = routines[index].title
        
        onCheckboxChecked(routineName)
        
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
    func savePressed(_ sender: UIBarButtonItem)
    {
        saveButtonPressed = true

        showLoading()
            
        _ = ServiceTask(event: ServiceEvent.UPDATE_LIST, delegate: self,
                        serviceURL: Constant.SERVICE_UPDATE_USER_ROUTINE,
                        params: Constant.generateServiceListVariables(email, variables: routinesToRemove, isInserting: false) as NSString)
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
     * Edits a list of items that is going to be sent to the server.
     */
    func onCheckboxChecked(_ name: String)
    {
        // Add or remove equipment from the user's routine list
        // if he or she clicks on a list item.
        if (routinesToRemove.contains(name))
        {
            routinesToRemove.remove(at: routinesToRemove.index(of: name)!)
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
        
        loadingView.isHidden = true
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = true
    }

    /**
     * Shows the task is in pro@objc @objc gress.
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
