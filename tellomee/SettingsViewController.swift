//
//  SettingsViewController.swift
//  tellomee
//
//  Created by Michael Miller on 11/11/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var phone: UITextField!
    
    var selectedUser:User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayName.text = selectedUser?.displayName
        phone.text = selectedUser?.phone
        
        imageView.image = selectedUser?.getProfileImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getPhotoButton_click(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(image, animated: true, completion: nil)
    }
    
    @IBAction func submitButton_click(_ sender: Any) {
        if (imageView.image != nil) {
            selectedUser?.uploadProfilePhoto(profileImage: imageView.image!)
        }
        selectedUser?.update(displayName: displayName.text!, phone: phone.text!)
        
        navigationController?.popViewController(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pickerInfo:NSDictionary = info as NSDictionary
        let img:UIImage = pickerInfo.object(forKey: UIImagePickerControllerOriginalImage) as! UIImage
        DispatchQueue.main.async { [unowned self] in
            self.imageView.image = img
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func logOut_click(_ sender: Any) {
        FirebaseManager.logOut()
       
        let logInVC: UIViewController? = self.storyboard?.instantiateViewController(withIdentifier: "launchViewController")
        self.present(logInVC!, animated: true, completion: nil)

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
