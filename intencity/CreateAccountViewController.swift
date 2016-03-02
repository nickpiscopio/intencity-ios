//
//  CreateAccountViewController.swift
//  Intencity
//
//  The controller for the create account view.
//
//  Created by Nick Piscopio on 2/9/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class CreateAccountViewController: UIViewController, ServiceDelegate
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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let unchecked = UIImage(named: Constant.CHECKBOX_UNCHECKED)
    let checked = UIImage(named: Constant.CHECKBOX_CHECKED)
    
    var termsString = NSLocalizedString("terms_checkbox", comment: "")
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("title_create_account", comment: "")
        
        initTermsText()
        
        firstNameTextField?.placeholder = NSLocalizedString("first_name", comment: "")
        lastNameTextField?.placeholder = NSLocalizedString("last_name", comment: "")
        emailTextField?.placeholder = NSLocalizedString("email", comment: "")
        confirmEmailTextField?.placeholder = NSLocalizedString("confirm_email", comment: "")
        passwordTextField?.placeholder = NSLocalizedString("password", comment: "")
        confirmPasswordTextField?.placeholder = NSLocalizedString("confirm_password", comment: "")
        createAccountButton?.setTitle(NSLocalizedString("create_account_button", comment: ""), forState: .Normal)
        
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
        
        var termsMutableString = NSMutableAttributedString()
        
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
    
    @IBAction func checkNameLength(sender: AnyObject)
    {
        checkStringLength(sender as! UITextField, maxLength: Integer.NAME_LENGTH)
    }
    
    @IBAction func checkEmailLength(sender: AnyObject)
    {
        checkStringLength(sender as! UITextField, maxLength: Integer.EMAIL_LENGTH)
    }
    
    @IBAction func checkPasswordLength(sender: AnyObject)
    {
        checkStringLength(sender as! UITextField, maxLength: Integer.PASSWORD_LENGTH)
    }
    
    /*
        Checks to see if the terms checkbox is checked.
    */
    func isTermsChecked() -> Bool
    {
        return termsButton.currentImage!.isEqual(checked)
    }
    
    /*
        The click function for creating an account.
    */
    @IBAction func createAccountClicked(sender: UIButton)
    {
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let email = emailTextField.text!
        let confirmEmail = confirmEmailTextField.text!
        let password = passwordTextField.text!
        let confirmPassword = confirmPasswordTextField.text!
        
        // Check if all the fields are filled in.
        if (!Util.checkStringLength(firstName, length: 1) || !Util.checkStringLength(lastName, length: 1) ||
            !Util.checkStringLength(email, length: 1) || !Util.checkStringLength(confirmEmail, length: 1) ||
            !Util.checkStringLength(password, length: 1) || !Util.checkStringLength(confirmPassword, length: 1))
        {
            Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("fill_in_fields", comment: ""), actions: [])
        }
        // Check if the email is valid.
        else if (!Util.isFieldValid(email, regEx: Constant.REGEX_EMAIL))
        {
            Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("email_validation_error", comment: ""), actions: [])
        }
        // Check if the first and last name have valid characters.
        else if (!Util.isFieldValid(firstName, regEx: Constant.REGEX_FIELD) || !Util.isFieldValid(lastName, regEx: Constant.REGEX_FIELD))
        {
            Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("field_validation_error", comment: ""), actions: [])
        }
            // Check to see if the emails match.
        else if (email != confirmEmail)
        {
            Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("email_match_error", comment: ""), actions: [])
        }
        // Check to see if the password is greater than the password length needed.
        // Check to see if the password is valid.
        else if (!Util.checkStringLength(password, length: Constant.REQUIRED_PASSWORD_LENGTH) || !Util.isFieldValid(password, regEx: Constant.REGEX_FIELD))
        {
            Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("password_validation_error", comment: ""), actions: [])
        }
        // Check to see if the passwords match.
        else if (password != confirmPassword)
        {
             Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("password_match_error", comment: ""), actions: [])
        }
        // Check to see if the user has accepted the terms.
        else if (!isTermsChecked())
        {
            Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("accept_terms", comment: ""), actions: [])
        }
        else
        {
            startCreateAccount()
            
            ServiceTask(event: ServiceEvent.GENERIC, delegate: self,
                serviceURL: Constant.SERVICE_CREATE_ACCOUNT,
                params: Constant.getAccountParameters(firstName, lastName: lastName, email: replacePlus(email), password: password, accountType: Constant.ACCOUNT_TYPE_NORMAL))
        }
    }
    
    /*
        Replaces the '+' character in a String of text.
        This is so we can create an account on the server with an email that has a '+' in it.
    
        text  The text to search.
    
        return  The new String with its replaced character.
    */
    func replacePlus(text: String) -> String
    {
        return text.stringByReplacingOccurrencesOfString("+", withString: "%2B")
    }
    
    /*
        Hides all the elements and starts the activity indicator.
    */
    func startCreateAccount()
    {
        activityIndicator.startAnimating()
        activityIndicator.hidden = false
        
        firstNameTextField.hidden = true
        lastNameTextField.hidden = true
        emailTextField.hidden = true
        confirmEmailTextField.hidden = true
        passwordTextField.hidden = true
        confirmPasswordTextField.hidden = true
        termsLabel.hidden = true
        termsButton.hidden = true
        createAccountButton.hidden = true
    }
    
    /*
        Shows the ui elements again because something went wrong.
    */
    func stopCreateAcount()
    {
        firstNameTextField.hidden = false
        lastNameTextField.hidden = false
        emailTextField.hidden = false
        confirmEmailTextField.hidden = false
        passwordTextField.hidden = false
        confirmPasswordTextField.hidden = false
        termsLabel.hidden = false
        termsButton.hidden = false
        createAccountButton.hidden = false
        
        activityIndicator.stopAnimating()
    }
    
    func onRetrievalSuccessful(event: Int, result: String)
    {
        let parsedResponse = result.stringByReplacingOccurrencesOfString("\"", withString: "")
        if (parsedResponse == Constant.EMAIL_EXISTS)
        {
            stopCreateAcount()
            
            Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("email_exists", comment: ""), actions: [])
        }
        else if (parsedResponse == Constant.ACCOUNT_CREATED)
        {
            Util.loadIntencity(self, email: emailTextField.text!, accountType: Constant.ACCOUNT_TYPE_NORMAL, createdDate: 0);
        }
        else
        {
            stopCreateAcount()
            
            Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("intencity_communication_error", comment: ""), actions: [])
        }
    }
    
    func onRetrievalFailed(event: Int)
    {
        Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("intencity_communication_error", comment: ""), actions: [])
    }
    
    /*
        Deletes extra characters in a textfield if it exceeds the allotted amount.
     */
    func checkStringLength(textField: UITextField!, maxLength: Int)
    {
        if (Util.checkStringLength(textField.text!, length: maxLength))
        {
            textField.deleteBackward()
        }
    }
}

