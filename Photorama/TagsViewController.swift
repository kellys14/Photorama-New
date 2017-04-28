//
//  TagsViewController.swift
//  Photorama
//
//  Created by Sean Melnick Kelly on 4/28/17.
//  Copyright © 2017 Sean Melnick Kelly. All rights reserved.
//

import UIKit
import CoreData


class TagsViewController: UITableViewController {
    // Class to display a list of all the tags. The user will be able
    // to see and select the tags that are associated with a specific
    // photo. The user can also add new tags from this screen
    
    var store: PhotoStore!
    var photo: Photo!
    
    var selectedIndexPaths = [IndexPath]()
    
    let tagDataSource = TagsDataSource() // pg. 424
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets the dataSource for the table view to be an instance
        // of TagsDataSource - pg. 424
        tableView.dataSource = tagDataSource
        tableView.delegate = self // pg. 425
        
        updateTags()
    }
    
    func updateTags() { // pg. 424
        // Method to fetch the tags and associate them with the tags
        // property on the data source
        
        store.fetchAllTags {
            (tagsResult) in
            
            switch tagsResult {
            case let .success(tags):
                self .tagDataSource.tags = tags
                
                guard let photoTags = self.photo.tags as? Set<Tag> else {
                    return
                }
                
                for tag in photoTags {
                    // Adds appropriate index paths to the selectedIndexPaths array
                    if let index = self.tagDataSource.tags.index(of: tag) {
                        let indexPath = IndexPath(row: index, section: 0)
                        self.selectedIndexPaths.append(indexPath)
                    }
                }
            case let .failure(error):
                print("Error fetching tags: \(error)")
            }
            
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    // MARK: Delegates - 2 methods below to handle selecting and displaying checkmarks
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // pg. 426
        // Method tells the delegate that the specifc row is now selected
        
        let tag = tagDataSource.tags[indexPath.row]
        
        if let index = selectedIndexPaths.index(of: indexPath) {
            selectedIndexPaths.remove(at: index)
            photo.removeFromTags(tag)
        } else {
            selectedIndexPaths.append(indexPath)
            photo.addToTags(tag)
        }
        
        do {
            try store.persistentContainer.viewContext.save()
        } catch {
            print("Core Data save failed: \(error).")
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) { // pg. 426
        // Method tells the delegate the table view whether or not to
        // add a checkmark for a cell in a particular row
        
        if selectedIndexPaths.index(of: indexPath) != nil {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
    }
    
    // MARK: Actions - Methods for Bar Button Items
    @IBAction func done(_ sender: UIBarButtonItem) { // pg. 429
        // Action method to dismiss Tags view controller
        
        presentingViewController?.dismiss(animated: true,
                                          completion: nil)
    }
    
    @IBAction func addNewTag(_ sender: UIBarButtonItem) { // pg. 429
        // Action method to add a new tag to the set for a photo
        
        let alertController = UIAlertController(title: "Add Tag", message: nil,
                                                preferredStyle: .alert)
        
        alertController.addTextField {
            (textField) -> Void in
            textField.placeholder = "tag name"
            textField.autocapitalizationType = .words
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) {
            (action) -> Void in
            
            if let tagName = alertController.textFields?.first?.text {
                // Inserts a new Tag into the context. Then save the context,
                // update the list of tags, and reload the table view section
                let context = self.store.persistentContainer.viewContext
                let newTag = NSEntityDescription.insertNewObject(forEntityName: "Tag",
                                                                 into: context)
                newTag.setValue(tagName, forKey: "name")
                
                do {
                    try self.store.persistentContainer.viewContext.save()
                } catch let error {
                    print("Core Data save failed: \(error)")
                }
                self.updateTags()
            }
            
        }
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}
