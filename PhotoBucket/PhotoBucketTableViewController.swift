//
//  PhotoBucketTableViewController.swift
//  PhotoBucket
//
//  Created by FengYizhi on 2018/4/13.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//

import UIKit

class PhotoBucketTableViewController: UITableViewController {
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updatePhotoArray()
        tableView.reloadData()
    }
    
    @objc func showAddDialog() {
        let alertController = UIAlertController(title: "Create a new Weatherpic",
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
            
            let newPhoto = Photo(context: self.context)
            newPhoto.caption = captionTextField.text
            newPhoto.imageUrl = (imageUrlTextField.text?.isEmpty)! ? self.getRandomImageUrl() : imageUrlTextField.text
            newPhoto.created = Date()
            self.updatePhotoArray()
            
            if self.photos.count == 1 {
                self.tableView.reloadData()
                self.setEditing(false, animated: true)
            } else {
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
            }
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
    
    func updatePhotoArray() {
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "created", ascending: false)]
        do {
            photos = try context.fetch(request)
        } catch {
            fatalError("Unresolve Core Data error \(error)")
        }
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
            context.delete(photos[indexPath.row])
            save()
            updatePhotoArray()
            
            if photos.count == 0 {
                tableView.reloadData()
            } else {
                tableView.deleteRows(at: [indexPath], with: .fade)}
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showDetailSegueIdentifier {
            if let indexPath = tableView.indexPathForSelectedRow {
                (segue.destination as! PhotoBucketDetailViewController).photo = photos[indexPath.row]
            }
        }
    }

}
