//
//  ThemedTableViewController.swift
//  EscaPAID
//
//  Created by Michael Miller on 5/24/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class ThemedTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as? UITableViewHeaderFooterView
        
        header?.textLabel?.textColor = Config.current.mainColor
        header?.textLabel?.font = UIFont(name: "Montserrat-Bold", size: (header?.textLabel?.font.pointSize)!)
        
    }
}
