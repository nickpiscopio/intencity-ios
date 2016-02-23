//
//  AboutCellController.swift
//  Intencity
//
//  The controller for the about cells.
//
//  Created by Nick Piscopio on 2/23/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class AboutCellController: UITableViewCell
{
    @IBOutlet weak var cellBackgroundView: UIView!
    
    @IBOutlet weak var cellHeader: UILabel!
    @IBOutlet weak var cellDescription: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        cellBackgroundView.backgroundColor = Color.page_background
        
        cellHeader.textColor = Color.secondary_light
        cellDescription.textColor = Color.secondary_light
    }
}