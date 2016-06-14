//
//  NotificationCellViewController.swift
//  Intencity
//
//  The controller for the notification cells.
//
//  Created by Nick Piscopio on 3/9/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class NotificationCellViewController: UITableViewCell
{
    @IBOutlet weak var awardImage: UIImageView!
    @IBOutlet weak var awardTitle: UILabel!
    @IBOutlet weak var awardDescription: UILabel!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var amount: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        awardTitle.textColor = Color.secondary_dark
        awardDescription.textColor = Color.secondary_dark
    }
    
    /**
     * Sets the cell with an image.
     */
    func initCellWithImage(imageName: String)
    {
        awardImage.image = UIImage(named: imageName)!
        
        awardTitle.hidden = true
        awardImage.hidden = false
    }
    
    /**
     * Sets the cell with a title.
     */
    func initCellWithTitle(title: String)
    {
        awardTitle.text = title
        
        awardImage.hidden = true
        awardTitle.hidden = false
    }
    
    /**
     * Sets and displays the amount view.
     * 
     * @param amountTotal   The number of awards.
     */
    func setAwardAmounts(awardTotal: Int)
    {
        if (awardTotal > 1)
        {
            amount.text = String(awardTotal)
            amountView.hidden = false
        }
        else
        {
            amountView.hidden = true
        }
    }
}