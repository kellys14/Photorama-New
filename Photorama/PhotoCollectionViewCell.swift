//
//  PhotoCollectionViewCell.swift
//  Photorama
//
//  Created by Sean Melnick Kelly on 4/27/17.
//  Copyright © 2017 Sean Melnick Kelly. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    // Class for the collection view of images
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    func update(with image: UIImage?) {
        // Method to show spinner when the cell is not displaying an image
        
        if let imageToDisplay = image {
            spinner.stopAnimating()
            imageView.image = imageToDisplay
        } else {
            spinner.startAnimating()
            imageView.image = nil
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        update(with: nil)
    }
    
    override func prepareForReuse() {
        // When a cell is being reused
        super.prepareForReuse()
        
        update(with: nil)
    }
}
