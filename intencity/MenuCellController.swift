//
//  MenuExerciseCellController.swift
//  Intencity
//
//  The cell controller for the exclusion and equipment lists.
//
//  Created by Nick Piscopio on 3/3/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class MenuExerciseCellController: UITableViewCell
{
    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var checkBox: UIButton!
    
    let UNCHECKED = UIImage(named: Constant.CHECKBOX_UNCHECKED)
    let CHECKED = UIImage(named: Constant.CHECKBOX_CHECKED)
    
    var listItemName: String!
    
    weak var delegate: MenuExerciseDelegate?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        exerciseNameLabel.textColor = Color.secondary_dark
    }
    
    /**
     * The click function for the terms of use checkbox and label.
     */
    @IBAction func checkBoxPressed(sender: UIButton)
    {        
        setChecked(!isExerciseHidden())
        
        delegate?.onCheckboxChecked(listItemName)
    }
    
    /**
     * Sets the exercise name in the cell.
     */
    func setListItem(name: String, checked: Bool)
    {
        listItemName = name
        
        exerciseNameLabel.text = listItemName
        
        setChecked(checked)
    }
    
    /**
     * Sets the checkbox check value.
     */
    func setChecked(checked: Bool)
    {
        checkBox.setImage(checked ? CHECKED : UNCHECKED, forState: .Normal)
    }
    
    /**
     * Checks to see if the terms checkbox is checked.
     */
    func isExerciseHidden() -> Bool
    {
        return checkBox.currentImage!.isEqual(CHECKED)
    }
}