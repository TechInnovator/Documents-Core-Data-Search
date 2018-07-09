//
//  DocumentsViewController.swift
//  Documents Core Data
//
//  Created by Dale Musser on 7/9/18.
//  Copyright © 2018 Dale Musser. All rights reserved.
//

import UIKit
import CoreData

class DocumentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    @IBOutlet weak var documentsTableView: UITableView!
    
    let dateFormatter = DateFormatter()
    
    var documents = [Document]()
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Documents"

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Documents"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchDocuments(searchString: "")
    }
    
    func fetchDocuments(searchString: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()
        
        do {
            if (searchString != "") {
                fetchRequest.predicate = NSPredicate(format: "name contains[c] %@ OR content contains[c] %@", searchString, searchString)
            }
            
            documents = try managedContext.fetch(fetchRequest)

            documentsTableView.reloadData()
        } catch {
            print("Fetch could not be performed")
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContentForSearchText(searchText)
            documentsTableView.reloadData()
        }
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        //let searchString = searchText.lowercased()
        let searchString = searchText
        
        fetchDocuments(searchString: searchString)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentCell", for: indexPath)
        
        if let cell = cell as? DocumentTableViewCell {
            let document = documents[indexPath.row]
            cell.nameLabel.text = document.getName()
            cell.sizeLabel.text = String(document.getSize()) + " bytes"
            
            if let modifiedDate = document.getModifiedDate() {
                cell.modifiedLabel.text = dateFormatter.string(from: modifiedDate)
            } else {
                cell.modifiedLabel.text = "unknown"
            }
            
        }
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DocumentViewController,
           let segueIdentifier = segue.identifier, segueIdentifier == "existingDocument",
           let row = documentsTableView.indexPathForSelectedRow?.row {
                destination.document = documents[row]
        }
    }
    
    func deleteDocument(at indexPath: IndexPath) {
        let document = documents[indexPath.row]
        
        if let managedObjectContext = document.managedObjectContext {
            managedObjectContext.delete(document)
            
            do {
                try managedObjectContext.save()
                self.documents.remove(at: indexPath.row)
                documentsTableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                print("Delete failed.")
                documentsTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteDocument(at: indexPath)
        }
    }
}
