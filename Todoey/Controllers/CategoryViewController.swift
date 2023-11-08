//
//  CategoryViewController.swift
//  Todoey
//
//  Created by mohamed reda oumahdi on 18/10/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categoryArray : Results<Category>?
    var hasAnimated = true
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }
    
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "The List of Categories is Empty"        
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
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default){
            (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            self.Save(category: newCategory,animated: false)
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
    
    func Save(category : Category, animated : Bool){
        self.hasAnimated = animated
        do {
            try realm.write({
                realm.add(category)
            })
        } catch {
            print("Error save cotennt :  \(error)")
        }
        self.tableView.reloadData()
        
    }
    
    //MARK: - LoadItems Method
    
    func loadItems(){
        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    //MARK: - Delete Data
    
    override func updateModel(at indexPath: IndexPath) {
        if let selectedCategory = self.categoryArray?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(selectedCategory)
                }
            } catch {
                print("Error deleting the row \(error)")
            }
        }
    }
}
