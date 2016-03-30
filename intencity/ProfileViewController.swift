//
//  ProfileViewController.swift
//  Intencity
//
//  The view controller for the a user's profile.
//
//  Created by Nick Piscopio on 2/10/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class ProfileViewController: UIViewController, ServiceDelegate
{
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var points: UILabel!
    @IBOutlet weak var pointsSuffix: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addRemoveButton: IntencityButtonRound!
    
    var user: User!
    
    var sections = [ProfileSection]()
    
    var profileIsCurrentUser = false
    
    var originalFollowingId = Int(Constant.CODE_FAILED)
    
    var userId: String!
    
    weak var delegate: UserSearchDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        userName.text = user.getName()
        points.text = String(user.earnedPoints)
        pointsSuffix.text = NSLocalizedString("points", comment: "")
        
        // Sets the title for the screen.
        //self.navigationItem.title = NSLocalizedString("title_rankings", comment: "")
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: 0, emptyTableStringRes: "")
        
        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.GENERIC_HEADER_CELL, cellName: Constant.GENERIC_HEADER_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.AWARD_CELL, cellName: Constant.AWARD_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.GENERIC_CELL, cellName: Constant.GENERIC_CELL)
        
        originalFollowingId = user.followingId
        
        if (!profileIsCurrentUser)
        {
            if (originalFollowingId > 0)
            {
                setAddRemoveButtonImage(Constant.REMOVE_USER_BUTTON)
            }
            else
            {
                setAddRemoveButtonImage(Constant.ADD_USER_BUTTON)
            }
        }
        else
        {
            
            addRemoveButton.hidden = true
        }
        

        userId = String(user.id)
        
        _ = ServiceTask(event: ServiceEvent.GET_BADGES, delegate: self,
                        serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_BADGES, variables: [ userId ]))
        
        _ = ServiceTask(event: ServiceEvent.GET_LAST_WEEK_ROUTINES, delegate: self,
                        serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_LAST_WEEK_ROUTINES, variables: [ userId ]))
    }
    
    override func viewWillAppear(animated: Bool)
    {
        // Shows the tab bar again.
        self.tabBarController?.tabBar.hidden = true
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        self.navigationController?.navigationBar.translucent = false
        
        let followingId = user.followingId
        
        if (!profileIsCurrentUser && originalFollowingId != followingId)
        {
            if (followingId < 0)
            {
                // Unfollow the user.
                _ = ServiceTask(event: ServiceEvent.UNFOLLOW, delegate: self,
                                serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                                params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_REMOVE_FROM_FOLLOWING, variables: [ String(originalFollowingId) ]))
            }
            else
            {
                // Follow the user
                _ = ServiceTask(event: ServiceEvent.GENERIC, delegate: self,
                                serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                                params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_FOLLOW_USER, variables: [ Util.getEmailFromDefaults(), userId ]))
            }
            
            delegate?.onUserAdded()
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addRemoveClicked(sender: AnyObject)
    {
        if (isUserAdded())
        {
            setAddRemoveButtonImage(Constant.REMOVE_USER_BUTTON)
            
            user.followingId = originalFollowingId > Int(Constant.CODE_FAILED) ? originalFollowingId : 1
        }
        else
        {
            setAddRemoveButtonImage(Constant.ADD_USER_BUTTON)
            
            user.followingId = Int(Constant.CODE_FAILED)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return sections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Return the number of rows in the section.
        return sections[section].rows.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let title = sections[section].title
        if (title != "")
        {
            let  headerCell = tableView.dequeueReusableCellWithIdentifier(Constant.GENERIC_HEADER_CELL) as! GenericHeaderCellController
            headerCell.title.text = title
            return headerCell
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return sections[section].title != "" ? Constant.GENERIC_HEADER_HEIGHT : 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 75.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        // Gets the row in the section.
        let row = sections[indexPath.section].rows[indexPath.row]
        let awards = row.awards
        
        if (awards.count > 0)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constant.AWARD_CELL) as! AwardCellController
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.awards = awards
            
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constant.GENERIC_CELL) as! GenericCellController
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.title.text = row.title
            
            return cell
        }
    }
    
    func onRetrievalSuccessful(event: Int, result: String)
    {
        var sectionTitle = ""
        var rows = [ProfileRow]()
        var awards = [AwardRow]()
        
        // This gets saved as NSDictionary, so there is no order
        let json: AnyObject? = result.parseJSONString
        
        if (json != nil)
        {
            switch(event)
            {
                case ServiceEvent.GET_BADGES:
                
                    for badge in json as! NSArray
                    {
                        let title = badge[Constant.COLUMN_BADGE_NAME] as! String
                        let amount = badge[Constant.COLUMN_TOTAL_BADGES] as! String
                    
                        awards.append(AwardRow(title: title, amount: amount))
                    }
                
                    rows.append(ProfileRow(title: "", awards: awards))
                
                    sectionTitle = NSLocalizedString("awards_title", comment: "")
                
                    break
                case ServiceEvent.GET_LAST_WEEK_ROUTINES:
                
                    for routine in json as! NSArray
                    {
                        let title = routine[Constant.COLUMN_DISPLAY_NAME] as! String
                    
                        rows.append(ProfileRow(title: title, awards: []))
                    }
                
                    sectionTitle = NSLocalizedString("profile_routines_title", comment: "")
                
                    break
                default:
                    break
            }
            
            sections.append(ProfileSection(title: sectionTitle, rows: rows))
            
            tableView.reloadData()
        }
    }
    
    func onRetrievalFailed(event: Int)
    {
        
    }
    
    /**
     * Sets the image for the addRemoveButton
     *
     * @param imageNamed    The name of the image to set.
     */
    func setAddRemoveButtonImage(imageNamed: String)
    {
        addRemoveButton.setImage(UIImage(named: imageNamed), forState: .Normal)
    }
    
    /**
     * Checks to see if the user is already added.
     */
    func isUserAdded() -> Bool
    {
        return addRemoveButton.currentImage!.isEqual(UIImage(named: Constant.ADD_USER_BUTTON))
    }
}