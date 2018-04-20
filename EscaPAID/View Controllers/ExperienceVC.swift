//
//  ExperienceVC.swift
//  EscaPAID
//
//  Created by Michael Miller on 11/23/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class ExperienceVC: UIViewController, UIPageViewControllerDataSource {
    
    var experience:Experience?

    @IBOutlet weak var experienceTitle: UILabel!
    
    @IBOutlet weak var skillLevel: UILabel!
    @IBOutlet weak var curator: UIButton!
    
    @IBOutlet weak var experienceDescription: UILabel!
    
    @IBOutlet weak var curatorImage: UIImageView!
    @IBOutlet weak var curatorName: ThemedLabel!
    @IBOutlet weak var curatorAboutMe: ThemedLabel!
    
    @IBOutlet weak var pagerContainer: UIView!
    
    @IBOutlet weak var favoritesButton: UIButton!
    
    var isFavorite: Bool = false
    
    var imagePageViewController:UIPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let experience = experience {
            experienceTitle.text = experience.title
            skillLevel.text = experience.skillLevel + " Level"
            curator.setTitle("By: \(experience.curator.firstName)", for: .normal)
            
            let includesArray = experience.includes.split(separator: ",")
            var includesText = ""
            for str in includesArray {
                includesText += str.trimmingCharacters(in: .whitespacesAndNewlines) + "\n"
            }
            
            experienceDescription.text = experience.experienceDescription + "\n\n" +
            "INCLUDES: \n" + includesText + "\n\n" +
            String(format: "PRICE: $%.02f", experience.price)
            
            if let profileImageURL = URL(string: experience.curator.profileImageUrl) {
                curatorImage.af_setImage(withURL: profileImageURL)
            }
            
            curatorName.text = experience.curator.fullName
            curatorAboutMe.text = experience.curator.aboutMe
           
            
            setFavoritesText()
        }
        
        imagePageViewController?.dataSource = self
        
        let startingViewController:ExperienceImageVC = viewControllerAtIndex(index: 0)!
        let viewControllers = [startingViewController]
        imagePageViewController?.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
    }
    
    private func setFavoritesText() {
        if let experience = experience {
            
            ExperienceManager.onIsFavoriteChanged(experience: experience, completion: { (isFavorite) in
                self.isFavorite = isFavorite
                
                if self.isFavorite {
                    self.favoritesButton.setTitle("Remove from Favorites", for: .normal)
                } else {
                    self.favoritesButton.setTitle("Add to Favorites", for: .normal)
                }
            })
        }
    }
    
    @IBAction func favoritesButton_click(_ sender: Any) {
        if (isFavorite) {
            ExperienceManager.unFavorite(experience: experience!)
        } else {
            ExperienceManager.favorite(experience: experience!)
        }
    }
    
    @IBAction func curatorView_click(_ sender: Any) {
        performSegue(withIdentifier: "showProfile", sender: self)
    }
    
    
    
    @IBAction func messageButton_click(_ sender: Any) {
        
        guard self.experience?.curator == FirebaseManager.user else {
            present(UIAlertController(message: "You cannot send a message to yourself."), animated: true)
            return
        }
        
        let data = ["user" : (self.experience?.curator)!]
        
        // Send a broadcast notification to let the inbox know which thread to show
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ThreadsNavigationController.SHOW_THREAD_POST), object: data)
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
        experienceImageVC.imageURL = (experience?.imageUrls[index])!
        
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "pageViewController_embed") {
            // Handle embedding the experience images
            imagePageViewController = segue.destination as! UIPageViewController
        } else if (segue.identifier == "showReservationVC") {
            (segue.destination as! ReservationVC).experience = experience
        } else if (segue.identifier == "showProfile") {
            (segue.destination as! ProfileVC).user = experience!.curator
        }
    }
    

}
