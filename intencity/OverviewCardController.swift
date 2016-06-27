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
    
    let WARM_UP_STRING = NSLocalizedString("warm_up", comment: "")
    let STRETCH_STRING = NSLocalizedString("stretch", comment: "")
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        content.backgroundColor = Color.page_background
        
        title.font = UIFont.boldSystemFontOfSize(Dimention.FONT_SIZE_SMALL)
        title.textColor = Color.secondary_light
        
        itemStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /**
     * Adds exercises to the exercise stack view.
     *
     * @param exercises    The awards to add.
     */
    func addExercises(exercises: [Exercise])
    {
        let count = exercises.count
        for i in 0 ..< count
        {
            let exercise = exercises[i]
            let exerciseName = exercise.exerciseName
            
            if (exerciseName != WARM_UP_STRING && exerciseName != STRETCH_STRING)
            {
                let view = Util.loadNib(Constant.OVERVIEW_EXERCISE_CELL) as! OverviewExerciseCellController
                view.heightAnchor.constraintEqualToConstant(view.bounds.size.height).active = true
                view.title.text = exercise.exerciseName
                view.title.textColor = exercise.fromIntencity ? Color.primary : Color.secondary_dark
                view.divider.hidden = i == count - 1
                
                let sets = exercise.sets
                let setCount = sets.count
                
                for z in 0 ..< setCount
                {
                    let setView = Util.loadNib(Constant.OVERVIEW_SET_CELL) as! OverviewSetCellController
                    setView.heightAnchor.constraintEqualToConstant(18).active = true
                    setView.setEditText(sets[z])
                    
                    view.setStackView.addArrangedSubview(setView)
                }
                
                itemStackView.addArrangedSubview(view)
 
            }
        }
    }

    /**
     * Adds awards to the award stack view.
     *
     * @param awards    The awards to add.
     */
    func addAwards(awards: [Awards])
    {
        let count = awards.count
        for i in 0 ..< count
        {
            let view = Util.loadNib(Constant.NOTIFICATION_CELL) as! NotificationCellViewController
            view.heightAnchor.constraintEqualToConstant(view.bounds.size.height).active = true
            
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
}