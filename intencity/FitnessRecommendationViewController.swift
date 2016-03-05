//
//  FitnessRecViewController.swift
//  Intencity
//
//  The view controller for the fitness recommendations.
//
//  Created by Nick Piscopio on 3/4/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class FitnessRecommendationViewController: UIViewController
{
    @IBOutlet weak var gainButton: UIButton!
    @IBOutlet weak var sustainButton: UIButton!
    @IBOutlet weak var loseButton: UIButton!
    @IBOutlet weak var toneButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var fitnessRecommendationRows = [FitnessRecommendationRow]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("how_to_workout_title", comment: "")
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.hidden = true
        
        gainButton.setTitle(NSLocalizedString("gain", comment: ""), forState: .Normal)
        sustainButton.setTitle(NSLocalizedString("sustain", comment: ""), forState: .Normal)
        loseButton.setTitle(NSLocalizedString("lose", comment: ""), forState: .Normal)
        toneButton.setTitle(NSLocalizedString("tone", comment: ""), forState: .Normal)

        // Initialize the tableview.
        Util.initTableView(tableView, removeSeparators: true, addFooter: false)
        
        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.FITNESS_RECOMMENDATION_CELL, cellName: Constant.FITNESS_RECOMMENDATION_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.FITNESS_RECOMMENDATION_HEADER_CELL, cellName: Constant.FITNESS_RECOMMENDATION_HEADER_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.FITNESS_RECOMMENDATION_FOOTER_CELL, cellName: Constant.FITNESS_RECOMMENDATION_FOOTER_CELL)
        
        setSelectionSustain()
    }
    
    override func viewWillDisappear(animated : Bool)
    {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    @IBAction func gainClicked(sender: AnyObject)
    {
        goalSelected(gainButton, weight: "weight_gain", duration: "duration_gain", rest: "rest_gain", cardio: "cardio_day_gain")
    }
    
    @IBAction func sustainClicked(sender: AnyObject)
    {
        setSelectionSustain()
    }
    
    @IBAction func loseClicked(sender: AnyObject)
    {
        goalSelected(loseButton, weight: "weight_lose", duration: "duration_lose", rest: "rest_lose", cardio: "cardio_day_lose")
    }
    
    @IBAction func toneClicked(sender: AnyObject)
    {
        goalSelected(toneButton, weight: "weight_tone", duration: "duration_tone", rest: "rest_tone", cardio: "cardio_day_tone")
    }
    
    func setSelectionSustain()
    {
        goalSelected(sustainButton, weight: "weight_sustain", duration: "duration_sustain", rest: "rest_sustain", cardio: "cardio_day_sustain")
    }
    
    func goalSelected(button: UIButton, weight: String, duration: String, rest: String, cardio: String)
    {
        gainButton.backgroundColor = button == gainButton ? Color.shadow : Color.transparent
        sustainButton.backgroundColor = button == sustainButton ? Color.shadow : Color.transparent
        loseButton.backgroundColor = button == loseButton ? Color.shadow : Color.transparent
        toneButton.backgroundColor = button == toneButton ? Color.shadow : Color.transparent
        
        fitnessRecommendationRows.removeAll()
        fitnessRecommendationRows.append(FitnessRecommendationRow(title: NSLocalizedString("title_weight", comment: ""), includeDecoration: true, description: NSLocalizedString(weight, comment: "")))
        fitnessRecommendationRows.append(FitnessRecommendationRow(title: NSLocalizedString("title_duration", comment: ""), includeDecoration: false, description: NSLocalizedString(duration, comment: "")))
        fitnessRecommendationRows.append(FitnessRecommendationRow(title: NSLocalizedString("rest_title", comment: ""), includeDecoration: false, description: NSLocalizedString(rest, comment: "")))
        fitnessRecommendationRows.append(FitnessRecommendationRow(title: NSLocalizedString("cardio_day_title", comment: ""), includeDecoration: false, description: NSLocalizedString(cardio, comment: "")))
        
        tableView.reloadData()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return fitnessRecommendationRows.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return tableView.dequeueReusableCellWithIdentifier(Constant.FITNESS_RECOMMENDATION_HEADER_CELL) as! FitnessRecHeaderCellController
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 40
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return tableView.dequeueReusableCellWithIdentifier(Constant.FITNESS_RECOMMENDATION_FOOTER_CELL) as! FitnessRecFooterCellController
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 90
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
        let fitnessRecommendationRow = fitnessRecommendationRows[index]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.FITNESS_RECOMMENDATION_CELL) as! FitnessRecommendationCellViewController
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.cellHeader.text = fitnessRecommendationRow.title
        cell.cellHeaderAstricks.hidden = !fitnessRecommendationRow.includeDecoration
        cell.cellDescription.text = fitnessRecommendationRow.description
        
        return cell
    }

}