//
//  UIResponder.swift
//
//  Created by Groom on 23/03/2015.
//  Copyright (c) 2015 Stephen Groom. All rights reserved.

import UIKit

extension UIResponder
{
    // Class var not supported in 1.0
    fileprivate struct CurrentFirstResponder
    {
        weak static var currentFirstResponder: UIResponder?
    }
    
    fileprivate class var currentFirstResponder: UIResponder?
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
        
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder), to: nil, from: nil, for: nil)
        
        return currentFirstResponder
    }
    
    @objc func findFirstResponder()
    {
        UIResponder.currentFirstResponder = self
    }
}
