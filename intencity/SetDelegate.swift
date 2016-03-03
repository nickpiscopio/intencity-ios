//
//  ServiceDelegate.swift
//  Intencity
//
//  The callback for the Sets.
//
//  Created by Nick Piscopio on 2/18/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

@objc protocol SetDelegate
{
    func onWeightUpdated(index: Int, weight: Float)
    func onDurationUpdated(index: Int, duration: String)
    func onIntensityUpdated(index: Int, intensity: Int)
}