//
//  DemoViewController.swift
//  Intencity
//
//  This is the controller for the demo screens.
//
//  Created by Nick Piscopio on 2/8/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class DemoViewController: UIViewController, UIPageViewControllerDataSource
{
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var next: UIButton!
    
    var pageViewController: UIPageViewController!
    var demoPages: [DemoView] = []
    
    var viewControllers: NSArray = []
    
    var index: Int = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Adds all the demo screens to the page controller.
        createNewDemoPage("app_name", description: "demo_description", imageName: "demo_intencity", backgroundColor: Color.primary)
        createNewDemoPage("demo_fitness_guru_title", description: "demo_fitness_guru_description", imageName: "demo_fitness_guru", backgroundColor: Color.secondary_light)
        createNewDemoPage("demo_fitness_direction_title", description: "demo_fitness_direction_description", imageName: "demo_intencity", backgroundColor: Color.secondary_dark)
        createNewDemoPage("demo_fitness_log_title", description: "demo_fitness_log_description", imageName: "demo_intencity", backgroundColor: Color.secondary_light)
        createNewDemoPage("demo_ranking_title", description: "demo_ranking_description", imageName: "demo_intencity", backgroundColor: Color.primary)
        createNewDemoPage("", description: "", imageName: "", backgroundColor: Color.page_background)
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        let startVC = self.displayViewControllerAtIndex(index)
        viewControllers = NSArray(object: startVC)
        
        setViewController()
        
        // 37 is apparently the height of the page indicator.
//        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.size.height + 37)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        
        // Bring the common elements to the front.
        self.view.bringSubviewToFront(pageControl)
        self.view.bringSubviewToFront(next)
        
        // Sets the number of dots in the page control.
        self.pageControl.numberOfPages = demoPages.count;
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /*
        Adds all the demo screens to the page controller.
    
        title               The title for the demo screen.
        description         The description for the demo screen.
        imageName           The name of the image that will be displayed on the screen.
                            This can be found in the Assets.xcassets.
        backgroundColor     The background color for the demo screen.
    */
    func createNewDemoPage(title: String, description: String, imageName: String, backgroundColor: UIColor)
    {
        self.demoPages.append(DemoView(title: NSLocalizedString(title, comment: ""), description: NSLocalizedString(description, comment: ""), imageName: imageName, backgroundColor: backgroundColor))
    }
    
    /*
        Displays the view controller at a specified index.
        
        index   The index of the view to show.
    
        return  The view controller to show.
    */
    func displayViewControllerAtIndex(index: Int) -> UIViewController
    {
        self.index = index
        
        let pageCount = self.demoPages.count
        let demoView = self.demoPages[index]
        let pageTitle = demoView.title
        
        if (pageCount == 0)
        {
            return DemoContentViewController()
        }
        else if (index >= pageCount)
        {
            return LoginViewController()
        }
        
        if (pageTitle == "")
        {
            pageControl.hidden = true
//            next.hidden = true
            let storyboard : UIStoryboard = UIStoryboard(name: Constant.LOGIN_STORYBOARD, bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier(Constant.LOGIN_NAV_CONTROLLER) as! LoginNavController
            vc.backgroundColor = demoView.backgroundColor
            
            return vc
        }
        else
        {
            pageControl.hidden = false
//            next.hidden = false
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("DemoContentViewController") as! DemoContentViewController
            vc.titleText = pageTitle
            vc.descriptionText = demoView.description
            vc.imageFile = demoView.imageName
            vc.pageIndex = index
            vc.backgroundColor = demoView.backgroundColor
            
            return vc;
        }
    }
    
    /*
        The function that is called to create a view before the current view.
    */
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        let vc = viewController as! PageViewController
        var index = vc.pageIndex as Int
        self.pageControl.currentPage = index
        
        if (index == 0 || index == NSNotFound)
        {
            return nil
        }
        
        index--
        
        return self.displayViewControllerAtIndex(index)
    }
    
    /*
        The function that is called to create a view after the current view.
    */
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        var index: Int
        do
        {
            index = try getCurrentIndex(viewController)
            
            self.pageControl.currentPage = index
        }
        catch
        {
            // If we can't determine the index, then we must be on the login screen.
            // The index for the login screen will be the last item in the list.
            index = demoPages.count - 1
        }
    
        
        if (index == NSNotFound)
        {
            return nil
        }
        
        index++
        
        if (index == self.demoPages.count)
        {
            return nil
        }
        
        return self.displayViewControllerAtIndex(index)
    }
    
    @IBAction func nextClicked(sender: AnyObject)
    {
        setViewController()
    }
    
    func setViewController()
    {
        let startVC : NSArray = viewControllers
        
        self.pageViewController.setViewControllers(startVC as? [UIViewController], direction: .Forward, animated: true, completion: nil)
    }
    
    /*
        Tries to get the current index.
    
        returns     The view controller index.
        throws      A cast error if it cannot get the index.
    */
    func getCurrentIndex(viewController: UIViewController) throws -> Int
    {
        if let vc = viewController as? PageViewController
        {
            return vc.pageIndex
        }
        
        throw IntencityError.CastError
    }

    
//    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
//    {
//        return self.demoPages.count
//    }
//    
//    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
//    {
//        return 0
//    }
}

