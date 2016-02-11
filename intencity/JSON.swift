//
//  JSON.swift
//  Intencity
//
//  An extention of String to parse JSON.
//
//  Created by Nick Piscopio on 2/11/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation

extension String
{
    var parseJSONString: AnyObject?
        {
            let data = self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            
            if let jsonData = data
            {
                do
                {
                    // Returns the JSON object if it can parse it properly.
                    return try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? NSDictionary
                    
                }
                catch let error as NSError
                {
                    // Prints the error if the parsing fails
                    print(error.localizedDescription)
                }
            }
            
            // Returns nil if the parsing fails.
            return nil
    }
}