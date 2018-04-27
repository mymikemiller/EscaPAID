//
//  ReviewsTableView.swift
//  EscaPAID
//
//  Created by Michael Miller on 4/26/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class ReviewTableView: UITableView {

    // The manager that fetches reviews from the database
    var reviewManager = ReviewManager()
    
    var experience: Experience!
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Prepare the cell display
        let nib = UINib(nibName: "ReviewCell",bundle: nil)
        register(nib, forCellReuseIdentifier: "reviewCell")
        layoutMargins = UIEdgeInsetsMake(0, 16, 0, 16)
        
        // Fill the reviews
        reviewManager.fillReviews(experienceId: experience.id) { (_) in
            self.newReviewAdded()
        }
    }
    
    func newReviewAdded() {
        // mikem: This is way too big a hammer. This happens every time a new Review is added to the database for this experience. Ideally we would only refresh that one item.
        self.reloadData()
    }
}


extension ReviewTableView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewManager.reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewCell
        
        let review: Review = reviewManager.reviews[indexPath.row]
        cell.review = review
        
        return cell
    }
}
