//
//  EditLocationViewController.swift
//  Intencity
//
//  Created by Greg Dalfonso on 4/8/17.
//  Copyright © 2017 Nick Piscopio. All rights reserved.
//

import Foundation
import UIKit

class EditLocationViewController: UIViewController, ServiceDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var savedLocations = [Location]()
    
    @IBOutlet var loadingView: UIView!
    @IBOutlet var titleView: UIView!
    @IBOutlet var locationsTitle: UILabel!
    @IBOutlet var locationsDescription: UILabel!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLoadingView()
        
        initTitleView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.reloadData()
        
        loadSavedLocations()
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: Dimention.TABLE_FOOTER_HEIGHT_NORMAL, emptyTableStringRes: "")
        
        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: "GenericCell", cellName: Constant.GENERIC_CELL)
        
    }
    
    /** 
        The edit equipment view controller is presented when the add button is pressed
    */
    @IBAction func addPressed(_ sender: Any) {
        let vc = storyboard!.instantiateViewController(withIdentifier: Constant.EDIT_EQUIPMENT_VIEW_CONTROLLER) as! EditEquipmentViewController
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    /**
        This loads the saved locations from the database and executes onRetrievalSuccessful or onRetriavalFailed when complete.
    */
    func loadSavedLocations() {
        
        showLoading()
        
        // We have a generic service event because we do not have to handle multiple events in this view.
        _ = ServiceTask(event: ServiceEvent.GENERIC,
                        delegate: self,
                        serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_FITNESS_LOCATIONS, variables: [ "greg.dalfonso@gmail.com" ]) as NSString)
    }
    
    /**
        When saved locations are returned successsfully we store a dictionary of each
        name and location in savedLocations.
    */
    func onRetrievalSuccessful(_ event: Int, result: String) {
        
        hideLoading()
        
        // This gets saved as NSDictionary, so there is no order
        let json: [AnyObject] = result.parseJSONString as! [AnyObject]
        
        for retrievedLocations in json
        {
            let name = retrievedLocations[Constant.COLUMN_DISPLAY_NAME] as! String
            let location = retrievedLocations[Constant.COLUMN_LOCATION] as! String
            
            let locationData = Location(name: name, location: location)
            
            savedLocations.append(locationData)
        }
        
        self.tableView.reloadData()

    }
    
    func onRetrievalFailed(_ event: Int) {
        
        hideLoading()
        
        print(event)
    }
    
    /**
        One table row is created for each savedLocation. One table row is returned if for the default row 
        if savedLocation count is zero.
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if savedLocations.count == 0 {
                return 1
        }
        
        return savedLocations.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.GENERIC_CELL) as! GenericCellController
        
        if index < savedLocations.count {
            
            let title = savedLocations[index].name
            let location = savedLocations[index].location
            
            // Sets the title to the display name. If no display name exists, use the location as
            // the title for the cell.
            if title != "" {
                cell.title.text = title
            } else {
                cell.title.text = location
            }
            
        } else {
            
            cell.title.text = NSLocalizedString("location_none_found", comment: "")

        }
        
        return cell
    }
    
    func initTitleView() {
        titleView.isHidden = true
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
