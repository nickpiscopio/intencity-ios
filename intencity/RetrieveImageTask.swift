//
//  ServiceTask.swift
//  Intencity
//
//  The task that uploads an iamge to the server.
//
//  Created by Nick Piscopio on 3/31/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import Foundation

class RetrieveImageTask
{
    init(delegate: ImageDelegate?, link: String)
    {        
        guard
            let url = NSURL(string: link)
            else
            {
                dispatch_async(dispatch_get_main_queue())
                {
                    delegate?.onImageRetrievalFailed()
                }
        
                return
            }
        
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            guard
                let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
                let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
                let data = data where error == nil,
                let image = UIImage(data: data)
                else
                {
                    dispatch_async(dispatch_get_main_queue())
                    {
                        delegate?.onImageRetrievalFailed()
                    }
                    
                    return
                }
            
            dispatch_async(dispatch_get_main_queue())
            {
                delegate?.onImageRetrieved(Int(Constant.CODE_FAILED), image: image, newUpload: false)
            }
        }).resume()
    }
}