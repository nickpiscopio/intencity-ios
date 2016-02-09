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
    
    @IBOutlet weak var emailTextField: IntencityTextField!
    @IBOutlet weak var passwordTextField: IntencityTextField!
    @IBOutlet weak var forgotPasswordButton: IntencityButtonNoBackground!
    @IBOutlet weak var createAccountButton: IntencityButtonNoBackground!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var termsCheckBox: UIButton!
    @IBOutlet weak var termsLabel: UIButton!
    @IBOutlet weak var signInButton: IntencityButton!
    @IBOutlet weak var tryIntencityButton: IntencityButtonNoBackground!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Sets the background color of the view.
        self.view.backgroundColor = backgroundColor
        
        emailTextField?.placeholder = NSLocalizedString("email", comment: "")
        passwordTextField?.placeholder = NSLocalizedString("password", comment: "")
        
        forgotPasswordButton?.setTitle(NSLocalizedString("forgot_password", comment: ""), forState: .Normal)
        createAccountButton?.setTitle(NSLocalizedString("create_account", comment: ""), forState: .Normal)
        signInButton?.setTitle(NSLocalizedString("sign_in", comment: ""), forState: .Normal)
        tryIntencityButton?.setTitle(NSLocalizedString("try_intencity", comment: ""), forState: .Normal)
        
        termsLabel?.setTitle(NSLocalizedString("terms_checkbox", comment: ""), forState: .Normal)
        termsLabel.setTitleColor(Color.secondary_dark, forState: .Normal)
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
}
