//
//  TaskDetailViewController.swift
//  Todoey
//
//  Created by mohamed reda oumahdi on 08/04/2025.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class TaskDetailViewController: UIViewController {
    
    // MARK: - Properties
    let realm = try! Realm()
    var selectedCategory: Category?
    var taskToEdit: Item?
    
    // MARK: - Outlets
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var prioritySegmentControl: UISegmentedControl!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var timeEstimateTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        if let task = taskToEdit {
            populateTaskData(task)
        }
    }
    
    // MARK: - UI Setup
    func setupUI() {
        timeEstimateTextField.keyboardType = .numberPad
        dueDatePicker.datePickerMode = .dateAndTime
        dueDatePicker.minimumDate = Date()
    }
    
    func populateTaskData(_ task: Item) {
        taskNameTextField.text = task.name
        prioritySegmentControl.selectedSegmentIndex = task.priorityLevel - 1
        if let dueDate = task.dueDate {
            dueDatePicker.date = dueDate
        }
        timeEstimateTextField.text = "\(task.timeEstimate)"
    }
    
    // MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let taskName = taskNameTextField.text, !taskName.isEmpty else {
            showAlert(message: "Please enter a task name")
            return
        }
        
        if let task = taskToEdit {
            updateExistingTask(task)
        } else {
            createNewTask()
        }
        
        dismiss(animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - Task Operations
    func createNewTask() {
        if let currentCategory = selectedCategory {
            do {
                try realm.write {
                    let newItem = Item()
                    configureTask(newItem)
                    currentCategory.items.append(newItem)
                }
            } catch {
                print("Error creating new task: \(error)")
            }
        }
    }
    
    func updateExistingTask(_ task: Item) {
        do {
            try realm.write {
                configureTask(task)
            }
        } catch {
            print("Error updating task: \(error)")
        }
    }
    
    func configureTask(_ task: Item) {
        task.name = taskNameTextField.text ?? "New Task"
        task.priorityLevel = prioritySegmentControl.selectedSegmentIndex + 1
        task.dueDate = dueDatePicker.date
        task.timeEstimate = Int(timeEstimateTextField.text ?? "0") ?? 0
        
        if task.dateCreated == nil {
            task.dateCreated = Date()
        }
    }
    
    // MARK: - Helpers
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
