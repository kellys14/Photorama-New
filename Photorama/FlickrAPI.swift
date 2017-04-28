//
//  FlickrAPI.swift
//  Photorama
//
//  Created by Sean Melnick Kelly on 4/24/17.
//  Copyright © 2017 Sean Melnick Kelly. All rights reserved.
//

import Foundation
import CoreData

enum FlickrError: Error {
    case invalidJSONData
}

enum Method: String {
    case interestingPhotos = "flickr.interestingness.getList"
    case recentPhotos = "flickr.photos.getRecent" // Chap 20 Silver Challenge **
}

struct FlickrAPI {
    
    private static let baseURLString = "https://api.flickr.com/services/rest"
    private static let apiKey = "a6d819499131071f158fd740860a5a88" // To authenticate w/ web service - pg. 356
    
    private static let dateFormatter: DateFormatter = { // pg. 366
        // Instance of DateFormatter to take datetaken string into instance Data
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    private static func flickrURL(method: Method, parameters: [String: String]?) -> URL { // pg. 355,356
    
        var components = URLComponents(string: baseURLString)!
        
        var queryItems = [URLQueryItem]()
        
        let baseParams = [ // pg. 356
            "method": method.rawValue,
            "format" : "json",
            "nojsoncallback" : "1",
            "api_key": apiKey
        ]
        
        for (key, value) in baseParams { // pg. 356
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParams = parameters { // pg. 355
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        components.queryItems = queryItems
        
        return components.url!
    }
    
    static var interestingPhotosURL: URL { // pg. 355
        return flickrURL(method: .interestingPhotos, parameters: ["extras": "url_h, date_taken"])
    }
    
    static var recentPhotoURL: URL { // Attempting Chap. 20 Silver **
        return flickrURL(method: .recentPhotos, parameters: ["extras": "url_h, date_taken"])
    }
    
    static func photos(fromJSON data: Data,
                       into context: NSManagedObjectContext) -> PhotosResult { // pg. 364
        // Method that takes in an instance of Data and uses the JSONSerialization
        // class to convert the data into basic foundation objects
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard // pg. 366
            let jsonDictionary = jsonObject as? [AnyHashable:Any],
            let photos = jsonDictionary["photos"] as? [String: Any],
            let photosArray = photos["photo"] as? [[String:Any]] else {
                
                // The JSON structure doesn't match our expectations
                return .failure(FlickrError.invalidJSONData)
            }
            
            var finalPhotos = [Photo]()
            for photoJSON in photosArray { // pg. 367
                if let photo = photo(fromJSON: photoJSON, into: context) {
                    finalPhotos.append(photo)
                }
            }
            
            if finalPhotos.isEmpty && !photosArray.isEmpty { // pg. 367
                // We weren't able to parse any of the photos
                // Maybe the JSON format for photos has changed
                return .failure(FlickrError.invalidJSONData)
            }
            return .success(finalPhotos)
        } catch let error {
            return .failure(error)
        }
    }
    
    private static func photo(fromJSON json: [String : Any],
                              into context: NSManagedObjectContext) -> Photo? { // pg. 366
        // Method to parse a JSON dictionary into a Photo instance
        guard
            let photoID = json["id"] as? String,
            let title = json["title"] as? String,
            let dateString = json["datetaken"] as? String,
            let photoURLString = json["url_h"] as? String,
            let url = URL(string: photoURLString),
            let dateTaken = dateFormatter.date(from: dateString) else {
            
                // Don't have enough information to construct a Photo
                return nil
        }
        
        // pg. 414 start
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Photo.photoID)) == \(photoID)")
        fetchRequest.predicate = predicate
        
        var fetchedPhotos: [Photo]?
        context.performAndWait {
            fetchedPhotos = try? fetchRequest.execute()
        }
        if let existingPhoto = fetchedPhotos?.first {
            return existingPhoto
        } // pg. 414 end
        
        // Tried with L photo, maybe try M photo
        var photo: Photo!
        context.performAndWait {
            photo = Photo(context: context)
            photo.title = title
            photo.photoID = photoID
            photo.remoteURL = url as NSURL
            photo.dateTaken = dateTaken as NSDate
            photo.viewCount = 0 // Chapter 22 Bronze **
            
        }
        return photo
    }
}
