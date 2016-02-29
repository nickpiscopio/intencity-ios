//
//  ExerciseListHeaderController.swift
//  Intencity
//
//  The controller for the exercise list header.
//
//  Created by Nick Piscopio on 2/19/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class ExerciseListHeaderController: UITableViewCell, ExerciseSearchDelegate
{
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var exerciseTotalLabel: UILabel!
    @IBOutlet weak var routineNameLabel: UILabel!
    
    var navigationController: UINavigationController!
    
    weak var exerciseSearchDelegate: ExerciseSearchDelegate!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        view.backgroundColor = Color.secondary_light
        
        exerciseTotalLabel.textColor = Color.white
        routineNameLabel.textColor = Color.white
    }
    
    @IBAction func searchClicked(sender: AnyObject)
    {
        let storyboard = UIStoryboard(name: Constant.MAIN_STORYBOARD, bundle: nil)
        
        let viewController = storyboard.instantiateViewControllerWithIdentifier("SearchViewController") as! SearchViewController
        viewController.state = ServiceEvent.SEARCH_FOR_EXERCISE
        viewController.exerciseSearchDelegate = self
        
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    @IBAction func infoClicked(sender: AnyObject)
    {
        
    }
    
    /**
     * The callback for when an exercise is added from searching.
     */
    func onExerciseAdded(exercise: Exercise)
    {
        exerciseSearchDelegate.onExerciseAdded(exercise)
    }
}