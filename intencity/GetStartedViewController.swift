//
//  GetStartedViewController.swift
//  Intencity
//
//  The controller for the get started view.
//
//  Created by Nick Piscopio on 10/8/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class GetStartedViewController: UIViewController, ServiceDelegate
{
    @IBOutlet weak var loginButton: IntencityButtonNoBackground!
    @IBOutlet weak var createAccountButton: IntencityButtonNoBackground!
    @IBOutlet weak var termsLabel: UIButton!
    @IBOutlet weak var getStartedButton: IntencityButton!
    
    @IBOutlet weak var separator: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var trialEmail: String = ""
    var trialAccountType: String = ""
    var trialDateCreated: Double = 0
    var termsString = NSLocalizedString("terms_agreement", comment: "")
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Sets the background color of the view.
        self.view.backgroundColor = Color.page_background
        
        separator.textColor = Color.secondary_dark
        
        let getStartedText = NSLocalizedString("get_started", comment: "")
        
        // Sets the title for the screen.
        self.navigationItem.title = getStartedText
        
        loginButton?.setTitle(NSLocalizedString("have_an_account", comment: ""), for: UIControlState())
        createAccountButton?.setTitle(NSLocalizedString("create_account", comment: ""), for: UIControlState())
        getStartedButton?.setTitle(getStartedText.uppercased(), for: UIControlState())
    
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
    
    /**
     * The button click for trying Intencity.
     */
    @IBAction func getStartedClicked(_ sender: AnyObject)
    {
        trialAccountType = Constant.ACCOUNT_TYPE_MOBILE_TRIAL
        trialDateCreated = Date().timeIntervalSince1970 * 1000
        let createdDateString = String(format:"%f", trialDateCreated)
        let firstName = "Anonymous";
        let lastName = "User";
        trialEmail = lastName +  createdDateString + "@intencity.fit";
        let password = createdDateString;
        
        startLogin()
        
        _ = ServiceTask(event: ServiceEvent.TRIAL, delegate: self,
                        serviceURL: Constant.SERVICE_CREATE_ACCOUNT,
                        params: Constant.getAccountParameters(firstName, lastName: lastName, email: trialEmail, password: password, accountType: trialAccountType) as NSString)
    }
    
    /**
     * The alert function for opening the terms.
     */
    func openTerms(_ alertAction: UIAlertAction!)
    {
        openTerms()
    }
    
    /**
     * Creates the trial account.
     */
    func createTrial(_ alertAction: UIAlertAction!)
    {
        
    }
    
    /**
     * The function called when we get the user's credentials come back from the server successfully.
     */
    func onRetrievalSuccessful(_ event: Int, result: String)
    {
        Util.loadIntencity(self, email: trialEmail, accountType: trialAccountType, createdDate: trialDateCreated)
    }
    
    /**
     * The function called when we fail to get the user's credentials back from the server.
     */
    func onRetrievalFailed(_ Event: Int)
    {
        Util.displayAlert(self, title:  NSLocalizedString("generic_error", comment: ""), message: NSLocalizedString("intencity_communication_error", comment: ""), actions: [])
        
        stopLogin()
    }
    
    func startLogin()
    {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        loginButton.isHidden = true
        createAccountButton.isHidden = true
        termsLabel.isHidden = true
        getStartedButton.isHidden = true
        separator.isHidden = true
    }
    
    func stopLogin()
    {
        loginButton.isHidden = false
        createAccountButton.isHidden = false
        termsLabel.isHidden = false
        getStartedButton.isHidden = false
        separator.isHidden = false
        
        activityIndicator.stopAnimating()
    }
    
    /**
     * Opens the terms of use.
     */
    func openTerms()
    {
        let viewController = storyboard!.instantiateViewController(withIdentifier: Constant.TERMS_VIEW_CONTROLLER) as! TermsViewController
        viewController.includeNavButton = true
        viewController.isTerms = true
        
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    /**
     * The click function for the terms of use checkbox and label.
     */
    @IBAction func termsOfUseClicked(_ sender: UIButton)
    {
        openTerms()
    }
}
