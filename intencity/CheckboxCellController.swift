//
//  CheckboxCellController.swift
//  Intencity
//
//  The cell controller for the a checkbox cell.
//
//  Created by Nick Piscopio on 3/3/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class CheckboxCellController: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkBox: UIImageView!
    @IBOutlet weak var separator: UIView!
    
    let UNCHECKED = UIImage(named: Constant.CHECKBOX_UNCHECKED)
    let CHECKED = UIImage(named: Constant.CHECKBOX_CHECKED)
    
    var listItemName: String!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        titleLabel.textColor = Color.secondary_dark
    }
    
    /**
     * Sets the exercise name in the cell.
     */
    func setListItem(name: String, checked: Bool)
    {
        listItemName = name
        
        titleLabel.text = listItemName
        
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
     * Checks to see if the checkbox is checked.
     */
    func isChecked() -> Bool
    {
        return checkBox.image!.isEqual(CHECKED)
    }
}