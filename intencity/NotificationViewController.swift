//
//  NotificationViewController.swift
//  Intencity
//
//  The view controller for the notification screen.
//
//  Created by Nick Piscopio on 2/23/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class NotificationViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!
    
    var notifications = NotificationHandler.getInstance(nil).awards
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.hidden = true
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("title_notifications", comment: "")
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: 0, emptyTableStringRes: "no_notifications")
        Util.addUITableViewCell(tableView, nibNamed: Constant.NOTIFICATION_CELL, cellName: Constant.NOTIFICATION_CELL)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        tableView.backgroundView?.hidden = notifications.count > 0
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return notifications.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
        
        let notification = notifications[index]
        let imageName = notification.awardImageName
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.NOTIFICATION_CELL) as! NotificationCellViewController
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        if (imageName != "")
        {
            cell.initCellWithImage(imageName)
        }
        else
        {
            cell.initCellWithTitle(notification.awardTitle)
        }
        
        cell.awardDescription.text = notification.awardDescription
        
        return cell
    }
}