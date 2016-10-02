//
//  OverviewSetCellController
//  Intencity
//
//  The controller for the overview set cell.
//
//  Created by Nick Piscopio on 6/19/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class OverviewSetCellController: UITableViewCell
{
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var setLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        numberLabel.textColor = Color.secondary_light
        numberLabel.font = numberLabel.font.withSize(Dimention.FONT_SIZE_SMALL)
    }
    
    /**
     * Sets the edit button text
     */
    func setEditText(_ mutableString: NSMutableAttributedString)
    {
        setLabel.attributedText = mutableString
    }
}
