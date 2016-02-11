//
//  LoginNavController.swift
//  Intencity
//
//  The controller for the login nav.
//
//  Created by Nick Piscopio on 2/11/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class LoginNavController: UINavigationController
{
    var backgroundColor: UIColor!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of the view.
        self.view.backgroundColor = backgroundColor
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}