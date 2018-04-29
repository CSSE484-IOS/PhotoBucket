//
//  AppDelegate.swift
//  PhotoBucket
//
//  Created by FengYizhi on 2018/4/13.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        FirebaseApp.configure()
        
        if Auth.auth().currentUser == nil {
            showLoginViewController();
        } else {
            showPhotoTableViewController();
        }
        window?.makeKeyAndVisible()
        
        return true
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

