//
//  ExperienceCollectionView.swift
//  EscaPAID
//
//  Created by Michael Miller on 5/4/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

@objc protocol ExperienceCollectionViewDelegate: class {
    @objc func didSelectCard(_ card: ExperienceCard)
    @objc optional func newExperienceAdded(total: Int)
}

class ExperienceCollectionView: UICollectionView {
    
    enum DisplayType {
        case Curator(User)
    }
    
    @IBOutlet weak var experienceDelegate: ExperienceCollectionViewDelegate?
    
    // The manager that fetches experiences from the database
    var experienceManager = ExperienceManager()
    
    var displayType: DisplayType? {
        didSet {
            refresh()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // We are our own delegate for the tableview. Users of this control most often can only set experienceDelegate and not interact with the underlying tableview delegates
        self.delegate = self
        self.dataSource = self
        
        // Prepare the cell display
        let nib = UINib(nibName: "ExperienceCardCollectionViewCell",bundle: nil)
        register(nib, forCellWithReuseIdentifier: "experienceCardCollectionViewCell")
//        layoutMargins = UIEdgeInsetsMake(0, 16, 0, 16)
//        rowHeight = contentSize.width
        
    }
    
    func refresh() {
        guard (displayType != nil) else {
            fatalError("ExperienceCollectionView must have its displayType set.")
        }

        // Empty the experiences first
        experienceManager.clear()
        
        // Fill the experience manager with experiences to display
        switch displayType! {
        case .Curator(let curator):
            experienceManager.fillExperiences(forCurator: curator) {
                
                self.newExperienceAdded()
            }
        }
    }
    
    func newExperienceAdded() {
        experienceDelegate?.newExperienceAdded?(total: experienceManager.experiences.count)
        
        // mikem: This is way too big a hammer. This happens every time a new Experience is added to the database. Ideally we would only refresh that one item.
        self.reloadData()
    }
}

extension ExperienceCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return experienceManager.experiences.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "experienceCardCollectionViewCell", for: indexPath) as! ExperienceCardCollectionViewCell
        
        let experience = experienceManager.experiences[indexPath.row]
        cell.card.experience = experience
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ExperienceCardCollectionViewCell
        experienceDelegate?.didSelectCard(cell.card)
    }
    
}
