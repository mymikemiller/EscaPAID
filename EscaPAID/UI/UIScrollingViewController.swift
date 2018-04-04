//
//  UIScrollingViewController.swift
//  EscaPAID
//
//  Created by Michael Miller on 4/3/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class UIScrollingViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var keyboardHeight: CGFloat = 0
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Listen for keyboard hide/show notifications. We use these to add a bit of scrolling space when the keyboard shows so the user can scroll down to the buttons/fields at the bottom.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(UIScrollingViewController.keyboardDidShow(_:)),
            name: Notification.Name.UIKeyboardDidShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(UIScrollingViewController.keyboardWillHide(_:)),
            name: Notification.Name.UIKeyboardWillHide,
            object: nil
        )

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        // Set the content insets to accomodate the keyboard's height
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // Set the content insets back to zero
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}
