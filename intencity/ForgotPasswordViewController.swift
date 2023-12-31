//
//  ForgotPasswordViewController.swift
//  Intencity
//
//  This is the controller class for Forgot Password.
//
//  Created by Nick Piscopio on 2/9/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class ForgotPasswordViewController: UIViewController, ServiceDelegate
{
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    @IBOutlet weak var emailTextField: IntencityTextField!
    @IBOutlet weak var resetPasswordButton: IntencityButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("title_forgot_password", comment: "")
        
        // Sets the elements' text.
        forgotPasswordLabel.text = NSLocalizedString("reset_password_message", comment: "")
        forgotPasswordLabel.textColor = Color.secondary_light
        emailTextField?.placeholder = NSLocalizedString("email", comment: "")
        resetPasswordButton?.setTitle(NSLocalizedString("reset", comment: ""), for: UIControlState())
        
        activityIndicator.hidesWhenStopped = true
    }
    
    @IBAction func resetPassword(_ sender: AnyObject)
    {
        let email = emailTextField.text!
        if (!Util.isFieldValid(email, regEx: Constant.REGEX_EMAIL))
        {
            Util.displayAlert(self, title: NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("email_validation_error", comment: ""), actions: [])
        }
        else
        {
            startResetPassword()
            
            _ = ServiceTask(event: ServiceEvent.GENERIC, delegate: self, serviceURL: Constant.SERVICE_FORGOT_PASSWORD, params: Constant.getStandardServiceUrlParams(Util.replacePlus(email)) as NSString)
        }
    }
    
    func startResetPassword()
    {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        emailTextField.isHidden = true
        resetPasswordButton.isHidden = true
        forgotPasswordLabel.isHidden = true
    }
    
    func stopRestPassword()
    {
        activityIndicator.stopAnimating()
        emailTextField.isHidden = false
        resetPasswordButton.isHidden = false
        forgotPasswordLabel.isHidden = false
    }
    
    func onRetrievalSuccessful(_ event: Int, result: String)
    {
        
            Util.displayAlert(self, title:  NSLocalizedString("forgot_password_email_sent_title", comment: ""), message: NSLocalizedString("forgot_password_email_sent", comment: ""), actions: [])
            
            self.stopRestPassword()
    }
    
    func onRetrievalFailed(_ event: Int)
    {
        Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("intencity_communication_error_email", comment: ""), actions: [])
        
        stopRestPassword()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
