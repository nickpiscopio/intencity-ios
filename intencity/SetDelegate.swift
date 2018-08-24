//
//  ServiceDelegate.swift
//  Intencity
//
//  The callback for the Sets.
//
//  Created by Nick Piscopio on 2/18/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

protocol SetDelegate: class
{
    func onWeightUpdated(_ index: Int, weight: Float)
    func onDurationUpdated(_ index: Int, duration: String)
    func onIntensityUpdated(_ index: Int, intensity: Int)
}
