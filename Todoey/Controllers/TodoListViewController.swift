//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

class TodoListViewController: SwipeTableViewController {
    let realm = try! Realm()
    
    var selectedCategory : Category?{
        didSet{
            loadItems()
        }
    }
    var itemArray : Results<Item>?
    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathExtension("ItemsList.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var hasAnimated = true


    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func sortButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Sort Tasks", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "By Priority (High to Low)", style: .default) { _ in
            self.itemArray = self.selectedCategory?.items.sorted(byKeyPath: "priorityLevel", ascending: false)
            self.tableView.reloadData()
        })
        
        alert.addAction(UIAlertAction(title: "By Due Date (Earliest First)", style: .default) { _ in
            self.itemArray = self.selectedCategory?.items.sorted(byKeyPath: "dueDate", ascending: true)
            self.tableView.reloadData()
        })
        
        alert.addAction(UIAlertAction(title: "By Time Estimate", style: .default) { _ in
            self.itemArray = self.selectedCategory?.items.sorted(byKeyPath: "timeEstimate", ascending: false)
            self.tableView.reloadData()
        })
        
        alert.addAction(UIAlertAction(title: "By Creation Date", style: .default) { _ in
            self.itemArray = self.selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
            self.tableView.reloadData()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }

    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = itemArray?[indexPath.row] {
            // Base task name
            var displayText = item.name
            
            // Add priority indicator
            switch item.priorityLevel {
            case 3:
                displayText = "❗️ " + displayText  // High priority
                cell.textLabel?.textColor = UIColor.red
            case 2:
                displayText = "❕ " + displayText   // Medium priority
                cell.textLabel?.textColor = UIColor.orange
            default:
                cell.textLabel?.textColor = UIColor.black
            }
            
            // Add time estimate if available
            if item.timeEstimate > 0 {
                if item.timeEstimate < 60 {
                    displayText += " (\(item.timeEstimate)m)"
                } else {
                    let hours = item.timeEstimate / 60
                    let mins = item.timeEstimate % 60
                    if mins == 0 {
                        displayText += " (\(hours)h)"
                    } else {
                        displayText += " (\(hours)h \(mins)m)"
                    }
                }
            }
            
            cell.textLabel?.text = displayText
            cell.accessoryType = item.done ? .checkmark : .none
            
            // Add due date as subtitle
            if let dueDate = item.dueDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                cell.detailTextLabel?.text = "Due: \(formatter.string(from: dueDate))"
                
                // Highlight overdue tasks
                let now = Date()
                if dueDate < now {
                    cell.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 1.0)
                } else if dueDate.timeIntervalSince(now) < 86400 { // Less than 24 hours
                    cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.9, alpha: 1.0)
                } else {
                    cell.backgroundColor = UIColor.white
                }
            } else {
                cell.detailTextLabel?.text = nil
                cell.backgroundColor = UIColor.white
            }
        } else {
            cell.textLabel?.text = "No Items Added"
            cell.detailTextLabel?.text = nil
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }

    // Format time estimate from minutes to hours and minutes
    func formatTimeEstimate(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(mins)m"
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        if hasAnimated {
            cell.alpha = 0
                UIView.animate(withDuration: 0.3, delay: 0.5 * Double(indexPath.row), animations: {
                    cell.alpha = 1
                })
        }
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedItem = itemArray?[indexPath.row] {
            do {
                self.hasAnimated = false
                try self.realm.write({
                    selectedItem.done = !selectedItem.done
                })
            } catch {
                print("Error Updating done Value \(error)")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTaskDetail" {
            if let destinationVC = segue.destination as? TaskDetailViewController {
                destinationVC.selectedCategory = selectedCategory
                
                // If editing existing task (optional)
                if let indexPath = tableView.indexPathForSelectedRow {
                    destinationVC.taskToEdit = itemArray?[indexPath.row]
                }
            }
        }
    }
    
    //MARK: - Add New Item
    
    
    @IBAction func addButtoPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Task", message: "", preferredStyle: .alert)
        
        var nameTextField = UITextField()
        var prioritySegment = UISegmentedControl(items: ["Low", "Medium", "High"])
        var dueDatePicker = UIDatePicker()
        var timeEstimateTextField = UITextField()
        
        // Configure UI elements
        prioritySegment.selectedSegmentIndex = 0
        dueDatePicker.datePickerMode = .dateAndTime
        timeEstimateTextField.placeholder = "Time estimate (minutes)"
        timeEstimateTextField.keyboardType = .numberPad
        
        // Create custom view to hold our elements
        let customView = UIStackView()
        customView.axis = .vertical
        customView.spacing = 10
        customView.addArrangedSubview(prioritySegment)
        customView.addArrangedSubview(dueDatePicker)
        customView.addArrangedSubview(timeEstimateTextField)
        
        // Set up the main task name field
        alert.addTextField { (textField) in
            textField.placeholder = "New task name"
            nameTextField = textField
        }
        
        // Add custom view to alert
        alert.view.addSubview(customView)
        
        // Position custom view
        customView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 80),
            customView.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 20),
            customView.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -20)
        ])
        
        // Resize alert
        alert.view.bounds = CGRect(x: 0, y: 0, width: 300, height: 350)
        
        // Add actions
        let addAction = UIAlertAction(title: "Add Task", style: .default) { (_) in
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.name = nameTextField.text ?? "New Task"
                        newItem.dateCreated = Date()
                        newItem.dueDate = dueDatePicker.date
                        newItem.priorityLevel = prioritySegment.selectedSegmentIndex + 1
                        newItem.timeEstimate = Int(timeEstimateTextField.text ?? "0") ?? 0
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error writing new task: \(error)")
                }
                self.hasAnimated = false
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    //MARK: - Model Manupulation Maethods
    
    //MARK: - Save Method
    
    func Save(newItem : Item){
        do {
            try realm.write({
                realm.add(newItem)
            })
        } catch {
            print("Error save cotennt :  \(error)")
        }
        self.tableView.reloadData()
        
    }
    
    //MARK: - LoadItems Method
    
    func loadItems(){
        itemArray = selectedCategory?.items.sorted(byKeyPath: "dateCreated",ascending: true)
        tableView.reloadData()
    }
    
    //MARK: - Delete Method
    
    override func updateModel(at indexPath: IndexPath) {
        if let selectedItem = self.itemArray?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(selectedItem)
                }
            } catch {
                print("Error deleting the row \(error)")
            }
        }
    }
    
    
}

//MARK: - SearchBar Methods

extension TodoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        itemArray = itemArray?.filter("name CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated",ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    
}


