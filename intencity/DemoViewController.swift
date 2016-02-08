//
//  ViewController.swift
//  intencity
//
//  Created by Nick Piscopio on 2/8/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController, UIPageViewControllerDataSource {

    var pageViewController: UIPageViewController!
    var demoPages: [DemoView] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createNewDemoPage("app_name", description: "demo_description", imageName: "demo_intencity", backgroundColor: Color.primary)
        createNewDemoPage("demo_fitness_guru_title", description: "demo_fitness_guru_description", imageName: "demo_fitness_guru", backgroundColor: Color.secondary_light)
        createNewDemoPage("demo_fitness_direction_title", description: "demo_fitness_direction_description", imageName: "demo_intencity", backgroundColor: Color.secondary_dark)
        createNewDemoPage("demo_fitness_log_title", description: "demo_fitness_log_description", imageName: "demo_intencity", backgroundColor: Color.secondary_light)
        createNewDemoPage("demo_ranking_title", description: "demo_ranking_description", imageName: "demo_intencity", backgroundColor: Color.primary)
        createNewDemoPage("", description: "", imageName: "", backgroundColor: Color.white)
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        let startVC = self.viewControllerAtIndex(0)
        let viewControllers = NSArray(object: startVC)
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: true, completion: nil)
        
        self.pageViewController.view.frame = CGRectMake(0, 30, self.view.frame.width, self.view.frame.size.height - 60)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createNewDemoPage(title: String, description: String, imageName: String, backgroundColor: UIColor)
    {
        self.demoPages.append(DemoView(title: NSLocalizedString(title, comment: ""), description: NSLocalizedString(description, comment: ""), imageName: imageName, backgroundColor: backgroundColor))
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController
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
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            vc.pageIndex = index
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
    
    //MARK - PageViewController Datasource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        let vc = viewController as! PageViewController
        var index = vc.pageIndex as Int
        
        if (index == 0 || index == NSNotFound)
        {
            return nil
        }
        
        index--
        
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        let vc = viewController as! PageViewController
        var index = vc.pageIndex as Int
        
        if (index == NSNotFound)
        {
            return nil
        }
        
        index++
        
        if (index == self.demoPages.count)
        {
            return nil
//            let storyboard = UIStoryboard(name: "Login", bundle: nil)
//            
//            return storyboard.instantiateViewControllerWithIdentifier("LoginViewController")
        }
//        else if (index > pageTitleCount)
//        {
//            return nil
//        }
        
        return self.viewControllerAtIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return self.demoPages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return 0
    }
}

