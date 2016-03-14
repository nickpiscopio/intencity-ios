//
//  SetCellController.swift
//  Intencity
//
//  The set cell controller.
//
//  Created by Nick Piscopio on 2/18/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import DropDown

class SetCellController: UITableViewCell
{
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var setNumberLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var intensityButton: UIButton!
    @IBOutlet weak var intensityDropDown: UIButton!
    
    let dropDown = DropDown()
    
    var index: Int!
    
    var isReps = true
    
    weak var delegate: SetDelegate?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.backgroundColor = Color.transparent
        
        setNumberLabel.textColor = Color.secondary_dark
        weightLabel.textColor = Color.secondary_dark
        weightLabel.text = NSLocalizedString("title_lbs", comment: "")
        
        weightTextField.textColor = Color.secondary_dark
        durationTextField.textColor = Color.secondary_dark
        intensityButton.setTitleColor(Color.secondary_dark, forState: .Normal)
        
        // Initialize the duration dropdown.
        dropDown.dataSource = [ "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" ]
        dropDown.selectionAction = { [unowned self] (index, item) in
            self.intensityButton.setTitle(item, forState: .Normal)
            // Call the delegate to update the intensity.
            self.delegate?.onIntensityUpdated(self.index, intensity: Int(item)!)
        }
        dropDown.anchorView = intensityButton
        dropDown.bottomOffset = CGPoint(x: intensityButton.bounds.width / 2, y: 0)
        // We set the width here to the largest item in the data source.
        // We do this so the drop down doesn't keep resizing every time an item is selcted.
        dropDown.width = 35
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        let text = textField.text!
        
        // Allow a backspace.
        if (string == "")
        {
            return true
        }
        // Allow numbers in the textfields.
        else if (Util.isFieldValid(string, regEx: "[0-9]+"))
        {
            if (textField == weightTextField)
            {
                // Allow up to 5 characters.
                // Allow backspaces here. The reason we need this is because if a backspace is being pressed, then nothing happens if we don't allow string == "" if the character count is already 5.
                return text.characters.count < 5
            }
            else
            {
                let value = isReps ? Int(text) : Util.convertToInt(text)
                let maxValue = 100000
                
                // Allow up to max value.
                // This makes the value 1 digit higher, but at that point we will return false.
                return value < maxValue
            }
        }
        else
        {
            return false
        }
    }
    
    /**
     * The drop down click.
     */
    @IBAction func showOrDismiss(sender: AnyObject)
    {
        if dropDown.hidden
        {
            dropDown.show()
        }
        else
        {
            dropDown.hide()
        }
    }
    
    /**
     * The weight change function to format the weight.
     */
    @IBAction func weightChanged(sender: AnyObject)
    {
        let weight = weightTextField.text!
        
        weightTextField.text = Util.convertToWeight(weight)
    }
    
    /**
     * The duration change function to format the duration.
     */
    @IBAction func durationChanged(sender: AnyObject)
    {
        if (!isReps)
        {
            let duration = durationTextField.text!
            
            durationTextField.text = Util.convertToTime(Util.convertToInt(duration))
        }
    }
    
    /**
     * Calls the callback when the weight is done being edited.
     */
    @IBAction func weightFinishedEditing(sender: AnyObject)
    {
        let weight = weightTextField.text
        
        delegate?.onWeightUpdated(index, weight: weight != "" ? Float(weight!)! : 0.0)
    }
    
    /**
     * Calls the callback when the duration is done being edited.
     */
    @IBAction func durationFinishedEditing(sender: AnyObject)
    {
        let duration: String? = durationTextField.text!
        if (duration != nil)
        {
            delegate?.onDurationUpdated(index, duration: duration!)
        }        
    }
}