//
//  DirectionViewController.swift
//  Intencity
//
//  The view controller for the stat screen.
//
//  Created by Nick Piscopio on 2/15/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import DropDown

class StatViewController: UIViewController, SetDelegate
{
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var durationTitleLabel: UIButton!
    @IBOutlet weak var weightTitleLabel: UILabel!
    @IBOutlet weak var durationDropDownImage: UIButton!
    @IBOutlet weak var IntensityTitleLabel: UILabel!
    
    let dropDown = DropDown()
    
    var exerciseName: String!
    var sets: [Set] = []    
    var index: Int!
    
    var repsString = ""
    var timeString = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let exercise = ExerciseData.getInstance().exerciseList[index]
        
        // Sets the title for the screen.
        self.navigationItem.title = exercise.name
        
        // Sets the sets from the exercise.
        sets = exercise.sets
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.hidden = true
        
        repsString = NSLocalizedString("title_reps", comment: "")
        timeString = NSLocalizedString("title_time", comment: "")
        
        weightTitleLabel.text = NSLocalizedString("title_weight", comment: "")
        IntensityTitleLabel.text = NSLocalizedString("title_intensity", comment: "")
        
        weightTitleLabel.textColor = Color.secondary_light
        IntensityTitleLabel.textColor = Color.secondary_light
        durationTitleLabel.setTitleColor(Color.secondary_light, forState: UIControlState.Normal)
        
        notesTextField?.placeholder = NSLocalizedString("note_hint", comment: "")
        
        // Initialize the tableview.
        Util.initTableView(tableView, removeSeparators: false)
        
        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: "Set", cellName: Constant.SET_CELL)
        
        // Initialize the duration dropdown.
        dropDown.dataSource = [ repsString, timeString ]
        dropDown.selectionAction = { [unowned self] (index, item) in
            self.durationTitleLabel.setTitle(item, forState: .Normal)
            
            self.setDuration(item)
        }
        dropDown.anchorView = durationTitleLabel
        dropDown.bottomOffset = CGPoint(x: 0, y:durationTitleLabel.bounds.height / 2)
        // We set the width here to the largest item in the data source.
        // We do this so the drop down doesn't keep resizing every time an item is selcted.
        dropDown.width = 53
        
        let duration = sets[0].duration
        if(duration != Constant.RETURN_NULL)
        {
            durationTitleLabel.setTitle(timeString, forState: .Normal)
            dropDown.selectRowAtIndex(1)
        }
        else
        {
            durationTitleLabel.setTitle(repsString, forState: .Normal)
            dropDown.selectRowAtIndex(0)
        }
    }
    
    /**
     * The drop down click.
     */
    @IBAction func showOrDismiss(sender: AnyObject)
    {
        if dropDown.hidden
        {
            dropDown.show()
            
            UIResponder.getCurrentFirstResponder()?.resignFirstResponder()
        }
        else
        {
            dropDown.hide()
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        // Shows the tab bar again.
        self.tabBarController?.tabBar.hidden = false
        
        // Takes all the sets and puts them back into the exercise.
        ExerciseData.getInstance().exerciseList[index].sets = sets
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
        let weight: Float = set.weight
        let weightValue: String = weight > 0.0 ? String(weight) : ""
        let difficulty = set.difficulty
        let reps = set.reps
        let repsValue = reps > 0 ? String(reps) : ""
        let time = set.duration
        let timeValue = time != Constant.RETURN_NULL ? time : ""        
        let duration = reps > 0 ? repsValue : timeValue
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.SET_CELL) as! SetCellController
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.delegate = self
        cell.index = index
        cell.weightTextField.text = weightValue
        cell.durationTextField.text = duration
        cell.dropDown.selectRowAtIndex(difficulty - 1)
        cell.intensityButton.setTitle(String(difficulty), forState: .Normal)
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
            Util.displayAlert(self, title: NSLocalizedString("title_add_set_error", comment: ""), message: NSLocalizedString("message_add_set_error", comment: ""), actions: [])
        }
    }
    
    /**
     * Changes the sets to either be time or reps based.
     */
    func setDuration(type: String)
    {
        let length = sets.count
        for var i = 0; i < length; i++
        {
            var duration = ""
            var reps = 0
            
            var durationSet = false
            
            if (type == repsString)
            {
                let durationValue = sets[i].duration
                if (durationValue != String(Constant.RETURN_NULL))
                {
                    duration = String(Constant.RETURN_NULL)
                    reps = Int(durationValue.stringByReplacingOccurrencesOfString(":", withString: ""))!
                    
                    durationSet = true
                }
            }
            else
            {
                let repsValue = sets[i].reps
                if (repsValue != Int(Constant.CODE_FAILED))
                {
                    let time = String(format: "%06d", repsValue)
                    
                    if let regex = try? NSRegularExpression(pattern: "..(?!$)", options: .CaseInsensitive)
                    {
                        duration = regex.stringByReplacingMatchesInString(time, options: .WithTransparentBounds, range: NSMakeRange(0, time.characters.count), withTemplate: "$0:")
                    }
                    
                    reps = Int(Constant.CODE_FAILED)

                    durationSet = true
                }
            }
            
            if (durationSet)
            {
                sets[i].duration = duration
                sets[i].reps = reps
            }
        }

        tableView.reloadData()
    }
    
    /**
     * Adds a new set for an exercise
     */
    func addSet()
    {
        var weight: Float = 0.0
        var difficulty = 10
        
        let totalSets = sets.count
        
        if (totalSets > 0)
        {
            let lastSet = totalSets - 1
            
            weight = sets[lastSet].weight
            difficulty = sets[lastSet].difficulty
        }
        
        let set = Set(webId: Int(Constant.CODE_FAILED), weight: weight, reps: Int(Constant.CODE_FAILED), duration: String(Constant.CODE_FAILED), difficulty: difficulty, notes: notesTextField.text!)
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
     * The callback for when the weight is updated.
     */
    func onWeightUpdated(index: Int, weight: Float)
    {
        sets[index].weight = weight
    }
    
    /**
     * The callback for when the reps are updated.
     */
    func onDurationUpdated(index: Int, duration: String)
    {
        if (dropDown.selectedItem! == repsString)
        {
            sets[index].reps = Int(duration)!
        }
        else
        {
            sets[index].duration = duration
        }
    }
    
    /**
     * The callback for when the intensity is updated.
     */
    func onIntensityUpdated(index: Int, intensity: Int)
    {
        sets[index].difficulty = intensity
    }
}