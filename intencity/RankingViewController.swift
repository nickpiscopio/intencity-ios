//
//  RankingViewController.swift
//  Intencity
//
//  The view controller for the Ranking screen.
//
//  Created by Nick Piscopio on 2/10/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class RankingViewController: UIViewController, ServiceDelegate, UserSearchDelegate, ImageDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addFollowerButton: IntencityButtonRound!
    
    let RANKING_RESET_STRING = NSLocalizedString("rankings_updated", comment: "")
    
    var currentUsers = [User]()
    
    var indexPath: IndexPath!
    var indexToRemove: Int!
    
    var refreshControl: UIRefreshControl!
    
    var notificationHandler: NotificationHandler!
    
    var profileViewController: ProfileViewController!

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
        self.refreshControl.addTarget(self, action: #selector(RankingViewController.refreshRankingList), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(self.refreshControl)
        
        notificationHandler = NotificationHandler.getInstance(nil)
        
        getMenuIcon()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        // Shows the tab bar again.
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        getMenuIcon()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addFollowerClicked(_ sender: AnyObject)
    {
        let storyboard = UIStoryboard(name: Constant.MAIN_STORYBOARD, bundle: nil)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: Constant.SEARCH_VIEW_CONTROLLER) as! SearchViewController
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
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_FOLLOWING, variables: [ email ]) as NSString)
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
    func setMenuButton(_ type: Int)
    {
        var icon: UIImage!
        
        switch(type)
        {
            case Constant.MENU_INITIALIZED:
                icon = UIImage(named: Constant.MENU_INITIALIZED_IMAGE)!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                break
            case Constant.MENU_NOTIFICATION_PRESENT:
                icon = UIImage(named: Constant.MENU_NOTIFICATION_PRESENT_IMAGE)!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                break
            default:
                break
        }

        let iconSize = CGRect(origin: CGPoint.zero, size: CGSize(width: Constant.MENU_IMAGE_WIDTH, height: Constant.MENU_IMAGE_HEIGHT))

        let iconButton = UIButton(frame: iconSize)
        iconButton.setImage(icon, for: UIControlState())
        iconButton.addTarget(self, action: #selector(RankingViewController.menuClicked), for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItem?.customView = iconButton
    }
    
    /**
     * Opens the menu.
     */
    func menuClicked()
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: Constant.MENU_VIEW_CONTROLLER) as! MenuViewController
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    /**
     * Displays a communication error message to the user.
     */
    func showErrorMessage()
    {
        Util.displayAlert(self, title: NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("intencity_communication_error", comment: ""), actions: [])
    }
    
    func onRetrievalSuccessful(_ event: Int, result: String)
    {
        switch(event)
        {
            case ServiceEvent.GET_FOLLOWING:
                
                do
                {
                    // This gets saved as NSDictionary, so there is no order
                    currentUsers = try UserDao().parseJson(result.parseJSONString as! [AnyObject]?)
                }
                catch
                {
                    showErrorMessage()
                }
                
                
                tableView.reloadData()
                
                self.refreshControl.endRefreshing()
                
                break
            case ServiceEvent.UNFOLLOW:
                
                currentUsers.remove(at: indexPath.row)
                
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                
                break
            default:
                break
        }
    }
    
    func onRetrievalFailed(_ event: Int)
    {
        switch(event)
        {
            // Unused.
            // We don't update the ui if we can't get followers.
            // As long as a person has > 1 follower, we don't show any messages.
            case ServiceEvent.GET_FOLLOWING:
                break
            case ServiceEvent.UNFOLLOW:
            
                showErrorMessage()
            
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
    
    func onImageRetrieved(_ index: Int, image: UIImage, newUpload: Bool)
    {
        currentUsers[index].profilePic = image
        
        if (profileViewController != nil && profileViewController.index == index)
        {
            profileViewController.profilePic.image = image
        }
        
        if (newUpload)
        {
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func onImageRetrievalFailed() { }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        tableView.backgroundView?.isHidden = currentUsers.count > 1
        
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Return the number of rows in the section.
        return currentUsers.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let index = (indexPath as NSIndexPath).row
        let user = currentUsers[index]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.RANKING_CELL) as! RankingCellController
        cell.user = user
        cell.name.text = user.getName()
        cell.userNotification.isHidden = user.followingId > Int(Constant.CODE_FAILED)
        cell.rankingLabel.text = String(index + 1)
        cell.pointsLabel.text = String(user.earnedPoints)
        cell.delegate = self
        cell.retrieveProfilePic(index)
        
        let totalBadges = user.totalBadges
        
        if (totalBadges > 0)
        {
            cell.badgeView.isHidden = false
            cell.badgeTotalLabel.text = String(totalBadges)
        }
        else
        {
            cell.badgeView.isHidden = true
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
    {
        // Deselects the row.
        tableView.deselectRow(at: indexPath, animated: true)
        
        let index = (indexPath as NSIndexPath).row
        
        // Gets the row in the section.
        let user = currentUsers[index]
        
        profileViewController = storyboard!.instantiateViewController(withIdentifier: Constant.PROFILE_VIEW_CONTROLLER) as! ProfileViewController
        profileViewController.index = index
        profileViewController.user = user
        // Only add the addRemoveButton if it is not the user.
        // A user cannot follow/unfollow him or herself.
        profileViewController.profileIsCurrentUser = user.followingId < 0
        profileViewController.delegate = self
        profileViewController.imageDelegate = self
        
        self.navigationController!.pushViewController(profileViewController, animated: true)
    }
}
