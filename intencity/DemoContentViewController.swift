//
//  DemoContentViewController.swift
//  Intencity
//
//  This is the controller for each demo screen.
//
//  Created by Nick Piscopio on 2/8/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class DemoContentViewController: PageViewController
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var paddedView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    var titleText: String!
    var descriptionText: String!
    var imageFile: String!
    
    var backgroundColor: UIColor!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        titleLabel.text = self.titleText
        descriptionLabel.text = self.descriptionText
        
        titleLabel.textColor = Color.white
        descriptionLabel.textColor = Color.white
        
        paddedView.backgroundColor = Color.transparent
        imageView.image = UIImage(named: self.imageFile)
        view.backgroundColor = backgroundColor
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}