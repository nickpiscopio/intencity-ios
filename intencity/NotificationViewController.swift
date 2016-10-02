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
        self.tabBarController?.tabBar.isHidden = true
        
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
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        tableView.backgroundView?.isHidden = notifications.count > 0
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let index = (indexPath as NSIndexPath).row
        
        let notification = notifications[index]
        let imageName = notification.awardImageName
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.NOTIFICATION_CELL) as! NotificationCellViewController
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        if (imageName != "")
        {
            cell.initCellWithImage(imageName)
        }
        else
        {
            cell.initCellWithTitle(notification.awardTitle)
        }
        
        cell.setAwardAmounts(notification.amount)
        cell.awardDescription.text = notification.awardDescription
        
        return cell
    }
}
