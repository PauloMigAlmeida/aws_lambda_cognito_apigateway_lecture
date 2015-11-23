//
//  ViewController.swift
//  FamilyMoments
//
//  Created by Paulo Miguel Almeida Rodenas on 11/22/15.
//  Copyright © 2015 Paulo Miguel Almeida Rodenas. All rights reserved.
//

import UIKit

class ViewController: UIViewController,FBSDKLoginButtonDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    //MARK: Components
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var postButton: UIButton!
    let imagePicker = UIImagePickerController()
    
    
    //MARK: View Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        facebookLoginButton.delegate = self;
        imagePicker.delegate = self
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    //MARK: Action methods
    func updateUI(){
        self.postButton.enabled = (FBSDKAccessToken.currentAccessToken() != nil)
    }
    
    @IBAction func touchUpInsidePostButton(sender: AnyObject) {
        print(__FUNCTION__)
    }
    @IBAction func tappedPhotoImageView(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: Facebook Button delegate
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print(__FUNCTION__)
        if let credentialsProvider = AWSServiceManager.defaultServiceManager().defaultServiceConfiguration.credentialsProvider as? AWSCognitoCredentialsProvider{
            credentialsProvider.logins = ["graph.facebook.com" : FBSDKAccessToken.currentAccessToken().tokenString]
            credentialsProvider.refresh()
        }
        updateUI()
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print(__FUNCTION__)
        updateUI()
    }
    
    //MARK: UIImagePicker delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            photoImageView.contentMode = .ScaleAspectFit
            photoImageView.image = pickedImage
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

