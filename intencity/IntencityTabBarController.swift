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

        // Change the color of teh tab bar.
        self.tabBar.backgroundColor = Color.page_background
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

