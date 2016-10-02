//
//  RankingCellController.swift
//  Intencity
//
//  The controller for the ranking cells.
//
//  Created by Nick Piscopio on 2/29/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class RankingCellController: UITableViewCell, ImageDelegate
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
    
    let USER_PROFILE_PIC_NAME = "/user-profile.jpg"
    
    var index: Int!
    
    var user: User!
    
    var email: String!
    
    weak var delegate: ImageDelegate?
    
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
    
    /**
     * Retrieves the profile picture from the server.
     */
    func retrieveProfilePic(_ index: Int)
    {
        let profilePic = user.profilePic
        if (profilePic == nil)
        {
            self.index = index
            
            _ = RetrieveImageTask(delegate: self, link: Constant.UPLOAD_FOLDER + String(user.id) + USER_PROFILE_PIC_NAME)
        }
        else
        {
            profilePictureView.image = profilePic
        }
    }
    
    func onImageRetrieved(_ index: Int, image: UIImage, newUpload: Bool)
    {
        delegate?.onImageRetrieved(self.index, image: image, newUpload: false)
        
        profilePictureView.image = image
    }
    
    func onImageRetrievalFailed()
    {
        profilePictureView.image = UIImage(named:"default_profile_pic")!
    }
}
