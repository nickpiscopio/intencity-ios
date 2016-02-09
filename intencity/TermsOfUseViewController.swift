//
//  TermsOfUseViewController.swift
//  Intencity
//
//  This is the controller for the terms of use.
//
//  Created by Nick Piscopio on 2/9/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class TermsOfUseViewController: UIViewController
{
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Sets the title for the screen.
        self.navigationController?.navigationBar.topItem!.title = NSLocalizedString("title_terms", comment: "")
        
        // Adds a back image to the navigation bar.
        // We need this because we can't add a standard navigation bar without disrupting the page view controller.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:UIImage(named: "back_button.png"), style:.Plain, target:self, action:"goBack");
        
        // Do any additional setup after loading the view, typically from a nib.
        let localfilePath = NSBundle.mainBundle().URLForResource("terms", withExtension: "html");
        let myRequest = NSURLRequest(URL: localfilePath!);
        webView.loadRequest(myRequest);
    }
    
    /*
        The function to dismiss the current view controller.
    */
    func goBack()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

