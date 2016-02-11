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
    
    let unchecked = UIImage(named: "checkbox_unchecked")
    let checked = UIImage(named: "checkbox_checked")
    
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
            let params = "email=\(email)&password=\(password)"
            
            ServiceTask(delegate: self, serviceURL: "http://www.intencityapp.com/dev/services/mobile/user_credentials.php", params: params)
        }
    }
    
    func onRetrievalSuccessful(result: String)
    {
        dispatch_async(dispatch_get_main_queue())
        {
            let parsedResponse = result.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
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
                let encryptedEmail = try! email.aesEncrypt(Key.key, iv: Key.iv)

                Util.saveLoginData(encryptedEmail, accountType: accountType, createdDate: 0)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let initialViewController = storyboard.instantiateViewControllerWithIdentifier("IntencityTabView")
                
                self.presentViewController(initialViewController, animated: true, completion: nil)
            }
        }
    }
    
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
        if (!isTermsChecked())
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
