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
    @IBOutlet weak var createAccountDescription: UILabel!
    @IBOutlet weak var createAccountPromise: UILabel!
    @IBOutlet weak var firstNameTextField: IntencityTextField!
    @IBOutlet weak var lastNameTextField: IntencityTextField!
    @IBOutlet weak var emailTextField: IntencityTextField!
    @IBOutlet weak var confirmEmailTextField: IntencityTextField!
    @IBOutlet weak var passwordTextField: IntencityTextField!
    @IBOutlet weak var confirmPasswordTextField: IntencityTextField!
    @IBOutlet weak var termsLabel: UIButton!
    @IBOutlet weak var createAccountButton: IntencityButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var termsString = NSLocalizedString("terms_create_account", comment: "")
    
    // We assume the user is just creating an account if we aren't notified that the user is creating a trial.
    var createAccountFromTrial = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        let title = createAccountFromTrial ? NSLocalizedString("title_convert_account", comment: "") : NSLocalizedString("title_create_account", comment: "")
        
        // Sets the title for the screen.
        self.navigationItem.title = title
        
        initTermsText()
        
        createAccountDescription.textColor = Color.secondary_light
        createAccountPromise.textColor = Color.card_button_delete_deselect
        
        createAccountDescription.text = NSLocalizedString("create_account_description", comment: "")
        createAccountPromise.text = NSLocalizedString("create_account_promise", comment: "")
        
        firstNameTextField?.placeholder = NSLocalizedString("first_name", comment: "")
        lastNameTextField?.placeholder = NSLocalizedString("last_name", comment: "")
        emailTextField?.placeholder = NSLocalizedString("email", comment: "")
        confirmEmailTextField?.placeholder = NSLocalizedString("confirm_email", comment: "")
        passwordTextField?.placeholder = NSLocalizedString("password", comment: "")
        confirmPasswordTextField?.placeholder = NSLocalizedString("confirm_password", comment: "")
        
        createAccountButton?.setTitle(title.uppercased(), for: UIControlState())
        
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
            tempMutableString.addAttribute(NSForegroundColorAttributeName, value: (i % 2 == 0) ? Color.secondary_dark : Color.primary, range: NSRange(location: 0, length: attributredTerms.characters.count))
            
            termsMutableString.append(tempMutableString)
        }
        
        termsLabel.setAttributedTitle(termsMutableString, for: UIControlState())
    }
    
    @IBAction func termsOfUseClicked(_ sender: UIButton)
    {
        let viewController = storyboard!.instantiateViewController(withIdentifier: Constant.TERMS_VIEW_CONTROLLER) as! TermsViewController
        viewController.includeNavButton = true
        viewController.isTerms = true
            
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    @IBAction func checkNameLength(_ sender: AnyObject)
    {
        checkStringLength(sender as! UITextField, maxLength: Integer.NAME_LENGTH)
    }
    
    @IBAction func checkEmailLength(_ sender: AnyObject)
    {
        checkStringLength(sender as! UITextField, maxLength: Integer.EMAIL_LENGTH)
    }
    
    @IBAction func checkPasswordLength(_ sender: AnyObject)
    {
        checkStringLength(sender as! UITextField, maxLength: Integer.PASSWORD_LENGTH)
    }
    
    /**
     * The click function for creating an account.
     */
    @IBAction func createAccountClicked(_ sender: UIButton)
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
        else if (!Util.isFieldValid(firstName, regEx: Constant.REGEX_NAME_FIELD) || !Util.isFieldValid(lastName, regEx: Constant.REGEX_NAME_FIELD))
        {
            Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("name_validation_error", comment: ""), actions: [])
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
        else
        {
            startCreateAccount()
            
            if (createAccountFromTrial)
            {
                _ = ServiceTask(event: ServiceEvent.GENERIC, delegate: self,
                                serviceURL: Constant.SERVICE_UPDATE_ACCOUNT,
                                params: Constant.getUpdateAccountParameters(Util.getEmailFromDefaults(), firstName: firstName, lastName: lastName, email: Util.replacePlus(email), password: Util.replaceApostrophe(password)) as NSString)
            }
            else
            {
                _ = ServiceTask(event: ServiceEvent.GENERIC, delegate: self,
                                serviceURL: Constant.SERVICE_CREATE_ACCOUNT,
                                params: Constant.getAccountParameters(firstName, lastName: lastName, email: Util.replacePlus(email), password: Util.replaceApostrophe(password), accountType: Constant.ACCOUNT_TYPE_NORMAL) as NSString)

            }
        }
    }
    
    /**
     * Hides all the elements and starts the activity indicator.
     */
    func startCreateAccount()
    {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        createAccountDescription.isHidden = true
        createAccountPromise.isHidden = true
        firstNameTextField.isHidden = true
        lastNameTextField.isHidden = true
        emailTextField.isHidden = true
        confirmEmailTextField.isHidden = true
        passwordTextField.isHidden = true
        confirmPasswordTextField.isHidden = true
        termsLabel.isHidden = true
        createAccountButton.isHidden = true
    }
    
    /**
     * Shows the ui elements again because something went wrong.
     */
    func stopCreateAccount()
    {
        createAccountDescription.isHidden = false
        createAccountPromise.isHidden = false
        firstNameTextField.isHidden = false
        lastNameTextField.isHidden = false
        emailTextField.isHidden = false
        confirmEmailTextField.isHidden = false
        passwordTextField.isHidden = false
        confirmPasswordTextField.isHidden = false
        termsLabel.isHidden = false
        createAccountButton.isHidden = false
        
        activityIndicator.stopAnimating()
    }
    
    func onRetrievalSuccessful(_ event: Int, result: String)
    {
        let email = emailTextField.text!
        
        let parsedResponse = result.replacingOccurrences(of: "\"", with: "")
        if (parsedResponse == Constant.EMAIL_EXISTS)
        {
            stopCreateAccount()
            
            Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("email_exists", comment: ""), actions: [])
        }
        else if (parsedResponse == Constant.ACCOUNT_CREATED)
        {
            Util.loadIntencity(self, email: email, accountType: Constant.ACCOUNT_TYPE_NORMAL, createdDate: 0);
        }
        else if (parsedResponse == Constant.ACCOUNT_UPDATED)
        {
            Util.convertAccount(email)
            
            Util.displayAlert(self, title: NSLocalizedString("success", comment: ""),
                              message: NSLocalizedString("account_converted", comment: ""),
                              actions: [ UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: loadIntencity)])
        }
        else
        {
            stopCreateAccount()
            
            Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("intencity_communication_error", comment: ""), actions: [])
        }
    }
    
    func onRetrievalFailed(_ event: Int)
    {
        Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("intencity_communication_error", comment: ""), actions: [])
        
        stopCreateAccount()
    }
    
    /**
     * Deletes extra characters in a textfield if it exceeds the allotted amount.
     */
    func checkStringLength(_ textField: UITextField!, maxLength: Int)
    {
        if (Util.checkStringLength(textField.text!, length: maxLength))
        {
            textField.deleteBackward()
        }
    }
    
    /**
     * The action for the ok button being clicked when we the user's account was converted successfully.
     */
    func loadIntencity(_ alertAction: UIAlertAction!) -> Void
    {
        // There is only one button here, so we aren't switching.
        Util.loadIntencity(self);
    }
}
