//
//  RoutineCellController.swift
//  Intencity
//
//  The cell controller for the routine cells.
//
//  Created by Nick Piscopio on 4/25/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class RoutineCellController: UITableViewCell
{
    @IBOutlet weak var view: IntencityCardView!
    
    @IBOutlet weak var routineTitle: UILabel!
    @IBOutlet weak var routineDescription: UILabel!
    @IBOutlet weak var indicator1: IntencityCircleView!
    @IBOutlet weak var indicator2: IntencityCircleView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        routineTitle.textColor = Color.page_background
        routineDescription.textColor = Color.page_background
        
        contentView.backgroundColor = Color.page_background
    }
    
    func setDescription(totalRoutines: Int)
    {
        routineDescription.text = routineTitle.text! == RoutineViewController.CUSTOM_ROUTINE_TITLE ? RoutineViewController.CUSTOM_ROUTINE_DESCRIPTION : String(format: RoutineViewController.DEFAULT_ROUTINE_DESCRIPTION, arguments: [ String(totalRoutines) ])
    }
    
    func setBackground()
    {
        switch routineTitle.text!
        {
            case RoutineViewController.CUSTOM_ROUTINE_TITLE:
                view.backgroundColor = Color.secondary_dark
                break
            case RoutineViewController.DEFAULT_ROUTINE_TITLE:
                view.backgroundColor = Color.secondary_light
                break
            case RoutineViewController.SAVED_ROUTINE_TITLE:
                view.backgroundColor = Color.primary
                break
            default:
                break
        }

    }
}