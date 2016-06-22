//
//  AwardCell.swift
//  Intencity
//
//  The class for the AwardCell.
//
//  Created by Nick Piscopio on 6/21/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class AwardCell: NSObject
{
    static func getCell(tableView: UITableView, indexPath: NSIndexPath, awards: [Awards]) -> UITableViewCell
    {
        let index = indexPath.row
        
        let notification = awards[index]
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
        
        cell.setAwardAmounts(notification.amount)
        cell.awardDescription.text = notification.awardDescription
        
        return cell
    }
}