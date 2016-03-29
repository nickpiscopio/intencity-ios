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
    
    var user: User!
    
    var sections = [ProfileSection]()
    
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
        
        let email = Util.getEmailFromDefaults()
        
        _ = ServiceTask(event: ServiceEvent.GET_BADGES, delegate: self,
                        serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_BADGES, variables: [ email ]))
    }
    
    override func viewWillAppear(animated: Bool)
    {
        // Shows the tab bar again.
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
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
        var awardRows = [ProfileRow]()
        var awards = [AwardRow]()
        
        // This gets saved as NSDictionary, so there is no order
        let json: AnyObject? = result.parseJSONString
        
        for badge in json as! NSArray
        {
            let title = badge[Constant.COLUMN_BADGE_NAME] as! String
            let amount = badge[Constant.COLUMN_TOTAL_BADGES] as! String
            
            awards.append(AwardRow(title: title, amount: amount))
        }
        
        awardRows.append(ProfileRow(title: "", awards: awards))
        
        var routineRows = [ ProfileRow(title: "Legs", awards: []),
                            ProfileRow(title: "Chest", awards: []),
                            ProfileRow(title: "Biceps", awards: []) ]
        
        sections.append(ProfileSection(title: NSLocalizedString("awards_title", comment: ""), rows: awardRows))
        sections.append(ProfileSection(title: NSLocalizedString("profile_routines_title", comment: ""), rows: routineRows))
        
        tableView.reloadData()
    }
    
    func onRetrievalFailed(event: Int)
    {
        
    }
}