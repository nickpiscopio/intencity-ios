//
//  ServiceDelegate.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/10/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

@objc protocol ServiceDelegate
{
    func onRetrievalSuccessful(result: String)
    func onRetrievalFailed()
}
