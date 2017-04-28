//
//  TagsDataSource.swift
//  Photorama
//
//  Created by Sean Melnick Kelly on 4/28/17.
//  Copyright © 2017 Sean Melnick Kelly. All rights reserved.
//

import UIKit
import CoreData

class TagsDataSource: NSObject, UITableViewDataSource {
    // Class thats responsible for displaying the list of tags
    // in the table view
    
    var tags: [Tag] = []
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        // Method that tells the data source how many rows to be given
        
        return tags.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell { 
        // Method that asks the data source for a cell to insert at a
        // particular location
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell",
                                                 for: indexPath)
        
        let tag = tags[indexPath.row]
        cell.textLabel?.text = tag.name
        
        return cell
    }
}
