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

    @IBOutlet weak var routineNameButton: UIButton!
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
        
        storyboard = UIStoryboard(name: Constant.MAIN_STORYBOARD, bundle: nil)
    }
    
    @IBAction func routineNameClicked(_ sender: AnyObject)
    {
        routineDelegate.onRoutineNameClicked()
    }
    
    @IBAction func finishClicked(_ sender: AnyObject)
    {
        routineDelegate.onFinishRoutine()
    }
    
    @IBAction func saveClicked(_ sender: AnyObject)
    {
        routineDelegate.onSaveRoutine()
    }
    
    @IBAction func infoClicked(_ sender: AnyObject)
    {        
        let vc = storyboard.instantiateViewController(withIdentifier: Constant.FITNESS_RECOMMENDATION_VIEW_CONTROLLER) as! FitnessRecommendationViewController
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    /**
     * Sets the header text on the exercise list header.
     *
     * @param completedExerciseTotal    The total number of exercises that have been completed.
     * @param totalExercises            The total number of exercises to complete in this routine.
     */
    func setExerciseTotalLabel(_ completedExerciseTotal: Int, totalExercises: Int)
    {
        let mutableString = NSMutableAttributedString()

        let exerciseTotal = routineName == NSLocalizedString("title_custom_routine", comment: "") ? "?" : String(totalExercises)
        
        mutableString.append(Util.getMutableString(String(completedExerciseTotal) + "/" + exerciseTotal + "  ", fontSize: Dimention.FONT_SIZE_NORMAL, color: Color.white, isBold: true))
        mutableString.append(Util.getMutableString(routineName, fontSize: Dimention.FONT_SIZE_MEDIUM, color: Color.white, isBold: false))
        
        routineNameButton.setAttributedTitle(mutableString, for: UIControlState())
    }
}
