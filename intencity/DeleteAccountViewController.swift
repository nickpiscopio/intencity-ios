//
//  DeleteAccountViewController.swift
//  Intencity
//
//  The view controller for the delete account screen.
//
//  Created by Nick Piscopio on 2/23/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class DeleteAccountViewController: UIViewController
{
    @IBOutlet weak var deleteDescription: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    
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
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    @IBAction func deleteClicked(sender: AnyObject)
    {
    }
}