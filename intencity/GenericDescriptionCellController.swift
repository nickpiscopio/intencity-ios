//
//  GenericDescriptionCellController.swift
//  Intencity
//
//  Created by Greg Dalfonso on 4/22/17.
//  Copyright © 2017 Nick Piscopio. All rights reserved.
//

import Foundation
import UIKit

class GenericDescriptionCellController: UITableViewCell
{
    
    @IBOutlet weak var cellHeader: UILabel!
    @IBOutlet weak var cellDescription: UILabel!
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var cellBorderBottom: UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        cellBackgroundView.backgroundColor = Color.page_background
        
        cellBorderBottom.backgroundColor = Color.shadow
        
        cellHeader.textColor = Color.secondary_light
        cellDescription.textColor = Color.secondary_light
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    
}
