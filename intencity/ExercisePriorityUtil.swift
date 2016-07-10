//
//  ExercisePriority.swift
//  Intencity
//
//  The class is a utility class for the Exercise Priorities.
//
//  Created by Nick Piscopio on 4/13/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import Foundation

class ExercisePriorityUtil
{
    static let PRIORITY_LIMIT_UPPER = 40
    static let PRIORITY_LIMIT_LOWER = 0
    static let INCREMENTAL_VALUE = 10
    
    static let HIGH_PRIORITY = NSLocalizedString("high_priority", comment: "")
    static let MEDIUM_PRIORITY = NSLocalizedString("medium_priority", comment: "")
    static let NORMAL_PRIORITY = NSLocalizedString("normal_priority", comment: "")
    static let LOW_PRIORITY = NSLocalizedString("low_priority", comment: "")
    static let HIDDEN = NSLocalizedString("hidden_exercise", comment: "")
    
    static let MORE_PRIORITY_NORMAL_IMAGE_RES = "thumb_up_outline";
    static let MORE_PRIORITY_HIGH_IMAGE_RES = "thumb_up";
    static let LESS_PRIORITY_NORMAL_IMAGE_RES = "thumb_down_outline";
    static let LESS_PRIORITY_HIGH_IMAGE_RES = "thumb_down";
    
    /**
     * Sets the priority for the exercise.
     *
     * @param exercisePriority  The current priority we are changing.
     * @param increment         Boolean value of whether or not the exercise should increment or decrement the current priority.
     *
     * @return The new exercise priority.
     */
    static func getExercisePriority(exercisePriority: Int, increment: Bool) -> Int
    {
        var priority = exercisePriority
        
        if (priority < PRIORITY_LIMIT_UPPER && increment)
        {
            priority += INCREMENTAL_VALUE
        }
        else if (priority > PRIORITY_LIMIT_LOWER && !increment)
        {
            priority -= INCREMENTAL_VALUE
        }
        
        return priority
    }
    
    /**
     * Sets the exercise priority buttons.
     *
     * @param priority          The current priority for the exercise.
     * @param morePriority      The more priority ImageButton.
     * @param lessPriority      The less priority ImageButton.
     */
    static func setPriorityButtons(priority: Int, morePriority: UIButton, lessPriority: UIButton)
    {
        switch (priority)
        {
            case PRIORITY_LIMIT_UPPER:
                morePriority.hidden = true
                lessPriority.hidden = false
                setButtonImage(lessPriority, imageName: LESS_PRIORITY_NORMAL_IMAGE_RES)
                break;
            case PRIORITY_LIMIT_UPPER -  INCREMENTAL_VALUE:
                morePriority.hidden = false
                setButtonImage(morePriority, imageName: MORE_PRIORITY_HIGH_IMAGE_RES)
                lessPriority.hidden = false
                setButtonImage(lessPriority, imageName: LESS_PRIORITY_NORMAL_IMAGE_RES)
                break;
            case PRIORITY_LIMIT_LOWER + INCREMENTAL_VALUE:
                morePriority.hidden = false
                setButtonImage(morePriority, imageName: MORE_PRIORITY_NORMAL_IMAGE_RES)
                lessPriority.hidden = false
                setButtonImage(lessPriority, imageName: LESS_PRIORITY_HIGH_IMAGE_RES)
                break;
            case PRIORITY_LIMIT_LOWER:
                morePriority.hidden = false
                setButtonImage(morePriority, imageName: MORE_PRIORITY_NORMAL_IMAGE_RES)
                lessPriority.hidden = true
                break;
            default:
                morePriority.hidden = false
                setButtonImage(morePriority, imageName: MORE_PRIORITY_NORMAL_IMAGE_RES)
                lessPriority.hidden = false
                setButtonImage(lessPriority, imageName: LESS_PRIORITY_NORMAL_IMAGE_RES)
                break;
        }
    }
    
    /**
     * Sets the button image.
     *
     * @param button        The button to set the iamge.
     * @param imageName     The name of the image resource.
     */
    static func setButtonImage(button: UIButton, imageName: String)
    {
        button.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
    }
}