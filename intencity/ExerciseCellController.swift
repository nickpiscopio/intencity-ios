//
//  ExerciseCellController.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/14/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class ExerciseCellController: UITableViewCell
{
    @IBOutlet weak var exerciseView: UIView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var exerciseButton: UIButton!
    @IBOutlet weak var exerciseDescription: UILabel!
    @IBOutlet weak var editStackView: UIStackView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var exerciseDescriptionView: UIView!
    @IBOutlet weak var hideButton: IntencityButtonNoBackground!
    
    let WARM_UP_STRING = NSLocalizedString("warm_up", comment: "")
    
    let EDIT_STRING = NSLocalizedString("edit", comment: "")
    
    let LBS_STRING = NSLocalizedString("title_lbs", comment: "")
    let REPS_STRING = NSLocalizedString("title_reps", comment: "")
    let SPACE = " "
    let SLASH = " / "
    
    weak var delegate: ExerciseDelegate?
    
    var tableView: UITableView!
    
    var deleteHeight: CGFloat = 0
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.backgroundColor = Color.page_background
    }
    
    /**
     * Initialize the terms of use text attributes.
     */
    func setEditButtonTitle(weight: Float, duration: String, isReps: Bool)
    {
        let mutableString = NSMutableAttributedString()
        
        let addWeight = weight > 0.0
        let addDuration = duration != Constant.RETURN_NULL && Util.convertToInt(duration) > 0
        
        if (addWeight || addDuration)
        {
            if (addWeight)
            {
                mutableString.appendAttributedString(Util.getMutableString(String(weight), fontSize: Dimention.FONT_SIZE_SMALL, color: Color.secondary_light, isBold: true))
                mutableString.appendAttributedString(Util.getMutableString(SPACE, fontSize: Dimention.FONT_SIZE_XX_SMALL, color: Color.secondary_light, isBold: false))
                mutableString.appendAttributedString(Util.getMutableString(LBS_STRING, fontSize: Dimention.FONT_SIZE_X_SMALL, color: Color.secondary_light, isBold: false))
                
                mutableString.appendAttributedString(Util.getMutableString(SLASH, fontSize: Dimention.FONT_SIZE_SMALL, color: Color.secondary_light, isBold: false))
            }
            
            mutableString.appendAttributedString(Util.getMutableString(duration, fontSize: Dimention.FONT_SIZE_SMALL, color: Color.secondary_light, isBold: true))
            
            if (isReps)
            {
                mutableString.appendAttributedString(Util.getMutableString(SPACE, fontSize: Dimention.FONT_SIZE_XX_SMALL, color: Color.secondary_light, isBold: false))
                mutableString.appendAttributedString(Util.getMutableString(REPS_STRING, fontSize: Dimention.FONT_SIZE_X_SMALL, color: Color.secondary_light, isBold: false))
            }
        }
        else
        {
            mutableString.appendAttributedString(Util.getMutableString(EDIT_STRING, fontSize: Dimention.FONT_SIZE_SMALL, color: Color.secondary_light, isBold: true))
        }
        
        editButton.setAttributedTitle(mutableString, forState: .Normal)
    }
    
    /**
     * Sets the card as an exercise.
     */
    func setAsExercise(fromIntencity: Bool)
    {
        exerciseDescriptionView.hidden = true
        
        hideButton.hidden = false
        
        editStackView.hidden = false
        
        if (fromIntencity)
        {
            exerciseButton.enabled = true
            exerciseButton.setTitleColor(Color.primary, forState: UIControlState.Normal)
        }
        else
        {
            exerciseButton.enabled = false
            exerciseButton.setTitleColor(Color.secondary_dark, forState: UIControlState.Normal)
        }
    }
    
    /**
     * Sets the description, then edits the card to show the proper views associated with it.
     */
    func setDescription(description: String)
    {
        exerciseDescription.text = description
        exerciseDescription.textColor = Color.secondary_light
        exerciseDescriptionView.hidden = false
        
        editStackView.hidden = true

        hideButton.hidden = true
        
        exerciseButton.setTitleColor(Color.secondary_light, forState: UIControlState.Normal)
    }
    
    /**
     * Sets the edit button text
     */
    func setEditText(set: Set)
    {
        let weight = set.weight
        let reps = set.reps
        let duration = set.duration
        
        let isReps = reps > 0
        
        setEditButtonTitle(weight, duration: isReps ? String(reps) : duration, isReps: isReps)
    }
    @IBAction func hideClicked(sender: AnyObject)
    {
        delegate?.onHideClicked(getIndexPath(sender))
    }
    
    @IBAction func editClicked(sender: AnyObject)
    {
        delegate?.onEditClicked(getIndexPath(sender).row)
    }
    
    @IBAction func exerciseClicked(sender: AnyObject)
    {
        delegate?.onExerciseClicked((exerciseButton.titleLabel?.text)!)
    }
    
    @IBAction func setExerciseWithMorePriority(sender: AnyObject)
    {
        delegate?.onSetExercisePriority(getIndexPath(sender), increasing: true)
    }
    
    @IBAction func setExerciseWithLessPriority(sender: AnyObject)
    {
        delegate?.onSetExercisePriority(getIndexPath(sender), increasing: false)
    }
    
    func getIndexPath(sender: AnyObject) -> NSIndexPath
    {
        return tableView.indexPathForCell(self)!
    }
}