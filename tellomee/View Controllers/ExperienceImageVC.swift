//
//  ExperienceImageVC.swift
//  tellomee
//
//  Created by Michael Miller on 11/29/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class ExperienceImageVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var pageIndex: Int = -1
    var imageUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let url = NSURL(string: imageUrl) {
            if let data = NSData(contentsOf: url as URL) {
                imageView.image = UIImage(data: data as Data)!
            }
        }
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
