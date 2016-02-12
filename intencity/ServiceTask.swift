//
//  ServiceTask.swift
//  Intencity
//
//  The task that calls webservices.
//
//  Created by Nick Piscopio on 2/10/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation
class ServiceTask
{
    init(event: Int, delegate: ServiceDelegate, serviceURL: String, params: NSString)
    {
        let failed = "FAILURE"
        let request = NSMutableURLRequest(URL: NSURL(string: serviceURL)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            // Check for fundamental networking errors.
            guard error == nil && data != nil else
            {
                print("error=\(error)")
                delegate.onRetrievalFailed(event)
                return
            }
            
            // Check for HTTP errors.
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200
            {
                print("statusCode: \(httpStatus.statusCode)")
                print("response = \(response)")
                delegate.onRetrievalFailed(event)
                return
            }

            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
            let parsedResponse = responseString.stringByReplacingOccurrencesOfString("\"", withString: "")
            if (parsedResponse != failed)
            {
                dispatch_async(dispatch_get_main_queue())
                {
                    // Print the response
                    delegate.onRetrievalSuccessful(event, result: responseString as String)
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue())
                {
                    delegate.onRetrievalFailed(event)
                }
            }
        }
        
        task.resume()
    }
}