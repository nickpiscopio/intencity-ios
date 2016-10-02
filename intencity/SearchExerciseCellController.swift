//
//  SearchExerciseCellController.swift
//  Intencity
//
//  The controller for the search cells.
//
//  Created by Nick Piscopio on 2/29/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class SearchExerciseCellController: UITableViewCell
{
    @IBOutlet weak var cellBackgroundView: UIView!

    @IBOutlet weak var resultName: UIButton!
    
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var resultDescription: UILabel!
    
    @IBOutlet weak var addButton: UIButton!
    
    weak var exerciseSearchDelegate: ExerciseSearchDelegate!
    
    var exercise: Exercise!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        resultName.setTitleColor(Color.secondary_dark, for: UIControlState())
        resultName.setTitleColor(Color.secondary_dark, for: .highlighted)
        
        resultDescription.textColor = Color.card_button_delete_deselect
        resultDescription.text = NSLocalizedString("search_exercise_not_found", comment: "")
    }
    
    @IBAction func addClicked(_ sender: AnyObject)
    {
        exerciseSearchDelegate.onExerciseAdded(exercise)
    }
    
    @IBAction func resultClicked(_ sender: AnyObject)
    {
        exerciseSearchDelegate?.onExerciseClicked((resultName.titleLabel?.text)!)
    }
    
    /**
     * Sets the exercise result.
     *
     * @param result    Either the exercise or user result to set the cell view.
     */
    func setExerciseResult(_ exercise: Exercise)
    {
        self.exercise = exercise
            
        resultName.setTitle(exercise.exerciseName, for: UIControlState())
        
        if (exercise.fromIntencity)
        {
            cellBackgroundView.backgroundColor = Color.white
            
            resultName.isEnabled = true
            descriptionView.isHidden = true
        }
        else
        {
            cellBackgroundView.backgroundColor = Color.page_background
            
            resultName.isEnabled = false
            descriptionView.isHidden = false
        }
    }
}
