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
            let url = URL(string: link)
            else
            {
                DispatchQueue.main.async
                {
                    delegate?.onImageRetrievalFailed()
                }
        
                return
            }
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            guard
                let httpURLResponse = response as? HTTPURLResponse , httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType , mimeType.hasPrefix("image"),
                let data = data , error == nil,
                let image = UIImage(data: data)
                else
                {
                    DispatchQueue.main.async
                    {
                        delegate?.onImageRetrievalFailed()
                    }
                    
                    return
                }
            
            DispatchQueue.main.async
            {
                delegate?.onImageRetrieved(Int(Constant.CODE_FAILED), image: image, newUpload: false)
            }
        }).resume()
    }
}
