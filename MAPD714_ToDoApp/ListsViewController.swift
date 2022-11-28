//
//  ListsViewController.swift
//  MAPD714_ToDoApp
//
//  View Controler to show To Do list for selected category.
//

import UIKit
import SQLite3

class ListsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var category: String?
    
    //List information to show in tableView
    struct listInfo {
        var id: Int
        var title: String
        var category: String
        var description: String
    }
    var thingsList = [listInfo]()
    var groceryList = [listInfo]()
    var homeList = [listInfo]()
    var shoppingList = [listInfo]()
    var customList = [listInfo]()
    
    //Get/Store search keys
    let userDefaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        userDefaults.set(category, forKey: "Category")
        
        //Retrieve information by category
        switch category {
        case "Things to do":
            fetchThingsData()
        case "Groceries":
            fetchGroceriesData()
        case "Home":
            fetchHomeData()
        case "Shopping":
            fetchShoppingData()
        default:
            fetchCustomData()
        }
        
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
    
    func fetchThingsData() {
        let selectStatmentString = "SELECT ListId, ListName, ListCategory, ListDescription FROM Lists WHERE ListCategory = 'Things to do';"
        
        var selectStatmentQuery: OpaquePointer?
        
        if sqlite3_prepare_v2(dbQueque, selectStatmentString, -1, &selectStatmentQuery, nil) == SQLITE_OK {
            
            while sqlite3_step(selectStatmentQuery) == SQLITE_ROW {
                thingsList.append(listInfo(id: Int(String(cString: sqlite3_column_text(selectStatmentQuery, 0))) ?? 0, title: String(String(cString: sqlite3_column_text(selectStatmentQuery, 1))), category: String(String(cString: sqlite3_column_text(selectStatmentQuery, 2))),                         description: String(String(cString: sqlite3_column_text(selectStatmentQuery, 3)))))
            }
            
            sqlite3_finalize(selectStatmentQuery)
        }
    }
    
    func fetchGroceriesData() {
        let selectStatmentString = "SELECT ListId, ListName, ListCategory, ListDescription FROM Lists WHERE ListCategory = 'Groceries';"
        
        var selectStatmentQuery: OpaquePointer?
        
        if sqlite3_prepare_v2(dbQueque, selectStatmentString, -1, &selectStatmentQuery, nil) == SQLITE_OK {
            
            while sqlite3_step(selectStatmentQuery) == SQLITE_ROW {
                groceryList.append(listInfo(id: Int(String(cString: sqlite3_column_text(selectStatmentQuery, 0))) ?? 0, title: String(String(cString: sqlite3_column_text(selectStatmentQuery, 1))), category: String(String(cString: sqlite3_column_text(selectStatmentQuery, 2))),                         description: String(String(cString: sqlite3_column_text(selectStatmentQuery, 3)))))
            }
            
            sqlite3_finalize(selectStatmentQuery)
        }
    }
    
    func fetchHomeData() {
        let selectStatmentString = "SELECT ListId, ListName, ListCategory, ListDescription FROM Lists WHERE ListCategory = 'Home';"
        
        var selectStatmentQuery: OpaquePointer?
        
        if sqlite3_prepare_v2(dbQueque, selectStatmentString, -1, &selectStatmentQuery, nil) == SQLITE_OK {
            
            while sqlite3_step(selectStatmentQuery) == SQLITE_ROW {
                homeList.append(listInfo(id: Int(String(cString: sqlite3_column_text(selectStatmentQuery, 0))) ?? 0, title: String(String(cString: sqlite3_column_text(selectStatmentQuery, 1))), category: String(String(cString: sqlite3_column_text(selectStatmentQuery, 2))),                      description: String(String(cString: sqlite3_column_text(selectStatmentQuery, 3)))))
            }
            
            sqlite3_finalize(selectStatmentQuery)
        }
    }
    
    func fetchShoppingData() {
        let selectStatmentString = "SELECT ListId, ListName, ListCategory, ListDescription FROM Lists WHERE ListCategory = 'Shopping';"
        
        var selectStatmentQuery: OpaquePointer?
        
        if sqlite3_prepare_v2(dbQueque, selectStatmentString, -1, &selectStatmentQuery, nil) == SQLITE_OK {
            
            while sqlite3_step(selectStatmentQuery) == SQLITE_ROW {
                shoppingList.append(listInfo(id: Int(String(cString: sqlite3_column_text(selectStatmentQuery, 0))) ?? 0, title: String(String(cString: sqlite3_column_text(selectStatmentQuery, 1))), category: String(String(cString: sqlite3_column_text(selectStatmentQuery, 2))),                        description: String(String(cString: sqlite3_column_text(selectStatmentQuery, 3)))))
            }
            
            sqlite3_finalize(selectStatmentQuery)
        }
    }
    
    func fetchCustomData() {
        let selectStatmentString = "SELECT ListId, ListName, ListCategory, ListDescription FROM Lists WHERE ListCategory = 'Custom';"
        
        var selectStatmentQuery: OpaquePointer?
        
        if sqlite3_prepare_v2(dbQueque, selectStatmentString, -1, &selectStatmentQuery, nil) == SQLITE_OK {
            
            while sqlite3_step(selectStatmentQuery) == SQLITE_ROW {
                customList.append(listInfo(id: Int(String(cString: sqlite3_column_text(selectStatmentQuery, 0))) ?? 0, title: String(String(cString: sqlite3_column_text(selectStatmentQuery, 1))), category: String(String(cString: sqlite3_column_text(selectStatmentQuery, 2))),                         description: String(String(cString: sqlite3_column_text(selectStatmentQuery, 3)))))
            }
            
            sqlite3_finalize(selectStatmentQuery)
        }
    }
    
    //Delete all the list
    func clearLists() {
        thingsList.removeAll()
        groceryList.removeAll()
        homeList.removeAll()
        shoppingList.removeAll()
        customList.removeAll()
    }
    
}

extension ListsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Send information on tap a category
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailList") as! DetailListViewController
        
        //Store the list ID and the pass the list name
        switch category {
        case "Things to do":
            userDefaults.set(thingsList[indexPath.row].id, forKey: "ListId")
            vc.title = "\(thingsList[indexPath.row].title)"
        case "Groceries":
            userDefaults.set(groceryList[indexPath.row].id, forKey: "ListId")
            vc.title = "\(groceryList[indexPath.row].title)"
        case "Home":
            userDefaults.set(homeList[indexPath.row].id, forKey: "ListId")
            vc.title = "\(homeList[indexPath.row].title)"
        case "Shopping":
            userDefaults.set(shoppingList[indexPath.row].id, forKey: "ListId")
            vc.title = "\(shoppingList[indexPath.row].title)"
        case "Custom":
            userDefaults.set(customList[indexPath.row].id, forKey: "ListId")
            vc.title = "\(customList[indexPath.row].title)"
        default:
            vc.title = "New List"
        }
        
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
        switch category {
        case "Things to do":
            return thingsList.count
        case "Groceries":
            return groceryList.count
        case "Home":
            return homeList.count
        case "Shopping":
            return shoppingList.count
        case "Custom":
            return customList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Display the information of a category list in the table. Use of a custom cell type.
        let cell = Bundle(for:CardListTableViewCell.self).loadNibNamed("CardListTableViewCell", owner: self,options:nil)?.first as! CardListTableViewCell
        
        switch category {
        case "Things to do":
            cell.titleLabel.text = thingsList[indexPath.row].title
            cell.descLabel.text = thingsList[indexPath.row].description
        case "Groceries":
            cell.titleLabel.text = groceryList[indexPath.row].title
            cell.descLabel.text = groceryList[indexPath.row].description
        case "Home":
            cell.titleLabel.text = homeList[indexPath.row].title
            cell.descLabel.text = homeList[indexPath.row].description
        case "Shopping":
            cell.titleLabel.text = shoppingList[indexPath.row].title
            cell.descLabel.text = shoppingList[indexPath.row].description
        case "Custom":
            cell.titleLabel.text = customList[indexPath.row].title
            cell.descLabel.text = customList[indexPath.row].description
        default:
            cell.titleLabel.text = ""
            cell.descLabel.text = ""
        }
        
        //Cell button edit list press
        cell.editListBtnPress = {[unowned self] in
            let vc = storyboard?.instantiateViewController(withIdentifier: "DetailList") as! DetailListViewController
            
            //Store the list ID and the pass the list name
            switch category {
            case "Things to do":
                userDefaults.set(thingsList[indexPath.row].id, forKey: "ListId")
                vc.title = "\(thingsList[indexPath.row].title)"
            case "Groceries":
                userDefaults.set(groceryList[indexPath.row].id, forKey: "ListId")
                vc.title = "\(groceryList[indexPath.row].title)"
            case "Home":
                userDefaults.set(homeList[indexPath.row].id, forKey: "ListId")
                vc.title = "\(homeList[indexPath.row].title)"
            case "Shopping":
                userDefaults.set(shoppingList[indexPath.row].id, forKey: "ListId")
                vc.title = "\(shoppingList[indexPath.row].title)"
            case "Custom":
                userDefaults.set(customList[indexPath.row].id, forKey: "ListId")
                vc.title = "\(customList[indexPath.row].title)"
            default:
                vc.title = "New List"
            }
            
            clearLists()
            
            navigationController?.pushViewController(vc, animated: true)
        }
        
        //Cell view task button
        cell.viewTasksBtnPress = {[unowned self] in
            let vc = storyboard?.instantiateViewController(withIdentifier: "taskList") as! TaskListViewController
            
            //Store the list ID and the pass the list name
            switch category {
            case "Things to do":
                userDefaults.set(thingsList[indexPath.row].id, forKey: "ListId")
                vc.title = "\(thingsList[indexPath.row].title) Tasks"
            case "Groceries":
                userDefaults.set(groceryList[indexPath.row].id, forKey: "ListId")
                vc.title = "\(groceryList[indexPath.row].title) Tasks"
            case "Home":
                userDefaults.set(homeList[indexPath.row].id, forKey: "ListId")
                vc.title = "\(homeList[indexPath.row].title) Tasks"
            case "Shopping":
                userDefaults.set(shoppingList[indexPath.row].id, forKey: "ListId")
                vc.title = "\(shoppingList[indexPath.row].title) Tasks"
            case "Custom":
                userDefaults.set(customList[indexPath.row].id, forKey: "ListId")
                vc.title = "\(customList[indexPath.row].title) Tasks"
            default:
                vc.title = "Tasks List"
            }
            
            clearLists()
            
            navigationController?.pushViewController(vc, animated: true)
        }
        
        return cell
    }
}

