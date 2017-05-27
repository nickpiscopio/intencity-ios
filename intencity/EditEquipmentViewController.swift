//
//  EditEquipmentViewController.swift
//  Intencity
//
//  The view controller for the edit equipment screen.
//
//  Created by Nick Piscopio on 2/23/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class EditEquipmentViewController: UIViewController, ServiceDelegate, GeocodeDelegate
{
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationViewTitle: UILabel!
    @IBOutlet weak var locationViewAddress: UILabel!
    
    var equipmentList = [String]()
    var userEquipmentList = [String]()
    
    var ADJUSTED_INDEX = 1
    
    var email = ""
    
    let geocode = GoogleGeocode()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        geocode.delegate = self
        
        geocode.getLocation()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.isHidden = true
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("edit_equipment", comment: "")
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: 0, emptyTableStringRes: "")
        
        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.CHECKBOX_CELL, cellName: Constant.CHECKBOX_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.DESCRIPTION_FOOTER_CELL, cellName: Constant.DESCRIPTION_FOOTER_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.GENERIC_DESCRIPTION_CELL, cellName: Constant.GENERIC_DESCRIPTION_CELL)
        
        initLocationView()
        initLoadingView()
        showLoading()
        
        email = Util.getEmailFromDefaults()
        
        UserDefaults.standard.set(true, forKey: Constant.USER_SET_EQUIPMENT)
        
        _ = ServiceTask(event: ServiceEvent.GET_LIST,
                        delegate: self,
                        serviceURL: Constant.SERVICE_STORED_PROCEDURE,
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
        // +1 Added to account for the GenericDescriptionCell at indoex 0.
        return equipmentList.count + ADJUSTED_INDEX
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let index = (indexPath as NSIndexPath).row
        
        if index == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.GENERIC_DESCRIPTION_CELL) as! GenericDescriptionCellController
            cell.cellHeader.text = NSLocalizedString("edit_equipment_title", comment: "")
            cell.cellDescription.text = NSLocalizedString("edit_equipment_description", comment: "")
            
            return cell
            
        } else {
            
            let equipmentName = equipmentList[index - ADJUSTED_INDEX]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.CHECKBOX_CELL) as! CheckboxCellController
            cell.setCheckboxImage(Constant.CHECKBOX_CHECKED, uncheckedImage: Constant.CHECKBOX_UNCHECKED)
            cell.setListItem(equipmentName, checked: userEquipmentList.contains(equipmentName))
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
    {
        let index = (indexPath as NSIndexPath).row
        
        // We ignore index 0 because it is a description cell.
        if index > 0 {
            let equipmentName = equipmentList[index - ADJUSTED_INDEX]
            
            onCheckboxChecked(equipmentName)
            
            let cell = tableView.cellForRow(at: indexPath) as! CheckboxCellController
            cell.setChecked(!cell.isChecked())
            
            // Deselects the row.
            tableView.deselectRow(at: indexPath, animated: false)
        }
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
    func savePressed(_ sender:UIBarButtonItem)
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
    
    /**
     * Opens the location settings of the phone. This is presented as a UIAlert
     * action to user's that previously denied location access.
     */
    func openLocationSettings(_ alertAction: UIAlertAction!) -> Void
    {
        UIApplication.shared.openURL(URL(string:Constant.ROOT_LOCATION_SERVICES)!)
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
    
    /**
     * Initializes the location view
     */
    func initLocationView()
    {
        locationView.backgroundColor = Color.page_background
        
        locationViewTitle.attributedText = Util.getMutableString("Fitness Location", fontSize: 14, color: Color.secondary_light, isBold: true)
        
        locationViewAddress.attributedText = Util.getMutableString("(Fitness Location Need)", fontSize: 16, color: Color.material_red, isItalic: true)
    }
    
    /**
     *  This is a delegate function that executes when an address is successfully retrieved. It sets
     *  the retrieved string in the fitness location.
     */
    func onLocationSuccess(address: String)
    {
        locationViewAddress.attributedText = Util.getMutableString(address, fontSize: 16, color: Color.material_red, isItalic: true)
    }
    
    /**
     *  This is a delegate function that executes when there was a problem retrieving the users location.
     */
    func onLocationFailure(errorCode: Int)
    {
        
        let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: ""),
                                   style: .cancel,
                                   handler: goBack)
        
        let settings = UIAlertAction(title: NSLocalizedString("open_settings", comment: ""),
                                     style: .default,
                                     handler: openLocationSettings)
        
        switch errorCode {
        case GoogleGeocode.GEO_AUTH_DENIED:
            
            Util.displayAlert(  self,
                                title: NSLocalizedString("location_settings_error_title", comment: ""),
                                message: NSLocalizedString("location_settings_error_description", comment: ""),
                                actions: [cancel, settings])
            
            break
        case GoogleGeocode.GEO_GENERAL_FAILURE:
            
            break
        default:
            break
        }
    }
    
}
