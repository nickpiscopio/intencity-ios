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
    @IBOutlet weak var outline: UIView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var awardImage: UIImageView!
    @IBOutlet weak var awardTitle: UILabel!
    @IBOutlet weak var awardDescription: UILabel!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var divider: UIView!
    
    var roundCorners = false
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        awardTitle.font = awardTitle.font.fontWithSize(Dimention.FONT_SIZE_LARGE)
        awardTitle.textColor = Color.secondary_dark
        awardDescription.textColor = Color.secondary_dark
        
        if (outline != nil)
        {
            outline.backgroundColor = Color.shadow
        }
        
        if (cellView != nil)
        {
            cellView.backgroundColor = Color.page_background
        }
        
        divider.backgroundColor = Color.shadow
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        // We only want to round the corners of the last row in the overview screen.
        if (roundCorners)
        {
            // This needs to be called in layoutSubviews() because if it is called in awakeFromNib(), the width of the view is divided in half.
            // Place in viewDidLayoutSubviews for normal ViewControllers.
            // http://stackoverflow.com/questions/10316902/rounded-corners-only-on-top-of-a-uiview
            outline.roundCorners([.BottomLeft, .BottomRight], radius: Dimention.RADIUS)
            view.roundCorners([.BottomLeft, .BottomRight], radius: Dimention.RADIUS_INNER)
        }
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
            amount.font = UIFont.boldSystemFontOfSize(Dimention.FONT_SIZE_X_SMALL)
            amount.text = String(awardTotal)
            amount.textColor = Color.white
            amountView.hidden = false
        }
        else
        {
            amountView.hidden = true
        }
    }
}