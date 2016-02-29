//
//  AboutCellController.swift
//  Intencity
//
//  The controller for the search cells.
//
//  Created by Nick Piscopio on 2/29/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class SearchCellController: UITableViewCell
{
    @IBOutlet weak var cellBackgroundView: UIView!
    
    @IBOutlet weak var resultName: UILabel!
    
    @IBOutlet weak var addButton: UIButton!
    
    var state: Int!
    
    var result: AnyObject?
    
    weak var exerciseSearchDelegate: ExerciseSearchDelegate!
    weak var userSearchDelegate: UserSearchDelegate!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        cellBackgroundView.backgroundColor = Color.white
        
        resultName.textColor = Color.secondary_dark
    }
    
    @IBAction func addClicked(sender: AnyObject)
    {
        if (state == ServiceEvent.SEARCH_FOR_EXERCISE)
        {
            exerciseSearchDelegate.onExerciseAdded(result as! Exercise)
        }
        else
        {
            userSearchDelegate.onUserAdded(result as! User)
        }
    }
    
    /**
     * Sets the search result state and result.
     *
     * @param state     The state of the view.
     *                  Either ServiceEvent.SEARCH_FOR_EXERCISE or ServiceEvent.SEARCH_FOR_USER
     * @param result    Either the exercise or user result to set the cell view.
     */
    func setSearchResult(state: Int, result: AnyObject?)
    {
        self.state = state
        self.result = result
        
        if (self.state == ServiceEvent.SEARCH_FOR_EXERCISE)
        {
            let exercise = result as! Exercise
            
            resultName.text = exercise.exerciseName
        }
        else
        {
            let user = result as! User
            
            resultName.text = user.firstName + " " + user.lastName
        }
    }
}