//
//  ViewController.swift
//  NotesApp
//
//  Created by Dmitry Knauer on 11.01.2023.
//

import UIKit

protocol NoteViewControllerDelegate {
    func reloadData()
}

class NoteListViewController: UITableViewController {
    
    private let cellID = "cell"
    private var notes: [Note] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchData()
    }
    
    private func setupView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        title = "Note List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewNote)
        )
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewNote() {
//        let noteVC = NoteViewController()
//        noteVC.delegate = self
//        present(noteVC, animated: true)
        showAlert()
    }
    
    private func save(noteName: String) {
        StorageManager.shared.create(noteName) { note in
            self.notes.append(note)
            self.tableView.insertRows(
                at: [IndexPath(row: self.notes.count - 1, section: 0)],
                with: .automatic
            )
        }
    }

    private func fetchData() {
        StorageManager.shared.fetchData { result in
            switch result {
            case .success(let notes):
                self.notes = notes
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension NoteListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let note = notes[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = note.title
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NoteListViewController {
    // Edit note
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let note = notes[indexPath.row]
        showAlert(note: note) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    // Delete note
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let note = notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            StorageManager.shared.delete(note)
        }
    }
}

// MARK: - Alert Controller
extension NoteListViewController {
    private func showAlert(note: Note? = nil, completion: (() -> Void)? = nil) {
        
        let title = note != nil ? "Update Note" : "New Note"
        let alert = UIAlertController.createAlertController(withTitle: title)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 0.1670374586)
        alert.action(note: note) { noteName in
            if let note = note, let completion = completion {
                StorageManager.shared.update(note, newName: noteName)
                completion()
            } else {
                self.save(noteName: noteName)
            }
        }
        
        present(alert, animated: true)
    }
}
