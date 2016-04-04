//
//  MainViewController.swift
//  Intencity
//
//  The view controller for the search.
//
//  Created by Nick Piscopio on 2/29/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, ServiceDelegate, ExerciseSearchDelegate, UserSearchDelegate, ImageDelegate
{
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var connectionView: UIView!
    @IBOutlet weak var connectionContainer: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var connectionIssue: UIImageView!
    @IBOutlet weak var noConnectionLabel: UILabel!
    
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
    
    var profileViewController: ProfileViewController!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.hidden = true
        
        initConnectionViews()
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: 0, emptyTableStringRes: "no_results")

        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.SEARCH_EXERCISE_CELL, cellName: Constant.SEARCH_EXERCISE_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.RANKING_CELL, cellName: Constant.RANKING_CELL)
        
        initSearchBar()
        
        email = Util.getEmailFromDefaults()
    }

     /**
     * Initializes the connection views.
     */
    func initConnectionViews()
    {
        loadingView.backgroundColor = Color.page_background
        connectionContainer.backgroundColor = Color.page_background
        connectionView.backgroundColor = Color.page_background
    
        loadingView.hidden = true
        connectionView.hidden = true
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.hidden = true
        
        noConnectionLabel.text = NSLocalizedString("generic_error", comment: "")
        noConnectionLabel.textColor = Color.secondary_light
    }
    
    /**
     * Shows the task is in progress.
     */
    func showLoading()
    {
        activityIndicator.startAnimating()
        activityIndicator.hidden = false
        
        loadingView.hidden = false
    }
    
    /**
     * Shows the task is in finished.
     */
    func hideLoading()
    {
        loadingView.hidden = true
        
        activityIndicator.stopAnimating()
    }
    /**
     * Shows there was a connection issue.
     */
    func showConnectionIssue()
    {
        connectionView.hidden = false
    }
    
    /**
     * Hides the connection issue.
     */
    func hideConnectionIssue()
    {
        connectionView.hidden = true
    }
    
    override func viewWillDisappear(animated : Bool)
    {
        super.viewWillDisappear(animated)
        
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
        showLoading()
        
        hideConnectionIssue()
        
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
            
            query = Util.replaceApostrophe(query)
            
            urlParameters = Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_SEARCH_USERS, variables: [ email, query ])
            
            event = ServiceEvent.SEARCH_FOR_USER
        }
        
        _ = ServiceTask(event: event, delegate: self, serviceURL: Constant.SERVICE_STORED_PROCEDURE, params: urlParameters)
        
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
                    do
                    {
                        exercises = try ExerciseDao().parseJson(json)
                    }
                    catch
                    {
                        exercises.removeAll()
                    }
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
                    do
                    {
                        users = try UserDao().parseJson(json)
                    }
                    catch
                    {
                       users.removeAll()
                    }
                    
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
        
        hideLoading()
    }
    
    func onRetrievalFailed(event: Int)
    {       
        hideLoading()
        
        showConnectionIssue()
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
     * The callback for when an exercise is clicked from searching.
     */
    func onExerciseClicked(exerciseName: String)
    {
        let vc = storyboard!.instantiateViewControllerWithIdentifier(Constant.DIRECTION_VIEW_CONTROLLER) as! DirectionViewController        
        vc.exerciseName = exerciseName
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    /**
     * The callback for when a user is added from searching.
     */
    func onUserAdded()
    {
        addedUser = true
    }
    
    func onImageRetrieved(index: Int, image: UIImage, newUpload: Bool)
    {
        users[index].profilePic = image
        
        if (profileViewController != nil && profileViewController.index == index)
        {
            profileViewController.profilePic.image = image
        }
    }
    
    func onImageRetrievalFailed() { }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        tableView.backgroundView?.hidden = exercises.count > 0 || users.count > 0
        
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
        
        if (state == ServiceEvent.SEARCH_FOR_EXERCISE)
        {
            let exercise = exercises[index]
            
            let currentExerciseCount = currentExercises.count
            
            var hasExerciseAlready = false
            
            for i in 0 ..< currentExerciseCount
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
            
            let cell = tableView.dequeueReusableCellWithIdentifier(Constant.RANKING_CELL) as! RankingCellController
            cell.user = user
            cell.rankingLabel.hidden = true
            cell.userNotification.hidden = true
            cell.name.text = user.getName()
            cell.pointsLabel.text = String(user.earnedPoints)
            cell.delegate = self
            cell.retrieveProfilePic(index)
            
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if (state == ServiceEvent.SEARCH_FOR_USER)
        {
            // Deselects the row.
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            let index = indexPath.row
            
            profileViewController = storyboard!.instantiateViewControllerWithIdentifier(Constant.PROFILE_VIEW_CONTROLLER) as! ProfileViewController
            profileViewController.index = index
            profileViewController.user = users[index]
            profileViewController.delegate = self
            
            self.navigationController!.pushViewController(profileViewController, animated: true)
        }
    }
}