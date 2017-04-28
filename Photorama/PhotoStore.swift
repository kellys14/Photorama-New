//
//  PhotoStore.swift
//  Photorama
//
//  Created by Sean Melnick Kelly on 4/24/17.
//  Copyright © 2017 Sean Melnick Kelly. All rights reserved.
//

import UIKit
import CoreData

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

enum TagsResult { // pg. 423
    case success([Tag])
    case failure(Error)
}

class PhotoStore {
    // Class responsible for initiating the web service requests
    
    let imageStore = ImageStore() // Property for an ImageStore - pg. 397
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Photorama")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error setting up Core Data (\(error)")
            }
        }
        return container
    }()
    
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
            
            var result = self.processPhotosRequest(data: data, error: error) // pg. 368
            
            if case .success = result {
                do {
                    try self.persistentContainer.viewContext.save()
                } catch let error {
                    result = .failure(error)
                }
            }
            
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
        
        return FlickrAPI.photos(fromJSON: jsonData, into: persistentContainer.viewContext)
    }
    
    func fetchImage(for photo: Photo, completion: @escaping (ImageResult) -> Void) { // pg. 371, 372, 407
        // Method to download image data
        
        guard let photoKey = photo.photoID else { // pg. 407
            preconditionFailure("Photo expected to have a photoID.")
        }
        if let image = imageStore.image(forKey: photoKey) { // pg. 397
            // Image Caching to prevent previously visible cells from
            // needing to be reloaded when scrolling
            OperationQueue.main.addOperation {
                completion(.success(image))
            }
        }
        
        guard let photoURL = photo.remoteURL else { // pg. 407
            preconditionFailure("Photo expected to have a remote URL.")
        }
        let request = URLRequest(url: photoURL as URL)
        
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
    
    func fetchAllPhotos(completion: @escaping (PhotosResult) -> Void ) { // pg. 413
        // Method that will fetch the Photo instances from the view context
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortByDateTaken = NSSortDescriptor(key: #keyPath(Photo.dateTaken), ascending: true)
        
        fetchRequest.sortDescriptors = [sortByDateTaken]
        
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allPhotos = try viewContext.fetch(fetchRequest)
                completion(.success(allPhotos))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchAllTags(completion: @escaping (TagsResult) -> Void) { // pg. 423
        // Method that fetches all the tags from the view content
        
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)
        fetchRequest.sortDescriptors = [sortByName]
        
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allTags = try fetchRequest.execute()
            } catch {
                completion(.failure(error))
            }
        }
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
