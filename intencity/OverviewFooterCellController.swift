//
//  OverviewFooterCellController
//  Intencity
//
//  The controller for the overview footer.
//
//  Created by Nick Piscopio on 6/12/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class OverviewFooterCellController: UITableViewCell
{
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var websitePrefix: UILabel!
    @IBOutlet weak var websiteSuffix: UILabel!
    @IBOutlet weak var websiteEnd: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        view.backgroundColor = Color.page_background
        
        websitePrefix.font = websitePrefix.font.fontWithSize(Dimention.FONT_SIZE_SMALL)
        websiteSuffix.font = UIFont.boldSystemFontOfSize(Dimention.FONT_SIZE_SMALL)
        websiteEnd.font = websiteEnd.font.fontWithSize(Dimention.FONT_SIZE_SMALL)
        
        websitePrefix.textColor = Color.secondary_light
        websiteSuffix.textColor = Color.secondary_light
        websiteEnd.textColor = Color.secondary_light
        
        websitePrefix.text = NSLocalizedString("app_name_prefix", comment: "")
        websiteSuffix.text = NSLocalizedString("app_name_suffix", comment: "")
        websiteEnd.text = NSLocalizedString("website_suffix", comment: "")        
    }
}