//
//  ServiceDelegate.swift
//  Intencity
//
//  Created by Nick Piscopio on 4/21/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

@objc protocol ViewDelegate
{    
    func onLoadView(view: Int, result: String)
}