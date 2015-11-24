//
//  ViewController.swift
//  FamilyMoments
//
//  Created by Paulo Miguel Almeida Rodenas on 11/22/15.
//  Copyright © 2015 Paulo Miguel Almeida Rodenas. All rights reserved.
//

import UIKit

class CreateMomentViewController: UIViewController,FBSDKLoginButtonDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

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
            let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.Indeterminate
            loadingNotification.labelText = "Posting"
            
            let commonBlock:() -> Void = {
                dispatch_async(dispatch_get_main_queue()) {
                    loadingNotification.hide(true)
                }
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                // Saving file locally
                let randomString = self.randomStringWithLength(10)
                let filename = "\(randomString).jpg"
                let image = self.photoImageView.image!.resizeToWidth(640)
                let fileManager = NSFileManager.defaultManager()
                let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                let filePathToWrite = "\(paths)/\(filename)"
                let imageData: NSData = UIImageJPEGRepresentation(image, 0.8)!
                fileManager.createFileAtPath(filePathToWrite, contents: imageData, attributes: nil)
                
                //Uploading it to S3
                if self.uploadPhotoToS3(NSURL(fileURLWithPath: filePathToWrite), filename: filename){
                    
                    //Creating a moment
                    let createMoment = CLICreateMomentRequest()
                    createMoment._id = randomString as String
                    createMoment.comment = self.commentTextField.text
                    createMoment.s3Object = filename
                    
                    let service = CLIFamilyMomentsClient.defaultClient()
                    service.momentsPost(createMoment).waitUntilFinished()
                    commonBlock()
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.alert("Info", message: "Moment created successfully")
                        
                        //Clean up
                        self.photoImageView.image = nil
                        self.commentTextField.text = nil
                    }
                }else{
                    commonBlock()
                    dispatch_async(dispatch_get_main_queue()){
                        self.alert("Error", message: "Error when creating a moment")
                    }
                }
            })
        }else{
            alert("Error", message: "You need to select an image from camera roll first")
        }

    }
    
    @IBAction func tappedPhotoImageView(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func tappedView(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    func uploadPhotoToS3(fileUrl:NSURL, filename:String) -> Bool{
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.body = fileUrl
        uploadRequest.key = filename
        uploadRequest.bucket = GlobalConstants.AWSBucketName
        uploadRequest.ACL = AWSS3ObjectCannedACL.PublicRead
        uploadRequest.contentType = GlobalConstants.AWSS3JpegContentType
        
        return self.upload(uploadRequest)
    }
    
    //MARK: Facebook Button delegate
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if let credentialsProvider = AWSServiceManager.defaultServiceManager().defaultServiceConfiguration.credentialsProvider as? AWSCognitoCredentialsProvider{
            credentialsProvider.logins = ["graph.facebook.com" : FBSDKAccessToken.currentAccessToken().tokenString]
            credentialsProvider.refresh()
        }
        updateUI()
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
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

