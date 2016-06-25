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
    static func getCell(tableView: UITableView, cellName: String, index: Int, awards: [Awards], roundLastCell: Bool) -> UITableViewCell
    {
        let notification = awards[index]
        let imageName = notification.awardImageName
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellName) as! NotificationCellViewController
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
        
        if (roundLastCell)
        {
            // We round the corners of the last row.
            cell.roundCorners = index == awards.count - 1
            // Since we have the rounded corner view, we don't need the divider.
            cell.divider.hidden = true
        }
        
        return cell
    }
}