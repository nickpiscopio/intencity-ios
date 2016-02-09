//
//  ForgotPasswordViewController.swift
//  Intencity
//
//  This is the controller class for Forgot Password.
//
//  Created by Nick Piscopio on 2/9/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class ForgotPasswordViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Sets the title for the screen.
        self.navigationController?.navigationBar.topItem!.title = NSLocalizedString("title_forgot_password", comment: "")
        
        // Adds a back image to the navigation bar.
        // We need this because we can't add a standard navigation bar without disrupting the page view controller.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:UIImage(named: "back_button.png"), style:.Plain, target:self, action:"goBack");
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /*
        The function to dismiss the current view controller.
    */
    func goBack()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
