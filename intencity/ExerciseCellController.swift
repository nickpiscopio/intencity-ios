//
//  ExerciseCellController.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/14/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class ExerciseCellController: UITableViewCell
{
    @IBOutlet weak var exerciseName: UIButton!
    
    weak var delegate: ExerciseDelegate?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.backgroundColor = Color.page_background
    }
    
    @IBAction func exerciseClicked(sender: AnyObject)
    {
        print("Exercise clicked: \(exerciseName.titleLabel?.text!)")
        
        delegate?.onExerciseClicked((exerciseName.titleLabel?.text)!)
    }
}