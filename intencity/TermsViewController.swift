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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("title_terms", comment: "")
        
        // Hides the tab bar.
        // This is needed for when we have the terms in the menu.
        self.tabBarController?.tabBar.hidden = true
        
        // Do any additional setup after loading the view, typically from a nib.
        let localfilePath = NSBundle.mainBundle().URLForResource("terms", withExtension: "html");
        let myRequest = NSURLRequest(URL: localfilePath!);
        webView.loadRequest(myRequest);
        webView.scrollView.bounces = false
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}