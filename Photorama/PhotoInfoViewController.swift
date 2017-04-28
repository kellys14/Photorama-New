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
    @IBOutlet var viewCountLabel: UILabel! // Chapter 22 Bronze **
    @IBAction func favoritesButton(_ sender: UIButton) { // Chapter 23 Silvers **
        if photo.favorite {
            sender.backgroundColor = UIColor.white
            photo.favorite = false
        }
        else {
            sender.backgroundColor = UIColor.red
            photo.favorite = true
        }
    }
    
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
        // Chapter 22 Bronze Challenge **
        photo.viewCount += 1
        store.saveCountContext()
        
        var counter = String(photo.viewCount)
        counter += " views"
        viewCountLabel.text = counter
        // Chapter 22 Bronze Challenge **

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Override method when the Tags bar button item is tapped, the
        // PhotosInfoViewController needs to pass along its store and
        // photo to the TagsViewController
        
        switch segue.identifier {
        case "showTags"?:
            let navController = segue.destination as! UINavigationController
            let tagController = navController.topViewController as! TagsViewController
            
            tagController.store = store
            tagController.photo = photo
        default:
            preconditionFailure("Unexpected segue identifier")
        }
        
    }
}
