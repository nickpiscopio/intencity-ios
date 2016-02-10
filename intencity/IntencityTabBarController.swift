//
//  IntencityTabViewController.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/10/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.
//

import UIKit

class IntencityTabBarController: UITabBarController
{
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Adds a back image to the navigation bar.
        // We need this because we can't add a standard navigation bar without disrupting the page view controller.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:UIImage(named: "back_button.png"), style:.Plain, target:self, action:"goBack");
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

