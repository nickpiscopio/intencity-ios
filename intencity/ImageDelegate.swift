//
//  ImageDelegate.swift
//  Intencity
//
//  Created by Nick Piscopio on 4/1/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import Foundation

@objc protocol ImageDelegate
{
    func onImageRetrieved(index: Int, image: UIImage)
}