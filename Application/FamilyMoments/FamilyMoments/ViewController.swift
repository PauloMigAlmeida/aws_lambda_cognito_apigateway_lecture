//
//  ViewController.swift
//  FamilyMoments
//
//  Created by Paulo Miguel Almeida Rodenas on 11/22/15.
//  Copyright © 2015 Paulo Miguel Almeida Rodenas. All rights reserved.
//

import UIKit

class ViewController: UIViewController,FBSDKLoginButtonDelegate {

    //MARK: Components
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    
    //MARK: View Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.facebookLoginButton.delegate = self;
    }

    //MARK: Facebook Button delegate
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print(__FUNCTION__)
        if let credentialsProvider = AWSServiceManager.defaultServiceManager().defaultServiceConfiguration.credentialsProvider as? AWSCognitoCredentialsProvider{
            credentialsProvider.logins = ["graph.facebook.com" : FBSDKAccessToken.currentAccessToken().tokenString]
            credentialsProvider.refresh()
        }
    
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print(__FUNCTION__)
    }
}

