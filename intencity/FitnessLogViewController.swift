//
//  MainViewController.swift
//  Intencity
//
//  The view controller for the Fitness Log.
//
//  Created by Nick Piscopio on 2/8/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class FitnessLogViewController: UIViewController, ServiceDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Sets the title for the screen.
        self.navigationController?.navigationBar.topItem!.title = NSLocalizedString("app_name", comment: "")
        
        let variables = [ Util.getEmailFromDefaults() ]
        
        let variable = Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_ALL_DISPLAY_MUSCLE_GROUPS, variables:  variables)

        let stored = Constant.SERVICE_STORED_PROCEDURE

        ServiceTask(event: ServiceEvent.GENERIC, delegate: self,
            serviceURL: Constant.SERVICE_STORED_PROCEDURE,
            params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_ALL_DISPLAY_MUSCLE_GROUPS, variables:  variables))
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func onRetrievalSuccessful(event: Int, result: String)
    {
        if (event == ServiceEvent.GENERIC)
        {
            // This gets saved as NSDictionary, so there is no order
            // ID, Email, Hashed password, AccountType
            let json: AnyObject? = result.parseJSONString
            
//            print("Muscle groups: \(result)")
            
            // New way to do JSON?
            // https://github.com/lingoer/SwiftyJSON

            for (key, value) in json as! NSDictionary
            {
                print("key: \"\(key as! String)\"")
                print("value: \"\(value as! String)\"")
            }
            
            print("Muscle groups: \(json)")
        }
    }
    
    func onRetrievalFailed(event: Int)
    {
        // Add code for when we can't get the muscle groups.
    }
}