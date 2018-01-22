//
//  ExperienceEditorTableVCTableViewController.swift
//  tellomee
//
//  Created by Michael Miller on 1/8/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class ExperienceEditorTableVC: UITableViewController {

    // Images per row in the collection view
    fileprivate let itemsPerRow: CGFloat = 3
    
    @IBOutlet weak var experienceTitle: UITextField!
    @IBOutlet weak var experiencePrice: UITextField!
    @IBOutlet weak var experienceCategory: UITextField!
    @IBOutlet weak var experienceCity: UITextField!
    @IBOutlet weak var experienceDescription: UILabel!
    @IBOutlet weak var experienceIncludes: UITextField!
    
    var experienceDays: Days = Days.All {
        didSet {
            experienceDaysLabel.text = experienceDays.toString()
        }
    }

    var newExperience = false
    var experience:Experience?
    
    @IBOutlet weak var experienceDaysLabel: UILabel!
    
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var uploadProgressView: UIProgressView!
    
    fileprivate let reuseIdentifier = "ExperienceImageUploadCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set up the category picker
        experienceCategory.text = Constants.categories[0]
        let categoryPicker = SelfContainedPickerView()
        categoryPicker.setUp(textField: experienceCategory, strings: Constants.categories)
        
        // Set up the city picker
        let cityPicker:SelfContainedPickerView = SelfContainedPickerView()
        cityPicker.setUp(textField: experienceCity, strings: Constants.cities)
        
        // Set the default values
        if let experience = experience {
            newExperience = false
            experienceTitle.text = experience.title
            experienceCategory.text = experience.category
            experienceIncludes.text = experience.includes
            experienceCity.text = experience.city
            experiencePrice.text = String(format: "%.02f", experience.price)
            experienceDescription.text = experience.experienceDescription
            experienceCategory.text = experience.category
            experienceDays = experience.days
        } else {
            newExperience = true
            experience = Experience.createNewExperience()
            
            // Set the default values.
            // Default to the first category if we are creating a new experience
            experienceCategory.text = Constants.categories[0]
            experienceCity.text = FirebaseManager.user?.city
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButton_click(_ sender: Any) {
        if (newExperience) {
            // Remove the new experience from the database if we canceled out of the page when creating a new experience. But first delete all the experience's images.
            for url in (experience?.imageUrls)! {
                StorageManager.removeImageFromStorage(folder: StorageManager.EXPERIENCE_IMAGES, imageUrl: url)
            }
            experience!.deleteSelf()
        }
        
        //Cancel does nothing if editing an existing experience.
        self.dismiss(animated: true, completion:nil)
    }
    
    @IBAction func saveButton_click(_ sender: Any) {
        let price = Double((experiencePrice?.text)!)
        
        // Only allow the user to save if they're filled in all the required information
        if ((experienceTitle?.text?.isEmpty)! ||
            (experienceCategory?.text?.isEmpty)! ||
            (experienceIncludes?.text?.isEmpty)! ||
            (experienceCity?.text?.isEmpty)! ||
            (experiencePrice?.text?.isEmpty)! ||
            price == nil ||
            (experienceDescription?.text?.isEmpty)! ||
            (experience?.imageUrls.isEmpty)! ) {
            
            let alertVC = UIAlertController(title: "Error", message: "Please fill in all required fields and upload at least one image.", preferredStyle: .alert)
            let alertActionOkay = UIAlertAction(title: "Okay", style: .default)
            alertVC.addAction(alertActionOkay)
            self.present(alertVC, animated: true, completion: nil)
            return
        }
        
        experience?.title = (experienceTitle?.text)!
        experience?.category = (experienceCategory?.text)!
        experience?.includes = (experienceIncludes?.text)!
        experience?.city = (experienceCity?.text)!
        experience?.price = price!
        experience?.days = experienceDays
        experience?.experienceDescription = (experienceDescription?.text)!
        experience?.save()
        self.dismiss(animated: true, completion:nil)
    }
    
    @IBAction func descriptionEdit_click(_ sender: Any) {
        let getter = TextGetterController()
        getter.setTitle("Description")
        getter.setText(experienceDescription.text!)
        getter.delegate = self
        self.present(getter, animated: true, completion: nil)
    }
    
    func imageForIndexPath(indexPath: IndexPath) -> UIImage {
        if (indexPath.row == experience?.imageUrls.count) {
            // Return the "add image" icon for the last image
            return #imageLiteral(resourceName: "ic_library_add")
        } else if (indexPath.row < (experience?.imageUrls.count)!) {
            
            if let url = NSURL(string: (experience?.imageUrls[indexPath.row])!) {
                if let data = NSData(contentsOf: url as URL) {
                    return UIImage(data: data as Data)!
                }
            }
        }
        return UIImage()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "EditDaysSegue") {
            (segue.destination as! DaySelectorTableVC).days = experienceDays
        }
    }
}

extension ExperienceEditorTableVC: TextGetterDelegate {
    func didGetText(_ text: String) {
        experienceDescription.text = text
    }
    
    
}

// MARK: - UICollectionViewDataSource
extension ExperienceEditorTableVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        // Add one for the "add image" button
        return (experience?.imageUrls.count)! + 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ExperienceImageCell
        
        let image = imageForIndexPath(indexPath: indexPath)
        cell.backgroundColor = UIColor.white
        
        cell.imageView.image = image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.row == experience?.imageUrls.count) {
            // If the user clicks the "add image" icon
            // Let the user pick an image
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(image, animated: true, completion: nil)
        } else {
            // If the user clicks on any other image, offer to delete it
            let alertVC = UIAlertController(title: "Confirm", message: "Remove this image?", preferredStyle: .alert)
            
            let alertActionRemove = UIAlertAction(title: "Remove", style: .default) {
                (_) in
                
                // Remove the image from storage. Note that this doesn't require you to click "Save"
                let url = self.experience?.imageUrls[indexPath.row]
                StorageManager.removeImageFromStorage(folder: StorageManager.EXPERIENCE_IMAGES, imageUrl: url!)
                
                // Remove the image from the experience. Note that this commits to the database and also doesn't require you to click "Save"
                self.experience?.removeImageUrl(url!)
                
                // Reload the collection view
                self.imageCollectionView.reloadData()
            }
            let alertActionCancel = UIAlertAction(title: "Cancel", style: .default)
            
            alertVC.addAction(alertActionRemove)
            alertVC.addAction(alertActionCancel)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ExperienceEditorTableVC : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension ExperienceEditorTableVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ExperienceEditorTableVC : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pickerInfo:NSDictionary = info as NSDictionary
        let img:UIImage = pickerInfo.object(forKey: UIImagePickerControllerOriginalImage) as! UIImage
        DispatchQueue.main.async { [unowned self] in
            
            let uploadTask = StorageManager.storeImage(folder: StorageManager.EXPERIENCE_IMAGES, image: img) { (url) in
                
                // After the image is uploaded, add the url to our list. Note that this gets saved immediately to the database and doens't require us to click the "Save" button"
                self.experience?.addImageUrl(url)
                
                // Refresh the view to show the new image
                self.imageCollectionView.reloadData()
                
                // Hide the progress bar
                self.uploadProgressView.isHidden = true
            }
            uploadTask?.observe(.progress) { snapshot in
                self.uploadProgressView.isHidden = false
                self.uploadProgressView.setProgress(Float((snapshot.progress?.fractionCompleted)!), animated: true)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
}
