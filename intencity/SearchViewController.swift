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
    
    // The milliseconds it takes to search for an exercise.
    // We want this because the user might be typing, and we don't want to flood the server with searches.
    let SEARCH_EXECUTE_SECONDS = 1.3;
    
    var state: Int!
    
    var searchBar: UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
    
    var currentExercises = [Exercise]()
    var exercises = [Exercise]()
    
    var currentUsers = [User]()
    var users = [User]()
    
    var email = ""
    
    var addedUser = false
    
    var profileViewController: ProfileViewController!
    
    var searchExecutionTimer = Timer()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.isHidden = true
        
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
    
        loadingView.isHidden = true
        connectionView.isHidden = true
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = true
        
        noConnectionLabel.text = NSLocalizedString("generic_error", comment: "")
        noConnectionLabel.textColor = Color.secondary_light
    }
    
    /**
     * Shows the task is in progress.
     */
    func showLoading()
    {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        loadingView.isHidden = false
    }
    
    /**
     * Shows the task is in finished.
     */
    func hideLoading()
    {
        loadingView.isHidden = true
        
        activityIndicator.stopAnimating()
    }
    /**
     * Shows there was a connection issue.
     */
    func showConnectionIssue()
    {
        connectionView.isHidden = false
    }
    
    /**
     * Hides the connection issue.
     */
    func hideConnectionIssue()
    {
        connectionView.isHidden = true
    }
    
    override func viewWillDisappear(_ animated : Bool)
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
        let image: UIImage = UIImage(named: "magnifying_glass_light")!
        searchBar.setImage(image, for: UISearchBarIcon.search, state: UIControlState())
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        let searchPlaceholder = state == ServiceEvent.SEARCH_FOR_EXERCISE ? NSLocalizedString("search_exercise", comment: "") : NSLocalizedString("search_user", comment: "")
        
        let textField = searchBar.value(forKey: "searchField") as! UITextField
        textField.backgroundColor = Color.primary
        textField.textColor = Color.white
        textField.attributedPlaceholder = NSAttributedString(string: searchPlaceholder, attributes:[NSAttributedStringKey.foregroundColor: Color.white])
        textField.keyboardType = UIKeyboardType.asciiCapable
        textField.clearButtonMode = UITextFieldViewMode.never
        
        self.navigationItem.titleView = searchBar
    }
    
    /**
     * The callback for when the search text changed.
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        showLoading()
        
        hideConnectionIssue()
        
        // Invalidate the search so we can start a new search in case the user isn't done typing.
        searchExecutionTimer.invalidate()
        // Start a timer to search after a specified time.
        searchExecutionTimer = Timer.scheduledTimer(timeInterval: SEARCH_EXECUTE_SECONDS, target: self, selector: #selector(search), userInfo: nil, repeats: false)
    }
    
    /**
     * The callback for the search button being clicked on the keyboard.
     */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        search()
    }
    
    /**
     * Executes a search.
     */
    @objc func search()
    {
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
            if let regex = try? NSRegularExpression(pattern: Constant.SPACE_REGEX, options: .caseInsensitive)
            {
                query = regex.stringByReplacingMatches(in: query, options: .withTransparentBounds, range: NSMakeRange(0, query.count), withTemplate: "")
            }
            
            query = Util.replaceApostrophe(query)
            
            urlParameters = Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_SEARCH_USERS, variables: [ email, query ])
            
            event = ServiceEvent.SEARCH_FOR_USER
        }
        
        _ = ServiceTask(event: event, delegate: self, serviceURL: Constant.SERVICE_STORED_PROCEDURE, params: urlParameters as NSString)
        
        searchBar.endEditing(true)
    }
    
    func onRetrievalSuccessful(_ event: Int, result: String)
    {
        // This gets saved as NSDictionary, so there is no order
        let json: AnyObject? = result.parseJSONString
        
        switch(event)
        {
            case ServiceEvent.SEARCH_FOR_EXERCISE:
                
                let searchString = searchBar.text!
                
                let exerciseDao = ExerciseDao()
                
                // This means we got results back from the web database.
                if (result != "" && result != Constant.RETURN_NULL)
                {
                    do
                    {
                        exercises = try exerciseDao.parseJson(json as? [AnyObject], searchString: searchString)
                    }
                    catch
                    {
                        exercises.removeAll()
                        
                        exercises.append(exerciseDao.getExercise(searchString))
                    }
                }
                else
                {
                    exercises.removeAll()
                    
                    exercises.append(exerciseDao.getExercise(searchString))
                }

                break
            case ServiceEvent.SEARCH_FOR_USER:
                
                // This means we got results back from the web database.
                if (result != "" && result != Constant.RETURN_NULL)
                {
                    do
                    {
                        users = try UserDao().parseJson(json as! [AnyObject]?)
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
    
    func onRetrievalFailed(_ event: Int)
    {
        exercises.removeAll()        
        exercises.append(ExerciseDao().getExercise(searchBar.text!))
        
        tableView.reloadData()

        hideLoading()
        
        showConnectionIssue()
    }
    
    /**
     * The callback for when an exercise is added from searching.
     */
    func onExerciseAdded(_ exercise: Exercise)
    {
        exerciseSearchDelegate.onExerciseAdded(exercise)
        
        // Navigates the user back to the previous screen.
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    /**
     * The callback for when an exercise is clicked from searching.
     */
    func onExerciseClicked(_ exerciseName: String)
    {
        let vc = storyboard!.instantiateViewController(withIdentifier: Constant.DIRECTION_VIEW_CONTROLLER) as! DirectionViewController        
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
    
    func onImageRetrieved(_ index: Int, image: UIImage, newUpload: Bool)
    {
        users[index].profilePic = image
        
        if (profileViewController != nil && profileViewController.index == index)
        {
            profileViewController.profilePic.image = image
        }
    }
    
    func onImageRetrievalFailed() { }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        tableView.backgroundView?.isHidden = exercises.count > 0 || users.count > 0
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Return the number of rows in the section.
        return state == ServiceEvent.SEARCH_FOR_EXERCISE ? exercises.count : users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let index = (indexPath as NSIndexPath).row
        
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
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.SEARCH_EXERCISE_CELL) as! SearchExerciseCellController
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.exerciseSearchDelegate = self
            cell.setExerciseResult(exercise)
            cell.addButton.isHidden = hasExerciseAlready
            
            return cell
        }
        else
        {
            let user = users[index]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.RANKING_CELL) as! RankingCellController
            cell.user = user
            cell.rankingLabel.isHidden = true
            cell.userNotification.isHidden = true
            cell.name.text = user.getName()
            cell.pointsLabel.text = String(user.earnedPoints)
            cell.delegate = self
            cell.retrieveProfilePic(index)
            
            let totalBadges = user.totalBadges
            
            if (totalBadges > 0)
            {
                cell.badgeView.isHidden = false
                cell.badgeTotalLabel.text = String(totalBadges)
            }
            else
            {
                cell.badgeView.isHidden = true
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
    {
        if (state == ServiceEvent.SEARCH_FOR_USER)
        {
            // Deselects the row.
            tableView.deselectRow(at: indexPath, animated: true)
            
            let index = (indexPath as NSIndexPath).row
            
            profileViewController = storyboard!.instantiateViewController(withIdentifier: Constant.PROFILE_VIEW_CONTROLLER) as! ProfileViewController
            profileViewController.index = index
            profileViewController.user = users[index]
            profileViewController.delegate = self
            
            self.navigationController!.pushViewController(profileViewController, animated: true)
        }
    }
}
