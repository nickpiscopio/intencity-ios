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
        self.tabBarController?.tabBar.isHidden = true
        
        let notificationHandler = NotificationHandler.getInstance(nil)
        notificationHandler.setNotificationViewed()
        
        let notifications = notificationHandler.getAwardCount()
        
        // Notification section.
        let notificationRow = [ MenuRow(title: String(format: NSLocalizedString("notifications", comment: ""), "(\(notifications))"), viewController: "NotificationViewController") ]

        menu.append(MenuSection(title: "", rows: notificationRow))
        
        let isMobileTrial = Util.isAccountTypeTrial()
        
        // The settings section.
        var settingsRows = [ MenuRow(title: NSLocalizedString("edit_priority", comment: ""), viewController: "EditExercisePrioritiesViewController"),
                             MenuRow(title: NSLocalizedString("edit_equipment", comment: ""), viewController: Constant.EDIT_EQUIPMENT_VIEW_CONTROLLER) ]
        
        if (isMobileTrial)
        {
            settingsRows.append(MenuRow(title: NSLocalizedString("convert_account", comment: ""), viewController: Constant.CREATE_ACCOUNT_VIEW_CONTROLLER))
        }
        else
        {
            settingsRows.append(MenuRow(title: NSLocalizedString("change_password", comment: ""), viewController: "ChangePasswordViewController"))

        }
        
        settingsRows.append(MenuRow(title: NSLocalizedString("title_log_out", comment: ""), viewController: Constant.LOG_OUT))

        menu.append(MenuSection(title: NSLocalizedString("title_settings", comment: ""), rows: settingsRows))
        
        // The info section.
        let infoRows = [ MenuRow(title: NSLocalizedString("title_about", comment: ""), viewController: "AboutViewController"),
                         MenuRow(title: NSLocalizedString("title_terms", comment: ""), viewController: Constant.TERMS_VIEW_CONTROLLER),
                         MenuRow(title: NSLocalizedString("title_privacy_policy", comment: ""), viewController: Constant.PRIVACY_POLICY_VIEW_CONTROLLER),
                         MenuRow(title: NSLocalizedString("title_rate_intencity", comment: ""), viewController: Constant.RATE_INTENCITY),
                         MenuRow(title: NSLocalizedString("title_contribute_intencity", comment: ""), viewController: Constant.CONTRIBUTE_INTENCITY)]
        
        menu.append(MenuSection(title: NSLocalizedString("title_app", comment: ""), rows: infoRows))
        
        if (!isMobileTrial)
        {
            // The account settings section.
            let accountSettingsRow = [ MenuRow(title: NSLocalizedString("title_delete_account", comment: ""), viewController: "DeleteAccountViewController") ]
            
            menu.append(MenuSection(title: NSLocalizedString("title_account_settings", comment: ""), rows: accountSettingsRow))
        }
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: 0, emptyTableStringRes: "")
        
        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.GENERIC_HEADER_CELL, cellName: Constant.GENERIC_HEADER_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.GENERIC_CELL, cellName: Constant.GENERIC_CELL)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        return menu.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return menu[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let title = menu[section].title
        if (title != "")
        {
            let  headerCell = tableView.dequeueReusableCell(withIdentifier: Constant.GENERIC_HEADER_CELL) as! GenericHeaderCellController
            headerCell.title.text = title
            return headerCell
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return menu[section].title != "" ? Constant.GENERIC_HEADER_HEIGHT : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        // Gets the row in the section.
        let row = menu[(indexPath as NSIndexPath).section].rows[(indexPath as NSIndexPath).row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.GENERIC_CELL) as! GenericCellController
        cell.title.text = row.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
    {
        // Deselects the row.
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Gets the row in the section.
        let row = menu[(indexPath as NSIndexPath).section].rows[(indexPath as NSIndexPath).row]
        
        let viewController = row.viewController
        
        switch(viewController)
        {
            case Constant.LOG_OUT:
                Util.logOut(self)
                break;
            case Constant.RATE_INTENCITY:
                UIApplication.shared.open(URL(string: "https://itunes.apple.com/app/id786650617")!, options: [:], completionHandler: nil)
                break;
            case Constant.CONTRIBUTE_INTENCITY:
                UIApplication.shared.open(URL(string: "http://intencity.fit/contribute.html")!, options: [:], completionHandler: nil)
                break;
            default:
                var storyboardName = ""
                var viewControllerName = ""
                
                if (viewController == Constant.TERMS_VIEW_CONTROLLER ||
                    viewController == Constant.PRIVACY_POLICY_VIEW_CONTROLLER ||
                    viewController == Constant.CREATE_ACCOUNT_VIEW_CONTROLLER)
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
                break;
        }
    }
    
    /**
     * Pushes the view controller from a menu item click
     *
     * @param identifier    The string identifier of the view to open.
     */
    func pushViewController(_ storyboardName: String, identifier: String)
    {
        let storyboard = storyboardName == "" ? self.storyboard : UIStoryboard(name: storyboardName, bundle: nil)
        
        if (identifier == Constant.TERMS_VIEW_CONTROLLER || identifier == Constant.PRIVACY_POLICY_VIEW_CONTROLLER)
        {
            let viewController = storyboard!.instantiateViewController(withIdentifier: Constant.TERMS_VIEW_CONTROLLER) as! TermsViewController
            viewController.includeNavButton = false
            
            if (identifier == Constant.PRIVACY_POLICY_VIEW_CONTROLLER)
            {
                viewController.isTerms = false
            }
            
            self.navigationController!.pushViewController(viewController, animated: true)
        }
        else if (identifier == Constant.CREATE_ACCOUNT_VIEW_CONTROLLER)
        {
            let viewController = storyboard!.instantiateViewController(withIdentifier: Constant.CREATE_ACCOUNT_VIEW_CONTROLLER) as! CreateAccountViewController
            viewController.createAccountFromTrial = true
            
            self.navigationController!.pushViewController(viewController, animated: true)
        }
        else
        {
            let viewController = storyboard!.instantiateViewController(withIdentifier: identifier)
            
            self.navigationController!.pushViewController(viewController, animated: true)
        }
    }
}
