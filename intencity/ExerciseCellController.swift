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
    @IBOutlet weak var exerciseButton: UIButton!
    @IBOutlet weak var exerciseDescription: UILabel!
    @IBOutlet weak var editStackView: UIStackView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var priorityStackView: UIStackView!
    @IBOutlet weak var exerciseDescriptionView: UIView!
    @IBOutlet weak var hideButton: IntencityButtonNoBackground!
    
    weak var delegate: ExerciseDelegate?
    
    var tableView: UITableView!
    
    var deleteHeight: CGFloat = 0
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.backgroundColor = Color.page_background
    }
    
    /**
     * Sets the card as an exercise.
     */
    func setAsExercise(fromIntencity: Bool, routineState: Int)
    {
        exerciseDescriptionView.hidden = true
        
        hideButton.hidden = false
        
        editStackView.hidden = false
        
        if (fromIntencity)
        {
            exerciseButton.enabled = true
            exerciseButton.setTitleColor(Color.primary, forState: UIControlState.Normal)
            
            // Hide the exercise priority buttons if we are not in the Intencity state of exercising.
            // Saved / Custom routines should hide the priorityStackView.
            priorityStackView.hidden = routineState != RoutineState.INTENCITY
        }
        else
        {
            exerciseButton.enabled = false
            exerciseButton.setTitleColor(Color.secondary_dark, forState: UIControlState.Normal)
            priorityStackView.hidden = true
        }
    }
    
    /**
     * Sets the description, then edits the card to show the proper views associated with it.
     */
    func setDescription(description: String)
    {
        exerciseDescription.text = description
        exerciseDescription.textColor = Color.secondary_light
        exerciseDescriptionView.hidden = false
        
        editStackView.hidden = true

        hideButton.hidden = true
        
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
        
        let isReps = reps > 0
        
        let mutableString = ExerciseSet.getSetText(weight, duration: isReps ? String(reps) : duration, isReps: isReps).mutableString
        editButton.setAttributedTitle(mutableString, forState: .Normal)
    }
    
    @IBAction func hideClicked(sender: AnyObject)
    {
        delegate?.onHideClicked(getIndexPath(sender))
    }
    
    @IBAction func editClicked(sender: AnyObject)
    {
        delegate?.onEditClicked(getIndexPath(sender).row)
    }
    
    @IBAction func exerciseClicked(sender: AnyObject)
    {
        delegate?.onExerciseClicked((exerciseButton.titleLabel?.text)!)
    }
    
    @IBAction func setExerciseWithMorePriority(sender: AnyObject)
    {
        delegate?.onSetExercisePriority(getIndexPath(sender), increasing: true)
    }
    
    @IBAction func setExerciseWithLessPriority(sender: AnyObject)
    {
        delegate?.onSetExercisePriority(getIndexPath(sender), increasing: false)
    }
    
    func getIndexPath(sender: AnyObject) -> NSIndexPath
    {
        return tableView.indexPathForCell(self)!
    }
}