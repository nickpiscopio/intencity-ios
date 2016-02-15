//
//  HeaderCellController.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/14/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.
//

import UIKit

class DirectionCellController: UITableViewCell
{    
    @IBOutlet weak var stepNumber: UILabel!
    @IBOutlet weak var stepDescription: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // Sets the background color of the header cell.
        self.backgroundColor = Color.transparent
        
        stepNumber.textColor = Color.secondary_dark
        stepDescription.textColor = Color.secondary_dark
    }
}