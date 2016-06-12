//
//  OverviewHeaderCellController
//  Intencity
//
//  The controller for the overview header.
//
//  Created by Nick Piscopio on 6/12/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class OverviewHeaderCellController: UITableViewCell
{
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var routineTitle: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        view.backgroundColor = Color.page_background
        
        routineTitle.font = UIFont.boldSystemFontOfSize(Dimention.FONT_SIZE_NORMAL)
        dateLabel.font = dateLabel.font.fontWithSize(Dimention.FONT_SIZE_SMALL)
        
        routineTitle.textColor = Color.secondary_dark
        dateLabel.textColor = Color.secondary_dark
    }
}