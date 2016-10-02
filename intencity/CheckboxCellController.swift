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
    
    var uncheckedImage: UIImage!
    var checkedImage: UIImage!
    
    var listItemName: String!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        titleLabel.textColor = Color.secondary_dark
    }
    
    /**
     * Sets the default checked and unchecked images.
     */
    func setCheckboxImage(_ checkedImage: String, uncheckedImage: String)
    {
        self.uncheckedImage = UIImage(named: uncheckedImage)
        self.checkedImage = UIImage(named: checkedImage)
    }
    
    /**
     * Sets the exercise name in the cell.
     */
    func setListItem(_ name: String, checked: Bool)
    {
        listItemName = name
        
        titleLabel.text = listItemName
        
        setChecked(checked)
    }
    
    /**
     * Sets the checkbox check value.
     */
    func setChecked(_ checked: Bool)
    {
        checkBox.image = checked ? checkedImage : uncheckedImage
    }
    
    /**
     * Checks to see if the checkbox is checked.
     */
    func isChecked() -> Bool
    {
        return checkBox.image!.isEqual(checkedImage)
    }
}
