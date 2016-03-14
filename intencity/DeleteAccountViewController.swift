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
    
    var email = ""
    var password = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.hidden = true
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("title_delete_account", comment: "")
        
        deleteDescription.textColor = Color.secondary_dark
        deleteDescription.text = NSLocalizedString("delete_account_message", comment: "")
        passwordTextField.placeholder = NSLocalizedString("password", comment: "")
        
        deleteButton.setTitle(NSLocalizedString("delete_account_button", comment: ""), forState: .Normal)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.hidden = true
        
        // Get the user's email.
        email = Util.getEmailFromDefaults()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func deleteClicked(sender: AnyObject)
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
                actions: [ UIAlertAction(title: NSLocalizedString("delete_account", comment: ""), style: .Destructive, handler: deleteAccount),
                           UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .Cancel, handler: nil)])
        }
    }
    
    /**
     * Navigates the user back to the previous screen.
     */
    func deleteAccount(alertAction: UIAlertAction!) -> Void
    {
        activityIndicator.startAnimating()
        activityIndicator.hidden = false
        
        _ = ServiceTask(event: ServiceEvent.VALIDATE_USER_CREDENTIALS, delegate: self,
                        serviceURL: Constant.SERVICE_VALIDATE_USER_CREDENTIALS,
                        params: Constant.getValidateUserCredentialsServiceParameters(email, password: password))
    }
    
    func onRetrievalSuccessful(event: Int, result: String)
    {
        switch(event)
        {
            case ServiceEvent.VALIDATE_USER_CREDENTIALS:
                let response = result.stringByReplacingOccurrencesOfString("\"", withString: "")
                
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
                                    serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                                    params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_REMOVE_ACCOUNT, variables: [ email ]))
                }

                break
            case ServiceEvent.REMOVE_ACCOUNT:
                Util.logOut(self)
                break
            default:
                break
        }
    }

    func onRetrievalFailed(event: Int)
    {
        // There isn't a need for a switch here.
        // The reactions are the same if the user cannot connect to Intencity's server.
        activityIndicator.stopAnimating()
        
        Util.displayAlert(self, title: NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("intencity_communication_error", comment: ""), actions: [])
    }
}