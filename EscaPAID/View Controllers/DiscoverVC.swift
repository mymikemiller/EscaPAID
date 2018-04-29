//
//  DiscoverVC.swift
//  EscaPAID
//
//  Created by Michael Miller on 11/22/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit
import Hero


class DiscoverVC: UIViewController {
    
    // Store the selected card each time the user taps a card.
    var selectedCard: ExperienceCard?

    @IBOutlet weak var showFavoritesButton: UIButton!
    var isShowingFavorites = false
    
    
    @IBOutlet weak var experienceTableView: ExperienceTableView!
    
    @IBOutlet weak var cityPickerToolbar: UIToolbar!
    @IBOutlet weak var cityPicker: SelfContainedPickerView!
    @IBOutlet weak var selectACityLabel: UILabel!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // This is set to the selected experience when the user selects a row. This is used to prepare for the segue.
    var selectedExperience: Experience?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the city picker
        cityPicker.setUp(textField: nil, strings: Constants.cities)

        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["All"]
        searchController.searchBar.scopeButtonTitles?.append(contentsOf: Config.current.categories)
        searchController.searchBar.delegate = self
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Experiences"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Respond to the user changing their city by refreshing all items in the table
        NotificationCenter.default.addObserver(self,
                                       selector: #selector(DiscoverVC.cityChanged),
                                       name: .cityChanged,
                                       object: nil)
        
        // Show "No city selected" if applicable
        setCityPickerVisibility()
        
        // Prepare the experience table
        refreshDisplayType()
    }
    
    func refreshDisplayType() {
        var displayType = isShowingFavorites ?
            DisplayType.Favorites(FirebaseManager.user!) :
            DisplayType.City(FirebaseManager.user!.city)
        
        // This will cause the table to refresh
        experienceTableView.displayType = displayType
    }
    
    @IBAction func cityPickerDone_click(_ sender: Any) {
        FirebaseManager.user?.city = cityPicker.selectedString
        FirebaseManager.user?.update()
        setCityPickerVisibility()
        cityChanged()
    }
    
    func setCityPickerVisibility() {
        if (FirebaseManager.user?.city.isEmpty)! {
            experienceTableView.isHidden = true
            cityPicker.isHidden = false
            selectACityLabel.isHidden = false
            cityPickerToolbar.isHidden = false
        } else {
            experienceTableView.isHidden = false
            cityPicker.isHidden = true
            selectACityLabel.isHidden = true
            cityPickerToolbar.isHidden = true
        }
    }
    
    @objc func cityChanged() {
        experienceTableView.displayType = DisplayType.City((FirebaseManager.user?.city)!)
    }

    @IBAction func showFavoritesButton_click(_ sender: Any) {
        isShowingFavorites = !isShowingFavorites
        
        // Refresh the display type now that we've changed isShowingFavorites
        refreshDisplayType()
        
        // Change the button's image. Using a "highlighted" image doesn't work for bar button items, apparently.
        let image = isShowingFavorites ?
            UIImage(named: "ic_favorite")?.withRenderingMode(.alwaysTemplate) :
            UIImage(named: "ic_favorite_border")?.withRenderingMode(.alwaysTemplate)
        showFavoritesButton.tintColor = Config.current.mainColor
        showFavoritesButton.setImage(image, for: .normal)
    }
    
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        experienceTableView.setFilter(searchText, scope: scope)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showExperience" {
            (segue.destination as! ExperienceVC).experience = selectedCard?.experience
        }
    }
}

extension DiscoverVC: ExperienceTableViewDelegate {
    func didSelectCard(_ card: ExperienceCard) {
        // Unset the hero id for the previously selected card
        selectedCard?.hero.id = nil
        
        // Store the selected card and set its hero id
        selectedCard = card
        selectedCard?.hero.id = "hero_card"
        
        self.performSegue(withIdentifier: "showExperience", sender: self)
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
}

extension DiscoverVC: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

extension DiscoverVC: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}
