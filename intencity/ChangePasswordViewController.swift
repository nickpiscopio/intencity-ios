//
//  ChangePasswordViewController.swift
//  Intencity
//
//  The view controller for the change password screen.
//
//  Created by Nick Piscopio on 2/23/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class ChangePasswordViewController: UIViewController, ServiceDelegate
{
    @IBOutlet weak var oldPasswordTextField: IntencityTextField!
    @IBOutlet weak var forgotPasswordButton: IntencityButtonNoBackground!
    @IBOutlet weak var newPasswordTextField: IntencityTextField!
    @IBOutlet weak var confirmNewPasswordTextField: IntencityTextField!
    @IBOutlet weak var changePasswordButton: IntencityButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var email = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.hidden = true
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("change_password", comment: "")
        
        oldPasswordTextField.placeholder = NSLocalizedString("current_password", comment: "")
        newPasswordTextField.placeholder = NSLocalizedString("new_password", comment: "")
        confirmNewPasswordTextField.placeholder = NSLocalizedString("confirm_new_password", comment: "")
        
        forgotPasswordButton.setTitle(NSLocalizedString("forgot_password", comment: ""), forState: .Normal)
        changePasswordButton.setTitle(NSLocalizedString("change_password_button_title", comment: ""), forState: .Normal)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.hidden = true
        
        // Get the user's email.
        email = Util.getEmailFromDefaults()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func forgotPasswordClicked(sender: AnyObject)
    {
        let storyboard = UIStoryboard(name: Constant.LOGIN_STORYBOARD, bundle: nil)
        
        let viewController = storyboard.instantiateViewControllerWithIdentifier("ForgotPasswordViewController")
        
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    @IBAction func changePasswordClicked(sender: AnyObject)
    {
        let oldPassword = oldPasswordTextField.text!
        let newPassword = newPasswordTextField.text!
        let confirmNewPassword = confirmNewPasswordTextField.text!
        
        // Check if all the fields are filled in.
        if (!Util.checkStringLength(oldPassword, length: 1) || !Util.checkStringLength(newPassword, length: 1))
        {
            Util.displayAlert(self, title: NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("fill_in_fields", comment: ""), actions: [])
        }
        // Check to see if the password is greater than the password length needed.
        // Check to see if the password is valid.
        else if (!Util.checkStringLength(newPassword, length: Constant.REQUIRED_PASSWORD_LENGTH) || !Util.isFieldValid(newPassword, regEx: Constant.REGEX_FIELD) || Util.checkStringLength(newPassword, length: Constant.MAX_TEXT_FIELD_LENGTH))
        {
            Util.displayAlert(self, title: NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("password_validation_error", comment: ""), actions: [])
        }
        // Check to see if the passwords match.
        else if (newPassword != confirmNewPassword)
        {
            Util.displayAlert(self, title: NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("password_match_error", comment: ""), actions: [])
        }
        else
        {
            activityIndicator.startAnimating()
            activityIndicator.hidden = false
            
            _ = ServiceTask(event: ServiceEvent.GENERIC, delegate: self,
                            serviceURL: Constant.SERVICE_CHANGE_PASSWORD,
                            params: Constant.generateChangePasswordVariables(email, currentPassword: oldPassword, newPassword: newPassword))
        }
    }
    
    func onRetrievalSuccessful(event: Int, result: String)
    {
        let response = result.stringByReplacingOccurrencesOfString("\"", withString: "")
        
        if (response == Constant.INVALID_PASSWORD)
        {
            Util.displayAlert(self, title: NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("invalid_password", comment: ""), actions: [])
        }
        else if (response == Constant.SUCCESS)
        {
            Util.displayAlert(self, title: NSLocalizedString("password_changed_title", comment: ""), message: NSLocalizedString("password_changed", comment: ""),
                                    actions: [ UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .Default, handler: goBack) ])
        }
        else
        {
            Util.displayAlert(self, title: NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("intencity_communication_error", comment: ""), actions: [])
        }
        
        activityIndicator.stopAnimating()
    }
    
    func onRetrievalFailed(event: Int)
    {
        activityIndicator.stopAnimating()
        
        Util.displayAlert(self, title: NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("intencity_communication_error", comment: ""), actions: [])
    }
    
    /**
     * Navigates the user back to the previous screen.
     */
    func goBack(alertAction: UIAlertAction!) -> Void
    {
        // Navigates the user back to the previous screen.
        self.navigationController?.popViewControllerAnimated(true)
    }
}