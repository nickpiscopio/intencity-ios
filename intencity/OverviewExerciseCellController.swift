//
//  OverviewExerciseCellController
//  Intencity
//
//  The controller for the overview exercise cell.
//
//  Created by Nick Piscopio on 6/18/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class OverviewExerciseCellController: UITableViewCell
{
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var setStackView: UIStackView!    
    @IBOutlet weak var divider: UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        title.font = UIFont.boldSystemFontOfSize(Dimention.FONT_SIZE_NORMAL)
        title.textColor = Color.secondary_light
        
        divider.backgroundColor = Color.shadow
    }
}