//
//  Photo.swift
//  PhotoBucket
//
//  Created by FengYizhi on 2018/4/22.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//

import UIKit
import Firebase

class Photo: NSObject {
    var id: String?
    var caption: String
    var imageUrl: String
    var created: Date!
    var uid: String!
    
    let captionKey = "caption"
    let imageUrlKey = "imageUrl"
    let createdKey = "created"
    let uidKey = "uid"
    
    init(caption: String, imageUrl: String) {
        self.caption = caption
        self.imageUrl = imageUrl
        self.created = Date()
        if let currentUser = Auth.auth().currentUser {
            self.uid = currentUser.uid
        } else {
            print("Error identifying the current user")
            return
        }
    }
    
    init(documentSnapshot: DocumentSnapshot) {
        self.id = documentSnapshot.documentID
        let data = documentSnapshot.data()!
        self.caption = data[captionKey] as! String
        self.imageUrl = data[imageUrlKey] as! String
        if data[createdKey] != nil {
            self.created = data[createdKey] as! Date
        }
        if data[uidKey] != nil {
            self.uid = data[uidKey] as! String
        }
    }
    
    var data: [String: Any] {
        return [captionKey: self.caption,
                imageUrlKey: self.imageUrl,
                createdKey: self.created,
                uidKey: self.uid]
    }
}
