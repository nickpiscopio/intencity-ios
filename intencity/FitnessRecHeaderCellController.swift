//
//  FitnessRecHeaderCellViewController.swift
//  Intencity
//
//  The header for the fitness recommendation table.
//
//  Created by Nick Piscopio on 3/4/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class FitnessRecHeaderCellController: UITableViewCell
{
    @IBOutlet weak var headerLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
//        self.backgroundView!.backgroundColor = Color.transparent
        
        headerLabel.textColor = Color.secondary_light
        
        headerLabel.text = NSLocalizedString("recommendations", comment: "")
    }
}