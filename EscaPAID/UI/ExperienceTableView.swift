//
//  ExperienceTableView.swift
//  EscaPAID
//
//  Shows a list of ExperienceCards from the given city, curator, or which are favorites of a given user
//
//  Created by Michael Miller on 4/23/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

enum DisplayType {
    case Curator(User)
    case City(String)
    case Favorites(User)
}

@objc protocol ExperienceTableViewDelegate: class {
    @objc func didSelectCard(_ card: ExperienceCard)
    @objc func isFiltering() -> Bool
}

class ExperienceTableView: UITableView {
    // The delegate that receives events such as when the user taps on a card
    @IBOutlet weak var experienceDelegate: ExperienceTableViewDelegate?

    // The manager that fetches experiences from the database
    var experienceManager = ExperienceManager()
    
    // When the experienceDelegate returns true for isFiltering, we'll display this filtered list instead of experienceManager's list.
    var filteredExperiences = [Experience]()
    
    var displayType: DisplayType? {
        didSet {
            refresh()
        }
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // We are our own delegate for the tableview. Users of this control most often can only set experienceDelegate and not interact with the underlying tableview delegates
        self.delegate = self
        self.dataSource = self
        
        // Prepare the cell display
        let nib = UINib(nibName: "ExperienceCardCell",bundle: nil)
        register(nib, forCellReuseIdentifier: "experienceCardCell")
        layoutMargins = UIEdgeInsetsMake(0, 37, 0, 37)
        rowHeight = contentSize.width / CGFloat(Constants.cardRatio)
    }
    
    func refresh() {
        guard (displayType != nil) else {
            fatalError("ExperienceTableView must have its displayType set.")
        }
        
        // Empty the experiences first
        experienceManager.clear()
        
        // Fill the experience manager with experiences to display
        switch displayType! {
        case .Curator(let curator):
            print("Curator name is: \(curator.fullName).")
            experienceManager.fillExperiences(forCurator: curator) {
                
                self.newExperienceAdded()
            }
        case .City(let city):
            print("City is: \(city)")
            experienceManager.fillExperiences(forCity: city) {
                
                self.newExperienceAdded()
            }
        case .Favorites(let user):
            print("Favorites of: \(user.fullName)")
            experienceManager.fillExperiences(forFavoritesOf: user) {
                
                self.newExperienceAdded()
            }
        }
    }
    
    func newExperienceAdded() {
        // mikem: This is way too big a hammer. This happens every time a new Experience is added to the database. Ideally we would only refresh that one item.
        self.reloadData()
    }
    
    // Sets the filter to use when filtering. This only has an effect when the experienceDelegate returns true for isFiltering
    func setFilter(_ searchText: String, scope: String = "All") {
        filteredExperiences = experienceManager.experiences.filter({( experience : Experience) -> Bool in
            let doesCategoryMatch = (scope == "All") || (experience.category == scope)
            
            if searchText.isEmpty {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && experience.title.lowercased().contains(searchText.lowercased())
            }
        })
        
        self.reloadData()
    }
}

extension ExperienceTableView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (experienceDelegate == nil || !experienceDelegate!.isFiltering()) {
            return experienceManager.experiences.count
        } else {
            return filteredExperiences.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "experienceCardCell", for: indexPath) as! ExperienceCardCell
        
        let experience: Experience
        if (experienceDelegate == nil || !experienceDelegate!.isFiltering()) {
            
            experience = experienceManager.experiences[indexPath.row]
        } else {
            experience = filteredExperiences[indexPath.row]
        }
        cell.card.experience = experience
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! ExperienceCardCell
        
        experienceDelegate?.didSelectCard(cell.card)
    }
}
