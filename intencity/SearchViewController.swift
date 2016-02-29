//
//  MainViewController.swift
//  Intencity
//
//  The view controller for the search.
//
//  Created by Nick Piscopio on 2/29/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, ServiceDelegate, ExerciseSearchDelegate, UserSearchDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    var state: Int!
    
    var searchBar: UISearchBar = UISearchBar(frame: CGRectMake(0, 0, 300, 20))
    
    var exercises = [Exercise]()
    var users = [User]()
    
    weak var exerciseSearchDelegate: ExerciseSearchDelegate!
    weak var userSearchDelegate: UserSearchDelegate!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        let image: UIImage = UIImage(named: "magnifying_glass")!
        searchBar.setImage(image, forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal)
        searchBar.delegate = self
        
//        searchBar.setImage(nil, forSearchBarIcon: UISearchBarIcon.Clear, state: UIControlState.Normal)
        
        let searchPlaceholder = state == ServiceEvent.SEARCH_FOR_EXERCISE ? NSLocalizedString("search_exercise", comment: "") : NSLocalizedString("search_user", comment: "")
        
        let textField = searchBar.valueForKey("searchField") as! UITextField
        textField.backgroundColor = Color.primary
        textField.textColor = Color.white
        textField.attributedPlaceholder = NSAttributedString(string: searchPlaceholder, attributes:[NSForegroundColorAttributeName: Color.white])
        textField.keyboardType = UIKeyboardType.ASCIICapable

        self.navigationItem.titleView = searchBar
        
        // Initialize the tableview.
        Util.initTableView(tableView, removeSeparators: false, addFooter: false)

        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.SEARCH_CELL, cellName: Constant.SEARCH_CELL)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /**
     * The callback for the search button being clicked on the keyboard.
     */
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
//        progressBar.setVisibility(View.VISIBLE);
//        
//        connectionIssue.setVisibility(View.GONE);
        
        let email = Util.getEmailFromDefaults()
        
        // The parameters to search on.
        var urlParameters = ""
        
        // Get all the users from the database with the search query minus the spaces.
        var query = searchBar.text!
        
        if (state == ServiceEvent.SEARCH_FOR_EXERCISE)
        {
            urlParameters = Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_SEARCH_EXERCISES, variables: [ email, query ])
        }
        else
        {
            if let regex = try? NSRegularExpression(pattern: Constant.SPACE_REGEX, options: .CaseInsensitive)
            {
                query = regex.stringByReplacingMatchesInString(query, options: .WithTransparentBounds, range: NSMakeRange(0, query.characters.count), withTemplate: "")
            }
            
            urlParameters = Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_SEARCH_USERS, variables: [ email, query ])
        }
        
        ServiceTask(event: ServiceEvent.SEARCH_FOR_EXERCISE, delegate: self, serviceURL: Constant.SERVICE_STORED_PROCEDURE, params: urlParameters)
        
        searchBar.endEditing(true)
    }
    
    func onRetrievalSuccessful(event: Int, result: String)
    {
        // This gets saved as NSDictionary, so there is no order
        let json: AnyObject? = result.parseJSONString
        
        switch(event)
        {
            case ServiceEvent.SEARCH_FOR_EXERCISE:
                
                // This means we got results back from the web database.
                if (result != "")
                {
                    exercises = ExerciseDao().parseJson(json)
                }

                break
            case ServiceEvent.SEARCH_FOR_USER:
                break
            default:
                break
        }
        
        tableView.reloadData()
    }
    
    func onRetrievalFailed(event: Int)
    {
        
        
    }
    
    /**
     * The callback for when an exercise is added from searching.
     */
    func onExerciseAdded(exercise: Exercise)
    {
        exerciseSearchDelegate.onExerciseAdded(exercise)
        
        // Navigates the user back to the previous screen.
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /**
     * The callback for when a user is added from searching.
     */
    func onUserAdded(user: User)
    {
        userSearchDelegate.onUserAdded(user)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Return the number of rows in the section.
        return state == ServiceEvent.SEARCH_FOR_EXERCISE ? exercises.count : users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
        
        let result = state == ServiceEvent.SEARCH_FOR_EXERCISE ? exercises[index] : users[index]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.SEARCH_CELL) as! SearchCellController
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.exerciseSearchDelegate = self
        cell.setSearchResult(state, result: result)
        
        return cell
    }

}