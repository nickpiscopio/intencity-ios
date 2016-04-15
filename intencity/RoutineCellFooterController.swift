//
//  RoutineCellFooterController.swift
//  Intencity
//
//  The controller for the exercise list header.
//
//  Created by Nick Piscopio on 4/15/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class RoutineCellFooterController: UITableViewCell
{
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var createRoutineTitle: UILabel!
    @IBOutlet weak var createRoutineButton: UIButton!
    
    var navigationController: UINavigationController!
    
    var storyboard: UIStoryboard!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        view.backgroundColor = Color.page_background
        createRoutineTitle.textColor = Color.secondary_light
        createRoutineTitle.text = NSLocalizedString("create_routine_title", comment: "")
        
        createRoutineButton.setTitle(NSLocalizedString("create_routine_button", comment: ""), forState: .Normal)
        
        storyboard = UIStoryboard(name: Constant.MAIN_STORYBOARD, bundle: nil)
    }
    
    @IBAction func createRoutine(sender: AnyObject)
    {
        let vc = storyboard.instantiateViewControllerWithIdentifier(Constant.CUSTOM_ROUTINE_VIEW_CONTROLLER) as! CustomRoutineViewController
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
}