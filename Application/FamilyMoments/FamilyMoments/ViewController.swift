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
        if photoImageView.image != nil {
            let filename = "test.jpg"
            
            let image = photoImageView.image!.resizeToWidth(640)
            
            let fileManager = NSFileManager.defaultManager()
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            let filePathToWrite = "\(paths)/\(filename)"
            let imageData: NSData = UIImageJPEGRepresentation(image, 0.7)!
            
            fileManager.createFileAtPath(filePathToWrite, contents: imageData, attributes: nil)
            print(fileManager.fileExistsAtPath(filePathToWrite))
            
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            uploadRequest.body = NSURL(fileURLWithPath: filePathToWrite)
            uploadRequest.key = filename
            uploadRequest.bucket = "awslambdacognitoapigatewaylecture"
            uploadRequest.ACL = AWSS3ObjectCannedACL.PublicRead
            uploadRequest.contentType = "image/jpeg"

            self.upload(uploadRequest)

        }else{
            print("You need to select an image from camera roll first")
        }

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
    
    //MARK: AmazonS3 methods
    func upload(uploadRequest: AWSS3TransferManagerUploadRequest) {
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject! in
            if let error = task.error {
                    print("upload() failed: [\(error)]")
            }
            
            if let exception = task.exception {
                print("upload() failed: [\(exception)]")
            }
            
            if task.result != nil {
                print("upload() successful")
            }
            return nil
        }
    }
    
}

