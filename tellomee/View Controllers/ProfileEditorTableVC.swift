//
//  ProfileEditorTableVC.swift
//  tellomee
//
//  Created by Michael Miller on 1/3/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class ProfileEditorTableVC: UITableViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var uploadProgressView: UIProgressView!

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var city: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the image view
        self.imageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(ProfileEditorTableVC.imageView_click)))
        
        // Crop to a circle
        self.imageView.layer.cornerRadius = self.imageView.frame.width / 2
        self.imageView.layer.masksToBounds = true
        self.imageView.image = FirebaseManager.user?.getProfileImage()
        
        // Set up the city picker
        city.text = FirebaseManager.user?.city
        let cityPicker = SelfContainedPickerView()
        cityPicker.setUp(textField: city, strings: Constants.cities)
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
    
    @IBAction func saveButton_click(_ sender: Any) {
        FirebaseManager.user?.displayName = name.text!
        FirebaseManager.user?.city = city.text!
        FirebaseManager.user?.phone = phone.text!
//        FirebaseManager.user?.aboutMe = aboutMe.text!
        FirebaseManager.user?.update()
        
        self.dismiss(animated: true, completion:nil)
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


extension ProfileEditorTableVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pickerInfo:NSDictionary = info as NSDictionary
        let img:UIImage = pickerInfo.object(forKey: UIImagePickerControllerOriginalImage) as! UIImage
        DispatchQueue.main.async { [unowned self] in
            
            self.imageView.image = img
            
            let uploadTask = StorageManager.storeImage(folder: StorageManager.PROFILE_IMAGES, image: img) { (url) in
                
                if (FirebaseManager.user?.profileImageUrl != nil &&
                    FirebaseManager.user?.profileImageUrl != "") {
                    // Delete the previous picture from storage
                    StorageManager.removeImageFromStorage(folder: StorageManager.PROFILE_IMAGES, imageUrl: (FirebaseManager.user?.profileImageUrl)!)
                }
                
                // Hide the progress bar
                self.uploadProgressView.isHidden = true
                
                // Save the URL to the database. Note that we don't have to press "Save" to make this happen. It saves automatically when the image is finished uploading.
                FirebaseManager.user?.updateProfileImageUrl(url)
                
            }
            uploadTask?.observe(.progress) { snapshot in
                self.uploadProgressView.isHidden = false
                self.uploadProgressView.setProgress(Float((snapshot.progress?.fractionCompleted)!), animated: true)
                
            }
            
        }
        self.dismiss(animated: true, completion: nil)
        
    }
}
