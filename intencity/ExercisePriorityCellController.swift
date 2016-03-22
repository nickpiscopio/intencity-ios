//
//  ExercisePriorityCellController.swift
//  Intencity
//
//  The cell controller for the exercise priority lists.
//
//  Created by Nick Piscopio on 3/21/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class ExercisePriorityCellController: UITableViewCell
{
    @IBOutlet weak var exerciseNameLabel: UILabel!
    
    @IBOutlet weak var priorityLabel: UILabel!
    
    let HIGH_PRIORITY = NSLocalizedString("high_priority", comment: "")
    let MEDIUM_PRIORITY = NSLocalizedString("medium_priority", comment: "")
    let NORMAL_PRIORITY = NSLocalizedString("normal_priority", comment: "")
    let HIDDEN = NSLocalizedString("hidden_exercise", comment: "")
    
    let PRIORITY_LIMIT_UPPER = 50
    let PRIORITY_LIMIT_LOWER = 0
    let INCREMENTAL_VALUE = 25

    weak var delegate: ExercisePriorityDelegate?

    var index: Int!
    var priority = 0
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        exerciseNameLabel.textColor = Color.secondary_dark
    }
    
    /**
     * Sets the exercise name in the cell.
     */
    func setListItem(exercise: String, priority: Int)
    {
        exerciseNameLabel.text = exercise
        
        self.priority = priority
        
        setExercisePriority()
    }
    
    @IBAction func morePriorityClicked(sender: AnyObject)
    {
        setExercisePriority(true)
        
        delegate?.onSetExercisePriority(index, priority: priority)
    }
    
    @IBAction func lessPriorityClicked(sender: AnyObject)
    {
        setExercisePriority(false)
        
        delegate?.onSetExercisePriority(index, priority: priority)
    }
    
    /**
     * Sets the priority for the exercise.
     */
    func setExercisePriority()
    {
        switch(priority)
        {
            case PRIORITY_LIMIT_UPPER:
                priorityLabel.textColor = Color.primary
                priorityLabel.text = HIGH_PRIORITY
                break;
            case INCREMENTAL_VALUE:
                priorityLabel.textColor = Color.secondary_dark
                priorityLabel.text = MEDIUM_PRIORITY
                break;
            case PRIORITY_LIMIT_LOWER:
                priorityLabel.textColor = Color.secondary_light
                priorityLabel.text = NORMAL_PRIORITY
                break;
            default:
                priorityLabel.textColor = Color.card_button_delete_select
                priorityLabel.text = HIDDEN
                break;
        }
    }
    
    /**
     * Sets the priority for the exercise.
     *
     * @param increment     Boolean value of whether or not the exercise should increment or decrement the current priority.
     */
    func setExercisePriority(increment: Bool)
    {
        if (priority < PRIORITY_LIMIT_UPPER && increment)
        {
            priority += INCREMENTAL_VALUE
        }
        else if (priority >= PRIORITY_LIMIT_LOWER && !increment)
        {
            priority -= INCREMENTAL_VALUE
        }

        setExercisePriority()
    }
}