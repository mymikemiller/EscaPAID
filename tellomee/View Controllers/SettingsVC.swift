//
//  SettingsViewController.swift
//  tellomee
//
//  Created by Michael Miller on 11/11/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var aboutMe: UITextView!
    
    @IBOutlet weak var uploadProgressView: UIProgressView!
    
    var user:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(SettingsVC.imageView_click)))
        
        FirebaseManager.getUser(uid: FirebaseManager.currentUserId) { (user) in
            self.user = user
            self.displayName.text = user.displayName
            self.phone.text = user.phone
            self.aboutMe.text = user.aboutMe
            
            self.imageView.image = user.getProfileImage()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This has to be an @objc func so it can be used as a selector for the TapGestureRecognizer, which we need to use because it's an imageView not a button.
    @objc func imageView_click(sender: AnyObject?) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(image, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pickerInfo:NSDictionary = info as NSDictionary
        let img:UIImage = pickerInfo.object(forKey: UIImagePickerControllerOriginalImage) as! UIImage
        DispatchQueue.main.async { [unowned self] in
        
            self.imageView.image = img
            
            let uploadTask = StorageManager.storeImage(folder: StorageManager.PROFILE_IMAGES, image: img) { (url) in
                
                if (self.user?.profileImageUrl != nil) {
                   // Delete the previous picture from storage
                    StorageManager.removeImageFromStorage(folder: StorageManager.PROFILE_IMAGES, imageUrl: (self.user?.profileImageUrl)!)
                }
                
                // Hide the progress bar
                self.uploadProgressView.isHidden = true
                
                // Save the URL to the database. Note that we don't have to press "Save" to make this happen. It saves automatically when the image is finished uploading.
                self.user?.updateProfileImageUrl(url)
                
            }
            uploadTask?.observe(.progress) { snapshot in
                self.uploadProgressView.isHidden = false
                self.uploadProgressView.setProgress(Float((snapshot.progress?.fractionCompleted)!), animated: true)
                
            }
            
        }
        self.dismiss(animated: true, completion: nil)
        
    }

    @IBAction func saveButton_click(_ sender: Any) {
        if (user != nil) {
            user?.update(displayName: displayName.text!, phone: phone.text!, aboutMe: aboutMe.text!)
            
            self.dismiss(animated: true, completion:nil)
        }
    }
    
    @IBAction func cancelButton_click(_ sender: Any) {
        self.dismiss(animated: true, completion:nil)
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
