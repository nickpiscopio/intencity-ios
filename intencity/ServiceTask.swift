//
//  ServiceTask.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/10/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.
//

import Foundation
class ServiceTask
{
    init(delegate: ServiceDelegate, serviceURL: String, params: NSString)
    {
        let request = NSMutableURLRequest(URL: NSURL(string: serviceURL)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            // Check for fundamental networking errors.
            guard error == nil && data != nil else
            {
                print("error=\(error)")
                delegate.onRetrievalFailed()
                return
            }
            
            // Check for HTTP errors.
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200
            {
                print("statusCode: \(httpStatus.statusCode)")
                print("response = \(response)")
                delegate.onRetrievalFailed()
                return
            }
            
            // Print the response
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            delegate.onRetrievalSuccessful(responseString! as String)
        }
        
        task.resume()
    }
}