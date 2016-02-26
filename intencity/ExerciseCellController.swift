//
//  ExerciseCellController.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/14/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class ExerciseCellController: UITableViewCell
{
    @IBOutlet weak var view: UIView!
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
    let EDIT_STRING = NSLocalizedString("edit", comment: "")
    
    weak var delegate: ExerciseDelegate?
    
    var index: Int!
    
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
     * Sets the card as an exercise.
     */
    func setAsExercise()
    {
        exerciseDescription.hidden = true
        
        editButton.hidden = false
        editStackView.hidden = false
        
        exerciseButton.setTitleColor(Color.primary, forState: UIControlState.Normal)
        
        let heightConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: stackView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: Dimention.LAYOUT_MARGIN)
        view.addConstraint(heightConstraint)
        
        // REMOVE THIS LINE WHEN WE HAVE THE SEARCH IMPLEMENTED FOR WARM-UPS AND STRETCHES.
        exerciseButton.enabled = true
    }
    
    /**
     * Sets the description, then edits the card to show the proper views associated with it.
     */
    func setDescription(description: String)
    {
        let heightConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: stackView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: Dimention.EXERCISE_DESCRIPTION_PADDING)
        view.addConstraint(heightConstraint)
        
        exerciseDescription.text = description
        exerciseDescription.textColor = Color.secondary_light
        exerciseDescription.hidden = false
        
        editButton.hidden = true
        editStackView.hidden = true
        
        exerciseButton.setTitleColor(Color.secondary_light, forState: UIControlState.Normal)
        
        // REMOVE THIS LINE WHEN WE HAVE THE SEARCH IMPLEMENTED FOR WARM-UPS AND STRETCHES.
        exerciseButton.enabled = false
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