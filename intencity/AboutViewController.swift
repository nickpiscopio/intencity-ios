//
//  AboutViewController.swift
//  Intencity
//
//  The view controller for the about screen.
//
//  Created by Nick Piscopio on 2/23/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class AboutViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var versionTitle: UILabel!
    @IBOutlet weak var versionDescription: UILabel!
    
    var sections = [AboutSection]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Hides the tab bar.
        self.tabBarController?.tabBar.isHidden = true
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("title_about", comment: "")
        
        versionTitle.textColor = Color.secondary_light
        versionDescription.textColor = Color.secondary_light
        
        versionTitle.text = NSLocalizedString("title_version", comment: "")
        versionDescription.text = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        
        #if DEBUG
            versionDescription.text = versionDescription.text! + " " + Constant.DEBUG
        #endif
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: 0, emptyTableStringRes: "")
        tableView.backgroundColor = Color.transparent
        
        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.ABOUT_CELL, cellName: Constant.ABOUT_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.DESCRIPTION_FOOTER_CELL, cellName: Constant.DESCRIPTION_FOOTER_CELL)
        
        sections.append(AboutSection(header: NSLocalizedString("title_mission", comment: ""), description: NSLocalizedString("mission", comment: "")))
        sections.append(AboutSection(header: NSLocalizedString("title_founders", comment: ""), description: NSLocalizedString("founders", comment: "")))
        sections.append(AboutSection(header: NSLocalizedString("title_contributors", comment: ""), description: NSLocalizedString("contributors", comment: "")))
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Return the number of rows in the section.
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        if (section == sections.count - 1)
        {
            let footer = tableView.dequeueReusableCell(withIdentifier: Constant.DESCRIPTION_FOOTER_CELL) as! DescriptionFooterCellController
            footer.title.text = NSLocalizedString("copyright", comment: "")
            footer.separator.isHidden = true
            
            return footer
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return section == sections.count - 1 ? 35 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        // Gets the section from the index.
        // Gets the row in the section.
        let section = sections[(indexPath as NSIndexPath).section]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.ABOUT_CELL) as! AboutCellController
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.cellHeader.text = section.header
        cell.cellDescription.text = section.description
        
        return cell
    }
}
