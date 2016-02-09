//
//  CreateAccountViewController.swift
//  Intencity
//
//  The controller for the create account view.
//
//  Created by Nick Piscopio on 2/9/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class CreateAccountViewController: UIViewController
{    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Sets the title for the screen.
        self.navigationController?.navigationBar.topItem!.title = NSLocalizedString("title_create_account", comment: "")
        
        // Adds a back image to the navigation bar.
        // We need this because we can't add a standard navigation bar without disrupting the page view controller.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:UIImage(named: "back_button.png"), style:.Plain, target:self, action:"goBack");
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /*
        The click function for creating an account.
    */
    @IBAction func createAccountClicked(sender: UIButton)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let initialViewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController")
        
        self.presentViewController(initialViewController, animated: true, completion: nil)
    }
    
    /*
        The function to dismiss the current view controller.
    */
    func goBack()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

