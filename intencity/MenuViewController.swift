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
        
        let notifications = NotificationHandler.getInstance(nil).getAwardCount()
        
        // Notification section.
        let notificationRow = [ MenuRow(title: String(format: NSLocalizedString("notifications", comment: ""), "(\(notifications))"), viewController: "NotificationViewController") ]

        menu.append(MenuSection(title: "", rows: notificationRow))
        
        let isMobileTrial = Util.isAccountTypeTrial()
        
        // The settings section.
        var settingsRows = [ MenuRow(title: NSLocalizedString("edit_exclusion", comment: ""), viewController: "EditExclusionViewController"),
                             MenuRow(title: NSLocalizedString("edit_equipment", comment: ""), viewController: "EditEquipmentViewController")]
        
        if (!isMobileTrial)
        {
           settingsRows.append(MenuRow(title: NSLocalizedString("change_password", comment: ""), viewController: "ChangePasswordViewController"))
        }
        
        settingsRows.append(MenuRow(title: NSLocalizedString("title_log_out", comment: ""), viewController: Constant.LOG_OUT))

        menu.append(MenuSection(title: NSLocalizedString("title_settings", comment: ""), rows: settingsRows))
        
        // The info section.
        let infoRows = [ MenuRow(title: NSLocalizedString("title_about", comment: ""), viewController: "AboutViewController"),
                         MenuRow(title: NSLocalizedString("title_terms", comment: ""), viewController: Constant.TERMS_VIEW_CONTROLLER),
                         MenuRow(title: NSLocalizedString("title_privacy_policy", comment: ""), viewController: Constant.PRIVACY_POLICY_VIEW_CONTROLLER)]
        
        menu.append(MenuSection(title: NSLocalizedString("title_info", comment: ""), rows: infoRows))
        
        if (!isMobileTrial)
        {
            // The account settings section.
            let accountSettingsRow = [ MenuRow(title: NSLocalizedString("title_delete_account", comment: ""), viewController: "DeleteAccountViewController") ]
            
            menu.append(MenuSection(title: NSLocalizedString("title_account_settings", comment: ""), rows: accountSettingsRow))
        }
        
        // Initialize the tableview.
        Util.initTableView(tableView, addFooter: false, emptyTableStringRes: "")
        
        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: "MenuHeader", cellName: Constant.MENU_HEADER_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.GENERIC_CELL, cellName: Constant.GENERIC_CELL)
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
        return menu[section].title != "" ? 45 : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        // Gets the row in the section.
        let row = menu[indexPath.section].rows[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.GENERIC_CELL) as! GenericCellController
        cell.title.text = row.title
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        // Deselects the row.
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // Gets the row in the section.
        let row = menu[indexPath.section].rows[indexPath.row]
        
        let viewController = row.viewController
        
        if (viewController == Constant.LOG_OUT)
        {
            Util.logOut(self)
        }
        else
        {
            var storyboardName = ""
            var viewControllerName = ""
            
            if (viewController == Constant.TERMS_VIEW_CONTROLLER || viewController == Constant.PRIVACY_POLICY_VIEW_CONTROLLER)
            {
                storyboardName = Constant.LOGIN_STORYBOARD
                
                viewControllerName = viewController
            }
            else
            {
                // We do not set the storyboardName here.
                // We do this so we can just use the main storyboard.
                viewControllerName = row.viewController
            }
            
            pushViewController(storyboardName, identifier: viewControllerName)
        }
    }
    
    /**
     * Pushes the view controller from a menu item click
     *
     * @param identifier    The string identifier of the view to open.
     */
    func pushViewController(storyboardName: String, identifier: String)
    {
        let storyboard = storyboardName == "" ? self.storyboard : UIStoryboard(name: storyboardName, bundle: nil)
        
        if (identifier == Constant.TERMS_VIEW_CONTROLLER || identifier == Constant.PRIVACY_POLICY_VIEW_CONTROLLER)
        {
            let viewController = storyboard!.instantiateViewControllerWithIdentifier(Constant.TERMS_VIEW_CONTROLLER) as! TermsViewController
            viewController.includeNavButton = false
            
            if (identifier == Constant.PRIVACY_POLICY_VIEW_CONTROLLER)
            {
                viewController.isTerms = false
            }
            
            self.navigationController!.pushViewController(viewController, animated: true)
        }
        else
        {
            let viewController = storyboard!.instantiateViewControllerWithIdentifier(identifier)
            
            self.navigationController!.pushViewController(viewController, animated: true)
        }
    }
}