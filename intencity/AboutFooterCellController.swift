//
//  AboutFooterCellController.swift
//  Intencity
//
//  The controller for the about footer cell.
//
//  Created by Nick Piscopio on 2/23/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class AboutFooterCellController: UITableViewCell
{    
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        self.backgroundColor = Color.page_background
        
        title.textColor = Color.secondary_light
        title.text = NSLocalizedString("copyright", comment: "")
    }
}