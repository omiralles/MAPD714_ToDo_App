//
//  ListsViewController.swift
//  MAPD714_ToDoApp
//
//  View Controler to show To Do list for selected category.
//

import UIKit

class ListsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var category: String?
    
    struct listInfo {
        var title: String
        var category: String
        var description: String
    }
    var thingsList = [listInfo]()
    var groceryList = [listInfo]()
    var homeList = [listInfo]()
    var shoppingList = [listInfo]()
    var customList = [listInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Delegate and datasource for tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        
        //Demo information added
        thingsList.append(listInfo(title: "Home work", category: "Things to do" ,description: "Class Assignments"))
        thingsList.append(listInfo(title: "Travel to Quebec", category: "Things to do" ,description: "Things to do before go to Quebec"))
        
        groceryList.append(listInfo(title: "Lunch food", category: "Grocery" ,description: "Things to buy to make the lunch"))
        
        customList.append(listInfo(title: "Mechanic", category: "Custom" , description: "Mechanic appointmet"))
        customList.append(listInfo(title: "Exam preparation", category: "Custom" , description: "Things to prepare the exam"))
        customList.append(listInfo(title: "Concert", category: "Custom" , description: "Buy concert things"))
        
        //Add navigation button to create a new list
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .done, target: self, action: #selector(NewList))
        
    }
    
    @objc func NewList() {
        //Function to navigate to the new list view
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailList") as! DetailListViewController
        
        vc.title = "New List"
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ListsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Send information on tap a category
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailList") as! DetailListViewController
        switch category {
        case "Things to do":
            vc.title = "\(thingsList[indexPath.row].title)"
        case "Groceries":
            vc.title = "\(groceryList[indexPath.row].title)"
        case "Home":
            vc.title = "\(homeList[indexPath.row].title)"
        case "Shopping":
            vc.title = "\(shoppingList[indexPath.row].title)"
        case "Custom":
            vc.title = "\(customList[indexPath.row].title)"
        default:
            vc.title = "New List"
        }
        
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
        
        return cell
    }
}

