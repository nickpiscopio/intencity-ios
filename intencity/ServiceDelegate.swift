//
//  ServiceDelegate.swift
//  Intencity
//
//  The callback for the ServiceTask.
//
//  Created by Nick Piscopio on 2/10/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

protocol ServiceDelegate
{    
    func onRetrievalSuccessful(_ event: Int, result: String)
    func onRetrievalFailed(_ event: Int)
}
