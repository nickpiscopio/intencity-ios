//
//  DescriptionFooterCellController.swift
//  Intencity
//
//  The controller for a footer cell with a description.
//
//  Created by Nick Piscopio on 2/23/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class DescriptionFooterCellController: UITableViewCell
{    
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        self.backgroundColor = Color.page_background
        
        title.textColor = Color.secondary_light
    }
}