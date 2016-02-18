//
//  DirectionViewController.swift
//  Intencity
//
//  The view controller for the stat screen.
//
//  Created by Nick Piscopio on 2/15/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class StatViewController: UIViewController, SetDelegate
{
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var exerciseName: String!
    var sets: [Set] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Sets the title for the screen.
        self.navigationItem.title = exerciseName
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.hidden = true
        
        notesTextField?.placeholder = NSLocalizedString("note_hint", comment: "")
        
        // Initialize the tableview.
        Util.initTableView(tableView, removeSeparators: false)
        
        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: "Set", cellName: Constant.SET_CELL)
        
        addSet()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    override func viewWillDisappear(animated : Bool)
    {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.hidden = false
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Return the number of rows in the section.
        return sets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
        let set = sets[index]
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.SET_CELL) as! SetCellController
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.delegate = self
        cell.index = index
        cell.weightTextField.text = String(set.reps)
        cell.intensityLabel.text = String(set.difficulty)
        cell.setNumberLabel.text = "\(index + 1)"
        return cell
    }
    
    /**
     * The button click for adding the next set.
     */
    @IBAction func addSet(sender: AnyObject)
    {
        let set = sets[sets.count - 1]
        if (set.duration != String(Constant.CODE_FAILED) || set.reps != Int (Constant.CODE_FAILED))
        {
            addSet()
        }
        else
        {
            Util.displayAlert(self, title: NSLocalizedString("title_add_set_error", comment: ""), message: NSLocalizedString("message_add_set_error", comment: ""))
        }
    }
    
    /**
     * Adds a new set for an exercise
     */
    func addSet()
    {
        let set = Set(webId: 0, weight: 0, reps: Int(Constant.CODE_FAILED), duration: String(Constant.CODE_FAILED), difficulty: 10, notes: notesTextField.text!)
        sets.append(set)
        
        insertRow()
    }
    
    /**
     * Animates a row being added to the screen.
     */
    func insertRow()
    {
        let indexPath = NSIndexPath(forRow: sets.count - 1, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Bottom)
        
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }
    
    /**
     * Calls the callback for when the weight is updated.
     */
    func onWeightUpdated(index: Int, weight: Float)
    {
        sets[index].weight = weight
    }
    
    /**
     * Calls the callback for when the reps are updated.
     */
    func onRepsUpdated(index: Int, reps: Int)
    {
        sets[index].reps = reps
    }
    
    /**
     * Calls the callback for when the duration is updated.
     */
    func onTimeUpdated(index: Int, time: String)
    {
        sets[index].duration = time
    }
}