//
//  NoItemCellController.swift
//  Intencity
//
//  The cell controller for the a cell that doesn't have an item in its section.
//
//  Created by Nick Piscopio on 4/27/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class NoItemCellController: UITableViewCell
{
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        titleLabel.textColor = Color.secondary_light
        
        view.backgroundColor = Color.page_background
    }
}