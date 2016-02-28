//
//  UIResponder.swift
//
//  Created by Groom on 23/03/2015.
//  Copyright (c) 2015 Stephen Groom. All rights reserved.

import UIKit

extension UIResponder
{
    // Class var not supported in 1.0
    private struct CurrentFirstResponder
    {
        weak static var currentFirstResponder: UIResponder?
    }
    
    private class var currentFirstResponder: UIResponder?
    {
        get
        {
            return CurrentFirstResponder.currentFirstResponder
        }
        
        set(newValue)
        {
            CurrentFirstResponder.currentFirstResponder = newValue
        }
    }
    
    class func getCurrentFirstResponder() -> UIResponder?
    {
        currentFirstResponder = nil
        
        UIApplication.sharedApplication().sendAction("findFirstResponder", to: nil, from: nil, forEvent: nil)
        
        return currentFirstResponder
    }
    
    func findFirstResponder()
    {
        UIResponder.currentFirstResponder = self
    }
}