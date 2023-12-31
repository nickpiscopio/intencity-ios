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
    
    weak var delegate: ExerciseDelegate?
    
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
        
        exerciseName = exercise.exerciseName
        
        // Sets the title for the screen.
        self.navigationItem.title = exerciseName
        
        // Sets the sets from the exercise.
        sets = exercise.sets
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.isHidden = true
        
        repsString = NSLocalizedString("title_reps", comment: "")
        timeString = NSLocalizedString("title_time", comment: "")
        
        weightTitleLabel.text = NSLocalizedString("title_weight", comment: "")
        IntensityTitleLabel.text = NSLocalizedString("title_intensity", comment: "")
        
        weightTitleLabel.textColor = Color.secondary_light
        IntensityTitleLabel.textColor = Color.secondary_light
        durationTitleLabel.setTitleColor(Color.secondary_light, for: UIControlState())
        
        let notes = sets[0].notes
        
        notesTextField?.placeholder = NSLocalizedString("note_hint", comment: "")
        notesTextField.text = notes.isEmpty || notes == Constant.RETURN_NULL ? "" : notes
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: Dimention.TABLE_FOOTER_HEIGHT_NORMAL, emptyTableStringRes: "")
        //tableView.backgroundColor = Color.white
        
        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: "Set", cellName: Constant.SET_CELL)
        
        // Initialize the duration dropdown.
        dropDown.dataSource = [ repsString, timeString ]
        dropDown.selectionAction = { [unowned self] (index, item) in
            self.durationTitleLabel.setTitle(item, for: .normal)
            
            self.setDuration(item)
        }
        dropDown.anchorView = durationTitleLabel
        dropDown.bottomOffset = CGPoint(x: 0, y: 0)
        // We set the width here to the largest item in the data source.
        // We do this so the drop down doesn't keep resizing every time an item is selcted.
        dropDown.width = 53
        
        let duration = sets[0].duration
        if(duration != Constant.RETURN_NULL && Util.convertToInt(duration) > 0)
        {
            durationTitleLabel.setTitle(timeString, for: UIControlState())
            dropDown.selectRow(at: 1)
        }
        else
        {
            durationTitleLabel.setTitle(repsString, for: UIControlState())
            dropDown.selectRow(at: 0)
        }
        
        let saveButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(StatViewController.savePressed(_:)))
        
        let infoIcon = UIImage(named: "info")
        
        let size = infoIcon!.size
        
        let iconSize = CGRect(origin: CGPoint.zero, size: CGSize(width: size.width + 20, height: size.height))
    
        let infoButton = UIButton(frame: iconSize)
        infoButton.setImage(infoIcon, for: UIControlState())
        infoButton.addTarget(self, action: #selector(StatViewController.infoPressed(_:)), for: .touchUpInside)
        
        let infoButtonItem: UIBarButtonItem = UIBarButtonItem(customView: infoButton)
    
        self.navigationItem.setRightBarButtonItems([saveButtonItem, infoButtonItem], animated: true)
    }
    
    /**
     * The drop down click.
     */
    @IBAction func showOrDismiss(_ sender: AnyObject)
    {
        if dropDown.isHidden
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
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Return the number of rows in the section.
        return sets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let index = (indexPath as NSIndexPath).row
        let set = sets[index]
        let weight: Float = set.weight
        let weightValue: String = weight > 0.0 ? String(weight) : ""
        let difficulty = set.difficulty
        let reps = set.reps
        let repsValue = reps > 0 ? String(reps) : ""
        let time = set.duration
        let timeValue = time != Constant.RETURN_NULL ? time : ""
        let duration = Util.convertToInt(time) > 0 ? timeValue : repsValue
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.SET_CELL) as! SetCellController
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.delegate = self
        cell.index = index
        cell.weightTextField.text = weightValue
        cell.durationTextField.text = duration
        cell.dropDown.selectRow(at: difficulty - 1)
        cell.intensityButton.setTitle(String(difficulty), for: UIControlState())
        cell.setNumberLabel.text = "\(index + 1)"
        cell.isReps = dropDown.selectedItem! == repsString
        return cell
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        return Util.isFieldValid(string, regEx: "[0-9a-zA-z\\.\\-_~\\s\\n]+") || string == ""
    }
    
    /**
     * The button click for adding the next set.
     */
    @IBAction func addSet(_ sender: AnyObject)
    {
        // Removed the first responder when the save is clicked
        // We do this so we can save values if the cursor is still in the textfield.
        UIResponder.getCurrentFirstResponder()?.resignFirstResponder()
        
        let set = sets[sets.count - 1]
        
        if (Util.convertToInt(set.duration) > 0 || set.reps > 0)
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
    func setDuration(_ type: String)
    {
        let length = sets.count
        for i in 0 ..< length
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
                    reps = Util.convertToInt(durationValue)
                    
                    durationSet = true
                }
            }
            else
            {
                let repsValue = sets[i].reps
                if (repsValue != Int(Constant.CODE_FAILED))
                {
                    duration = Util.convertToTime(repsValue)
                    
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
     * The function for when the info button is pressed.
     */
    @objc func infoPressed(_ sender: UIBarButtonItem)
    {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: Constant.DIRECTION_VIEW_CONTROLLER) as! DirectionViewController
        viewController.exerciseName = exerciseName
        
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    /**
     * The function for when the save button is pressed.
     */
    @objc func savePressed(_ sender: UIBarButtonItem)
    {
        // Removed the first responder when the save is clicked
        // We do this so we can save values if the cursor is still in the textfield.
        UIResponder.getCurrentFirstResponder()?.resignFirstResponder()
        
        let set = sets[sets.count - 1]
        let duration = set.duration
        let durationValue = Util.convertToInt(duration)
        
        if set.reps > 0 || durationValue > 0
        {
            saveSets(false)
        }
        else
        {
            Util.displayAlert(self, title: NSLocalizedString("button_remove_set", comment: ""),
                message: NSLocalizedString("message_remove_last_set", comment: ""),
                actions: [ UIAlertAction(title: NSLocalizedString("button_remove_set", comment: ""), style: .destructive, handler: removeLastSetClicked),
                    UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil) ])
        }
    }
    
    /**
     * The action for the remove last set alert button.
     */
    func removeLastSetClicked(_ alertAction: UIAlertAction!) -> Void
    {
        saveSets(true)
    }
    
    /**
     * The function for when the save button is pressed.
     */
    func saveSets(_ removeLastSet: Bool)
    {
        if (removeLastSet)
        {
            sets.removeLast()
            
            if (sets.count == 0)
            {
                addSet()
            }
        }
        
        // Navigates the user back to the previous screen.
        self.navigationController!.popToRootViewController(animated: true)
        
        // Takes all the sets and puts them back into the exercise.
        ExerciseData.getInstance().exerciseList[index].sets = sets
        
        // Tell the previous screen that the set was updated.
        delegate?.onSetUpdated(index)
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
        
        let set = Set(webId: Int(Constant.CODE_FAILED), weight: weight, reps: 0, duration: Util.convertToTime(0), difficulty: difficulty, notes: notesTextField.text!)
        sets.append(set)
        
        if (totalSets > 0)
        {
            insertRow()
        }        
    }
    
    /**
     * Animates a row being added to the screen.
     */
    func insertRow()
    {
        let indexPath = IndexPath(row: sets.count - 1, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .bottom)
        
        tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
    }
    
    @IBAction func onNotesUpdated(_ sender: AnyObject)
    {
        let totalSets = sets.count
        
        for i in 0 ..< totalSets
        {
            sets[i].notes = notesTextField.text!
        }
    }
    /**
     * The callback for when the weight is updated.
     */
    func onWeightUpdated(_ index: Int, weight: Float)
    {
        if (index <= sets.count - 1)
        {
            sets[index].weight = weight
        }
    }
    
    /**
     * The callback for when the reps are updated.
     */
    func onDurationUpdated(_ index: Int, duration: String)
    {
        if (index <= sets.count - 1)
        {
            if (dropDown.selectedItem! == repsString)
            {
                sets[index].reps = Util.convertToInt(duration)
            }
            else
            {
                sets[index].duration = duration
            }
        }
    }
    
    /**
     * The callback for when the intensity is updated.
     */
    func onIntensityUpdated(_ index: Int, intensity: Int)
    {
        if (index <= sets.count - 1)
        {
            sets[index].difficulty = intensity
        }
    }
}
