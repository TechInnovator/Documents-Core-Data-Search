//
//  DocumentsViewController.swift
//  Documents Core Data
//
//  Created by Dale Musser on 7/9/18.
//  Copyright © 2018 Dale Musser. All rights reserved.
//

import UIKit
import CoreData

class DocumentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    @IBOutlet weak var documentsTableView: UITableView!
    
    let dateFormatter = DateFormatter()
    var documents = [Document]()
    var searchController : UISearchController?
    var selectedSearchScope = SearchScope.all

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Documents"

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        searchController = UISearchController(searchResultsController: nil)
        
        searchController?.searchResultsUpdater = self
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "Search Documents"
        
        //searchController.searchBar.searchBarStyle = .minimal
        navigationItem.searchController = searchController
        // alterantively the searchBar can be placed in the tableHeaderView of the Table View
        // documentsTableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        
        searchController?.searchBar.scopeButtonTitles = SearchScope.titles
        searchController?.searchBar.delegate = self
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
                switch (selectedSearchScope) {
                case .all:
                    fetchRequest.predicate = NSPredicate(format: "name contains[c] %@ OR content contains[c] %@", searchString, searchString)
                case .name:
                    fetchRequest.predicate = NSPredicate(format: "name contains[c] %@", searchString)
                case .content:
                    fetchRequest.predicate = NSPredicate(format: "content contains[c] %@", searchString)
                }
            }
            documents = try managedContext.fetch(fetchRequest)
            documentsTableView.reloadData()
        } catch {
            print("Fetch could not be performed")
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchString = searchController.searchBar.text {
            fetchDocuments(searchString: searchString)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        selectedSearchScope = SearchScope.scopes[selectedScope]
        if let searchString = searchController?.searchBar.text {
            fetchDocuments(searchString: searchString)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        self.searchController?.dismiss(animated: true, completion: {
            () in
            print("Did complete")
            self.searchController?.isActive = false
            
        })
        
        /*
        DispatchQueue.main.async {
            self.searchController?.isActive = false
            
            self.searchController?.dismiss(animated: true, completion: {
                () in
                print("Did complete")
            })
            
            //self.searchController.isActive = false
            // self.navigationController?.navigationBar.topItem?.title = "Documents"
            //self.navigationItem.titleView = nil
        }
        */
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
