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
    
    weak var exerciseSearchDelegate: ExerciseSearchDelegate!
    weak var userSearchDelegate: UserSearchDelegate!
    
    var state: Int!
    
    var searchBar: UISearchBar = UISearchBar(frame: CGRectMake(0, 0, 300, 20))
    
    var currentExercises = [Exercise]()
    var exercises = [Exercise]()
    
    var currentUsers = [User]()
    var users = [User]()
    
    var email = ""
    
    var addedUser = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.hidden = true
        
        // Initialize the tableview.
        Util.initTableView(tableView, removeSeparators: true, addFooter: false)

        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.SEARCH_EXERCISE_CELL, cellName: Constant.SEARCH_EXERCISE_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.RANKING_CELL, cellName: Constant.RANKING_CELL)
        
        initSearchBar()
        
        email = Util.getEmailFromDefaults()
    }
    
    override func viewWillDisappear(animated : Bool)
    {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.hidden = false
        
        if (addedUser)
        {
             userSearchDelegate.onUserAdded()
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /**
     * Initializes the search bar.
     */
    func initSearchBar()
    {
        let image: UIImage = UIImage(named: "magnifying_glass")!
        searchBar.setImage(image, forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal)
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        let searchPlaceholder = state == ServiceEvent.SEARCH_FOR_EXERCISE ? NSLocalizedString("search_exercise", comment: "") : NSLocalizedString("search_user", comment: "")
        
        let textField = searchBar.valueForKey("searchField") as! UITextField
        textField.backgroundColor = Color.primary
        textField.textColor = Color.white
        textField.attributedPlaceholder = NSAttributedString(string: searchPlaceholder, attributes:[NSForegroundColorAttributeName: Color.white])
        textField.keyboardType = UIKeyboardType.ASCIICapable
        textField.clearButtonMode = UITextFieldViewMode.Never
        
        self.navigationItem.titleView = searchBar
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
        
        var event = 0
        
        if (state == ServiceEvent.SEARCH_FOR_EXERCISE)
        {
            urlParameters = Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_SEARCH_EXERCISES, variables: [ email, query ])
            
            event = ServiceEvent.SEARCH_FOR_EXERCISE
        }
        else
        {
            if let regex = try? NSRegularExpression(pattern: Constant.SPACE_REGEX, options: .CaseInsensitive)
            {
                query = regex.stringByReplacingMatchesInString(query, options: .WithTransparentBounds, range: NSMakeRange(0, query.characters.count), withTemplate: "")
            }
            
            urlParameters = Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_SEARCH_USERS, variables: [ email, query ])
            
            event = ServiceEvent.SEARCH_FOR_USER
        }
        
        ServiceTask(event: event, delegate: self, serviceURL: Constant.SERVICE_STORED_PROCEDURE, params: urlParameters)
        
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
                if (result != "" && result != Constant.RETURN_NULL)
                {
                    exercises = ExerciseDao().parseJson(json)
                }
                else
                {
                    exercises.removeAll()
                }

                break
            case ServiceEvent.SEARCH_FOR_USER:
                
                // This means we got results back from the web database.
                if (result != "" && result != Constant.RETURN_NULL)
                {
                    users = UserDao().parseJson(json)
                }
                else
                {
                    users.removeAll()
                }
                
                break
            default:
                break
        }
        
        tableView.reloadData()
    }
    
    func onRetrievalFailed(event: Int)
    {
        exercises.removeAll()
        
        tableView.reloadData()
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
    func onUserAdded()
    {
        addedUser = true
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        if (exercises.count <= 0 && users.count <= 0)
        {
            let emptyTableLabel = UILabel(frame: CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height))
            emptyTableLabel.text = NSLocalizedString("no_results", comment: "")
            emptyTableLabel.textColor = Color.secondary_light
            emptyTableLabel.font = emptyTableLabel.font.fontWithSize(Dimention.FONT_SIZE_NORMAL)
            emptyTableLabel.textAlignment = .Center
            emptyTableLabel.sizeToFit()

            tableView.backgroundView = emptyTableLabel
            
            return 0
        }
        else
        {
            tableView.backgroundView = nil
            
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Return the number of rows in the section.
        return state == ServiceEvent.SEARCH_FOR_EXERCISE ? exercises.count : users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
        
        if (state == ServiceEvent.SEARCH_FOR_EXERCISE)
        {
            let exercise = exercises[index]
            
            let currentExerciseCount = currentExercises.count
            
            var hasExerciseAlready = false
            
            for (var i = 0; i < currentExerciseCount; i++)
            {
                if (currentExercises[i].exerciseName == exercise.exerciseName)
                {
                    hasExerciseAlready = true
                    
                    break
                }
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier(Constant.SEARCH_EXERCISE_CELL) as! SearchExerciseCellController
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.exerciseSearchDelegate = self
            cell.setExerciseResult(exercise)
            cell.addButton.hidden = hasExerciseAlready
            
            return cell
        }
        else
        {
            let user = users[index]
            
            let currentUserCount = currentUsers.count
            
            var isAreadyFollowing = false
            
            for (var i = 0; i < currentUserCount; i++)
            {
                if (currentUsers[i].getName() == user.getName())
                {
                    isAreadyFollowing = true
                    
                    break
                }
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier(Constant.RANKING_CELL) as! RankingCellController
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.userSearchDelegate = self
            cell.addButton.hidden = isAreadyFollowing
            cell.rankingLabel.hidden = true
            cell.name.text = user.getName()
            cell.email = email
            cell.userId = String(user.id)
            cell.pointsLabel.text = String(user.earnedPoints)
            
            let totalBadges = user.totalBadges
            
            if (totalBadges > 0)
            {
                cell.badgeView.hidden = false
                cell.badgeTotalLabel.text = String(totalBadges)
            }
            else
            {
                cell.badgeView.hidden = true
            }
            
            return cell
        }
    }
}