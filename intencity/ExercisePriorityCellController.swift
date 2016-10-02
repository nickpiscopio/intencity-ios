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
    @IBOutlet weak var morePriority: IntencityButtonNoBackground!
    @IBOutlet weak var lessPriority: IntencityButtonNoBackground!
    @IBOutlet weak var separator: UIView!
    
    weak var delegate: ExercisePriorityDelegate?

    var index: Int!
    var priority = 0
    
    var exercisePriority: ExercisePriorityUtil!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        exerciseNameLabel.textColor = Color.secondary_dark
    }
    
    /**
     * Sets the exercise name in the cell.
     */
    func setListItem(_ exercise: String, priority: Int)
    {
        exerciseNameLabel.text = exercise
        
        self.priority = priority
        
        setExercisePriority()
    }
    
    @IBAction func morePriorityClicked(_ sender: AnyObject)
    {
        priority = ExercisePriorityUtil.getExercisePriority(priority, increment: true)
        
        setExercisePriority()
        
        delegate?.onSetExercisePriority(index, priority: priority)
    }
    
    @IBAction func lessPriorityClicked(_ sender: AnyObject)
    {
        priority = ExercisePriorityUtil.getExercisePriority(priority, increment: false)
        
        setExercisePriority()
        
        delegate?.onSetExercisePriority(index, priority: priority)
    }
    
    /**
     * Sets the priority for the exercise.
     */
    func setExercisePriority()
    {
        ExercisePriorityUtil.setPriorityButtons(priority, morePriority: morePriority, lessPriority: lessPriority)
        
        switch(priority)
        {
            // 40
            case ExercisePriorityUtil.PRIORITY_LIMIT_UPPER:
                priorityLabel.textColor = Color.primary
                priorityLabel.text = ExercisePriorityUtil.HIGH_PRIORITY
                break;
            // 30
            case ExercisePriorityUtil.INCREMENTAL_VALUE * 3:
                priorityLabel.textColor = Color.primary_dark
                priorityLabel.text = ExercisePriorityUtil.MEDIUM_PRIORITY
                break;
            // 20
            case ExercisePriorityUtil.INCREMENTAL_VALUE * 2:
                priorityLabel.textColor = Color.secondary_dark
                priorityLabel.text = ExercisePriorityUtil.NORMAL_PRIORITY
                break;
            // 10
            case ExercisePriorityUtil.INCREMENTAL_VALUE:
                priorityLabel.textColor = Color.secondary_light
                priorityLabel.text = ExercisePriorityUtil.LOW_PRIORITY
                break;
            default:
                priorityLabel.textColor = Color.card_button_delete_select
                priorityLabel.text = ExercisePriorityUtil.HIDDEN
                break;
        }
    }
}
