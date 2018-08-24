//
//  IntencityRoutineFooterCellController.swift
//  Intencity
//
//  The cell controller for a n Intencity Routine header.
//
//  Created by Nick Piscopio on 2/26/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class IntencityRoutineFooterCellController: UITableViewCell
{
    weak var delegate: ButtonDelegate?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    @IBAction func onFooterClicked(_ sender: AnyObject)
    {
        delegate?.onButtonClicked()
    }
}
