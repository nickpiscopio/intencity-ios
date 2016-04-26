//
//  ServiceDelegate.swift
//  Intencity
//
//  The callback for when a generic button is clicked.
//
//  Created by Nick Piscopio on 2/26/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

@objc protocol ButtonDelegate
{    
    func onButtonClicked()
}