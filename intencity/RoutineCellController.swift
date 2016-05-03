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
    
    @IBOutlet weak var titleStackView: UIStackView!
    @IBOutlet weak var routineTitle: UILabel!
    @IBOutlet weak var routineDescription: UILabel!
    
    var hasKeys = false
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
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
     * Adds the key indicators to the stackview if they aren't already added.
     * These keys inform the user what exercises are associated with each routine type.
     * 
     * @param keys  The key indicators to add to the stackview 
     */
    func setKeys(keys: [Int])
    {
        if (!hasKeys)
        {
            let keyCount = keys.count
            for i in 0..<keyCount
            {
                let indicator = IntencityCircleView(frame: CGRectMake(0,0,8,8))
                indicator.heightAnchor.constraintEqualToConstant(8).active = true;
                indicator.widthAnchor.constraintEqualToConstant(8).active = true;
                switch keys[i]
                {
                    case RoutineKeys.RANDOM:
                        indicator.backgroundColor = Color.accent
                        break
                    case RoutineKeys.USER_SELECTED:
                        indicator.backgroundColor = Color.card_button_delete_deselect
                        break
                    case RoutineKeys.CONSECUTIVE:
                        indicator.backgroundColor = Color.primary_dark
                        break
                    default:
                        break
                }
                
                titleStackView.addArrangedSubview(indicator)
                titleStackView.translatesAutoresizingMaskIntoConstraints = false;
                
                hasKeys = true
            }
        }
    }
    
    /**
     * Sets the background color pf the routine card.
     */
    func setBackground()
    {
        switch routineTitle.text!
        {
            case RoutineViewController.CUSTOM_ROUTINE_TITLE:
                view.backgroundColor = Color.secondary_dark
                backgroundImage.image = UIImage(named: "custom_routine_background")
                break
            case RoutineViewController.INTENCITY_ROUTINE_TITLE:
                view.backgroundColor = Color.secondary_light
                backgroundImage.image = UIImage(named: "intencity_routine_background")
                break
            case RoutineViewController.SAVED_ROUTINE_TITLE:
                view.backgroundColor = Color.primary
                backgroundImage.image = UIImage(named: "saved_routine_background")
                break
            default:
                break
        }

    }
}