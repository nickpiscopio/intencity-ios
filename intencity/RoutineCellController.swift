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
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var routineLevel: UILabel!
    @IBOutlet weak var titleStackView: UIStackView!
    @IBOutlet weak var routineTitle: UILabel!
    @IBOutlet weak var routineDescription: UILabel!
    
    var hasKeys = false
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        routineLevel.textColor = Color.grey_text_transparent
        routineLevel.font = UIFont.boldSystemFontOfSize(Dimention.FONT_SIZE_X_SMALL)
        
        routineTitle.textColor = Color.page_background
        routineDescription.textColor = Color.page_background
        
        contentView.backgroundColor = Color.page_background
    }
    
    /**
     * Sets the description of the routine card.
     */
    func setDescription(totalRoutines: Int)
    {
        let description = totalRoutines > 1 ? RoutineViewController.DEFAULT_ROUTINES_DESCRIPTION : RoutineViewController.DEFAULT_ROUTINE_DESCRIPTION
        
        routineDescription.text = routineTitle.text! == RoutineViewController.CUSTOM_ROUTINE_TITLE ? RoutineViewController.CUSTOM_ROUTINE_DESCRIPTION : String(format: description, arguments: [ String(totalRoutines) ])
    }
    
    /**
     * Sets the background color of the routine card.
     */
    func setCard()
    {
        switch routineTitle.text!
        {
            case RoutineViewController.FEATURED_ROUTINE_TITLE:
                view.backgroundColor = Color.accent
                backgroundImage.image = UIImage(named: "intencity_routine_background")
                routineLevel.text = NSLocalizedString("routine_level_beginner", comment: "")
                break
            case RoutineViewController.SAVED_ROUTINE_TITLE:
                view.backgroundColor = Color.primary_dark
                backgroundImage.image = UIImage(named: "saved_routine_background")
                routineLevel.text = NSLocalizedString("routine_level_advanced", comment: "")
                break
            case RoutineViewController.CUSTOM_ROUTINE_TITLE:
                view.backgroundColor = Color.secondary_dark
                backgroundImage.image = UIImage(named: "custom_routine_background")
                routineLevel.text = NSLocalizedString("routine_level_expert", comment: "")
                break
            default:
                break
        }

    }
}