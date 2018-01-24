//
//  ExperienceVC.swift
//  tellomee
//
//  Created by Michael Miller on 11/23/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class ExperienceVC: UIViewController, UIPageViewControllerDataSource {
    
    var experience:Experience?

    @IBOutlet weak var experienceTitle: UILabel!
    
    @IBOutlet weak var category: UILabel!
    
    @IBOutlet weak var curator: UILabel!
    
    @IBOutlet weak var info: UITextView!
    
    @IBOutlet weak var pagerContainer: UIView!
    
    
    var imagePageViewController:UIPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let experience = experience {
            experienceTitle.text = experience.title
            category.text = experience.category
            curator.text = "By: \(experience.curator.displayName)"
            
            let includesArray = experience.includes.split(separator: ",")
            var includesText = ""
            for str in includesArray {
                includesText += str.trimmingCharacters(in: .whitespacesAndNewlines) + "\n"
            }
            
            info.text = experience.description + "\n\n" +
            "INCLUDES: \n" + includesText + "\n\n" +
            "ABOUT ME: " + experience.curator.aboutMe + "\n\n" +
            String(format: "PRICE: $%.02f", experience.price)
        }
        
        imagePageViewController?.dataSource = self
        
        let startingViewController:ExperienceImageVC = viewControllerAtIndex(index: 0)!
        let viewControllers = [startingViewController]
        imagePageViewController?.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func messageButton_click(_ sender: Any) {
        
        if (FirebaseManager.user?.uid == self.experience?.curator.uid) {
            let alertVC = UIAlertController(title: "Error", message: "You can't send a message to yourself.", preferredStyle: .alert)
            let alertActionOkay = UIAlertAction(title: "Okay", style: .default)
            alertVC.addAction(alertActionOkay)
            self.present(alertVC, animated: true, completion: nil)
            
            return
        }
        
        ThreadManager.getOrCreateThread(between: FirebaseManager.user!, and: (self.experience?.curator)!, completion: {thread in
            
            let threadsNavigationController: ThreadsNavigationController = self.tabBarController?.viewControllers![2] as! ThreadsNavigationController
            threadsNavigationController.threadToShowOnLoad = thread
            self.tabBarController?.selectedViewController = threadsNavigationController
        })
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! ExperienceImageVC).pageIndex
        if (index == 0) { return nil }
        index -= 1
        return viewControllerAtIndex(index: index)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! ExperienceImageVC).pageIndex
        index += 1
        if (index == experience?.imageUrls.count) {
            return nil
        }
        return viewControllerAtIndex(index: index)
    }
    
    func viewControllerAtIndex(index: Int) -> ExperienceImageVC? {
        if ((experience?.imageUrls.count == 0) || index >= (experience?.imageUrls.count)!) {
            return nil
        }
        
        let experienceImageVC: ExperienceImageVC = self.storyboard?.instantiateViewController(withIdentifier: "ExperienceImageVC") as! ExperienceImageVC
        experienceImageVC.pageIndex = index
        experienceImageVC.imageUrl = (experience?.imageUrls[index])!
        
        return experienceImageVC;
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return (experience?.imageUrls.count)!
    }
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        // Start at index 0
        return 0
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "pageViewController_embed") {
            imagePageViewController = segue.destination as! UIPageViewController
        }
    }
    

}
