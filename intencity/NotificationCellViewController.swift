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
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var awardImage: UIImageView!
    @IBOutlet weak var awardTitle: UILabel!
    @IBOutlet weak var awardDescription: UILabel!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var divider: UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        awardTitle.font = awardTitle.font.withSize(Dimention.FONT_SIZE_LARGE)
        awardTitle.textColor = Color.secondary_dark
        awardDescription.textColor = Color.secondary_dark
    }
    
    /**
     * Sets the cell with an image.
     */
    func initCellWithImage(_ imageName: String)
    {
        awardImage.image = UIImage(named: imageName)!
        
        awardTitle.isHidden = true
        awardImage.isHidden = false
    }
    
    /**
     * Sets the cell with a title.
     */
    func initCellWithTitle(_ title: String)
    {
        awardTitle.text = title
        
        awardImage.isHidden = true
        awardTitle.isHidden = false
    }
    
    /**
     * Sets and displays the amount view.
     * 
     * @param amountTotal   The number of awards.
     */
    func setAwardAmounts(_ awardTotal: Int)
    {
        if (awardTotal > 1)
        {
            amount.font = UIFont.boldSystemFont(ofSize: Dimention.FONT_SIZE_XX_SMALL)
            amount.text = String(awardTotal)
            amount.textColor = Color.white
            amountView.isHidden = false
        }
        else
        {
            amountView.isHidden = true
        }
    }
}
