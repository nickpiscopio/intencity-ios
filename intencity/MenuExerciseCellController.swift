//
//  MenuExerciseCellController.swift
//  Intencity
//
//  The cell controller for the equipment lists.
//
//  Created by Nick Piscopio on 3/3/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class MenuExerciseCellController: UITableViewCell
{
    @IBOutlet weak var exerciseNameLabel: UILabel!    
    @IBOutlet weak var checkBox: UIImageView!
    @IBOutlet weak var separator: UIView!
    
    let UNCHECKED = UIImage(named: Constant.CHECKBOX_UNCHECKED)
    let CHECKED = UIImage(named: Constant.CHECKBOX_CHECKED)
    
    var listItemName: String!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        exerciseNameLabel.textColor = Color.secondary_dark
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
        checkBox.image = checked ? CHECKED : UNCHECKED
    }
    
    /**
     * Checks to see if the terms checkbox is checked.
     */
    func isExerciseHidden() -> Bool
    {
        return checkBox.image!.isEqual(CHECKED)
    }
}