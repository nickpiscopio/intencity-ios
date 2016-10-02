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
    static let FAILED = "FAILURE"

    init(event: Int, delegate: ServiceDelegate?, serviceURL: String, params: NSString)
    {
        let request = NSMutableURLRequest(url: URL(string: serviceURL)!)
        request.httpMethod = "POST"
        request.httpBody = params.data(using: String.Encoding.utf8.rawValue)
  
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            if (event != ServiceEvent.NO_RETURN)
            {
                // Check for fundamental networking errors.
                guard error == nil && data != nil else
                {
                    print("error=\(error)")
                    
                    DispatchQueue.main.async
                    {
                        delegate!.onRetrievalFailed(event)
                    }
                    
                    return
                }
                
                // Check for HTTP errors.
                if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200
                {
                    DispatchQueue.main.async
                    {
                        delegate!.onRetrievalFailed(event)
                    }
                    
                    return
                }
                
                let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                let parsedResponse = responseString.replacingOccurrences(of: "\"", with: "")
                if (parsedResponse != ServiceTask.FAILED)
                {
                    DispatchQueue.main.async
                    {
                        delegate!.onRetrievalSuccessful(event, result: responseString as String)
                    }
                }
                else
                {
                    DispatchQueue.main.async
                    {
                        delegate!.onRetrievalFailed(event)
                    }
                }
            }
        }) 
        
        task.resume()
    }
}
