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
            let json: AnyObject? = result.parseJSONString

            for muscleGroups in json as! NSArray
            {
                print("muscleGroup: \"\(muscleGroups[Constant.COLUMN_DISPLAY_NAME] as! String)\"")
                print("recommended: \"\(muscleGroups[Constant.COLUMN_CURRENT_MUSCLE_GROUP] as! String)\"")
            }
        }
    }
    
    func onRetrievalFailed(event: Int)
    {
        // Add code for when we can't get the muscle groups.
    }
}