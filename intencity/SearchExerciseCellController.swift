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
    
    @IBOutlet weak var addButton: UIButton!
    
    weak var exerciseSearchDelegate: ExerciseSearchDelegate!
    
    var exercise: Exercise!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        cellBackgroundView.backgroundColor = Color.white
        
        resultName.setTitleColor(Color.secondary_dark, forState: .Normal)
        resultName.setTitleColor(Color.secondary_dark, forState: .Highlighted)
    }
    
    @IBAction func addClicked(sender: AnyObject)
    {
        exerciseSearchDelegate.onExerciseAdded(exercise)
    }
    
    @IBAction func resultClicked(sender: AnyObject)
    {
        exerciseSearchDelegate?.onExerciseClicked((resultName.titleLabel?.text)!)
    }
    
    /**
     * Sets the exercise result.
     *
     * @param result    Either the exercise or user result to set the cell view.
     */
    func setExerciseResult(exercise: Exercise)
    {
        self.exercise = exercise
            
        resultName.setTitle(exercise.exerciseName, forState: .Normal)
    }
}