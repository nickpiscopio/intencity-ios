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
    
    weak var exerciseSearchDelegate: ExerciseSearchDelegate!
    
    var navigationController: UINavigationController!
    
    var currentExercises = [Exercise]()
    
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
        
        let viewController = storyboard.instantiateViewControllerWithIdentifier(Constant.SEARCH_VIEW_CONTROLLER) as! SearchViewController
        viewController.state = ServiceEvent.SEARCH_FOR_EXERCISE
        viewController.exerciseSearchDelegate = self
        viewController.currentExercises = currentExercises
        
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    @IBAction func infoClicked(sender: AnyObject)
    {
        let storyboard = UIStoryboard(name: Constant.MAIN_STORYBOARD, bundle: nil)
        
        let viewController = storyboard.instantiateViewControllerWithIdentifier(Constant.FITNESS_RECOMMENDATION_VIEW_CONTROLLER) as! FitnessRecommendationViewController
        
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    /**
     * The callback for when an exercise is added from searching.
     */
    func onExerciseAdded(exercise: Exercise)
    {
        exerciseSearchDelegate.onExerciseAdded(exercise)
    }
    
    func pushViewController()
    {
        

    }
}