//
//  RoutineCellFooterController.swift
//  Intencity
//
//  The controller for the routine list footer.
//
//  Created by Nick Piscopio on 4/15/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class RoutineCellFooterController: UITableViewCell
{
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var userInputStackView: UIStackView!
    @IBOutlet weak var randomInputStackView: UIStackView!
    @IBOutlet weak var consecutiveInputStackView: UIStackView!
    
    @IBOutlet weak var userInputIndicator: IntencityCircleView!
    @IBOutlet weak var userInputLabel: UILabel!
    @IBOutlet weak var randomInputIndicator: IntencityCircleView!
    @IBOutlet weak var randomInputLabel: UILabel!
    @IBOutlet weak var consecutiveInputIndicator: IntencityCircleView!
    @IBOutlet weak var consecutiveLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        view.backgroundColor = Color.page_background
        
        userInputIndicator.backgroundColor = Color.card_button_delete_deselect
        randomInputIndicator.backgroundColor = Color.accent
        consecutiveInputIndicator.backgroundColor = Color.primary_dark
        
        userInputLabel.textColor = Color.secondary_light
        randomInputLabel.textColor = Color.secondary_light
        consecutiveLabel.textColor = Color.secondary_light
        
        userInputLabel.text = NSLocalizedString("key_user_selected", comment: "")
        randomInputLabel.text = NSLocalizedString("key_random", comment: "")
        consecutiveLabel.text = NSLocalizedString("key_consecutive", comment: "")
    }
}