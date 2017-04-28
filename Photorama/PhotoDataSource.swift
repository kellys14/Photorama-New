//
//  PhotoDataSource.swift
//  Photorama
//
//  Created by Sean Melnick Kelly on 4/25/17.
//  Copyright © 2017 Sean Melnick Kelly. All rights reserved.
//

import UIKit

class PhotoDataSource: NSObject, UICollectionViewDataSource {
    // Class responsible for responding to data source questions 
    // and it will be reusable as necesary
    
   // var photos: [Photo] = []
    var photos = [Photo]()
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { // pg. 383
        // Data source callback that asks how many cells to display

        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell { // pg. 383
        // Data source callback that asks for UICollectionViewCell to
        // display for a given index path
        
        let identifier = "PhotoCollectionViewCell"
        let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                               for: indexPath) as! PhotoCollectionViewCell
        
        return cell
    }
}
