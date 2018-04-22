//
//  PhotoBucketDetailViewController.swift
//  PhotoBucket
//
//  Created by FengYizhi on 2018/4/13.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//

import UIKit
import Firebase

class PhotoBucketDetailViewController: UIViewController {

    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinnerStackView: UIStackView!
    
    var photo: Photo?
    var photoRef: DocumentReference!
    var photoListener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(showEditDialog))
    }

    @objc func showEditDialog() {
        let alertController = UIAlertController(title: "Edit this Photo",
                                                message: "",
                                                preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Caption"
            textField.text = self.photo?.caption
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        
        let editAction = UIAlertAction(title: "Edit",
                                         style: .default)
        { (action) in
            let captionTextField = alertController.textFields![0]
            self.photo?.caption = captionTextField.text!
            self.photoRef?.setData(self.photo!.data)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(editAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.spinnerStackView.isHidden = false;
        photoListener = photoRef?.addSnapshotListener({ (documentSnapshot, error) in
            if let error = error {
                print("Error getting the document: \(error.localizedDescription)")
                return
            }
            if !documentSnapshot!.exists {
                print("This document got deleted by someone else")
                return
            }
            self.photo = Photo(documentSnapshot: documentSnapshot!)
            self.captionLabel.text = self.photo?.caption
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        photoListener.remove()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let imgString = photo?.imageUrl {
            if let imgUrl = URL(string: imgString) {
                DispatchQueue.global().async { // Download in the background
                    do {
                        let data = try Data(contentsOf: imgUrl)
                        DispatchQueue.main.async { // Then update on main thread
                            self.imageView.image = UIImage(data: data)
                            self.spinnerStackView.isHidden = true;
                        }
                    } catch {
                        print("Error downloading image: \(error)")
                    }
                }
            }
        }
    }
}
