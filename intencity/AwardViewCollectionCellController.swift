//
//  AwardViewCollectionCellController.swift
//  Intencity
//
//  The controller for the award view collection cells.
//
//  Created by Nick Piscopio on 3/29/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class AwardViewCollectionCellController: UICollectionViewCell
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        xLabel.textColor = Color.secondary_dark
        amount.textColor = Color.secondary_dark
        
        self.contentView.setNeedsLayout()
    }
    
    func setImage(badgeName: String)
    {
        var imageName: String
        
        switch badgeName
        {
            case Badge.FINISHER:
                imageName = Badge.FINISHER_IMAGE_NAME
                break
            case Badge.LEFT_IT_ON_THE_FIELD:
                imageName = Badge.LEFT_IT_ON_THE_FIELD_IMAGE_NAME
                break
            case Badge.KEPT_SWIMMING:
                imageName = Badge.KEPT_SWIMMING_IMAGE_NAME
                break
            default:
                imageName = "ranking_badge"
                break
        }
        
        imageView.image = UIImage(named:imageName)!
    }
}