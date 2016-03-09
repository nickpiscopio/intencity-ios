//
//  Awards.swift
//  Intencity
//
//  The class for the awards the user is granted.
//
//  Created by Nick Piscopio on 2/14/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

class Awards: NSObject
{
    var awardTitle = ""
    var awardDescription = ""
    var awardImageName = ""
    
    init(awardTitle: String, awardDescription: String)
    {
        self.awardTitle = awardTitle
        self.awardDescription = awardDescription
    }
    
    init(awardImageName: String, awardDescription: String)
    {
        self.awardImageName = awardImageName
        self.awardDescription = awardDescription
    }
}