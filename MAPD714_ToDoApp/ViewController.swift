//
//  ViewController.swift
//  MAPD714_ToDoApp
//
// Student Name: Carlos Hernandez Galvan
// Student ID: 301290263
//
// Student Name: Oscar Miralles Fernandez
// Student ID: 301250756
//
// First UI shows the presentation screen with somo categories to create
// a To Do list.
// We have created a tableView with custom cells for this porpose.
// We also have a navigte controller to navigate between the different screens.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    struct category {
        var name: String
        var image: UIImage
    }
    var categories = [category]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Favorites"
    
        //Delegate and datasource for tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        
        //Categoires added to the screen
        categories.append(category(name: "Things to do", image: UIImage(named: "Accept-icon")!))
        categories.append(category(name: "Groceries", image: UIImage(named: "Steak-icon")!))
        categories.append(category(name: "Home", image: UIImage(named: "home")!))
        categories.append(category(name: "Shopping", image: UIImage(named: "shop-icon")!))
        categories.append(category(name: "Custom", image: UIImage(named: "custom-reports-icon")!))
        
    }
    
}

extension ViewController: UITableViewDelegate {
    
    //Navigate to the listView sending the category selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ListsView") as! ListsViewController
        vc.title = "\(categories[indexPath.row].name) Lists"
        vc.category = categories[indexPath.row].name
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Use of the custom cell created
        let cell = Bundle(for:CardTableViewCell.self).loadNibNamed("CardTableViewCell", owner: self,options:nil)?.first as! CardTableViewCell
        
        cell.categoryName.text = categories[indexPath.row].name
        cell.categoryImage.image = categories[indexPath.row].image
        
        return cell
    }
}


