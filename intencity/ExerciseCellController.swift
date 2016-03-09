//
//  ExerciseCellController.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/14/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class ExerciseCellController: UITableViewCell
{
    @IBOutlet weak var exerciseView: UIView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var exerciseButton: UIButton!
    @IBOutlet weak var exerciseDescription: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var editStackView: UIStackView!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var lbsLabel: UILabel!
    @IBOutlet weak var slashLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var backgroundEditView: UIView!
    @IBOutlet weak var exerciseDescriptionView: UIView!
    
    let EDIT_STRING = NSLocalizedString("edit", comment: "")
    
    weak var delegate: ExerciseDelegate?
    
    var index: Int!
    
    var deleteHeight: CGFloat = 0
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.backgroundColor = Color.page_background

        backgroundEditView.hidden = true
        
        weightLabel.textColor = Color.secondary_light
        lbsLabel.textColor = Color.secondary_light
        slashLabel.textColor = Color.secondary_light
        durationLabel.textColor = Color.secondary_light
        repsLabel.textColor = Color.secondary_light
        
        lbsLabel.text = NSLocalizedString("title_lbs", comment: "")
        repsLabel.text = NSLocalizedString("title_reps", comment: "")
    }
    
    /**
     * Edits the UI of the delete button.
     */
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        var subViews = self.subviews
        let subviewsCount = subviews.count
        
        // Gets the new height of the delete button.
        deleteHeight = exerciseView.frame.height - Dimention.LAYOUT_MARGIN / 2
        
        for (var i = 0; i < subviewsCount; i++)
        {
            let view = subViews[0]
            
            let classView = String(view.classForCoder)

            // The subview of the delete button.
            if (classView == "UITableViewCellDeleteConfirmationView")
            {
                let delete = view
                
                var deleteFrame = delete.frame
                deleteFrame.size.height = deleteHeight
                
                // Rounds the corners of the delete button
                let path = UIBezierPath(roundedRect:delete.bounds, byRoundingCorners:[.TopLeft, .BottomLeft], cornerRadii: CGSizeMake(Dimention.RADIUS, Dimention.RADIUS))
                let maskLayer = CAShapeLayer()
                maskLayer.path = path.CGPath
                
                delete.layer.mask = maskLayer
                delete.frame = deleteFrame
            }
        }
    }
    
    /**
     * Sets the card as an exercise.
     */
    func setAsExercise()
    {
        exerciseDescriptionView.hidden = true
        
        editView.hidden = false
        
        exerciseButton.setTitleColor(Color.primary, forState: UIControlState.Normal)
    }
    
    /**
     * Sets the description, then edits the card to show the proper views associated with it.
     */
    func setDescription(description: String)
    {
        exerciseDescription.text = description
        exerciseDescription.textColor = Color.secondary_light
        exerciseDescriptionView.hidden = false

        editView.hidden = true
        
        exerciseButton.setTitleColor(Color.secondary_light, forState: UIControlState.Normal)
    }
    
    /**
     * Sets the edit button text
     */
    func setEditText(set: Set)
    {
        let weight = set.weight
        let reps = set.reps
        let duration = set.duration
        let durationInt = Util.convertToInt(set.duration)
        
        if reps > 0 || durationInt > 0
        {
            if (weight > 0)
            {
                weightLabel.text = "\(weight)"
                weightLabel.hidden = false
                lbsLabel.hidden = false
                slashLabel.hidden = false
            }
            else
            {
                weightLabel.hidden = true
                lbsLabel.hidden = true
                slashLabel.hidden = true
            }
            
            if (reps > 0)
            {
                durationLabel.text = "\(reps)"
                durationLabel.hidden = false
                repsLabel.hidden = false
            }
            else
            {
                durationLabel.text = duration
                durationLabel.hidden = false
                repsLabel.hidden = true
            }
        }
        else
        {
            weightLabel.text = EDIT_STRING
            
            weightLabel.hidden = false
            lbsLabel.hidden = true
            repsLabel.hidden = true
            durationLabel.hidden = true
            slashLabel.hidden = true
        }

    }
    
    @IBAction func editPressed(sender: AnyObject)
    {
        backgroundEditView.hidden = false
    }
    
    @IBAction func editReleased(sender: AnyObject)
    {
        backgroundEditView.hidden = true
    }
    
    @IBAction func editClicked(sender: AnyObject)
    {
        delegate?.onEditClicked(index)
    }
    
    @IBAction func exerciseClicked(sender: AnyObject)
    {
        delegate?.onExerciseClicked((exerciseButton.titleLabel?.text)!)
    }
}