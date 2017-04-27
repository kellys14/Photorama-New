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
    
    let imageStore = ImageStore() // Property for an ImageStore - pg. 397
    
    private let session: URLSession = { // pg. 358
        // Creates an instance of the web session that holds properties/policies
        // for the given session
        
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func fetchInterestingPhotos(completion: @escaping (PhotosResult) -> Void) { // pg. 358, 362, 368
        // Method to create a URLRequest that connects to api.flickr.com and asks
        // for the list of interesting photos, then uses the URLSession to create
        // a URLSessionDataTask that transfers the request to the server
        
        let url = FlickrAPI.interestingPhotosURL
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let result = self.processPhotosRequest(data: data, error: error) // pg. 368
            
            // Chapter 20 Bronze Challenge Start **
            let responseInfo = response as! HTTPURLResponse
            print("StatusCode: \(responseInfo.statusCode)")
            print("HeaderField: \(responseInfo.allHeaderFields)")
            // Chapter 20 Bronze Challenge End
            
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
        
        let photoKey = photo.photoID
        if let image = imageStore.image(forKey: photoKey) { // pg. 397
            // Image Caching to prevent previously visible cells from
            // needing to be reloaded when scrolling
            OperationQueue.main.addOperation {
                completion(.success(image))
            }
        }
        
        let photoURL = photo.remoteURL
        let request = URLRequest(url: photoURL)
        
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let result = self.processImageRequest(data: data, error: error) // pg. 372
            
            if case let .success(image) = result { // pg. 397
                // Image caching continued
                self.imageStore.setImage(image, forKey: photoKey)
            }
            
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
    
    // Chap. 20 Silver Challenge **
    func fetchRecentPhotos(completion: @escaping (PhotosResult) -> Void) {
        // CH.20 SILVER: Method that follows the fetchInterestingPhotos method
        // setup, but requests the list of recent photos
        
        let url = FlickrAPI.recentPhotoURL
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let result = self.processPhotosRequest(data: data, error: error)
            
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    // Chap. 20 Silver End */
}
