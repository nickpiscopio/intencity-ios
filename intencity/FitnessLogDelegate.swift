//
//  IntencityRoutineDelegate.swift
//  Intencity
//
//  Created by Nick Piscopio on 4/27/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

protocol IntencityRoutineDelegate
{
    func onRoutineSaved(_ hasMoreRoutines: Bool)
    func onRoutineUpdated(_ groups: [RoutineGroup])
}
