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
    @IBOutlet weak var firstNameTextField: IntencityTextField!
    @IBOutlet weak var lastNameTextField: IntencityTextField!
    @IBOutlet weak var emailTextField: IntencityTextField!
    @IBOutlet weak var confirmEmailTextField: IntencityTextField!
    @IBOutlet weak var passwordTextField: IntencityTextField!
    @IBOutlet weak var confirmPasswordTextField: IntencityTextField!
    @IBOutlet weak var termsLabel: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var createAccountButton: IntencityButton!
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
        
        firstNameTextField?.placeholder = NSLocalizedString("first_name", comment: "")
        lastNameTextField?.placeholder = NSLocalizedString("last_name", comment: "")
        emailTextField?.placeholder = NSLocalizedString("email", comment: "")
        confirmEmailTextField?.placeholder = NSLocalizedString("confirm_email", comment: "")
        passwordTextField?.placeholder = NSLocalizedString("password", comment: "")
        confirmPasswordTextField?.placeholder = NSLocalizedString("confirm_password", comment: "")
        termsLabel?.setTitle(NSLocalizedString("terms_checkbox", comment: ""), forState: .Normal)
        termsLabel.setTitleColor(Color.secondary_dark, forState: .Normal)
        createAccountButton?.setTitle(NSLocalizedString("create_account_button", comment: ""), forState: .Normal)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /*
    The click function for the terms of use checkbox and label.
    
    sender  The Button being pressed.
    */
    @IBAction func termsOfUseClicked(sender: UIButton)
    {
        let unchecked = UIImage(named: "checkbox_unchecked")
        let checked = UIImage(named: "checkbox_checked")
        
        if (termsButton.currentImage!.isEqual(unchecked))
        {
            termsButton.setImage(checked, forState: .Normal)
            
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TermsOfUseViewController") as! TermsOfUseViewController
            
            let navigationController = UINavigationController(rootViewController: vc)
            
            self.presentViewController(navigationController, animated: true, completion: nil)
        }
        else
        {
            termsButton.setImage(unchecked, forState: .Normal)
        }
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

