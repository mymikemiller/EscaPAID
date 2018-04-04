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
            selector: #selector(UIScrollingViewController.keyboardWillShow(_:)),
            name: Notification.Name.UIKeyboardWillShow,
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
    
    func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
        // Return early if the keyboard's frame isn't changing.
        let userInfo = notification.userInfo ?? [:]
        let beginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        guard beginFrame.equalTo(endFrame) == false else {
            return
        }

        let adjustmentHeight = (keyboardHeight + 20) * (show ? 1 : -1)
        scrollView.contentInset.bottom += adjustmentHeight
        scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardHeight = keyboardFrame.height
        
        adjustInsetForKeyboardShow(true, notification: notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        adjustInsetForKeyboardShow(false, notification: notification)
    }
}
