//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Sean Melnick Kelly on 4/24/17.
//  Copyright © 2017 Sean Melnick Kelly. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    var store: PhotoStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Starts web exchange for the photos when the view controller comes onscreen - pg. 359
        store.fetchInterestingPhotos {
            (PhotosResult) -> Void in // pg. 370
            
            switch PhotosResult { // pg. 370
            case let .success(photos):
                print("Successfully found \(photos.count) interesting photos.")
                if let firstPhoto = photos.first { // pg. 372
                    self.updateImageView(for: firstPhoto, type: false)
                }
            case let .failure(error):
                print("Error fetching interesting photos: \(error)")
            }
        } 
     /*   // Chap. 20 Silver **
        store.fetchRecentPhotos {
            (PhotosResult) -> Void in
            
            switch PhotosResult {
            case let .success(photos):
                print("Successfully found \(photos.count) recent photos")
                if let firstPhoto = photos.first { // pg. 372
                    self.updateImageView(for: firstPhoto, type: true)
                }
            case let .failure(error):
                print("Error fetching recent photos: \(error)")
            }
        }
        // Chap. 20 Silver End */
    }
    
    func updateImageView(for photo: Photo, type: Bool) {
        // Method that will fetch image and display to image view
        store.fetchImage(for: photo) {
            (imageResult) -> Void in
            
            switch imageResult { // pg. 372
            case let .success(image):
                self.imageView.image = image
            case let .failure(error):
                print("Error downloading image: \(error)")
            }
        }
    }
}
