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
        
        if let items = tabBar.items
        {
            for item in items
            {
                item.title = ""
                item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
            }
        }
    }
    
    override func viewWillLayoutSubviews()
    {
        // Sets the tab bar height
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = Dimention.TAB_BAR_HEIGHT
        tabFrame.origin.y = self.view.frame.size.height - Dimention.TAB_BAR_HEIGHT
        self.tabBar.frame = tabFrame
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}