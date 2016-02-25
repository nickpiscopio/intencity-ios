//
//  ChangePasswordViewController.swift
//  Intencity
//
//  The view controller for the change password screen.
//
//  Created by Nick Piscopio on 2/23/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class ChangePasswordViewController: UIViewController
{
    @IBOutlet weak var oldPasswordTextField: IntencityTextField!
    @IBOutlet weak var forgotPasswordButton: IntencityButtonNoBackground!
    @IBOutlet weak var newPasswordTextField: IntencityTextField!
    @IBOutlet weak var confirmNewPasswordTextField: IntencityTextField!
    @IBOutlet weak var changePasswordButton: IntencityButton!
    
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
        
    }
}