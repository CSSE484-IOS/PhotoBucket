//
//  LoginViewController.swift
//  PhotoBucket
//
//  Created by FengYizhi on 2018/4/29.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//

import UIKit
import Firebase
import Rosefire
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    let ROSEFIRE_REGISTRY_TOKEN = "a498270b-df1a-4313-a0e2-dbaa14e76842"
    
    @IBOutlet weak var rosefireLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: GIDSignInButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareRosefireLogin()
        prepareGoogleLogin()
    }
    
    func prepareRosefireLogin() {
        rosefireLoginButton.setTitle("Rosefire Login", for: .normal)
        rosefireLoginButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 15.0)
        rosefireLoginButton.setTitleColor(.white, for: .normal)
        rosefireLoginButton.backgroundColor = UIColor(red: 0.5, green: 0, blue: 0, alpha: 0.9)
    }
    
    func prepareGoogleLogin() {
        GIDSignIn.sharedInstance().uiDelegate = self
        googleLoginButton.style = .wide
    }
    
    // MARK: - Login Methods
    
    func loginCompletionCallback(_ user: User?, _ error: Error?) {
        if let error = error {
            print("Error during log in: \(error.localizedDescription)")
            let ac = UIAlertController(title: "Login failed", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true)
        } else {
            appDelegate.handleLogin()
        }
    }
    
    @IBAction func pressedRosefireLogin(_ sender: Any) {
        Rosefire.sharedDelegate().uiDelegate = self
        Rosefire.sharedDelegate().signIn(registryToken: ROSEFIRE_REGISTRY_TOKEN) {
            (error, result) in
            if let error = error {
                print("Error communicating with Rosefire! \(error.localizedDescription)")
                return
            }
            print("You are now signed in with Rosefire! username: \(result!.username)")
            Auth.auth().signIn(withCustomToken: result!.token, completion: self.loginCompletionCallback)
        }
    }
}
