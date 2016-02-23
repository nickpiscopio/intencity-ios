//
//  AboutViewController.swift
//  Intencity
//
//  The view controller for the about screen.
//
//  Created by Nick Piscopio on 2/23/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class AboutViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var versionTitle: UILabel!
    @IBOutlet weak var versionDescription: UILabel!
    
    var sections = [AboutSection]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.hidden = true
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("title_about", comment: "")
        
        versionTitle.textColor = Color.secondary_dark
        versionDescription.textColor = Color.secondary_dark
        
        versionTitle.text = NSLocalizedString("title_version", comment: "")
        versionDescription.text = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        
        // Initialize the tableview.
        Util.initTableView(tableView, removeSeparators: true)
        
        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.ABOUT_CELL, cellName: Constant.ABOUT_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.ABOUT_FOOTER_CELL, cellName: Constant.ABOUT_FOOTER_CELL)
        
        sections.append(AboutSection(header: NSLocalizedString("title_mission", comment: ""), description: NSLocalizedString("mission", comment: "")))
        sections.append(AboutSection(header: NSLocalizedString("title_founders", comment: ""), description: NSLocalizedString("founders", comment: "")))
        sections.append(AboutSection(header: NSLocalizedString("title_contributors", comment: ""), description: NSLocalizedString("contributors", comment: "")))
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
        return 1
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        if (section == sections.count - 1)
        {
            let footerCell = tableView.dequeueReusableCellWithIdentifier(Constant.ABOUT_FOOTER_CELL) as! AboutFooterCellController
            return footerCell
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return section == sections.count - 1 ? 35 : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        // Gets the section from the index.
        // Gets the row in the section.
        let section = sections[indexPath.section]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.ABOUT_CELL) as! AboutCellController
        cell.cellHeader.text = section.header
        cell.cellDescription.text = section.description
        
        return cell
    }
}