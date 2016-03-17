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
    @IBOutlet weak var emailTextField: IntencityTextField!
    @IBOutlet weak var passwordTextField: IntencityTextField!
    @IBOutlet weak var forgotPasswordButton: IntencityButtonNoBackground!
    @IBOutlet weak var createAccountButton: IntencityButtonNoBackground!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var termsCheckBox: UIButton!
    @IBOutlet weak var termsLabel: UIButton!
    @IBOutlet weak var signInButton: IntencityButton!
    @IBOutlet weak var tryIntencityButton: IntencityButtonNoBackground!
    
    @IBOutlet weak var separator: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let unchecked = UIImage(named: Constant.CHECKBOX_UNCHECKED)
    let checked = UIImage(named: Constant.CHECKBOX_CHECKED)
    
    var trialEmail: String = ""
    var trialAccountType: String = ""
    var trialDateCreated: Double = 0
    var termsString = NSLocalizedString("terms_checkbox", comment: "")
    
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
        
        forgotPasswordButton?.setTitle(NSLocalizedString("forgot_password", comment: ""), forState: .Normal)
        createAccountButton?.setTitle(NSLocalizedString("create_account", comment: ""), forState: .Normal)
        signInButton?.setTitle(NSLocalizedString("sign_in", comment: ""), forState: .Normal)
        tryIntencityButton?.setTitle(NSLocalizedString("try_intencity", comment: ""), forState: .Normal)
    
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
        let termsStrings = termsString.componentsSeparatedByString("@")
        
        let termsCount = termsStrings.count
        
        let termsMutableString = NSMutableAttributedString()
        
        for (var i = 0; i < termsCount; i++)
        {
            let attributredTerms = termsStrings[i]
            
            var tempMutableString = NSMutableAttributedString()
            tempMutableString = NSMutableAttributedString(string: attributredTerms, attributes: nil)
            tempMutableString.addAttribute(NSForegroundColorAttributeName, value: (i % 2 == 0) ? Color.secondary_dark : Color.primary, range: NSRange(location: 0, length: attributredTerms.characters.count))

            termsMutableString.appendAttributedString(tempMutableString)
        }

        termsLabel.setAttributedTitle(termsMutableString, forState: .Normal)
    }
    
    /**
     * The click function for the login button.
     */
    @IBAction func loginClicked(sender: UIButton)
    {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if (email.isEmpty || password.isEmpty)
        {
            Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("fill_in_fields", comment: ""), actions: [])
        }
        else if (!isTermsChecked())
        {
            Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("accept_terms", comment: ""), actions: [])
        }
        else
        {
            startLogin()
            
            _ = ServiceTask(event: ServiceEvent.LOGIN, delegate: self, serviceURL: Constant.SERVICE_VALIDATE_USER_CREDENTIALS, params: Constant.getValidateUserCredentialsServiceParameters(Util.replacePlus(email), password: Util.replaceApostrophe(password)))
        }
    }
    
    /**
     * The button click for trying Intencity.
     */
    @IBAction func tryIntencityClicked(sender: AnyObject)
    {
        if (isTermsChecked())
        {
            let actions = [ UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .Default, handler: self.createTrial) ]

            Util.displayAlert(self, title:  NSLocalizedString("trial_account_title", comment: ""), message: NSLocalizedString("trial_account_message", comment: ""), actions: actions)
        }
        else
        {
            Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("accept_terms", comment: ""), actions: [])
        }
    }
    
    /**
     * Creates the trial account.
     */
    func createTrial(alertAction: UIAlertAction!)
    {
        trialAccountType = Constant.ACCOUNT_TYPE_MOBILE_TRIAL
        trialDateCreated = NSDate().timeIntervalSince1970 * 1000
        let createdDateString = String(format:"%f", trialDateCreated)
        let firstName = "Anonymous";
        let lastName = "User";
        trialEmail = lastName +  createdDateString + "@intencity.fit";
        let password = createdDateString;
        
        startLogin()
        
        _ = ServiceTask(event: ServiceEvent.TRIAL, delegate: self,
                        serviceURL: Constant.SERVICE_CREATE_ACCOUNT,
                        params: Constant.getAccountParameters(firstName, lastName: lastName, email: trialEmail, password: password, accountType: trialAccountType))
    }
    
    /**
     * The function called when we get the user's credentials back from the server successfully.
     */
    func onRetrievalSuccessful(event: Int, result: String)
    {
        if (event == ServiceEvent.LOGIN)
        {
            let parsedResponse = result.stringByReplacingOccurrencesOfString("\"", withString: "")
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
        else
        {
            Util.loadIntencity(self, email: trialEmail, accountType: trialAccountType, createdDate: trialDateCreated)
        }
    }
    
    /**
     * The function called when we fail to get the user's credentials back from the server.
     */
    func onRetrievalFailed(Event: Int)
    {
        Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("intencity_communication_error", comment: ""), actions: [])
        
        stopLogin()
    }
    
    /**
     * Checks to see if the terms checkbox is checked.
     */
    func isTermsChecked() -> Bool
    {
        return termsButton.currentImage!.isEqual(checked)
    }
    
    func startLogin()
    {
        activityIndicator.startAnimating()
        activityIndicator.hidden = false
        
        emailTextField.hidden = true
        passwordTextField.hidden = true
        forgotPasswordButton.hidden = true
        createAccountButton.hidden = true
        termsCheckBox.hidden = true
        termsButton.hidden = true
        termsLabel.hidden = true
        signInButton.hidden = true
        tryIntencityButton.hidden = true
        separator.hidden = true
    }
    
    func stopLogin()
    {
        emailTextField.hidden = false
        passwordTextField.hidden = false
        forgotPasswordButton.hidden = false
        createAccountButton.hidden = false
        termsCheckBox.hidden = false
        termsButton.hidden = false
        termsLabel.hidden = false
        signInButton.hidden = false
        tryIntencityButton.hidden = false
        separator.hidden = false
        
        activityIndicator.stopAnimating()
    }
    
    /**
     * The click function for the terms of use checkbox and label.
     */
    @IBAction func termsOfUseClicked(sender: UIButton)
    {
        if (!isTermsChecked())
        {
            termsButton.setImage(checked, forState: .Normal)

            let viewController = storyboard!.instantiateViewControllerWithIdentifier(Constant.TERMS_VIEW_CONTROLLER) as! TermsViewController
            viewController.includeNavButton = true
            viewController.isTerms = true
                
            self.navigationController!.pushViewController(viewController, animated: true)

        }
        else
        {
            termsButton.setImage(unchecked, forState: .Normal)
        }
    }
}
