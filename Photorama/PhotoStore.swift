//
//  PhotoStore.swift
//  Photorama
//
//  Created by Sean Melnick Kelly on 4/24/17.
//  Copyright © 2017 Sean Melnick Kelly. All rights reserved.
//

import UIKit

enum ImageResult { // pg. 371
    case success(UIImage)
    case failure(Error)
}

enum PhotoError: Error { // pg. 371
    case imageCreationError
}

enum PhotosResult { // pg. 364
    case success([Photo])
    case failure(Error)
}

class PhotoStore {
    
    private let session: URLSession = { // pg. 358
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func fetchInterestingPhotos(completion: @escaping (PhotosResult) -> Void) { // pg. 358, 362, 368
        let url = FlickrAPI.interestingPhotosURL
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let result = self.processPhotosRequest(data: data, error: error) // pg. 368
            OperationQueue.main.addOperation {
                completion(result) // pg. 368
            }
        }
        task.resume()
    }
    
    private func processPhotosRequest(data: Data?, error: Error?) -> PhotosResult { // pg. 368
        // Method that will process JSON data that is returned from the web request
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        return FlickrAPI.photos(fromJSON: jsonData)
    }
    
    func fetchImage(for photo: Photo, completion: @escaping (ImageResult) -> Void) { // pg. 371, 372
        // Method to download image data
        
        let photoURL = photo.remoteURL
        let request = URLRequest(url: photoURL)
        
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let result = self.processImageRequest(data: data, error: error) // pg. 372
            OperationQueue.main.addOperation { // pg. 374
                completion(result) // pg. 372
            }
        }
        task.resume()
        
    }
    
    private func processImageRequest(data: Data?, error: Error?) -> ImageResult { // pg. 372
        // Method that processes data from the web service request into an image
        guard
            let imageData = data,
            let image = UIImage(data: imageData) else {
                
                // Couldn't create an image
                if data == nil {
                    return .failure(error!)
                } else {
                    return .failure(PhotoError.imageCreationError)
                }
        }
        return .success(image)
    }
}
