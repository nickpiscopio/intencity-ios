//
//  ExerciseCellController.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/14/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class ExerciseCellController: UITableViewCell
{
    @IBOutlet weak var exerciseButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    weak var delegate: ExerciseDelegate?
    
    var index: Int!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.backgroundColor = Color.page_background
        
        exerciseButton.setTitleColor(Color.primary, forState: UIControlState.Normal)
        
        editButton.setTitleColor(Color.secondary_light, forState: UIControlState.Normal)
        editButton.setTitle(NSLocalizedString("edit", comment: ""), forState: .Normal)
    }
    
    @IBAction func exerciseClicked(sender: AnyObject)
    {
        delegate?.onExerciseClicked((exerciseButton.titleLabel?.text)!)
    }
    
    @IBAction func EditedClicked(sender: AnyObject)
    {
        delegate?.onEditClicked(index)
    }
}