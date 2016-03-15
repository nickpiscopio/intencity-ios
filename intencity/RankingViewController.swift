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
    
    let RANKING_RESET_STRING = NSLocalizedString("rankings_updated", comment: "")
    
    var currentUsers = [User]()
    
    var indexPath: NSIndexPath!
    var indexToRemove: Int!
    
    var refreshControl: UIRefreshControl!
    
    var notificationHandler: NotificationHandler!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("title_rankings", comment: "")
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: Dimention.TABLE_FOOTER_HEIGHT_NORMAL, emptyTableStringRes: "no_friends")
        
        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.RANKING_CELL, cellName: Constant.RANKING_CELL)
        
        getFollowing()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("pull_to_refresh", comment: ""))
        self.refreshControl.addTarget(self, action: "refreshRankingList", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl)
        
        notificationHandler = NotificationHandler.getInstance(nil)
        
        getMenuIcon()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        // Shows the tab bar again.
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewDidAppear(animated: Bool)
    {
        getMenuIcon()
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
     * Refreshes the ranking list.
     */
    func refreshRankingList()
    {
        getFollowing()

        // Documentation: https://github.com/scalessec/Toast-Swift
        self.tabBarController?.view.makeToast(String(format: RANKING_RESET_STRING, arguments: [ DateUtil().getMondayAt12AM() ]))
    }
    
    /**
     * Start the task to get the user's following.
     */
    func getFollowing()
    {
        let email = Util.getEmailFromDefaults()
        
        _ = ServiceTask(event: ServiceEvent.GET_FOLLOWING, delegate: self,
                        serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_FOLLOWING, variables: [ email ]))
    }
    
    /**
     * Sets the menu item depending upon whether there are new notifications or not.
     */
    func getMenuIcon()
    {
        setMenuButton(notificationHandler.hasNewNotifications ? Constant.MENU_NOTIFICATION_PRESENT : Constant.MENU_INITIALIZED)
    }
    
    /**
     * Sets the menu button.
     *
     * @param type  The button type to set.
     */
    func setMenuButton(type: Int)
    {
        var icon: UIImage!
        
        switch(type)
        {
            case Constant.MENU_INITIALIZED:
                icon = UIImage(named: Constant.MENU_INITIALIZED_IMAGE)!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                break
            case Constant.MENU_NOTIFICATION_PRESENT:
                icon = UIImage(named: Constant.MENU_NOTIFICATION_PRESENT_IMAGE)!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                break
            default:
                break
        }

        let iconSize = CGRect(origin: CGPointZero, size: CGSizeMake(Constant.MENU_IMAGE_WIDTH, Constant.MENU_IMAGE_HEIGHT))

        let iconButton = UIButton(frame: iconSize)
        iconButton.setImage(icon, forState: .Normal)
        iconButton.addTarget(self, action: "menuClicked", forControlEvents: .TouchUpInside)
        
        self.navigationItem.rightBarButtonItem?.customView = iconButton
    }
    
    /**
     * Opens the menu.
     */
    func menuClicked()
    {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier(Constant.MENU_VIEW_CONTROLLER) as! MenuViewController
        
        self.navigationController!.pushViewController(vc, animated: true)
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
            // Unused.
            // We don't update the ui if we can't get followers.
            // As long as a person has > 1 follower, we don't show any messages.
            case ServiceEvent.GET_FOLLOWING:
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
        tableView.backgroundView?.hidden = currentUsers.count > 1
        
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
        return NSLocalizedString("unfollow", comment: "")
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if (editingStyle == UITableViewCellEditingStyle.Delete)
        {
            self.indexPath = indexPath
            indexToRemove = indexPath.row
            
            let user = currentUsers[indexToRemove]
            
            _ = ServiceTask(event: ServiceEvent.UNFOLLOW, delegate: self,
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