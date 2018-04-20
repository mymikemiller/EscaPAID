//
//  ProfileVC.swift
//  EscaPAID
//
//  Created by Michael Miller on 4/17/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
    
    var user: User!

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var aboutMeLabel: ThemedLabel!
    
    override func viewDidLoad() {
        imageView.image = user.getProfileImage()
        nameLabel.text = user.fullName
        aboutMeLabel.text = user.aboutMe
    }
    
}
