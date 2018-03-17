//
//  ExperienceImageVC.swift
//  EscaPAID
//
//  Created by Michael Miller on 11/29/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit
import SDWebImage

class ExperienceImageVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var pageIndex: Int = -1
    var imageURL: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let placeholder = UIImage(named: "loading")!
        let url = URL(string: imageURL)
        
        imageView.sd_setImage(with: url, placeholderImage:placeholder)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
