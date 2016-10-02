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

class UploadImageTask
{
    init(event: Int, delegate: ServiceDelegate?, image: UIImage, id: String)
    {
        let myUrl = URL(string: Constant.SERVICE_UPLOAD_PROFILE_PIC);
        
        let param = [ "id" : id ]
        
        let boundary = generateBoundaryString()
        
        let imageData = UIImageJPEGRepresentation(image, 1)
        if(imageData == nil)  { return; }
        
        let request = NSMutableURLRequest(url:myUrl!);
        request.httpMethod = "POST";
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = createBodyWithParameters(param, filePathKey: "file", imageDataKey: imageData!, boundary: boundary)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                
                delegate!.onRetrievalFailed(event)
                
                return
            }
            
            // Print out reponse body
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
        })        

        
        task.resume()
    }
    
    func createBodyWithParameters(_ parameters: [String: String]?, filePathKey: String?, imageDataKey: Data, boundary: String) -> Data
    {
        let body = NSMutableData();
        
        if parameters != nil
        {
            for (key, value) in parameters!
            {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let filename = "user-profile.jpg"
        
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey)
        body.appendString("\r\n")
        
        
        
        body.appendString("--\(boundary)--\r\n")
        
        return body as Data
    }
    
    func generateBoundaryString() -> String
    {
        return "Boundary-\(UUID().uuidString)"
    }
}
