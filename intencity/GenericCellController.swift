//
//  GenericCellController.swift
//  Intencity
//
//  The cell controller for a generic table view.
//
//  Created by Nick Piscopio on 2/22/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class GenericCellController: UITableViewCell
{
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        title.textColor = Color.secondary_dark
    }
}