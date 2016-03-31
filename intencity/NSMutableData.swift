//
//  NSMutableData.swift
//  Intencity
//
//  An extention of NSMutableData.
//
//  Created by Nick Piscopio on 3/31/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

extension NSMutableData
{
    func appendString(string: String)
    {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        appendData(data!)
    }
}