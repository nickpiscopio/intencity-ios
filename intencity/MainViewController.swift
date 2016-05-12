//
//  MainViewController.swift
//  Intencity
//
//  The view controller for the insitial view.
//
//  Created by Nick Piscopio on 4/21/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class MainViewController: UIViewController, ViewDelegate, NotificationDelegate
{
    @IBOutlet weak var container: UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("app_name", comment: "")
        
        NotificationHandler.getInstance(self)
        
        setMenuButton(Constant.MENU_INITIALIZED)
        
        onLoadView(View.ROUTINE_VIEW, result: "", savedExercises: nil, state: RoutineState.NONE)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        // Shows the tab bar again.
        self.tabBarController?.tabBar.hidden = false
    }
    
    func onLoadView(view: Int, result: String, savedExercises: SavedExercise?, state: Int)
    {
        switch view
        {
            case View.ROUTINE_VIEW:
                
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier(Constant.ROUTINE_VIEW_CONTROLLER) as! RoutineViewController
                vc.viewDelegate = self
                
                loadView(vc)
                
                break;
            
            case View.FITNESS_LOG_VIEW:
                
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier(Constant.FITNESS_LOG_VIEW_CONTROLLER) as! FitnessLogViewController
                vc.viewDelegate = self
                vc.result = result
                vc.savedExercises = savedExercises
                vc.routineState = state
                
                loadView(vc)
                
                break;
            
        default:
            break;
        }
    }
    
    /**
     * Loads the child view.
     */
    func loadView(vc: UIViewController)
    {
        self.addChildViewController(vc)
        vc.view.frame = CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height);
        self.container.addSubview(vc.view)
        vc.didMoveToParentViewController(self)
    }
    
    /**
     * Sets the menu button.
     *
     * @param type  The button type to set.
     */
    func setMenuButton(type: Int)
    {
        var icon: UIImage!
        
        switch(type)
        {
            case Constant.MENU_INITIALIZED:
                icon = UIImage(named: Constant.MENU_INITIALIZED_IMAGE)!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                break
            case Constant.MENU_NOTIFICATION_FOUND:
            
                let duration = 0.5
            
                NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: #selector(MainViewController.stopAnimation), userInfo: nil, repeats: false)
            
                icon = UIImage.animatedImageNamed(Constant.MENU_NOTIFICATION_FOUND_IMAGE, duration: duration)!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            
                break
            case Constant.MENU_NOTIFICATION_PRESENT:
                icon = UIImage(named: Constant.MENU_NOTIFICATION_PRESENT_IMAGE)!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                break
            default:
                break
        }
        
        let iconSize = CGRect(origin: CGPointZero, size: CGSizeMake(Constant.MENU_IMAGE_WIDTH, Constant.MENU_IMAGE_HEIGHT))
        
        let iconButton = UIButton(frame: iconSize)
        iconButton.setImage(icon, forState: .Normal)
        iconButton.addTarget(self, action: #selector(MainViewController.menuClicked), forControlEvents: .TouchUpInside)
        
        self.navigationItem.rightBarButtonItem?.customView = iconButton
    }
    
    /**
     * Opens the menu.
     */
    func menuClicked()
    {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier(Constant.MENU_VIEW_CONTROLLER) as! MenuViewController
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    /**
     * Sets the menu button animation.
     */
    func stopAnimation()
    {
        setMenuButton(Constant.MENU_NOTIFICATION_PRESENT)
    }
    
    func onNotificationAdded()
    {
        setMenuButton(Constant.MENU_NOTIFICATION_FOUND)
    }
    
    func onNotificationsViewed()
    {
        setMenuButton(Constant.MENU_INITIALIZED)
    }
}