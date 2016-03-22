//
//  EditEquipmentViewController.swift
//  Intencity
//
//  The view controller for the edit equipment screen.
//
//  Created by Nick Piscopio on 2/23/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class EditEquipmentViewController: UIViewController, ServiceDelegate
{
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var equipmentList = [String]()
    var userEquipmentList = [String]()
    
    var email = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.hidden = true
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("edit_equipment", comment: "")
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: 0, emptyTableStringRes: "")
        
        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.MENU_EXERCISE_CELL, cellName: Constant.MENU_EXERCISE_CELL)        
        Util.addUITableViewCell(tableView, nibNamed: Constant.DESCRIPTION_FOOTER_CELL, cellName: Constant.DESCRIPTION_FOOTER_CELL)
        
        initLoadingView()
        showLoading()
        
        email = Util.getEmailFromDefaults()
        
        _ = ServiceTask(event: ServiceEvent.GET_LIST,
                        delegate: self,
                        serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_EQUIPMENT, variables: [ email ]))
        
        let saveButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(EditEquipmentViewController.savePressed(_:)))
        
        self.navigationItem.rightBarButtonItem = saveButtonItem
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return equipmentList.count
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let footer = tableView.dequeueReusableCellWithIdentifier(Constant.DESCRIPTION_FOOTER_CELL) as! DescriptionFooterCellController
        footer.title.text = NSLocalizedString("edit_equipment_description", comment: "")
        
        return footer
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return Constant.FOOTER_DESCRIPTION_HEIGHT
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
        
        let equipmentName = equipmentList[index]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.MENU_EXERCISE_CELL) as! MenuExerciseCellController
        cell.setListItem(equipmentName, checked: userEquipmentList.contains(equipmentName))
        cell.separator.hidden = index == equipmentList.count - 1
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let index = indexPath.row
        
        let equipmentName = equipmentList[index]
        
        onCheckboxChecked(equipmentName)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! MenuExerciseCellController
        cell.setChecked(!cell.isExerciseHidden())
        
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
                
                for equipment in json as! NSArray
                {
                    var userHasEquipment = false
                    
                    let equipmentName = equipment[Constant.COLUMN_EQUIPMENT_NAME] as! String
                    
                    // Might not have a FollowingId
                    if let _ = equipment[Constant.COLUMN_HAS_EQUIPMENT] as? String
                    {
                        userHasEquipment = true
                    }
                    else
                    {
                        userHasEquipment = false
                    }
                    
                    equipmentList.append(equipmentName)
                    
                    if (userHasEquipment)
                    {
                        userEquipmentList.append(equipmentName)
                    }
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
        _ = ServiceTask(event: ServiceEvent.UPDATE_LIST, delegate: self,
                        serviceURL: Constant.SERVICE_UPDATE_EQUIPMENT,
                        params: Constant.generateEquipmentListVariables(email, variables: userEquipmentList))
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
        if (userEquipmentList.contains(name))
        {
            userEquipmentList.removeAtIndex(userEquipmentList.indexOf(name)!)
        }
        else
        {
            userEquipmentList.append(name);
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