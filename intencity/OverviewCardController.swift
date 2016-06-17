//
//  OverviewCardController
//  Intencity
//
//  The controller for the overview card.
//
//  Created by Nick Piscopio on 6/17/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class OverviewCardController: UITableViewCell
{
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var cardIcon: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var itemStackView: UIStackView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        content.backgroundColor = Color.page_background
        
        title.font = UIFont.boldSystemFontOfSize(Dimention.FONT_SIZE_SMALL)
        title.textColor = Color.secondary_light
    }
    
    func setAwards(awards: [Awards])
    {
        let count = awards.count
        for i in 0 ..< count
        {
            let view = loadNib()
            view.heightAnchor.constraintEqualToConstant(75).active = true
            
            let award = awards[i]
            let imageName = award.awardImageName
            
            if (imageName != "")
            {
                view.initCellWithImage(imageName)
            }
            else
            {
                view.initCellWithTitle(award.awardTitle)
            }
            
            view.setAwardAmounts(award.amount)
            view.awardDescription.text = award.awardDescription
            view.divider.hidden = i == count - 1
            
            itemStackView.addArrangedSubview(view)
        }
    }
    
    func loadNib() -> NotificationCellViewController {
        return NSBundle.mainBundle().loadNibNamed(Constant.NOTIFICATION_CELL, owner: nil, options: nil)[0] as! NotificationCellViewController
    }
}