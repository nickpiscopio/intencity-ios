//
//  DemoViewController.swift
//  Intencity
//
//  This is the controller for the demo screens.
//
//  Created by Nick Piscopio on 2/8/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class DemoViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var next: UIButton!
    
    var pageViewController: UIPageViewController!
    var demoPages: [DemoView] = []
    var currentIndex: Int = 0
    
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
        
        pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        setViewController(currentIndex)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        
        // Bring the common elements to the front.
        self.view.bringSubviewToFront(pageControl)
        self.view.bringSubviewToFront(next)
        
        // Sets the number of dots in the page control.
        self.pageControl.numberOfPages = demoPages.count
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /**
     * Adds all the demo screens to the page controller.
     *
     * @param title               The title for the demo screen.
     * @param description         The description for the demo screen.
     * @param imageName           The name of the image that will be displayed on the screen.
     *                     This can be found in the Assets.xcassets.
     * @param backgroundColor     The background color for the demo screen.
     */
    func createNewDemoPage(title: String, description: String, imageName: String, backgroundColor: UIColor)
    {
        self.demoPages.append(DemoView(title: NSLocalizedString(title, comment: ""), description: NSLocalizedString(description, comment: ""), imageName: imageName, backgroundColor: backgroundColor))
    }
    
    /**
     *  Displays the view controller at a specified index.
     *
     * @param index   The index of the view to show.
     *
     * @return The view controller to show.
    */
    func displayViewControllerAtIndex(index: Int) -> UIViewController
    {
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
            let storyboard : UIStoryboard = UIStoryboard(name: Constant.LOGIN_STORYBOARD, bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier(Constant.LOGIN_NAV_CONTROLLER) as! LoginNavController
            vc.backgroundColor = demoView.backgroundColor
            
            return vc
        }
        else
        {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("DemoContentViewController") as! DemoContentViewController
            vc.titleText = pageTitle
            vc.descriptionText = demoView.description
            vc.imageFile = demoView.imageName
            vc.pageIndex = index
            vc.backgroundColor = demoView.backgroundColor
            
            return vc;
        }
    }
    
    /**
     * The function that is called to create a view before the current view.
     */
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        var index = currentIndex
        
        if (index == 0 || index == NSNotFound)
        {
            return nil
        }
        
        index--
        
        return self.displayViewControllerAtIndex(index)
    }
    
    /**
     * The function that is called to create a view after the current view.
     */
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        var index = currentIndex

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
    
    /**
     * The function that is called after the transition is completed from a pageViewController control swipe.
     */
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {
        let viewControllers = pageViewController.viewControllers!
        
        do
        {
            currentIndex = try getCurrentIndex(viewControllers[viewControllers.count - 1])
        }
        catch
        {
            // If we can't determine the index, then we must be on the login screen.
            // The index for the login screen will be the last item in the list.
            currentIndex = demoPages.count - 1
        }
        
        updatePageControl()
    }
    
    @IBAction func nextClicked(sender: AnyObject)
    {
        setViewController(++currentIndex)
    }
    
    /**
     * Sets the view controller for the demo pages.
     *
     *  @param index    The index of the demo pages to show.
     */
    func setViewController(index: Int)
    {
        // Pushes a view onto the pageViewController and forward.
        pageViewController.setViewControllers([displayViewControllerAtIndex(index)], direction: .Forward, animated: true, completion: nil)
        
        updatePageControl()
    }
    
    /**
     * Updates the page control on the demo screen.
     */
    func updatePageControl()
    {
        if (currentIndex == demoPages.count - 1)
        {
            next.hidden = true
            pageControl.hidden = true
        }
        else
        {
            next.hidden = false
            pageControl.hidden = false
        }
        
        pageControl.currentPage = currentIndex
    }
    
    /**
     * Tries to get the current index.
     *
     * @returns     The view controller index.
     * @throws      A cast error if it cannot get the index.
     */
    func getCurrentIndex(viewController: UIViewController) throws -> Int
    {
        if let vc = viewController as? PageViewController
        {
            return vc.pageIndex
        }
        
        throw IntencityError.CastError
    }
}