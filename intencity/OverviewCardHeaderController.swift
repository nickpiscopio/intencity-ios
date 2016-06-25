//
//  OverviewCardController
//  Intencity
//
//  The controller for the overview card header.
//
//  Created by Nick Piscopio on 6/17/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class OverviewCardHeaderController: UITableViewCell
{
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var outline: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var cardIcon: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        content.backgroundColor = Color.page_background
        outline.backgroundColor = Color.shadow
        
        title.font = UIFont.boldSystemFontOfSize(Dimention.FONT_SIZE_SMALL)
        title.textColor = Color.secondary_light
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        // This needs to be called in layoutSubviews() because if it is called in awakeFromNib(), the width of the view is divided in half.
        // Place in viewDidLayoutSubviews for normal ViewControllers.
        // http://stackoverflow.com/questions/10316902/rounded-corners-only-on-top-of-a-uiview
        outline.roundCorners([.TopLeft, .TopRight], radius: Dimention.RADIUS)
        headerView.roundCorners([.TopLeft, .TopRight], radius: Dimention.RADIUS)
    }
}