//
//  AppDelegate.swift
//  PhotoBucket
//
//  Created by FengYizhi on 2018/4/13.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        if Auth.auth().currentUser == nil {
            showLoginViewController();
        } else {
            showPhotoTableViewController();
        }
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("Error with Google Auth! Error: \(error.localizedDescription)")
            return
        }
        print("You are signed in using Google account: \(user.profile.email)")
        //        guard let authentication = user.authentication else { return }
        //        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
        //                                                       accessToken: authentication.accessToken)
    }
    
    func handleLogin() {
        showPhotoTableViewController()
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error on sign out: \(error.localizedDescription)")
        }
        showLoginViewController()
    }
    
    func showLoginViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window!.rootViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
    }
    
    func showPhotoTableViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window!.rootViewController = storyboard.instantiateViewController(withIdentifier: "NavigationController")
    }

}

extension UIViewController {
    var appDelegate : AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }
}

