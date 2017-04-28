//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Sean Melnick Kelly on 4/24/17.
//  Copyright © 2017 Sean Melnick Kelly. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate {
    // Class responsible for the view that will hold the data from
    // from the web service
    
    @IBOutlet var collectionView: UICollectionView! // pg. 383
    
    var store: PhotoStore!
    let photoDataSource = PhotoDataSource()
        
    override func viewDidLoad() {
        // Override to set delegates start web exchange for the photos when
        // the view controller comes on screen
        
        super.viewDidLoad()
            
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self // Sets PhotosViewController as delegate
        
        updateDataSource()
            
        // Starts web exchange for the photos when the view controller comes onscreen - pg. 359
        store.fetchInterestingPhotos {
            (photosResult) -> Void in // pg. 370
                
            self.updateDataSource() // pg. 413
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // pg. 399
        // Override to pass along the photo and the store
        
        switch segue.identifier {
        case "showPhoto"?:
            if let selectedIndexPath =
                collectionView.indexPathsForSelectedItems?.first {
                
                let photo = photoDataSource.photos[selectedIndexPath.row]
                
                let destinationVC =
                    segue.destination as! PhotoInfoViewController
                destinationVC.photo = photo
                destinationVC.store = store
            }
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        // Delegate method to to download image data for only cells user is
        // attempting to view - pg. 393
        
        let photo = photoDataSource.photos[indexPath.row]
        
        // Download the image data, which could take some time
        store.fetchImage(for: photo, completion: { (result) -> Void in
            
            // The index path for the photo might have changed between the
            // time the request started and finished, so find the most
            // interesting index path
            
            guard let photoIndex = self.photoDataSource.photos.index(of: photo),
                case let .success(image) = result else {
                    return
            }
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            
            // When the request finishes, only update the cell if it's still visible
            if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                cell.update(with: image)
            }
        })
    }
    
    private func updateDataSource() { // pg. 413
        // Method that will update data source with all the photos
        
        store.fetchAllPhotos {
            (photosResults) in
            
            switch photosResults {
            case let .success(photos):
                self.photoDataSource.photos = photos
            case .failure:
                self.photoDataSource.photos.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
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
