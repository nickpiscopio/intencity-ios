//
//  IntencityRoutineHeaderCellController.swift
//  Intencity
//
//  The cell controller for a n Intencity Routine header.
//
//  Created by Nick Piscopio on 2/26/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class IntencityRoutineHeaderCellController: UITableViewCell
{
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var editImage: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var view: UIView!
    
    weak var delegate: ButtonDelegate?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        title.textColor = Color.secondary_light
        title.backgroundColor = Color.page_background
        
        view.backgroundColor = Color.page_background
    }
    
    @IBAction func onHeaderClicked(sender: AnyObject)
    {
        delegate?.onButtonClicked()
    }
}