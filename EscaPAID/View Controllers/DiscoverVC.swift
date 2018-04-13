//
//  ExperiencesTableViewController.swift
//  EscaPAID
//
//  Created by Michael Miller on 11/22/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class DiscoverVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let experienceManager = ExperienceManager()

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var cityPickerToolbar: UIToolbar!
    @IBOutlet weak var cityPicker: SelfContainedPickerView!
    @IBOutlet weak var selectACityLabel: UILabel!
    
    var filteredExperiences = [Experience]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // This is set to the selected experience when the user selects a row. This is used to prepare for the segue.
    var selectedExperience: Experience?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the city picker
        cityPicker.setUp(textField: nil, strings: Constants.cities)
        
        // Set up the TableView
        let nib = UINib(nibName: "ExperienceTableViewCell",bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "experienceCell")
        tableView.layoutMargins = UIEdgeInsetsMake(0, 37, 0, 37)

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
                                       selector: #selector(DiscoverVC.refreshTable),
                                       name: .cityChanged,
                                       object: nil)
        
        // Show "No city selected" if applicable
        setCityPickerVisibility()
        
        // Refresh the table once we're done loading
        refreshTable()
    }
    
    @IBAction func cityPickerDone_click(_ sender: Any) {
        FirebaseManager.user?.city = cityPicker.selectedString
        FirebaseManager.user?.update()
        setCityPickerVisibility()
        refreshTable()
    }
    
    func setCityPickerVisibility() {
        if (FirebaseManager.user?.city.isEmpty)! {
            tableView.isHidden = true
            cityPicker.isHidden = false
            selectACityLabel.isHidden = false
            cityPickerToolbar.isHidden = false
        } else {
            tableView.isHidden = false
            cityPicker.isHidden = true
            selectACityLabel.isHidden = true
            cityPickerToolbar.isHidden = true
        }
    }
    
    @objc func refreshTable() {
        // Empty the table
        experienceManager.emptyExperiences()
        self.tableView.reloadData()
        
        // Refresh the experiences (e.g. when the user changes their city)
        experienceManager.fillExperiences(forCity: (FirebaseManager.user?.city)!) {
            () in
            DispatchQueue.main.async {
                // This is too big a hammer. This happens every time a new Experience is added to the database. Ideally we would only refresh that one item.
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isFiltering()) {
            return filteredExperiences.count
        } else {
            return experienceManager.experiences.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "experienceCell", for: indexPath) as! ExperienceTableViewCell

        let experience: Experience
        if isFiltering() {
            experience = filteredExperiences[indexPath.row]
        } else {
            experience = experienceManager.experiences[indexPath.row]
        }
        
        cell.card.experience = experience

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showExperience", sender: self)
    }

    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredExperiences = experienceManager.experiences.filter({( experience : Experience) -> Bool in
            let doesCategoryMatch = (scope == "All") || (experience.category == scope)
            
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && experience.title.lowercased().contains(searchText.lowercased())
            }
        })
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showExperience" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let experience: Experience
                if isFiltering() {
                    experience = filteredExperiences[indexPath.row]
                } else {
                    experience = experienceManager.experiences[indexPath.row]
                }
                let controller = segue.destination as! ExperienceVC
                controller.experience = experience
//                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
//                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
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

