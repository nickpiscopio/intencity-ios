//
//  LoginViewController.swift
//  Intencity
//
//  The controller for the login view.
//
//  Created by Nick Piscopio on 2/8/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class LoginViewController: PageViewController
{
    var backgroundColor: UIColor!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.view.backgroundColor = backgroundColor
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
        The click function for the login button.
    
        sender  The Button being pressed.
    */
    @IBAction func loginClicked(sender: UIButton)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let initialViewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController")
        
        self.presentViewController(initialViewController, animated: true, completion: nil)
    }
    
    /*
        The click function for the forgot password button.
    
        sender  The Button being pressed.
    */
    @IBAction func forgotPasswordClicked(sender: UIButton)
    {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ForgotPasswordViewController") as! ForgotPasswordViewController
        
        let navigationController = UINavigationController(rootViewController: vc)

        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    /*
        The click function for the create account button.
    
        sender  The Button being pressed.
    */
    @IBAction func createAccountClicked(sender: UIButton)
    {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CreateAccountViewController") as! CreateAccountViewController
        
        let navigationController = UINavigationController(rootViewController: vc)
        
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    /*
        The click function for the terms of use checkbox and label.
    
        sender  The Button being pressed.
    */
    @IBAction func termsOfUseClicked(sender: UIButton)
    {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TermsOfUseViewController") as! TermsOfUseViewController
        
        let navigationController = UINavigationController(rootViewController: vc)
        
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
}
