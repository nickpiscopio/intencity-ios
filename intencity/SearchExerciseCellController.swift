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
    
    @IBOutlet weak var resultName: UILabel!
    
    @IBOutlet weak var addButton: UIButton!
    
    weak var exerciseSearchDelegate: ExerciseSearchDelegate!
    
    var exercise: Exercise!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        cellBackgroundView.backgroundColor = Color.white
        
        resultName.textColor = Color.secondary_dark
    }
    
    @IBAction func addClicked(sender: AnyObject)
    {
        exerciseSearchDelegate.onExerciseAdded(exercise)
    }
    
    /**
     * Sets the exercise result.
     *
     * @param result    Either the exercise or user result to set the cell view.
     */
    func setExerciseResult(exercise: Exercise)
    {
        self.exercise = exercise
            
        resultName.text = exercise.exerciseName
    }
}