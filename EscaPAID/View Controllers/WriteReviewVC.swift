//
//  WriteReviewVCViewController.swift
//  EscaPAID
//
//  Created by Michael Miller on 5/17/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class WriteReviewVC: UIViewController {
    
    var experience: Experience!

    @IBOutlet weak var titleTextField: BorderedTextField!
    
    @IBOutlet weak var reviewTextView: BorderedTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func cancelButton_click(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButton_click(_ sender: Any) {
        let review = Review(experience: experience, title: titleTextField.text!, text: reviewTextView.text!, reviewer: FirebaseManager.user!, date: Date())
        
        ReviewManager.add(review: review, to: experience, completion: {
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    
}
