//
//  MenuViewController.swift
//  Intencity
//
//  The view controller for the menu.
//
//  Created by Nick Piscopio on 2/10/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class MenuViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!
    
    var menu = [MenuSection]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("title_menu", comment: "")
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.hidden = true
        
        // Notification section.
        menu.append(MenuSection(title: "", rows: [String(format: NSLocalizedString("notifications", comment: ""), "(0)")]))
        
        // The settings section.
        menu.append(MenuSection(title: NSLocalizedString("title_settings", comment: ""),
                                rows: [ NSLocalizedString("edit_exclusion", comment: ""),
                                        NSLocalizedString("edit_equipment", comment: ""),
                                        NSLocalizedString("change_password", comment: ""),
                                        NSLocalizedString("title_log_out", comment: "") ]))
        
        // The info section.
        menu.append(MenuSection(title: NSLocalizedString("title_info", comment: ""),
                                rows: [ NSLocalizedString("title_about", comment: ""),
                                        NSLocalizedString("title_terms", comment: "") ]))
        
        // The account settings section.
        menu.append(MenuSection(title: NSLocalizedString("title_account_settings", comment: ""),
                                rows: [ NSLocalizedString("title_delete_account", comment: "") ]))
        
        // Initialize the tableview.
        Util.initTableView(tableView, removeSeparators: true)
        
        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: "MenuHeader", cellName: Constant.MENU_HEADER_CELL)
        Util.addUITableViewCell(tableView, nibNamed: "Menu", cellName: Constant.MENU_CELL)
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return menu.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Return the number of rows in the section.
        return menu[section].rows.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let title = menu[section].title
        if (title != "")
        {
            let  headerCell = tableView.dequeueReusableCellWithIdentifier(Constant.MENU_HEADER_CELL) as! MenuHeaderCellController
            headerCell.title.text = title
            return headerCell
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return menu[section].title != "" ? 43 : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        // Gets the title from the row in the section.
        let title = menu[indexPath.section].rows[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.MENU_CELL) as! MenuCellController
        cell.title.text = title
        
        return cell
    }
}