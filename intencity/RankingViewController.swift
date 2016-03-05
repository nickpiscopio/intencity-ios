//
//  RankingViewController.swift
//  Intencity
//
//  The view controller for the Ranking screen.
//
//  Created by Nick Piscopio on 2/10/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class RankingViewController: UIViewController, ServiceDelegate, UserSearchDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addFollowerButton: IntencityButtonRound!
    
    var currentUsers = [User]()
    
    var indexPath: NSIndexPath!
    var indexToRemove: Int!
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Sets the title for the screen.
        self.navigationController?.navigationBar.topItem!.title = NSLocalizedString("app_name", comment: "")
        
        // Initialize the tableview.
        Util.initTableView(tableView, removeSeparators: true, addFooter: true)
        
        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.RANKING_CELL, cellName: Constant.RANKING_CELL)
        
        getFollowing()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("pull_to_refresh", comment: ""))
        self.refreshControl.addTarget(self, action: "getFollowing", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl) // not required when using UITableViewController
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addFollowerClicked(sender: AnyObject)
    {
        let storyboard = UIStoryboard(name: Constant.MAIN_STORYBOARD, bundle: nil)
        
        let viewController = storyboard.instantiateViewControllerWithIdentifier(Constant.SEARCH_VIEW_CONTROLLER) as! SearchViewController
        viewController.state = ServiceEvent.SEARCH_FOR_USER
        viewController.userSearchDelegate = self
        viewController.currentUsers = currentUsers
        
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    /**
     * Start the task to get the user's following.
     */
    func getFollowing()
    {
        let email = Util.getEmailFromDefaults()
        
        ServiceTask(event: ServiceEvent.GET_FOLLOWING, delegate: self,
            serviceURL: Constant.SERVICE_STORED_PROCEDURE,
            params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_FOLLOWING, variables: [ email ]))
    }
    
    func onRetrievalSuccessful(event: Int, result: String)
    {
        switch(event)
        {
            case ServiceEvent.GET_FOLLOWING:
                
                // This gets saved as NSDictionary, so there is no order
                currentUsers = UserDao().parseJson(result.parseJSONString)
                
                tableView.reloadData()
                
                self.refreshControl.endRefreshing()
                
                break
            case ServiceEvent.UNFOLLOW:
                
                currentUsers.removeAtIndex(indexPath.row)
                
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                
                break
            default:
                break
        }
    }
    
    func onRetrievalFailed(event: Int)
    {
        switch(event)
        {
        case ServiceEvent.GET_FOLLOWING:
            
            // update ui for when it can't get users.
            
            break
        case ServiceEvent.UNFOLLOW:
            
            Util.displayAlert(self, title: NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("intencity_communication_error", comment: ""), actions: [])
            
            break
        default:
            break
        }
    }
    
    func onUserAdded()
    {
        // At least 1 user was added, so we are refreshing the list.
        getFollowing()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Return the number of rows in the section.
        return currentUsers.count
    }
   
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
        let user = currentUsers[index]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.RANKING_CELL) as! RankingCellController
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.addButton.hidden = true
        cell.name.text = user.getName()
        cell.rankingLabel.text = String(index + 1)
        cell.pointsLabel.text = String(user.earnedPoints)
        
        let totalBadges = user.totalBadges
        
        if (totalBadges > 0)
        {
            cell.badgeView.hidden = false
            cell.badgeTotalLabel.text = String(totalBadges)
        }
        else
        {
            cell.badgeView.hidden = true
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String!
    {
        return NSLocalizedString("unfollow", comment: "")//or customize for each indexPath
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if (editingStyle == UITableViewCellEditingStyle.Delete)
        {
            self.indexPath = indexPath
            indexToRemove = indexPath.row
            
            let user = currentUsers[indexToRemove]
            
            ServiceTask(event: ServiceEvent.UNFOLLOW, delegate: self,
                serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_REMOVE_FROM_FOLLOWING, variables: [ String(user.followingId) ]))
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
        let index = indexPath.row
        let user = currentUsers[index]
        
        // Only add the unfollow button if it is not the user.
        // A user cannot unfollow him or herself.
        if (user.followingId > 0)
        {
            return UITableViewCellEditingStyle.Delete
        }

        return UITableViewCellEditingStyle.None
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
}