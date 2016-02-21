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
    var exerciseName: String!
    var sets: [Set] = []
    
    let dropDown = DropDown()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Sets the title for the screen.
        self.navigationItem.title = exerciseName
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.hidden = true
        
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
        dropDown.dataSource = [ NSLocalizedString("title_reps", comment: ""), NSLocalizedString("title_time", comment: "") ]
        dropDown.selectionAction = { [unowned self] (index, item) in
            self.durationTitleLabel.setTitle(item, forState: .Normal)
            
            self.setDuration(item)
        }
        dropDown.anchorView = durationTitleLabel
        dropDown.bottomOffset = CGPoint(x: 0, y:durationTitleLabel.bounds.height / 2)
        // We set the width here to the largest item in the data source.
        // We do this so the drop down doesn't keep resizing every time an item is selcted.
        dropDown.width = 53
        durationTitleLabel.setTitle(NSLocalizedString("title_reps", comment: ""), forState: .Normal)
        dropDown.selectRowAtIndex(0)
    }
    
    /**
     * The drop down click.
     */
    @IBAction func showOrDismiss(sender: AnyObject)
    {
        if dropDown.hidden
        {
            dropDown.show()
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
        let difficulty = set.difficulty
        let reps = set.reps
        let duration = reps > 0 ? String(reps) : set.duration
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.SET_CELL) as! SetCellController
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.delegate = self
        cell.index = index
        cell.weightTextField.text = String(set.weight)
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
            Util.displayAlert(self, title: NSLocalizedString("title_add_set_error", comment: ""), message: NSLocalizedString("message_add_set_error", comment: ""))
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
            
            if (type == NSLocalizedString("title_reps", comment: ""))
            {
                duration = String(Constant.CODE_FAILED)
                reps = Int(sets[i].duration.stringByReplacingOccurrencesOfString(":", withString: ""))!
            }
            else
            {
                let time = String(format: "%06d", sets[i].reps)

                if let regex = try? NSRegularExpression(pattern: "..(?!$)", options: .CaseInsensitive)
                {
                    duration = regex.stringByReplacingMatchesInString(time, options: .WithTransparentBounds, range: NSMakeRange(0, time.characters.count), withTemplate: "$0:")
                }
                
                reps = Int(Constant.CODE_FAILED)
            }
            
            sets[i].duration = duration
            sets[i].reps = reps
        }
        
        // reload table after done
        
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
        if (dropDown.selectedItem! == NSLocalizedString("title_reps", comment: ""))
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