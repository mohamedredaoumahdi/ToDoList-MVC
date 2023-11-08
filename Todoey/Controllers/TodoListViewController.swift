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

    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = itemArray?[indexPath.row] {
            cell.textLabel?.text = item.name
            cell.accessoryType = item.done ? .checkmark : .none
        }else {
            cell.textLabel?.text = "No Items Added"
        }
        return cell
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
    
    //MARK: - Add New Item
    
    
    @IBAction func addButtoPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default){
            (action) in
            if let currentCategory = self.selectedCategory {
                do{
                    try self.realm.write({
                        let newItem = Item()
                        newItem.name = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    })
                } catch {
                    print("Writing new Item to Realm Error : \(error)")
                }
                self.hasAnimated = false
                self.tableView.reloadData()
                
                
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cansel", style: .cancel)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
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


