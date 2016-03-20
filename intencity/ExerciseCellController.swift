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
    @IBOutlet weak var priorityStackView: UIStackView!
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
                mutableString.appendAttributedString(getMutableString(String(weight), fontSize: Dimention.FONT_SIZE_SMALL, isBold: true))
                mutableString.appendAttributedString(getMutableString(SPACE, fontSize: Dimention.FONT_SIZE_XX_SMALL, isBold: false))
                mutableString.appendAttributedString(getMutableString(LBS_STRING, fontSize: Dimention.FONT_SIZE_X_SMALL, isBold: false))
                
                mutableString.appendAttributedString(getMutableString(SLASH, fontSize: Dimention.FONT_SIZE_SMALL, isBold: false))
            }
            
            mutableString.appendAttributedString(getMutableString(duration, fontSize: Dimention.FONT_SIZE_SMALL, isBold: true))
            
            if (isReps)
            {
                mutableString.appendAttributedString(getMutableString(SPACE, fontSize: Dimention.FONT_SIZE_XX_SMALL, isBold: false))
                mutableString.appendAttributedString(getMutableString(REPS_STRING, fontSize: Dimention.FONT_SIZE_X_SMALL, isBold: false))
            }
        }
        else
        {
            mutableString.appendAttributedString(getMutableString(EDIT_STRING, fontSize: Dimention.FONT_SIZE_SMALL, isBold: true))
        }
        
        editButton.setAttributedTitle(mutableString, forState: .Normal)
    }
    
    func getMutableString(string: String, fontSize: CGFloat, isBold: Bool) -> NSMutableAttributedString
    {
        let attributes = isBold ? UIFont.boldSystemFontOfSize(fontSize) : UIFont.systemFontOfSize(fontSize)
        
        var mutableString = NSMutableAttributedString()
        mutableString = NSMutableAttributedString(string: string, attributes: [ NSFontAttributeName:  attributes])
        mutableString.addAttribute(NSForegroundColorAttributeName, value: Color.secondary_light, range: NSRange(location: 0, length: string.characters.count))
        
        return mutableString
    }
    
    /**
     * Edits the UI of the delete button.
     */
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        var subViews = self.subviews
        let subviewsCount = subviews.count
        
        // Gets the new height of the delete button.
        deleteHeight = exerciseView.frame.height - Dimention.LAYOUT_MARGIN / 2
        
        for (var i = 0; i < subviewsCount; i++)
        {
            let view = subViews[0]
            
            let classView = String(view.classForCoder)

            // The subview of the delete button.
            if (classView == "UITableViewCellDeleteConfirmationView")
            {
                let delete = view
                
                var deleteFrame = delete.frame
                deleteFrame.size.height = deleteHeight
                
                // Rounds the corners of the delete button
                let path = UIBezierPath(roundedRect:delete.bounds, byRoundingCorners:[.TopLeft, .BottomLeft], cornerRadii: CGSizeMake(Dimention.RADIUS, Dimention.RADIUS))
                let maskLayer = CAShapeLayer()
                maskLayer.path = path.CGPath
                
                delete.layer.mask = maskLayer
                delete.frame = deleteFrame
            }
        }
    }
    
    /**
     * Sets the card as an exercise.
     */
    func setAsExercise()
    {
        exerciseDescriptionView.hidden = true
        
        editButton.hidden = false
        
        priorityStackView.hidden = false
        
        exerciseButton.setTitleColor(Color.primary, forState: UIControlState.Normal)
    }
    
    /**
     * Sets the description, then edits the card to show the proper views associated with it.
     */
    func setDescription(description: String)
    {
        exerciseDescription.text = description
        exerciseDescription.textColor = Color.secondary_light
        exerciseDescriptionView.hidden = false
        
        editButton.hidden = true
        
        priorityStackView.hidden = true

        hideButton.hidden = (exerciseButton.titleLabel?.text)! == WARM_UP_STRING
        
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
        delegate?.setExercisePriority(getIndexPath(sender), increasing: true)
    }
    
    @IBAction func setExerciseWithLessPriority(sender: AnyObject)
    {
        delegate?.setExercisePriority(getIndexPath(sender), increasing: false)
    }
    
    func getIndexPath(sender: AnyObject) -> NSIndexPath
    {
        return tableView.indexPathForCell(self)!
    }
}