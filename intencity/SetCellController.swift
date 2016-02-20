//
//  SetCellController.swift
//  Intencity
//
//  The set cell controller.
//
//  Created by Nick Piscopio on 2/18/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.
//
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
        dropDown.bottomOffset = CGPoint(x: 0, y:intensityButton.bounds.height)
        // We set the width here to the largest item in the data source.
        // We do this so the drop down doesn't keep resizing every time an item is selcted.
        dropDown.width = 35
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
     * Calls the callback when the weight is done being edited.
     */
    @IBAction func weightFinishedEditing(sender: AnyObject)
    {
        delegate?.onWeightUpdated(index, weight: Float(weightTextField.text!)!)
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