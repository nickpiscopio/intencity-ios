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
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var rightDivider: UIView!
    @IBOutlet weak var title: UILabel! 
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leftDivider: UIView!
    @IBOutlet weak var divider: UIView!
    
    private let ROW_HEIGHT: CGFloat = 18
    
    var sets = [Set]()
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        title.font = UIFont.boldSystemFontOfSize(Dimention.FONT_SIZE_NORMAL)
        title.textColor = Color.secondary_light
        
        divider.backgroundColor = Color.shadow
        
        leftDivider.backgroundColor = Color.shadow
        rightDivider.backgroundColor = Color.shadow
        
        view.backgroundColor = Color.page_background
    }
    
    func initializeTableView()
    {
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
    
    // http://stackoverflow.com/questions/31870206/how-to-insert-new-cell-into-uitableview-in-swift
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return sets.count
    }
    
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
//    {
//        if (exerciseListHeader == nil)
//        {
//            exerciseListHeader = tableView.dequeueReusableCellWithIdentifier(Constant.EXERCISE_LIST_HEADER) as! ExerciseListHeaderController
//            exerciseListHeader.routineName = exerciseData.routineName.uppercaseString
//            exerciseListHeader.navigationController = self.navigationController
//            exerciseListHeader.routineDelegate = self
//        }
//        
//        return exerciseListHeader.contentView
//    }
    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
//    {
//        return 65
//    }
    
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