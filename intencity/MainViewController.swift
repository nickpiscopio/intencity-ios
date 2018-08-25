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
        
        _ = NotificationHandler.getInstance(self)
        
        setMenuButton(Constant.MENU_INITIALIZED)
        
        onLoadView(View.ROUTINE_VIEW, result: "", savedExercises: nil, state: RoutineState.NONE)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        // Shows the tab bar again.
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func onLoadView(_ view: Int, result: String, savedExercises: SavedExercise?, state: Int)
    {
        switch view
        {
            case View.ROUTINE_VIEW:
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: Constant.ROUTINE_VIEW_CONTROLLER) as! RoutineViewController
                vc.viewDelegate = self
                
                loadView(vc)
                
                break;
            
            case View.FITNESS_LOG_VIEW:
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: Constant.FITNESS_LOG_VIEW_CONTROLLER) as! FitnessLogViewController
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
    func loadView(_ vc: UIViewController)
    {
        self.addChildViewController(vc)
        vc.view.frame = CGRect(x: 0, y: 0, width: self.container.frame.size.width, height: self.container.frame.size.height);
        self.container.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
    }
    
    /**
     * Sets the menu button.
     *
     * @param type  The button type to set.
     */
    func setMenuButton(_ type: Int)
    {
        var icon: UIImage!
        
//        switch(type)
//        {
//            case Constant.MENU_INITIALIZED:
//                icon = UIImage(named: Constant.MENU_INITIALIZED_IMAGE)!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
//                break
//            case Constant.MENU_NOTIFICATION_FOUND:
//                let duration = 0.5
//            
//                Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(MainViewController.stopAnimation), userInfo: nil, repeats: false)
//            
//                icon = UIImage.animatedImageNamed(Constant.MENU_NOTIFICATION_FOUND_IMAGE, duration: duration)!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
//            
//                break
//            case Constant.MENU_NOTIFICATION_PRESENT:
//                icon = UIImage(named: Constant.MENU_NOTIFICATION_PRESENT_IMAGE)!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
//                break
//            default:
//                break
//        }
        
        icon = UIImage(named: Constant.MENU_INITIALIZED_IMAGE)!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        let iconSize = CGRect(origin: CGPoint.zero, size: CGSize(width: Constant.MENU_IMAGE_WIDTH, height: Constant.MENU_IMAGE_HEIGHT))
        
        let iconButton = UIButton(frame: iconSize)
        iconButton.setImage(icon, for: UIControlState())
        iconButton.addTarget(self, action: #selector(MainViewController.menuClicked), for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItem?.customView = iconButton
    }
    
    /**
     * Opens the menu.
     */
    @objc func menuClicked()
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: Constant.MENU_VIEW_CONTROLLER) as! MenuViewController
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    /**
     * Sets the menu button animation.
     */
    @objc func stopAnimation()
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
