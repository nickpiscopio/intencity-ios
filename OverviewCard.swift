//
//  RoutineSection.swift
//  Intencity
//
//  The struct for each section in the overview screen.
//
//  Created by Nick Piscopio on 6/21/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class OverviewCard: NSObject
{
    var type: Int!
    var icon: UIImage!
    var title: String!
    var rows: [AnyObject]!
    
    init(type: Int, icon: UIImage, title: String)
    {
        self.type = type
        self.icon = icon
        self.title = title
    }
    
    init(type: Int, rows: [AnyObject])
    {
        self.type = type
        self.rows = rows
    }
}