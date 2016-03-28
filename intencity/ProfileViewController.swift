//
//  ProfileViewController.swift
//  Intencity
//
//  The view controller for the a user's profile.
//
//  Created by Nick Piscopio on 2/10/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class ProfileViewController: UIViewController
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
        Util.addUITableViewCell(tableView, nibNamed: Constant.GENERIC_CELL, cellName: Constant.GENERIC_CELL)
        
        // The settings section.
        var awardRows = [ ProfileRow(title: "", amount: 10),
                             ProfileRow(title: "", amount: 9),
                             ProfileRow(title: "", amount: 8) ]
        
        var routineRows = [ ProfileRow(title: "Legs", amount: 0),
                          ProfileRow(title: "Chest", amount: 0),
                          ProfileRow(title: "Biceps", amount: 0) ]
        
        sections.append(ProfileSection(title: NSLocalizedString("awards_title", comment: ""), rows: awardRows))
        sections.append(ProfileSection(title: NSLocalizedString("profile_routines_title", comment: ""), rows: routineRows))
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        // Gets the row in the section.
        let row = sections[indexPath.section].rows[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.GENERIC_CELL) as! GenericCellController
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.title.text = row.title
        
        return cell
    }
}