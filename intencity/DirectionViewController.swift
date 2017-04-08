//
//  DirectionViewController.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/15/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import youtube_ios_player_helper

class DirectionViewController: UIViewController, ServiceDelegate
{
    @IBOutlet weak var submittedByLabel: UILabel!
    @IBOutlet weak var directionTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var youTubePlayerView: YTPlayerView!
    
    var exerciseName: String!
    var videoId: String!
    var submittedBy: String!
    var steps = [String]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Sets the title for the screen.
        self.navigationItem.title = exerciseName
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.isHidden = true
        
        youTubePlayerView.backgroundColor = Color.transparent
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: 0, emptyTableStringRes: "")
        Util.addUITableViewCell(tableView, nibNamed: "Direction", cellName: Constant.DIRECTION_CELL)
        
        _ = ServiceTask(event: ServiceEvent.GENERIC, delegate: self,
                        serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_EXERCISE_DIRECTION, variables: [ exerciseName ]) as NSString)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func onRetrievalSuccessful(_ event: Int, result: String)
    {
        // This gets saved as NSDictionary, so there is no order
        let json: [AnyObject] = result.parseJSONString as! [AnyObject]
        
        for steps in json
        {
            videoId = steps[Constant.COLUMN_VIDEO_URL] as! String
            submittedBy = steps[Constant.COLUMN_SUBMITTED_BY] as! String
            
            let step = steps[Constant.COLUMN_DIRECTION] as! String
            // Start at the third character so we can remove the number from the string.
            // This also means we can never have more than 9 steps in the directions.
            // We add the number later so it can be formatted properly.
            self.steps.append(step.substring(from: step.index(step.startIndex, offsetBy: 3)))
        }
        
        populateDirections()
    }
    
    func onRetrievalFailed(_ event: Int)
    {
        Util.displayAlert(self,
                            title: NSLocalizedString("generic_error", comment: ""),
                            message: NSLocalizedString("intencity_communication_error", comment: ""),
                            actions: [ UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: goBack) ])
    }
    
    /**
     * Initializes the directions when we get the information from the server.
     */
    func populateDirections()
    {
        submittedByLabel.textColor = Color.secondary_light
        submittedByLabel.text = String(format: NSLocalizedString("submitted_by", comment: ""), submittedBy)
        
        directionTitleLabel.text = NSLocalizedString("title_direction", comment: "")
        directionTitleLabel.textColor = Color.secondary_dark
        
        // This is so we don't get suggested videos after the exercise video ends.
        let vars = ["rel" : 0]
        youTubePlayerView.load(withVideoId: videoId, playerVars: vars)
        
        reloadTable()
    }
    
    /**
     * Animates the table being added to the screen.
     */
    func reloadTable()
    {
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesIn: range)
        
        self.tableView.reloadSections(sections as IndexSet, with: .top)
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Return the number of rows in the section.
        return steps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.DIRECTION_CELL) as! DirectionCellController
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.stepNumber.text =  String(index + 1) + "."
        cell.stepDescription.text = steps[index]
        
        return cell
    }
    
    /**
     * Navigates the user back to the previous view.
     */
    func goBack(alertAction: UIAlertAction!) -> Void
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
