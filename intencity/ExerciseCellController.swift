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
    @IBOutlet weak var morePriority: IntencityExerciseCardButton!
    @IBOutlet weak var lessPriority: IntencityExerciseCardButton!
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
    func setAsExercise(_ fromIntencity: Bool, priority: Int, routineState: Int)
    {
        exerciseDescriptionView.isHidden = true
        
        hideButton.isHidden = false
        
        editStackView.isHidden = false
        
        if (fromIntencity)
        {
            exerciseButton.isEnabled = true
            exerciseButton.setTitleColor(Color.primary, for: UIControlState())
            
            // Hide the exercise priority buttons if we are not in the Intencity state of exercising.
            // Saved / Custom routines should hide the priorityStackView.
            priorityStackView.isHidden = routineState != RoutineState.INTENCITY
            
            ExercisePriorityUtil.setPriorityButtons(priority, morePriority: morePriority, lessPriority: lessPriority)
        }
        else
        {
            exerciseButton.isEnabled = false
            exerciseButton.setTitleColor(Color.secondary_dark, for: UIControlState())
            priorityStackView.isHidden = true
        }
    }
    
    /**
     * Sets the description, then edits the card to show the proper views associated with it.
     */
    func setDescription(_ description: String)
    {
        exerciseDescription.text = description
        exerciseDescription.textColor = Color.secondary_light
        exerciseDescriptionView.isHidden = false
        
        editStackView.isHidden = true

        hideButton.isHidden = true
        
        exerciseButton.setTitleColor(Color.secondary_light, for: UIControlState())
    }
    
    /**
     * Sets the edit button text
     */
    func setEditText(_ set: Set)
    {
        let weight = set.weight
        let reps = set.reps
        let duration = set.duration
        
        let isReps = reps > 0
        
        let mutableString = ExerciseSet.getSetText(weight, duration: isReps ? String(reps) : duration, isReps: isReps).mutableString
        editButton.setAttributedTitle(mutableString, for: UIControlState())
    }
    
    @IBAction func hideClicked(_ sender: AnyObject)
    {
        delegate?.onHideClicked(getIndexPath(sender))
    }
    
    @IBAction func editClicked(_ sender: AnyObject)
    {
        delegate?.onEditClicked((getIndexPath(sender) as NSIndexPath).row)
    }
    
    @IBAction func exerciseClicked(_ sender: AnyObject)
    {
        delegate?.onExerciseClicked((exerciseButton.titleLabel?.text)!)
    }
    
    @IBAction func setExerciseWithMorePriority(_ sender: AnyObject)
    {
        delegate?.onSetExercisePriority(getIndexPath(sender), morePriority: morePriority, lessPriority: lessPriority, increment: true)
    }
    
    @IBAction func setExerciseWithLessPriority(_ sender: AnyObject)
    {
        delegate?.onSetExercisePriority(getIndexPath(sender), morePriority: morePriority, lessPriority: lessPriority, increment: false)
    }
    
    func getIndexPath(_ sender: AnyObject) -> IndexPath
    {
        return tableView.indexPath(for: self)!
    }
}
