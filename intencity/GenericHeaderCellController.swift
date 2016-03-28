//
//  MenuCellController.swift
//  Intencity
//
//  The cell controller for the menu header.
//
//  Created by Nick Piscopio on 2/22/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class GenericHeaderCellController: UITableViewCell
{
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var view: UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        title.textColor = Color.secondary_light
        title.backgroundColor = Color.page_background
        
        view.backgroundColor = Color.page_background
    }
}