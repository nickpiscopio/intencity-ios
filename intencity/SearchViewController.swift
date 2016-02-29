//
//  MainViewController.swift
//  Intencity
//
//  The view controller for the search.
//
//  Created by Nick Piscopio on 2/29/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class SearchViewController: UIViewController
{
    var searchBar: UISearchBar = UISearchBar(frame: CGRectMake(0, 0, 300, 20))
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        let image: UIImage = UIImage(named: "magnifying_glass")!
        searchBar.setImage(image, forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal)
        
//        searchBar.setImage(nil, forSearchBarIcon: UISearchBarIcon.Clear, state: UIControlState.Normal)
        
        let textField = searchBar.valueForKey("searchField") as! UITextField
        textField.backgroundColor = Color.primary
        textField.textColor = Color.white
        textField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("search_exercise", comment: ""), attributes:[NSForegroundColorAttributeName: Color.white])
        textField.keyboardType = UIKeyboardType.ASCIICapable

        self.navigationItem.titleView = searchBar
        
        // Initialize the tableview.
//        Util.initTableView(tableView, removeSeparators: true, addFooter: true)
//
//        // Load the cells we are going to use in the tableview.
//        Util.addUITableViewCell(tableView, nibNamed: "RoutineCard", cellName: Constant.ROUTINE_CELL)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}