//
//  ImageDelegate.swift
//  Intencity
//
//  Created by Nick Piscopio on 4/1/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import Foundation

protocol ImageDelegate: class
{
    func onImageRetrieved(_ index: Int, image: UIImage, newUpload: Bool)
    func onImageRetrievalFailed()
}
