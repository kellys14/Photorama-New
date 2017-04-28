//
//  PhotoInfoViewController.swift
//  Photorama
//
//  Created by Sean Melnick Kelly on 4/27/17.
//  Copyright © 2017 Sean Melnick Kelly. All rights reserved.
//

import UIKit

class PhotoInfoViewController: UIViewController {
    // Class that adds functionality to allow the user to navigate to
    // and display a single photo
    
    @IBOutlet var imageView: UIImageView!
    
    var photo: Photo! {
        didSet {
            // When photo is set on this view controller, the navigation
            // item will be updated to display the name of the photo
            navigationItem.title = photo.title
        }
    }
    var store: PhotoStore!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.fetchImage(for: photo) { (result) -> Void in
            // Sets the image on imageView when the view is loaded
            switch result {
            case let .success(image):
                self.imageView.image = image
            case let .failure(error):
                print("Error fetching image for photo: \(error)")
            }
        }
    }
}