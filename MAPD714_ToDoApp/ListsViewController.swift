//
//  ListsViewController.swift
//  MAPD714_ToDoApp
//
// Student Name: Carlos Hernandez Galvan
// Student ID: 301290263
//
// Student Name: Oscar Miralles Fernandez
// Student ID: 301250756
//
//  View Controler to show To Do list for selected category.
//
//  Class to show the different to do list by category

import UIKit
//import SQLite3

class ListsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var category: String?
    // Database instance
    var db:DBManagement = DBManagement()
    
    //Store list information
    var toDoShowList: [ToDoList] = []
    
    //Get/Store search keys
    let userDefaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        userDefaults.set(category, forKey: "Category")
        
        //Retrieve information by category
        toDoShowList = db.fetchTodoListData(category: category ?? "")
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Delegate and datasource for tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
    }
    
    @IBAction func NewListAction(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailList") as! DetailListViewController
        
        userDefaults.set(0, forKey: "ListId")
        
        clearLists()
        
        vc.title = "New List"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //Delete all the list
    func clearLists() {
        toDoShowList.removeAll()
    }
    
}

extension ListsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Send information on tap a category
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailList") as! DetailListViewController
        
        //Store the list ID and the pass the list name
        userDefaults.set(toDoShowList[indexPath.row].id, forKey: "ListId")
        vc.title = "\(toDoShowList[indexPath.row].title)"
        
        clearLists()
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ListsViewController: UITableViewDataSource {
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Display the list of a category
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoShowList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Display the information of a category list in the table. Use of a custom cell type.
        let cell = Bundle(for:CardListTableViewCell.self).loadNibNamed("CardListTableViewCell", owner: self,options:nil)?.first as! CardListTableViewCell
        
        cell.titleLabel.text = toDoShowList[indexPath.row].title
        cell.descLabel.text = toDoShowList[indexPath.row].description
        
        //Cell button edit list press
        cell.editListBtnPress = {[unowned self] in
            let vc = storyboard?.instantiateViewController(withIdentifier: "DetailList") as! DetailListViewController
            
            //Store the list ID and the pass the list name
            userDefaults.set(toDoShowList[indexPath.row].id, forKey: "ListId")
            vc.title = "\(toDoShowList[indexPath.row].title)"
            
            clearLists()
            
            navigationController?.pushViewController(vc, animated: true)
        }
        
        //Cell view task button
        cell.viewTasksBtnPress = {[unowned self] in
            let vc = storyboard?.instantiateViewController(withIdentifier: "taskList") as! TaskListViewController
            
            //Store the list ID and the pass the list name
            userDefaults.set(toDoShowList[indexPath.row].id, forKey: "ListId")
            vc.title = "\(toDoShowList[indexPath.row].title) Tasks"
            
            clearLists()
            
            navigationController?.pushViewController(vc, animated: true)
        }
        
        return cell
    }
}

