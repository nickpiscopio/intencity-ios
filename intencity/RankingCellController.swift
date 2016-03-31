//
//  RankingCellController.swift
//  Intencity
//
//  The controller for the ranking cells.
//
//  Created by Nick Piscopio on 2/29/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class RankingCellController: UITableViewCell
{
    @IBOutlet weak var cellBackgroundView: UIView!
    
    @IBOutlet weak var rankingLabel: UILabel!
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var badgeTotalLabel: UILabel!
    @IBOutlet weak var badgeView: UIStackView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var pointsSuffix: UILabel!    
    @IBOutlet weak var userNotification: IntencityCircleView!
    
    var user: User!
    
    var email: String!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        cellBackgroundView.backgroundColor = Color.white
        
        rankingLabel.textColor = Color.secondary_light
        name.textColor = Color.secondary_dark
        xLabel.textColor = Color.secondary_dark
        badgeTotalLabel.textColor = Color.secondary_dark
        pointsSuffix.textColor = Color.secondary_dark
        pointsLabel.textColor = Color.secondary_dark
        
        pointsSuffix.text = NSLocalizedString("points", comment: "")
    }
    
    @IBAction func addClicked(sender: AnyObject)
    {
        
    }
    
    /**
     * Sets the user result.
     *
     * @param result    Either the exercise or user result to set the cell view.
     */
    func setUserResult(user: User)
    {
        self.user = user
        
        name.text = user.getName()
    }
}