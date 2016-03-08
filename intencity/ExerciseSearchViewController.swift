//
//  ExerciseSearchViewController.swift
//  Intencity
//
//  The view controller for the warm-up and stretch search.
//
//  Created by Nick Piscopio on 3/7/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class ExerciseSearchViewController: UIViewController, ServiceDelegate
{
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var connectionView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var connectionIssue: UIImageView!
    @IBOutlet weak var connectionIssueLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var exercises = [String]()
    
    var searchType: String!
    var routineName: String!
    
    var WARM_UP_STRING = NSLocalizedString("warm_up", comment: "")
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.hidden = true
        
        // Sets the title for the screen.
        self.navigationItem.title = String(format: NSLocalizedString(searchType == WARM_UP_STRING ? "warm_ups_title" : "stretches_title", comment: ""), routineName)
        
        initConnectionViews()
        
        // Initialize the tableview.
        Util.initTableView(tableView, addFooter: false, emptyTableStringRes: "no_results")

        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.GENERIC_CELL, cellName: Constant.GENERIC_CELL)
        
        initSearch()
    }

     /**
     * Initializes the connection views.
     */
    func initConnectionViews()
    {
        loadingView.backgroundColor = Color.page_background
        connectionView.backgroundColor = Color.page_background
    
        loadingView.hidden = true
        connectionView.hidden = true
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.hidden = true
        
        connectionIssueLabel.text = NSLocalizedString("generic_error", comment: "")
        connectionIssueLabel.textColor = Color.secondary_light
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
    /**
     * Shows there was a connection issue.
     */
    func showConnectionIssue()
    {
        connectionView.hidden = false
    }
    
    /**
     * Hides the connection issue.
     */
    func hideConnectionIssue()
    {
        connectionView.hidden = true
    }
    
    override func viewWillDisappear(animated : Bool)
    {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.hidden = false
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /**
     * The function to initialize the search screen.
     */
    func initSearch()
    {
        showLoading()
        
        hideConnectionIssue()
        
        routineName = routineName == Constant.ROUTINE_CARDIO ? Constant.ROUTINE_LEGS_AND_LOWER_BACK : routineName
        
        ServiceTask(event: ServiceEvent.GENERIC, delegate: self,
                    serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                    params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_INJURY_PREVENTION_WORKOUTS, variables: [ searchType, routineName.stringByReplacingOccurrencesOfString("&", withString: "%26") ]))
    }
    
    func onRetrievalSuccessful(event: Int, result: String)
    {
        // This gets saved as NSDictionary, so there is no order
        let json: AnyObject? = result.parseJSONString
        
        for exercise in json as! NSArray
        {
            exercises.append(exercise[Constant.COLUMN_EXERCISE_NAME] as! String)
        }
        
        tableView.reloadData()
        
        hideLoading()
    }
    
    func onRetrievalFailed(event: Int)
    {
        exercises.removeAll()
        
        tableView.reloadData()
        
        hideLoading()
        
        showConnectionIssue()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Return the number of rows in the section.
        return exercises.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
            
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.GENERIC_CELL) as! GenericCellController
        cell.title.text = exercises[index]
            
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let index = indexPath.row
        
        let directionViewController = self.storyboard?.instantiateViewControllerWithIdentifier(Constant.DIRECTION_VIEW_CONTROLLER) as! DirectionViewController
        directionViewController.exerciseName = exercises[index]
        
        self.navigationController!.pushViewController(directionViewController, animated: true)
        
        // Deselects the row.
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}