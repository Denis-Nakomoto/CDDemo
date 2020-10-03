//
//  TaskListViewController.swift
//  CoreDataDemoApp
//
//  Created by Alexey Efimov on 30.09.2020.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private let cellID = "cell"
    private var tasks: [Task] = []
    var coreDataCoordinator = StorageManager.shared
    var context = StorageManager.shared.persistentContainer.viewContext
    private var editingMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coreDataCoordinator.fetchData(context: context) { tasks in
            self.tasks = tasks
        }
        tableView.reloadData()
    }
    
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addTask() {
        showAlert(with: "New Task", and: "What do you want to do?", nil)
    }
    
    private func showAlert(with title: String, and message: String, _ indexPath: IndexPath?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if self.editingMode {
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = self.tasks[indexPath!.row].name
            })
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                let task = self.tasks[indexPath!.row]
                let newValue = alert.textFields?.first?.text
                task.setValue(newValue, forKey: "name")
                self.coreDataCoordinator.saveContext(self.context)
                self.tableView.reloadData()
                self.editingMode = false
            }
            alert.addAction(saveAction)
        } else {
            alert.addTextField()
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                self.coreDataCoordinator.saveData(task, self.context) { task in
                    self.tasks.append(task)
                }
                let cellIndex = IndexPath(row: self.tasks.count - 1, section: 0)
                self.tableView.insertRows(at: [cellIndex], with: .automatic)
            }
            alert.addAction(saveAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(cancelAction)
        present(alert, animated: true)
        editingMode = false
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let task = self.tasks[indexPath.row]
        if editingStyle == .delete{
            coreDataCoordinator.deleteData(task, self.context)
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editingMode = true
        showAlert(with: "Edit Task", and: "What do you want to do now?", indexPath)
    }
}
