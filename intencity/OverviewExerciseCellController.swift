//
//  OverviewExerciseCellController
//  Intencity
//
//  The controller for the overview exercise cell.
//
//  Created by Nick Piscopio on 6/18/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class OverviewExerciseCellController: UITableViewCell, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var outline: UIView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var title: UILabel! 
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    
    private let ROW_HEIGHT: CGFloat = 18
    
    var sets = [Set]()
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        title.font = UIFont.boldSystemFontOfSize(Dimention.FONT_SIZE_NORMAL)
        title.textColor = Color.secondary_light
        
        content.backgroundColor = Color.page_background
        outline.backgroundColor = Color.shadow
    }
    
    /**
     * Initializes the tableview.
     */
    func initializeTableView()
    {
        let set = sets[sets.count - 1]
        let reps = set.reps
        let duration = set.duration
        
        if (reps > 0 || Util.convertToInt(duration) > 0)
        {
            stackView.spacing = Dimention.LAYOUT_MARGIN_HALF
            tableView.hidden = false
            tableView.delegate = self
            tableView.dataSource = self
            tableView.scrollEnabled = false
            
            // Initialize the tableview.
            Util.initTableView(tableView, footerHeight: 0, emptyTableStringRes: "")
            
            // Load the cells we are going to use in the tableview.
            Util.addUITableViewCell(tableView, nibNamed: Constant.OVERVIEW_SET_CELL, cellName: Constant.OVERVIEW_SET_CELL)
            
            let tableViewSize = ROW_HEIGHT * CGFloat(sets.count)
            tableView.heightAnchor.constraintEqualToConstant(tableViewSize).active = true

        }
        else
        {
            stackView.spacing = 0
            tableView.hidden = true
        }
    }
    
    // http://stackoverflow.com/questions/31870206/how-to-insert-new-cell-into-uitableview-in-swift
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return sets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.item

        let set = sets[index]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.OVERVIEW_SET_CELL) as! OverviewSetCellController
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.setEditText(set)
        
        return cell
    }

}