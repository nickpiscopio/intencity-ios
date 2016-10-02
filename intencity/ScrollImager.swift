//
//  ScrollImager.swift
//  ScrollImager
//
//  Scrolls a view to take a screenshot of it.
//
//  Created by Nick Piscopio on 6/26/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.
//
//  https://github.com/romainmenke/ScrollViewImager

import UIKit

extension UIView {
    
    /**
     Returns a screenshot from the visible area
     */
    var mockup: UIImage {
        get {
            return generateMockup()
        }
    }
    
    fileprivate func generateMockup() -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        self.drawHierarchy(in: rect, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

extension UIScrollView {
    
    /**
     Generate a screenshot by resizing the scrollview
     - unsafe with memory intensive cells
     */
    func screenshot(_ scale: CGFloat) -> UIImage {
        let currentSize = frame.size
        let currentOffset = contentOffset // temp store current offset
        
        frame.size = contentSize
        setContentOffset(CGPoint.zero, animated: false)
        
        
        let rect = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        self.drawHierarchy(in: rect, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        frame.size = currentSize
        setContentOffset(currentOffset, animated: false)
        
        return resizeUIImage(image!, scale: scale)
        
    }
    
    /**
     Generate a screenshot from the content
     - display acts a bit glitchy
     - scrollview will scroll when doing this
     */
    func screenshot(_ scale: CGFloat, completion: @escaping (_ screenshot: UIImage?) -> Void) {
        
        let pointsAndFrames = self.getScreenshotRects()
        let points = pointsAndFrames.points
        let frames = pointsAndFrames.frames
        
        let finalSize = CGSize(width: self.contentSize.width * scale, height: self.contentSize.height * scale)
        
        makeScreenshots(points: points, frames: frames, scale: scale) { (screenshots) -> Void in
            
            let stitched = self.stitchImages(images: screenshots, finalSize: finalSize)
            
            completion(stitched)
            
        }
    }
    
    fileprivate func makeScreenshots(points points_I: [[CGPoint]], frames frames_I: [[CGRect]], scale:CGFloat, completion: @escaping (_ screenshots: [[UIImage]]) -> Void) {
        
        var counter: Int = 0
        
        // use didSet as a responder to the completion handler,instead of a loop, ensuring nice sequential execution
        var images: [[UIImage]] = [] {
            didSet {
                if counter < points_I.count {
                    internalScreenshotRow()
                } else {
                    completion(images)
                }
            }
        }
        
        // same code is used twice -> nested function
        func internalScreenshotRow() {
            makeScreenshotRow(points: points_I[counter], frames: frames_I[counter], scale: scale) { (screenshot) -> Void in
                counter += 1
                images.append(screenshot)
            }
        }
        
        internalScreenshotRow() // start first run
    }
    
    fileprivate func makeScreenshotRow(points points_I: [CGPoint], frames frames_I: [CGRect], scale:CGFloat, completion: @escaping (_ screenshots: [UIImage]) -> Void) {
        
        var counter: Int = 0
        
        // use didSet as a responder to the completion handler,instead of a loop, ensuring nice sequential execution
        var images: [UIImage] = [] {
            didSet {
                if counter < points_I.count {
                    internalTakeScreenshotAtPoint()
                } else {
                    completion(images)
                }
            }
        }
        
        // same code is used twice -> nested function
        func internalTakeScreenshotAtPoint() {
            takeScreenshotAtPoint(point: points_I[counter], scale: scale) { (screenshot) -> Void in
                counter += 1
                images.append(screenshot)
            }
        }
        
        internalTakeScreenshotAtPoint() // start first run
    }
    
    fileprivate func getScreenshotRects() -> (points: [[CGPoint]], frames: [[CGRect]]) {
        
        // start with zero offsets
        let zeroOriginBounds = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        var currentOffset = CGPoint(x: 0, y: 0)
        
        // get the remainder -> last offset in eacht direction will probably not be an exact multipe of bounds width/height
        let xPartial = contentSize.width.truncatingRemainder(dividingBy: bounds.size.width)
        let yPartial = contentSize.height.truncatingRemainder(dividingBy: bounds.size.height)
        
        // get the number of screenshots needed in each direction, without the partials
        let xSlices = Int((contentSize.width - xPartial) / bounds.size.width)
        let ySlices = Int((contentSize.height - yPartial) / bounds.size.height)
        
        // arrays of offsets and frames to use later
        var offsets : [[CGPoint]] = []
        var rects : [[CGRect]] = []
        
        // total number of slices in x dimention
        var xSlicesWithPartial : Int = xSlices
        
        if xPartial > 0 {
            xSlicesWithPartial += 1
        }
        
        // total number of slices in y dimention
        var ySlicesWithPartial : Int = ySlices
        
        if yPartial > 0 {
            ySlicesWithPartial += 1
        }
        
        // loops
        for y in 0..<ySlicesWithPartial {
            
            // add rows and reset x
            var offsetRow : [CGPoint] = []
            var rectRow : [CGRect] = []
            currentOffset.x = 0
            
            for x in 0..<xSlicesWithPartial {
                
                // check for partials
                if y == ySlices && x == xSlices {
                    let rect = CGRect(x: bounds.width - xPartial, y: bounds.height - yPartial, width: xPartial, height: yPartial) // double partial
                    rectRow.append(rect)
                    
                } else if y == ySlices {
                    let rect = CGRect(x: 0, y: bounds.height - yPartial, width: bounds.width, height: yPartial) // y partial
                    rectRow.append(rect)
                    
                } else if x == xSlices {
                    let rect = CGRect(x: bounds.width - xPartial, y: 0, width: xPartial, height: bounds.height) // x partial
                    rectRow.append(rect)
                    
                } else {
                    rectRow.append(zeroOriginBounds) // not a partial
                }
                
                offsetRow.append(currentOffset) // add current offset before altering
                
                if x == xSlices {
                    currentOffset.x = contentSize.width - bounds.size.width // x partial
                } else {
                    currentOffset.x = currentOffset.x + bounds.size.width // not a partial
                }
            }
            if y == ySlices {
                currentOffset.y = contentSize.height - bounds.size.height // y partial
            } else {
                currentOffset.y = currentOffset.y + bounds.size.height // not a partial
            }
            
            offsets.append(offsetRow)
            rects.append(rectRow)
            
        }
        
        return (points: offsets, frames: rects)
    }
    
    fileprivate func takeScreenshotAtPoint(point point_I: CGPoint, scale:CGFloat, completion: @escaping (_ screenshot: UIImage) -> Void) {
        
        let rect = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        let currentOffset = contentOffset // temp store current offset
        
        setContentOffset(point_I, animated: false) // set content offset to the area to be drawn
        
        // add delay to allow redraw
        delay(0.001) {
            
            UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
            self.drawHierarchy(in: rect, afterScreenUpdates: true)
            
            var image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if scale != 1 {
                image = self.resizeUIImage(image!, scale: scale)
            }
            
            self.setContentOffset(currentOffset, animated: false) // reset offset to previous value
            
            completion(image!)
        }
    }
    
    
    fileprivate func delay(_ delay:Double, closure:@escaping ()->()) {
        
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    
    fileprivate func crop(image image_I:UIImage, toRect toRect_I:CGRect) -> UIImage? {
        
        guard let imageRef: CGImage = image_I.cgImage?.cropping(to: toRect_I) else {
            return nil
        }
        return UIImage(cgImage:imageRef)
    }
    
    fileprivate func resizeUIImage(_ image: UIImage, scale: CGFloat) -> UIImage {
        
        let size = image.size
        
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    fileprivate func stitchImages(images images_I: [[UIImage]], finalSize finalSize_I: CGSize) -> UIImage? {
        
        let finalRect = CGRect(x: 0, y: 0, width: finalSize_I.width, height: finalSize_I.height)
        
        guard let firstRow = images_I.first, let _ = firstRow.first else {
            return nil
        }
        
        UIGraphicsBeginImageContext(finalRect.size)
        
        var offsetY : CGFloat = 0
        
        for imageRow in images_I {
            
            var offsetX : CGFloat = 0
            
            for image in imageRow {
                
                let width = image.size.width
                let height = image.size.height
                
                let rect = CGRect(x: offsetX, y: offsetY, width: width, height: height)
                image.draw(in: rect)
                
                offsetX += width
                
            }
            
            if let firstimage = imageRow.first {
                offsetY += firstimage.size.height
            }
        }
        
        let stitchedImages = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return stitchedImages
    }
}
