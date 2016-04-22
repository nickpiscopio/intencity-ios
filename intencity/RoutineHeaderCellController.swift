//
//  RoutineHeaderCellController.swift
//  Intencity
//
//  The cell controller for the routine header.
//
//  Created by Nick Piscopio on 4/22/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class RoutineHeaderCellController: UITableViewCell
{
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var userInputIndicator: IntencityCircleView!
    @IBOutlet weak var randomInputIndicator: IntencityCircleView!
    @IBOutlet weak var constantInputIndicator: IntencityCircleView!

    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var associatedButtonImage: UIImageView!
    
    var storyboard: UIStoryboard!
    var navigationController: UINavigationController!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        title.textColor = Color.secondary_light
        title.backgroundColor = Color.page_background
        
        view.backgroundColor = Color.page_background
        
        userInputIndicator.backgroundColor = Color.accent
        randomInputIndicator.backgroundColor = Color.primary_dark
        constantInputIndicator.backgroundColor = Color.card_button_delete_select
        
        storyboard = UIStoryboard(name: Constant.MAIN_STORYBOARD, bundle: nil)
        
        userInputIndicator.hidden = true
        randomInputIndicator.hidden = true
        constantInputIndicator.hidden = true
    }
    
    func setClickEnabled(enabled: Bool)
    {
        editButton.hidden = !enabled
        associatedButtonImage.hidden = !enabled
    }
    
    @IBAction func editRoutines(sender: AnyObject)
    {
        let vc = storyboard.instantiateViewControllerWithIdentifier(Constant.CUSTOM_ROUTINE_VIEW_CONTROLLER) as! CustomRoutineViewController
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
}