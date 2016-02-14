//
//  HeaderCellController.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/14/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.
//

import UIKit

class HeaderCellController: UITableViewCell
{    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // Sets the background color of the header cell.
        self.backgroundColor = Color.transparent
    }
}