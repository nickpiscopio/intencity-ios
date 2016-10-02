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
    var awardType: AwardType!
    var awardTitle = ""
    var awardDescription = ""
    var awardImageName = ""
    var amount = 1
    
    init(awardType: AwardType, awardTitle: String, awardDescription: String)
    {
        self.awardType = awardType
        self.awardTitle = awardTitle
        self.awardDescription = awardDescription
    }
    
    init(awardType: AwardType, awardImageName: String, awardDescription: String)
    {
        self.awardType = awardType
        self.awardImageName = awardImageName
        self.awardDescription = awardDescription
    }
    
    /**
     * Sets the amount of awards.
     */
    func setAmountValue(_ amount: Int)
    {
        self.amount  = amount
    }
}
