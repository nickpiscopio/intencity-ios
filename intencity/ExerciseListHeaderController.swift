//
//  ExerciseListHeaderController.swift
//  Intencity
//
//  The controller for the exercise list header.
//
//  Created by Nick Piscopio on 2/19/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class ExerciseListHeaderController: UITableViewCell
{
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var exerciseTotalLabel: UILabel!
    @IBOutlet weak var routineNameLabel: UILabel!
    @IBOutlet weak var saveButton: IntencityButtonNoBackgroundDark!
    
    weak var saveDelegate: SaveDelegate!
    
    var navigationController: UINavigationController!
    
    var currentExercises = [Exercise]()
    
    var storyboard: UIStoryboard!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        view.backgroundColor = Color.secondary_light
        
        exerciseTotalLabel.textColor = Color.white
        routineNameLabel.textColor = Color.white
        
        storyboard = UIStoryboard(name: Constant.MAIN_STORYBOARD, bundle: nil)
    }
    
    @IBAction func saveClicked(sender: AnyObject)
    {
        saveDelegate.onSaveRoutine()
    }
    
    @IBAction func infoClicked(sender: AnyObject)
    {        
        let viewController = storyboard.instantiateViewControllerWithIdentifier(Constant.FITNESS_RECOMMENDATION_VIEW_CONTROLLER) as! FitnessRecommendationViewController
        
        self.navigationController!.pushViewController(viewController, animated: true)
    }
}