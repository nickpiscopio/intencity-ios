//
//  FitnessRecommendationCellViewController.swift
//  Intencity
//
//  The controller for the about cells.
//
//  Created by Nick Piscopio on 3/4/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class FitnessRecommendationCellViewController: UITableViewCell
{
    @IBOutlet weak var cellHeader: UILabel!
    @IBOutlet weak var cellHeaderAstricks: UILabel!
    @IBOutlet weak var cellDescription: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        cellHeaderAstricks.text = NSLocalizedString("asterisk", comment: "")
        
        cellHeader.textColor = Color.secondary_dark
        cellHeaderAstricks.textColor = Color.card_button_delete_select
        cellDescription.textColor = Color.secondary_dark
    }
}