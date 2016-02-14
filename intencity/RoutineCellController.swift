//
//  RoutineCellController.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/13/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class RoutineCellController: IntencityCard
{
    @IBOutlet weak var routinePickerView: UIPickerView!
    
    weak var delegate: RoutineDelegate?
    
    var pickerDataSource = [String]()
    
    var selectedRoutineNumber = 0
    
    @IBOutlet weak var routineTitle: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        routineTitle.text = NSLocalizedString("title_routine", comment: "")
        startButton.setTitle(NSLocalizedString("start", comment: ""), forState: .Normal)
    }
    
    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return pickerDataSource.count
    }
    
    // pragma MARK: UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
        return pickerDataSource[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        // Need to add 1 to the routine so we get back the correct value when setting the muscle group for today.
        // CompletedMuscleGroup starts at 1.
        selectedRoutineNumber = row + 1
    }
    
    /**
     * The start button click.
     */
    @IBAction func startExercising(sender: AnyObject)
    {
        delegate!.onStartExercising(selectedRoutineNumber)
    }
}