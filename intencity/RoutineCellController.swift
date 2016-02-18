//
//  RoutineCellController.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/13/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import DropDown

class RoutineCellController: UITableViewCell
{
    @IBOutlet weak var routineTitle: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var routineButton: UIButton!
    @IBOutlet weak var routineDropDown: UIButton!
    
    weak var delegate: RoutineDelegate?
    
    var dropDown = DropDown()
    
    var dataSource = [String]()
    
    var selectedRoutineNumber = 0  
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        backgroundColor = Color.transparent
        
        routineTitle.text = NSLocalizedString("title_routine", comment: "")
        startButton.setTitle(NSLocalizedString("start", comment: ""), forState: .Normal)
        
        routineButton.setTitleColor(Color.secondary_dark, forState: .Normal)
        
        dropDown.selectionAction = { [unowned self] (index, item) in
            // Need to add 1 to the routine so we get back the correct value when setting the muscle group for today.
            // CompletedMuscleGroup starts at 1.
            self.selectedRoutineNumber = index + 1
            self.routineButton.setTitle(item, forState: .Normal)
        }

        dropDown.anchorView = routineButton
        dropDown.bottomOffset = CGPoint(x: 0, y: routineButton.bounds.height + routineButton.bounds.height / 2)
        dropDown.width = 147
    }
    
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
    
    func setDropDownDataSource(recommended: Int)
    {
        dropDown.dataSource = dataSource
        dropDown.selectRowAtIndex(recommended)
    }

    /**
     * The start button click.
     */
    @IBAction func startExercising(sender: AnyObject)
    {
        delegate!.onStartExercising(selectedRoutineNumber)
    }
}