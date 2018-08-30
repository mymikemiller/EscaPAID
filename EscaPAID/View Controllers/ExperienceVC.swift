//
//  ExperienceVC.swift
//  EscaPAID
//
//  Created by Michael Miller on 11/23/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit
import ImageSlideshow

class ExperienceVC: UIViewController, UIPageViewControllerDataSource {
    
    var experience:Experience!
    
    var reviewManager: ReviewManager = ReviewManager()

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var imageSlideshow: ImageSlideshow!
    
    @IBOutlet weak var experienceTitle: UILabel!
    @IBOutlet weak var skillLevel: UILabel!
    
    @IBOutlet weak var experienceDescription: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var includes: UILabel!
    
    @IBOutlet weak var curatorImage: UIImageView!
    @IBOutlet weak var curatorName: ThemedLabel!
    @IBOutlet weak var curatorAboutMe: ThemedLabel!
    
    @IBOutlet weak var reviewsLabel: ThemedLabel!
    
    @IBOutlet weak var favoritesButton: UIButton!
    
    var isFavorite: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        guard experience != nil else {
            // This page must have an experience set
            return
        }
        
        // Register the cell for reviews
        tableView.register(UINib(nibName: "ReviewCell", bundle: Bundle.main), forCellReuseIdentifier: "reviewCell")
        
        // Set up the tableView to auto-fit reviews
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140 // arbitrary value
       
        // Fetch the reviews
        reviewManager.fillReviews(experience: experience) {
            // Update the review label now that we know how many reviews there are
            self.reviewsLabel.text = "\(self.reviewManager.reviews.count) Review\(self.reviewManager.reviews.count == 1 ? "" : "s")"
            
            // Heavy hammer. Reload the entire table for every new review.
            self.tableView.reloadData()
        }

        // Tint the favorite button's image.
        favoritesButton.setImage(UIImage(named: "ic_favorite_border")?.withRenderingMode(.alwaysTemplate), for: .normal)
        favoritesButton.setImage(UIImage(named: "ic_favorite")?.withRenderingMode(.alwaysTemplate), for: .highlighted)
        favoritesButton.tintColor = Config.current.mainColor
        
        // Set the size of the imageView container. We can't use an aspect ratio constraint because systemLayoutSizeFitting (which we use to compress the empty space out of the header) doesn't play nice with that, so we calculate the height ourselves
        let imageHeight = imageSlideshow.bounds.size.width
         / CGFloat(Constants.experienceImageRatio)
        imageSlideshow.addConstraint(NSLayoutConstraint(item: imageSlideshow, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: imageHeight))
        
        // Set the images for the slideshow
        imageSlideshow.setImageInputs(experience.imageUrls.map { (urlString) -> AlamofireSource in
            return AlamofireSource(urlString: urlString)!;
        })
        
        // Configure slideshow
        imageSlideshow.slideshowInterval = 3
        imageSlideshow.zoomEnabled = true
        imageSlideshow.pageIndicator = getImagePageIndicator();
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ExperienceVC.didTapSlideshow))
        imageSlideshow.addGestureRecognizer(gestureRecognizer)
        
        
        experienceTitle.text = experience.title
        skillLevel.text = experience.skillLevel + " Level"
        
        experienceDescription.text = experience.experienceDescription
        price.text = String(format: "$%.02f", Double(experience.price) / 100.0)
        includes.text = experience.includes
        
        if let profileImageURL = URL(string: experience.curator.profileImageUrl) {
            curatorImage.af_setImage(withURL: profileImageURL)
        }
        
        curatorName.text = experience.curator.fullName
        curatorAboutMe.text = experience.curator.aboutMe
       
        setFavoritesButtonState()
        
    }
    
    func getImagePageIndicator() -> UIPageControl {
        let indicator = UIPageControl()
        indicator.currentPageIndicatorTintColor = UIColor.white
        indicator.numberOfPages = imageSlideshow.images.count
        indicator.backgroundColor = UIColor.clear
        indicator.pageIndicatorTintColor = UIColor.lightGray
        return indicator;
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // The following is necessary to get the header of the tableview (all the content of the page besides the reviews) to shrink to fit the content snugly. See https://useyourloaf.com/blog/variable-height-table-view-header/
        guard let headerView = tableView.tableHeaderView else {
            return
        }
        
        let size = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        // Avoid a layout loop by only resizing if necessary
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
            tableView.layoutIfNeeded()
        }
    }
    
    @objc private func didTapSlideshow() {
        
        let fullScreenController = imageSlideshow.presentFullScreenController(from: self)
        
        // Customize the pagerIndicator
        fullScreenController.slideshow.pageIndicator = getImagePageIndicator();
    }
    
    private func setFavoritesButtonState() {
        if let experience = experience {
            ExperienceManager.onIsFavoriteChanged(experience: experience, completion: { (isFavorite) in
                self.isFavorite = isFavorite
                
                if self.isFavorite {
                    self.favoritesButton.isHighlighted = true
                } else {
                    self.favoritesButton.isHighlighted = false
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
        
        guard self.experience.curator.uid != FirebaseManager.user!.uid else {
            present(UIAlertController(message: "You cannot send a message to yourself."), animated: true)
            return
        }
        
        let data = ["user" : self.experience.curator]
        
        // Send a broadcast notification to let the inbox know which thread to show
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ThreadsNavigationController.SHOW_THREAD_POST), object: data)
    }
    
    
    @IBAction func reserveButton_click(_ sender: Any) {
        guard self.experience.isActive() else {
            let alertVC = UIAlertController(title: "Unavailable", message: "Sorry, this \(Config.current.experienceText.lowercased()) has no availability. Try messaging the \(Config.current.curatorText.lowercased()).", preferredStyle: .alert)
            let alertActionOkay = UIAlertAction(title: "Okay", style: .default)
            alertVC.addAction(alertActionOkay)
            self.present(alertVC, animated: true, completion: nil)
            return
        }
        
        performSegue(withIdentifier: "showReservationVC", sender: self)
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
        if (index == experience.imageUrls.count) {
            return nil
        }
        return viewControllerAtIndex(index: index)
    }
    
    func viewControllerAtIndex(index: Int) -> ExperienceImageVC? {
        if ((experience.imageUrls.count == 0) || index >= (experience.imageUrls.count)) {
            return nil
        }
        
        let experienceImageVC: ExperienceImageVC = self.storyboard?.instantiateViewController(withIdentifier: "ExperienceImageVC") as! ExperienceImageVC
        experienceImageVC.pageIndex = index
        experienceImageVC.imageURL = experience.imageUrls[index]
        
        return experienceImageVC;
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return experience.imageUrls.count
    }
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        // Start at index 0
        return 0
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showReservationVC") {
            (segue.destination as! ReservationVC).experience = experience
        } else if (segue.identifier == "showProfile") {
            (segue.destination as! ProfileVC).user = experience!.curator
        } else if (segue.identifier == "showWriteReview") {
            (segue.destination as! WriteReviewVC).experience = experience
        }
    }
}

// Handle reviews
extension ExperienceVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewManager.reviews.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the reviews in reverse order so the newest review is first
        let review = reviewManager.reviews.reversed()[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewCell
        cell.configure(with: review)
        
        // No need to show the experience name
        cell.hideExperienceTitle()
        
        return cell
    }
}


