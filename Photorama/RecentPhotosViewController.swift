//
//  RecentPhotosViewController.swift
//  Photorama
//
//  Created by Sean Melnick Kelly on 4/25/17.
//  Copyright © 2017 Sean Melnick Kelly. All rights reserved.
//

import UIKit

class RecentPhotosViewController: UIViewController { // Created for Chap. 20 Silver
    
    @IBOutlet var imageViewTwo: UIImageView!
    var store: PhotoStore? // Switched ! to ? to prevent crash - How to reload photos?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Chap. 20 Silver **
        store?.fetchRecentPhotos {
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
        // Chap. 20 Silver End
    }
    
    func updateImageView(for photo: Photo, type: Bool) {
        // Method that will fetch image and display to image view
        store?.fetchImage(for: photo) {
            (imageResult) -> Void in
            
            switch imageResult { // pg. 372
            case let .success(image):
                self.imageViewTwo.image = image
            case let .failure(error):
                print("Error downloading image: \(error)")
            }
        }
    }
}
