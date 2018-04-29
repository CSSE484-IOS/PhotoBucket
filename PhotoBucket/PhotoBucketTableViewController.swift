//
//  PhotoBucketTableViewController.swift
//  PhotoBucket
//
//  Created by FengYizhi on 2018/4/13.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//

import UIKit
import Firebase

class PhotoBucketTableViewController: UITableViewController {
    var photosRef: CollectionReference!
    var photoListener: ListenerRegistration!
    
    var titleRef: DocumentReference!
    
    let photoCellIdentifier = "PhotoCell"
    let noPhotoCellIdentifier = "NoPhotoCell"
    let showDetailSegueIdentifier = "ShowDetailSegue"
    var photos = [Photo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(showAddDialog))
        
        photosRef = Firestore.firestore().collection("photo")
        titleRef = Firestore.firestore().collection("title").document("myTitleID")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        photos.removeAll()
        photoListener = photosRef.order(by: "created", descending: true).limit(to: 20)
            .addSnapshotListener({ (querySnapshot, error) in
                guard let snapshot = querySnapshot else {
                    print("Error fetching photos.  error: \(error!.localizedDescription)")
                    return
                }
                snapshot.documentChanges.forEach({ (docChange) in
                    if docChange.type == .added {
                        print("New photo: \(docChange.document.data())")
                        self.photoAdded(docChange.document)
                    } else if docChange.type == .modified {
                        print("Modified photo: \(docChange.document.data())")
                        self.photoUpdated(docChange.document)
                    } else if docChange.type == .removed {
                        print("Removed photo: \(docChange.document.data())")
                        self.photoRemoved(docChange.document)
                    }
                })
                self.photos.sort(by: { (p1, p2) -> Bool in
                    return p1.created > p2.created
                })
                self.tableView.reloadData()
            })
        titleRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error fetching document.  \(error.localizedDescription)")
                return
            }
            
            if let title = documentSnapshot?.get("title") as? String {
                self.navigationItem.title = title.isEmpty ? "PhotoBucket" : title
            }
        }
    }
    
    func photoAdded(_ document: DocumentSnapshot) {
        let newPhoto = Photo(documentSnapshot: document)
        photos.append(newPhoto)
    }
    func photoUpdated(_ document: DocumentSnapshot) {
        let modifiedPhoto = Photo(documentSnapshot: document)
        for photo in photos {
            if photo.id == modifiedPhoto.id {
                photo.caption = modifiedPhoto.caption
                break
            }
        }
    }
    func photoRemoved(_ document: DocumentSnapshot) {
        for i in 0..<photos.count {
            if photos[i].id == document.documentID {
                photos.remove(at: i)
                break
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        photoListener.remove()
    }
    
    @objc func showAddDialog() {
        let alertController = UIAlertController(title: "Create a new Photo",
                                                message: "",
                                                preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Caption"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Image URL (or blank)"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        
        let createAction = UIAlertAction(title: "Create",
                                              style: .default)
        { (action) in
            let captionTextField = alertController.textFields![0]
            let imageUrlTextField = alertController.textFields![1]
            let imageUrl = (imageUrlTextField.text!.isEmpty) ? self.getRandomImageUrl() : imageUrlTextField.text
            let newPhoto = Photo(caption: captionTextField.text!,
                                 imageUrl: imageUrl!)
            self.photosRef.addDocument(data: newPhoto.data)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(createAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func getRandomImageUrl() -> String {
        let testImages = ["https://upload.wikimedia.org/wikipedia/commons/0/04/Hurricane_Isabel_from_ISS.jpg",
                          "https://upload.wikimedia.org/wikipedia/commons/0/00/Flood102405.JPG",
                          "https://upload.wikimedia.org/wikipedia/commons/6/6b/Mount_Carmel_forest_fire14.jpg"]
        let randomIndex = Int(arc4random_uniform(UInt32(testImages.count)))
        return testImages[randomIndex];
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if photos.count == 0 {
            super.setEditing(false, animated: animated)
        } else {
            super.setEditing(editing, animated: animated)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(photos.count, 1)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if photos.count == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: noPhotoCellIdentifier, for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: photoCellIdentifier, for: indexPath)
            cell.textLabel?.text = photos[indexPath.row].caption
        }
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return photos.count > 0
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let photoToDelete = photos[indexPath.row]
            photosRef.document(photoToDelete.id!).delete()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showDetailSegueIdentifier {
            if let indexPath = tableView.indexPathForSelectedRow {
                (segue.destination as! PhotoBucketDetailViewController).photoRef = photosRef.document(photos[indexPath.row].id!)
            }
        }
    }

}
