//
//  ServiceDelegate.swift
//  Intencity
//
//  Created by Nick Piscopio on 4/21/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

protocol ViewDelegate
{    
    func onLoadView(_ view: Int, result: String, savedExercises: SavedExercise?, state: Int)
}
