//
//  DeleteAccountViewController.swift
//  Intencity
//
//  The view controller for the delete account screen.
//
//  Created by Nick Piscopio on 2/23/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class DeleteAccountViewController: UIViewController, ServiceDelegate
{
    @IBOutlet weak var deleteDescription: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var forgotPasswordButton: IntencityButtonNoBackground!
    
    var email = ""
    var password = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.isHidden = true
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("title_delete_account", comment: "")
        
        deleteDescription.textColor = Color.secondary_light
        deleteDescription.text = NSLocalizedString("delete_account_message", comment: "")
        passwordTextField.placeholder = NSLocalizedString("password", comment: "")
        
        forgotPasswordButton.setTitle(NSLocalizedString("forgot_password", comment: ""), for: UIControlState())
        deleteButton.setTitle(NSLocalizedString("delete_account_button", comment: ""), for: UIControlState())
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = true
        
        // Get the user's email.
        email = Util.getEmailFromDefaults()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func forgotPasswordClicked(_ sender: AnyObject)
    {
        let storyboard = UIStoryboard(name: Constant.LOGIN_STORYBOARD, bundle: nil)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "ForgotPasswordViewController")
        
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    @IBAction func deleteClicked(_ sender: AnyObject)
    {
        password = passwordTextField.text!
        
        // Check if all the fields are filled in.
        if (!Util.checkStringLength(password, length: 1))
        {
            Util.displayAlert(self, title: NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("fill_in_password", comment: ""), actions: [])
        }
        else
        {
            Util.displayAlert(self, title: NSLocalizedString("title_delete_account", comment: ""), message: NSLocalizedString("delete_account_dialog_message", comment: ""),
                actions: [ UIAlertAction(title: NSLocalizedString("delete_account", comment: ""), style: .destructive, handler: deleteAccount),
                           UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)])
        }
    }
    
    /**
     * Navigates the user back to the previous screen.
     */
    func deleteAccount(_ alertAction: UIAlertAction!) -> Void
    {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        _ = ServiceTask(event: ServiceEvent.VALIDATE_USER_CREDENTIALS, delegate: self,
                        serviceURL: Constant.SERVICE_VALIDATE_USER_CREDENTIALS,
                        params: Constant.getValidateUserCredentialsServiceParameters(email, password: Util.replaceApostrophe(password)) as NSString)
    }
    
    func onRetrievalSuccessful(_ event: Int, result: String)
    {
        switch(event)
        {
            case ServiceEvent.VALIDATE_USER_CREDENTIALS:
                let response = result.replacingOccurrences(of: "\"", with: "")
                
                if (response == Constant.INVALID_PASSWORD)
                {
                    activityIndicator.stopAnimating()
                    
                    Util.displayAlert(self, title: NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("invalid_password", comment: ""), actions: [])
                }
                else if (response == Constant.COULD_NOT_FIND_EMAIL)
                {
                    Util.logOut(self)
                }
                else
                {
                    _ = ServiceTask(event: ServiceEvent.REMOVE_ACCOUNT, delegate: self,
                                    serviceURL: Constant.SERVICE_EXECUTE_STORED_PROCEDURE,
                                    params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_REMOVE_ACCOUNT, variables: [ email ]) as NSString)
                }

                break
            case ServiceEvent.REMOVE_ACCOUNT:
                Util.logOut(self)
                break
            default:
                break
        }
    }

    func onRetrievalFailed(_ event: Int)
    {
        // There isn't a need for a switch here.
        // The reactions are the same if the user cannot connect to Intencity's server.
        activityIndicator.stopAnimating()
        
        Util.displayAlert(self, title: NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("intencity_communication_error", comment: ""), actions: [])
    }
}
