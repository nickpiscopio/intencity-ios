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

class SetCellController: UITableViewCell
{
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var setNumberLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var intensityLabel: UILabel!
    @IBOutlet weak var intensityDropDownImageView: UIImageView!
    
    var index: Int!
    
    weak var delegate: SetDelegate?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.backgroundColor = Color.transparent
        
        setNumberLabel.textColor = Color.secondary_dark
        weightLabel.textColor = Color.secondary_dark
        weightLabel.text = NSLocalizedString("title_lbs", comment: "")
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
        let duration: Int? = Int(durationTextField.text!)
        if (duration != nil)
        {
            delegate?.onRepsUpdated(index, reps: duration!)
        }        
    }
}