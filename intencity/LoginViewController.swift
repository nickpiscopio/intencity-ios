//
//  LoginViewController.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/8/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.
//

import UIKit

class LoginViewController: PageViewController
{
    var backgroundColor: UIColor!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.view.backgroundColor = backgroundColor
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginClicked(sender: UIButton)
    {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let initialViewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController")        
//        self.presentViewController(initialViewController, animated: true, completion: nil)
    }
    
    /*
        The click function for the forgot password button.
    
        sender  The Button being pressed.
    */
    @IBAction func forgotPasswordClicked(sender: UIButton)
    {
        let storyboard : UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("ForgotPasswordViewController") as! ForgotPasswordViewController
        
        let navigationController = UINavigationController(rootViewController: vc)

        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
