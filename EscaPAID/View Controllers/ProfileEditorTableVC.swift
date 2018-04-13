//
//  ProfileEditorTableVC.swift
//  EscaPAID
//
//  Created by Michael Miller on 1/3/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit
import RSKImageCropper

extension Notification.Name {
    static let cityChanged = Notification.Name(
        rawValue: "cityChanged")
}

class ProfileEditorTableVC: UITableViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var uploadProgressView: UIProgressView!

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var aboutMe: UILabel!
    
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
        
        // Set up the About Me text
        aboutMe.adjustsFontSizeToFitWidth = false
        aboutMe.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
        // Set initial values
        firstName.text = FirebaseManager.user?.firstName
        lastName.text = FirebaseManager.user?.lastName
        aboutMe.text = FirebaseManager.user?.aboutMe
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
    @IBAction func aboutMeEdit_click(_ sender: Any) {
        let getter = TextGetterController()
        getter.setTitle("About Me")
        getter.setText(aboutMe.text!)
        getter.delegate = self
        self.present(getter, animated: true, completion: nil)
    }
    
    @IBAction func saveButton_click(_ sender: Any) {
        
        let cityUpdated = FirebaseManager.user?.city != city.text!
        
        FirebaseManager.user?.firstName = firstName.text!
        FirebaseManager.user?.lastName = lastName.text!
        FirebaseManager.user?.city = city.text!
        FirebaseManager.user?.aboutMe = aboutMe.text!
        FirebaseManager.user?.update()
        
        if (cityUpdated) {
            // Send a broadcast notification to let the app know we changed the city
            NotificationCenter.default.post(name: Notification.Name.cityChanged, object: nil)
        }
        
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
            
            // Pop up the image cropper loaded with the chosen image
            
            
            let cropper = RSKImageCropViewController.init(image: img)
            cropper.delegate = self
            self.navigationController?.pushViewController(cropper, animated: true)
            
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func updateProfileImage(_ image: UIImage) {
        let uploadTask = StorageManager.storeImage(folder: StorageManager.PROFILE_IMAGES, image: image) { (url) in

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
}

extension ProfileEditorTableVC: RSKImageCropViewControllerDelegate {
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        // Close the cropper
        navigationController?.popViewController(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        
        // Close the cropper
        navigationController?.popViewController(animated: true)

        // Set the newly cropped image
        self.imageView.image = croppedImage
        
        // save the image to the database
        updateProfileImage(croppedImage)
    }
    
    
}

extension ProfileEditorTableVC: TextGetterDelegate {
    func didGetText(title: String, text: String) {
        // aboutMe is the only text view using TextGetterDelegate, so we don't need to look at title here
        aboutMe.text = text
    }
    
    
}
