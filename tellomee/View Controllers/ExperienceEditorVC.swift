//
//  ExperienceEditorVC.swift
//  tellomee
//
//  Created by Michael Miller on 11/28/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class ExperienceEditorVC: UIViewController {
    
    fileprivate let itemsPerRow: CGFloat = 3

    var experience:Experience?
    var imageUrls: [String] = []
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var uploadProgressView: UIProgressView!
    
    fileprivate let reuseIdentifier = "ExperienceImageUploadCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    @IBOutlet weak var experienceTitle: UITextField!
    @IBOutlet weak var experienceIncludes: UITextField!
    @IBOutlet weak var experienceDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let experience = experience {
            experienceTitle.text = experience.title
            experienceIncludes.text = experience.includes
            experienceDescription.text = experience.experienceDescription
            imageUrls = experience.imageUrls
        }
    }
    @IBAction func cancelButton_click(_ sender: Any) {
        self.dismiss(animated: true, completion:nil)
    }
    
    @IBAction func saveButton_click(_ sender: Any) {
        experience?.title = (experienceTitle?.text)!
        experience?.includes = (experienceIncludes?.text)!
        experience?.experienceDescription = (experienceDescription?.text)!
        experience?.imageUrls = imageUrls
        experience?.save()
        self.dismiss(animated: true, completion:nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func imageForIndexPath(indexPath: IndexPath) -> UIImage {
        if (indexPath.row == imageUrls.count) {
            // Return the "add image" icon for the last image
            return #imageLiteral(resourceName: "ic_library_add")
        } else if (indexPath.row < imageUrls.count) {
            
            if let url = NSURL(string: imageUrls[indexPath.row]) {
                if let data = NSData(contentsOf: url as URL) {
                    return UIImage(data: data as Data)!
                }
            }
        }
        return UIImage()
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


// MARK: - UICollectionViewDataSource
extension ExperienceEditorVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        // Add one for the "add image" button
        return imageUrls.count + 1
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
        if (indexPath.row == imageUrls.count) {
            // If the user clicks the "add image" icon
            // Let the user pick an image
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(image, animated: true, completion: nil)
        } else {
            // If the uer clicks on any other image, offer to delete it
            let alertVC = UIAlertController(title: "Confirm", message: "Remove this image?", preferredStyle: .alert)
            
            let alertActionRemove = UIAlertAction(title: "Remove", style: .default) {
                (_) in
                
                // Remove the image
                self.imageUrls.remove(at: indexPath.row)
                
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
extension ExperienceEditorVC : UICollectionViewDelegateFlowLayout {
    
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

// MARK: - UIImagePickerControllerDelegate
extension ExperienceEditorVC : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pickerInfo:NSDictionary = info as NSDictionary
        let img:UIImage = pickerInfo.object(forKey: UIImagePickerControllerOriginalImage) as! UIImage
        DispatchQueue.main.async { [unowned self] in
            
            let uploadTask = StorageManager.storeImage(folder: "experienceImages", image: img) { (url) in
                // After the image is uploaded, add the url to our list and refresh the view to show the new image
                self.imageUrls.append(url)
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
