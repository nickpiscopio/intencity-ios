//
//  FitnessRecFooterCellViewController.swift
//  Intencity
//
//  The footer for the fitness recommendation table.
//
//  Created by Nick Piscopio on 3/4/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class FitnessRecFooterCellController: UITableViewCell
{
    @IBOutlet weak var asteriskLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        asteriskLabel.textColor = Color.card_button_delete_select
        descriptionLabel.textColor = Color.secondary_light
        
        asteriskLabel.text = NSLocalizedString("asterisk", comment: "")
        descriptionLabel.text = NSLocalizedString("weight_description", comment: "")
    }
}