//
//  LoginViewController.swift
//  Intencity
//
//  The controller for the login view.
//
//  Created by Nick Piscopio on 2/8/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class LoginViewController: PageViewController, ServiceDelegate
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
    
    let unchecked = UIImage(named: Constant.CHECKBOX_UNCHECKED)
    let checked = UIImage(named: Constant.CHECKBOX_CHECKED)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Sets the background color of the view.
        self.view.backgroundColor = backgroundColor
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("sign_in_title", comment: "")
        
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
    }
    
    /*
        The click function for the login button.
    
        sender  The Button being pressed.
    */
    @IBAction func loginClicked(sender: UIButton)
    {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if (email.isEmpty || password.isEmpty)
        {
            Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("fill_in_fields", comment: ""))
        }
        else if (!isTermsChecked())
        {
            Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("accept_terms", comment: ""))
        }
        else
        {
            ServiceTask(delegate: self, serviceURL: Constant.SERVICE_VALIDATE_USER_CREDENTIALS, params: Constant.getValidateUserCredentialsServiceParameters(email, password: password))
        }
    }
    
    /*
        The function called when we get the user's credentials back from the server successfully.
    */
    func onRetrievalSuccessful(result: String)
    {
        let parsedResponse = result.stringByReplacingOccurrencesOfString("\"", withString: "")
        if (parsedResponse == Constant.COULD_NOT_FIND_EMAIL || parsedResponse == Constant.INVALID_PASSWORD)
        {
            Util.displayAlert(self, title:  NSLocalizedString("login_error_title", comment: ""), message: NSLocalizedString("login_error_message", comment: ""))
        }
        else
        {
            // This gets saved as NSDictionary, so there is no order
            // ID, Email, Hashed password, AccountType
            let json: AnyObject? = result.parseJSONString
                
            let accountType = json![Constant.COLUMN_ACCOUNT_TYPE] as! String
            let email = json![Constant.COLUMN_EMAIL] as! String

            Util.loadIntencity(self, email: email, accountType: accountType, createdDate: 0)
        }
    }
    
    /*
        The function called when we fail to get the user's credentials back from the server.
    */
    func onRetrievalFailed()
    {
        
    }
    
    /*
        Checks to see if the terms checkbox is checked.
    */
    func isTermsChecked() -> Bool
    {
        return termsButton.currentImage!.isEqual(checked)
    }
    
    /*
        The click function for the terms of use checkbox and label.
    
        sender  The Button being pressed.
    */
    @IBAction func termsOfUseClicked(sender: UIButton)
    {
        if (!isTermsChecked())
        {
            termsButton.setImage(checked, forState: .Normal)
            
            self.performSegueWithIdentifier("SegueToTerms", sender: sender)
        }
        else
        {
            termsButton.setImage(unchecked, forState: .Normal)
        }
    }
}
