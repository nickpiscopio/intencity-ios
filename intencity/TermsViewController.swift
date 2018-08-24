//
//  TermsViewController.swift
//  Intencity
//
//  This is the controller for the terms of use.
//
//  Created by Nick Piscopio on 2/9/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class TermsViewController: UIViewController
{
    @IBOutlet weak var webView: UIWebView!
    
    var isTerms = true
    var includeNavButton = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background

        // Hides the tab bar.
        // This is needed for when we have the terms in the menu.
        self.tabBarController?.tabBar.isHidden = true
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString(isTerms ? "title_terms" : "title_privacy_policy", comment: "")
        if (isTerms && includeNavButton)
        {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("title_privacy_policy", comment: ""), style: .plain, target: self, action: #selector(TermsViewController.privacyPolicyClicked))
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        let localfilePath = Bundle.main.url(forResource: isTerms ? "terms" : "privacy", withExtension: "html");
        let myRequest = URLRequest(url: localfilePath!);
        webView.loadRequest(myRequest);
        webView.scrollView.bounces = false
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /**
     * The privacy policy button click.
     */
    @objc func privacyPolicyClicked()
    {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: Constant.TERMS_VIEW_CONTROLLER) as! TermsViewController
        viewController.isTerms = false
        
        self.navigationController!.pushViewController(viewController, animated: true)
    }
}
