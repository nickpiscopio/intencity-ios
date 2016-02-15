//
//  DirectionViewController.swift
//  Intencity
//
//  Created by Nick Piscopio on 2/15/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class DirectionViewController: UIViewController, ServiceDelegate
{
    @IBOutlet weak var youTubeWebView: UIWebView!
    @IBOutlet weak var submittedByLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var exerciseName: String!
    var videoUrl: String!
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
        self.tabBarController?.tabBar.hidden = true
        
        // Initialize the tableview.
        Util.initTableView(tableView, removeSeparators: false)
        Util.addUITableViewCell(tableView, nibNamed: "Direction", cellName: Constant.DIRECTION_CELL)
        
        ServiceTask(event: ServiceEvent.GENERIC, delegate: self,
            serviceURL: Constant.SERVICE_STORED_PROCEDURE,
            params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_EXERCISE_DIRECTION, variables: [ exerciseName ]))
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func onRetrievalSuccessful(event: Int, result: String)
    {
        print("directions: \(result)")
        
        // This gets saved as NSDictionary, so there is no order
        let json: AnyObject? = result.parseJSONString
        
        for steps in json as! NSArray
        {
            videoUrl = steps[Constant.COLUMN_VIDEO_URL] as! String
            submittedBy = steps[Constant.COLUMN_SUBMITTED_BY] as! String
            
            let step = steps[Constant.COLUMN_DIRECTION] as! String
            // Start at the third character so we can remove the number from the string.
            // This also means we can never have more than 9 steps in the directions.
            // We add the number later so it can be formatted properly.
            self.steps.append(step.substringFromIndex(step.startIndex.advancedBy(2)))
        }
        
        submittedByLabel.textColor = Color.secondary_light
        submittedByLabel.text = String(format: NSLocalizedString("submitted_by", comment: ""), submittedBy)
        
        loadYouTubeVideo()
        
        reloadTable()
    }
    
    func onRetrievalFailed(event: Int)
    {
    }
    
    func loadYouTubeVideo()
    {
        let width = youTubeWebView.frame.width
        let link = "http://www.youtube.com/embed/ \(videoUrl)"
        let iframe = "<iframe width='\(width)' height='auto' src='\(link)' frameborder='0' allowfullscreen></iframe>"
        
        youTubeWebView.loadHTMLString(iframe, baseURL: nil)
    }
    
    /**
     * Animates the table being added to the screen.
     */
    func reloadTable()
    {
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesInRange: range)
        
        self.tableView.reloadSections(sections, withRowAnimation: .Top)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Return the number of rows in the section.
        return steps.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.DIRECTION_CELL) as! DirectionCellController
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.stepNumber.text =  String(index + 1
            ) + "."
        cell.stepDescription.text = steps[index]
        
        return cell
    }
}