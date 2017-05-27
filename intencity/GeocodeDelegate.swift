//
//  GeocodeDelegate.swift
//  Intencity
//
//  Created by Greg Dalfonso on 4/23/17.
//  Copyright © 2017 Nick Piscopio. All rights reserved.
//

import Foundation

protocol GeocodeDelegate: class
{
    func onLocationSuccess(address: String)
    func onLocationFailure(errorCode: Int)
}
