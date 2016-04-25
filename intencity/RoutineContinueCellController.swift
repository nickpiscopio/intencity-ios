//
//  RoutineCellController.swift
//  Intencity
//
//  The cell controller for the routine continue cell.
//
//  Created by Nick Piscopio on 4/25/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class RoutineContinueCellController: UITableViewCell
{
    @IBOutlet weak var view: IntencityCardView!
    
    @IBOutlet weak var routineTitle: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        routineTitle.textColor = Color.secondary_light
        
        contentView.backgroundColor = Color.page_background
        view.backgroundColor = Color.page_background
    }
}