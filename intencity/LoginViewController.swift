//
//  LoginViewController.swift
//  Intencity
//
//  The controller for the login view.
//
//  Created by Nick Piscopio on 2/8/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class LoginViewController: UIViewController, ServiceDelegate
{
    @IBOutlet weak var emailTextField: IntencityTextField!
    @IBOutlet weak var passwordTextField: IntencityTextField!
    @IBOutlet weak var forgotPasswordButton: IntencityButtonNoBackground!
    @IBOutlet weak var createAccountButton: IntencityButtonNoBackground!
    @IBOutlet weak var termsLabel: UIButton!
    @IBOutlet weak var signInButton: IntencityButton!
    
    @IBOutlet weak var separator: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var trialEmail: String = ""
    var trialAccountType: String = ""
    var trialDateCreated: Double = 0
    var termsString = NSLocalizedString("terms_login", comment: "")
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Sets the background color of the view.
        self.view.backgroundColor = Color.page_background
        
        separator.textColor = Color.secondary_dark
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("sign_in_title", comment: "")
        
        emailTextField?.placeholder = NSLocalizedString("email", comment: "")
        passwordTextField?.placeholder = NSLocalizedString("password", comment: "")
        
        forgotPasswordButton?.setTitle(NSLocalizedString("forgot_password", comment: ""), for: UIControlState())
        createAccountButton?.setTitle(NSLocalizedString("create_account", comment: ""), for: UIControlState())
        signInButton?.setTitle(NSLocalizedString("sign_in", comment: ""), for: UIControlState())
    
        initTermsText()
        
        activityIndicator.hidesWhenStopped = true
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /**
     * Initialize the terms of use text attributes.
     */
    func initTermsText()
    {
        let termsStrings = termsString.components(separatedBy: "@")
        
        let termsCount = termsStrings.count
        
        let termsMutableString = NSMutableAttributedString()
        
        for i in 0 ..< termsCount
        {
            let attributredTerms = termsStrings[i]
            
            var tempMutableString = NSMutableAttributedString()
            tempMutableString = NSMutableAttributedString(string: attributredTerms, attributes: nil)
            tempMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: (i % 2 == 0) ? Color.secondary_dark : Color.primary, range: NSRange(location: 0, length: attributredTerms.count))

            termsMutableString.append(tempMutableString)
        }

        termsLabel.setAttributedTitle(termsMutableString, for: UIControlState())
    }
    
    /**
     * The click function for the login button.
     */
    @IBAction func loginClicked(_ sender: UIButton)
    {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if (email.isEmpty || password.isEmpty)
        {
            Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("fill_in_fields", comment: ""), actions: [])
        }
        else
        {
            startLogin()
            
            _ = ServiceTask(event: ServiceEvent.LOGIN, delegate: self, serviceURL: Constant.SERVICE_VALIDATE_USER_CREDENTIALS, params: Constant.getValidateUserCredentialsServiceParameters(Util.replacePlus(email), password: Util.replaceApostrophe(password)) as NSString)
        }
    }
    
    /**
     * The alert function for opening the terms.
     */
    func openTerms(_ alertAction: UIAlertAction!)
    {
        openTerms()
    }
    
    /**
     * The function called when we get the user's credentials back from the server successfully.
     */
    func onRetrievalSuccessful(_ event: Int, result: String)
    {
        let parsedResponse = result.replacingOccurrences(of: "\"", with: "")
        if (parsedResponse == Constant.COULD_NOT_FIND_EMAIL || parsedResponse == Constant.INVALID_PASSWORD)
        {
            Util.displayAlert(self, title:  NSLocalizedString("login_error_title", comment: ""), message: NSLocalizedString("login_error_message", comment: ""), actions: [])
            
            stopLogin()
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
    
    /**
     * The function called when we fail to get the user's credentials back from the server.
     */
    func onRetrievalFailed(_ Event: Int)
    {
        Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("intencity_communication_error", comment: ""), actions: [])
        
        stopLogin()
    }
    
    func startLogin()
    {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        emailTextField.isHidden = true
        passwordTextField.isHidden = true
        forgotPasswordButton.isHidden = true
        createAccountButton.isHidden = true
        termsLabel.isHidden = true
        signInButton.isHidden = true
        separator.isHidden = true
    }
    
    func stopLogin()
    {
        emailTextField.isHidden = false
        passwordTextField.isHidden = false
        forgotPasswordButton.isHidden = false
        createAccountButton.isHidden = false
        termsLabel.isHidden = false
        signInButton.isHidden = false
        separator.isHidden = false
        
        activityIndicator.stopAnimating()
    }
    
    /**
     * Opens the terms of use.
     */
    func openTerms()
    {
        let viewController = storyboard!.instantiateViewController(withIdentifier: Constant.TERMS_VIEW_CONTROLLER) as! TermsViewController
        viewController.includeNavButton = true
        viewController.isTerms = true
        
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    /**
     * The click function for the terms of use checkbox and label.
     */
    @IBAction func termsOfUseClicked(_ sender: UIButton)
    {
        openTerms()
    }
}
