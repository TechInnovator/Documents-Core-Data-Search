//
//  DocumentViewController.swift
//  Documents Core Data
//
//  Created by Dale Musser on 7/9/18.
//  Copyright © 2018 Dale Musser. All rights reserved.
//

import UIKit

class DocumentViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    var document: Document?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = ""

        if let document = document {
            let name = document.getName()
            nameTextField.text = name
            contentTextView.text = document.getContent()
            title = name
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func save(_ sender: Any) {
        guard let name = nameTextField.text, name != "" else {
            print("A title is required. Document not saved.")
            return
        }
        
        let content = contentTextView.text
        
        if document == nil {
            // document doesn't exist, create new one
            document = Document(name: name, content: content)
        } else {
            // document exists, update existing one
            document?.update(name: name, content: content)
        }
        
        if let document = document {
            do {
                let managedContext = document.managedObjectContext
                try managedContext?.save()
            } catch {
                print("Context could not be saved")
            }
        } else {
            print("Document could not be created.")
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nameChanged(_ sender: Any) {
        title = nameTextField.text
    }
}
