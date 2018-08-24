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
    @IBOutlet weak var editEquipmentTitle: UILabel!
    @IBOutlet weak var editEquipmentDescription: UILabel!
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
        self.tabBarController?.tabBar.isHidden = true
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("edit_equipment", comment: "")
        
        editEquipmentTitle.text = NSLocalizedString("edit_equipment_title", comment: "")
        editEquipmentTitle.textColor = Color.secondary_light
        
        editEquipmentDescription.text = NSLocalizedString("edit_equipment_description", comment: "")
        editEquipmentDescription.textColor = Color.secondary_light
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: 0, emptyTableStringRes: "")
        
        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.CHECKBOX_CELL, cellName: Constant.CHECKBOX_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.DESCRIPTION_FOOTER_CELL, cellName: Constant.DESCRIPTION_FOOTER_CELL)
        
        initLoadingView()
        showLoading()
        
        email = Util.getEmailFromDefaults()
        
        UserDefaults.standard.set(true, forKey: Constant.USER_SET_EQUIPMENT)
        
        _ = ServiceTask(event: ServiceEvent.GET_LIST,
                        delegate: self,
                        serviceURL: Constant.SERVICE_EXECUTE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_EQUIPMENT, variables: [ email ]) as NSString)
        
        let saveButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(EditEquipmentViewController.savePressed(_:)))
        
        self.navigationItem.rightBarButtonItem = saveButtonItem
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return equipmentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let index = (indexPath as NSIndexPath).row
        
        let equipmentName = equipmentList[index]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.CHECKBOX_CELL) as! CheckboxCellController
        cell.setCheckboxImage(Constant.CHECKBOX_CHECKED, uncheckedImage: Constant.CHECKBOX_UNCHECKED)
        cell.setListItem(equipmentName, checked: userEquipmentList.contains(equipmentName))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
    {
        let index = (indexPath as NSIndexPath).row
        
        let equipmentName = equipmentList[index]
        
        onCheckboxChecked(equipmentName)
        
        let cell = tableView.cellForRow(at: indexPath) as! CheckboxCellController
        cell.setChecked(!cell.isChecked())
        
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
                
                for equipment in json
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
    @objc func savePressed(_ sender:UIBarButtonItem)
    {
        showLoading()
        
        _ = ServiceTask(event: ServiceEvent.UPDATE_LIST, delegate: self,
                        serviceURL: Constant.SERVICE_UPDATE_EQUIPMENT,
                        params: Constant.generateServiceListVariables(email, variables: userEquipmentList, isInserting: true) as NSString)
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
    
    func onCheckboxChecked(_ name: String)
    {
        // Add or remove equipment from the user's list of equipment
        // if he or she clicks on a list item.
        if (userEquipmentList.contains(name))
        {
            userEquipmentList.remove(at: userEquipmentList.index(of: name)!)
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
