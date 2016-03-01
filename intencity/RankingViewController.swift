//
//  RankingViewController.swift
//  Intencity
//
//  The view controller for the Ranking screen.
//
//  Created by Nick Piscopio on 2/10/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class RankingViewController: UIViewController, ServiceDelegate, UserSearchDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addFollowerButton: IntencityButtonRound!
    
    var currentUsers = [User]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Sets the title for the screen.
        self.navigationController?.navigationBar.topItem!.title = NSLocalizedString("app_name", comment: "")
        
        // Initialize the tableview.
        Util.initTableView(tableView, removeSeparators: true, addFooter: true)
        
        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.RANKING_CELL, cellName: Constant.RANKING_CELL)
        
        getFollowing()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addFollowerClicked(sender: AnyObject)
    {
        let storyboard = UIStoryboard(name: Constant.MAIN_STORYBOARD, bundle: nil)
        
        let viewController = storyboard.instantiateViewControllerWithIdentifier(Constant.SEARCH_VIEW_CONTROLLER) as! SearchViewController
        viewController.state = ServiceEvent.SEARCH_FOR_USER
        viewController.userSearchDelegate = self
        viewController.currentUsers = currentUsers
        
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    /**
     * Start the task to get the user's following.
     */
    func getFollowing()
    {
        let email = Util.getEmailFromDefaults()
        
        ServiceTask(event: ServiceEvent.GENERIC, delegate: self,
            serviceURL: Constant.SERVICE_STORED_PROCEDURE,
            params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_FOLLOWING, variables: [ email ]))
    }
    
    func onRetrievalSuccessful(event: Int, result: String)
    {
        // This gets saved as NSDictionary, so there is no order
        currentUsers = UserDao().parseJson(result.parseJSONString)
        
        tableView.reloadData()
    }
    
    func onRetrievalFailed(event: Int)
    {
        // for when it fails.
    }
    
    func onUserAdded(user: User)
    {
        // MIGHT NOT BE NEEDED.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        // Return the number of rows in the section.
        return currentUsers.count
    }
   
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
        let user = currentUsers[index]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.RANKING_CELL) as! RankingCellController
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.addButton.hidden = true
        cell.name.text = user.getName()
        cell.rankingLabel.text = String(index + 1)
        
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

//    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?
//    {
//        isSwipeOpen = true
//        
//        let remove = UITableViewRowAction(style: .Normal, title: NSLocalizedString("hide", comment: "")) { action, index in
//            
//            let exerciseName = self.exerciseData.exerciseList[indexPath.row].exerciseName
//            let actions = [ UIAlertAction(title: NSLocalizedString("hide_for_now", comment: ""), style: .Default, handler: self.hideExercise(indexPath)),
//                UIAlertAction(title: NSLocalizedString("hide_forever", comment: ""), style: .Destructive, handler: self.hideExercise(indexPath)),
//                UIAlertAction(title: NSLocalizedString("do_not_hide", comment: ""), style: .Cancel, handler: self.cancelRemoval(indexPath)) ]
//            Util.displayAlert(self, title: String(format: NSLocalizedString("hide_exercise", comment: ""), exerciseName), message: "", actions: actions)
//        }
//        
//        remove.backgroundColor = Color.card_button_delete_select
//        
//        return [remove]
//    }
//    
//    func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath)
//    {
//        self.isSwipeOpen = false
//    }
//    
//    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
//    {
//        // Only edit the cells if the user is exercising.
//        return state == Constant.EXERCISE_CELL
//    }
//    
//    /**
//     * Hides an exercise in the exercise list.
//     *
//     * @param indexPath The index path for the exercise to hide.
//     */
//    func hideExercise(indexPath: NSIndexPath)(alertAction: UIAlertAction!) -> Void
//    {
//        tableView.beginUpdates()
//        
//        let index = indexPath.row
//        
//        currentExercises.removeAtIndex(index)
//        exerciseData.exerciseList.removeAtIndex(index)
//        
//        exerciseData.exerciseIndex--
//        
//        updateExerciseTotal()
//        
//        // Note that indexPath is wrapped in an array: [indexPath]
//        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//        
//        addExercise()
//        
//        tableView.endUpdates()
//    }
//    
//    func cancelRemoval(indexPath: NSIndexPath)(alertAction: UIAlertAction!) { }

}
