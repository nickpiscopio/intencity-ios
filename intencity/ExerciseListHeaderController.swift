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
    @IBOutlet weak var routineNameLabel: UILabel!
    @IBOutlet weak var saveButton: IntencityButtonNoBackgroundDark!
    
    weak var routineDelegate: RoutineDelegate!
    
    var navigationController: UINavigationController!
    
    var currentExercises = [Exercise]()
    
    var storyboard: UIStoryboard!
    
    var routineName: String!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        view.backgroundColor = Color.secondary_light

        routineNameLabel.textColor = Color.white
        
        storyboard = UIStoryboard(name: Constant.MAIN_STORYBOARD, bundle: nil)
    }
    
    @IBAction func finishClicked(sender: AnyObject)
    {
        routineDelegate.onFinishRoutine()
    }
    
    @IBAction func saveClicked(sender: AnyObject)
    {
        routineDelegate.onSaveRoutine()
    }
    
    @IBAction func infoClicked(sender: AnyObject)
    {        
        let viewController = storyboard.instantiateViewControllerWithIdentifier(Constant.FITNESS_RECOMMENDATION_VIEW_CONTROLLER) as! FitnessRecommendationViewController
        
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    /**
     * Sets the header text on the exercise list header.
     *
     * @param completedExerciseTotal    The total number of exercises that have been completed.
     * @param totalExercises            The total number of exercises to complete in this routine.
     */
    func setExerciseTotalLabel(completedExerciseTotal: Int, totalExercises: Int)
    {
        let mutableString = NSMutableAttributedString()

        mutableString.appendAttributedString(Util.getMutableString(String(completedExerciseTotal) + "/" + String(totalExercises) + "  ", fontSize: Dimention.FONT_SIZE_NORMAL, color: Color.white, isBold: true))
        mutableString.appendAttributedString(Util.getMutableString(routineName, fontSize: Dimention.FONT_SIZE_NORMAL, color: Color.white, isBold: false))
        
        routineNameLabel.attributedText = mutableString
    }
}