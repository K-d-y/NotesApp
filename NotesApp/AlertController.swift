//
//  AlertController.swift
//  NotesApp
//
//  Created by Dmitry Knauer on 12.01.2023.
//

import UIKit

extension UIAlertController {
    
    static func createAlertController(withTitle title: String) -> UIAlertController {
        UIAlertController(title: title, message: "Write down your note", preferredStyle: .alert)
    }
    
    func action(note: Note?, completion: @escaping (String) -> Void) {
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let newValue = self.textFields?.first?.text else { return }
            guard !newValue.isEmpty else { return }
            completion(newValue)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        
        addAction(saveAction)
        addAction(cancelAction)
        addTextField { textField in
            textField.placeholder = "Note"
            textField.text = note?.title
        }
    }
}
