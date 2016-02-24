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
    
    weak var delegate: ExerciseDelegate?
    
    var index: Int!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.backgroundColor = Color.page_background
        
        editButton.setTitleColor(Color.secondary_light, forState: UIControlState.Normal)
        editButton.setTitle(NSLocalizedString("edit", comment: ""), forState: .Normal)
    }
    
    /**
     * Sets the card as an exercise.
     */
    func setAsExercise()
    {
        exerciseDescription.hidden = true
        
        editButton.hidden = false
        
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
        
        exerciseButton.setTitleColor(Color.secondary_light, forState: UIControlState.Normal)
        
        // REMOVE THIS LINE WHEN WE HAVE THE SEARCH IMPLEMENTED FOR WARM-UPS AND STRETCHES.
        exerciseButton.enabled = false
    }
    
    @IBAction func exerciseClicked(sender: AnyObject)
    {
        delegate?.onExerciseClicked((exerciseButton.titleLabel?.text)!)
    }
    
    @IBAction func EditedClicked(sender: AnyObject)
    {
        delegate?.onEditClicked(index)
    }
}