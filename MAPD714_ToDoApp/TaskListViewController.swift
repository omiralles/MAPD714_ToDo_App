//
//  TaskListViewController.swift
//  MAPD714_ToDoApp
//
//  ViewController to show To Do list tasks.
//  Use a tableView with custom cell.
//

import UIKit

class TaskListViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    struct taskInfo {
        var image: UIImage
        var name: String
        var day: String
        var hour: String
        var done: Bool
    }
    var tasksList = [taskInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Demo information
        tasksList.append(taskInfo(image: UIImage(named: "checked")!, name: "Test task 1", day: "11/01/2022", hour: "09:00 AM", done: true))
        tasksList.append(taskInfo(image: UIImage(named: "checked")!, name: "Test task 2", day: "11/01/2022", hour: "10:00 AM", done: true))
        tasksList.append(taskInfo(image: UIImage(named: "Unchecked")!, name: "Test task 3", day: "11/01/2022", hour: "09:00 AM", done: false))
        
        //Delegate and datasource for tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        
        //Add navigation button to create a new Task
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .done, target: self, action: #selector(NewTask))
    }
    
    @objc func NewTask() {
        //Load the view to create a new task
        let vc = storyboard?.instantiateViewController(withIdentifier: "TaskCardView") as! TaskCardViewController
        
        vc.title = "New Task"
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension TaskListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Load the view to display detailed task information.
        let vc = storyboard?.instantiateViewController(withIdentifier: "TaskCardView") as! TaskCardViewController
        
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension TaskListViewController: UITableViewDataSource {
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Load demo information in our custom cell.
        let cell = Bundle(for:CardTaskTableViewCell.self).loadNibNamed("CardTaskTableViewCell", owner: self,options:nil)?.first as! CardTaskTableViewCell
        
        cell.imageTask.image = tasksList[indexPath.row].image
        cell.nameTask.text = tasksList[indexPath.row].name
        cell.hourTask.text = tasksList[indexPath.row].hour
        cell.dayTask.text = tasksList[indexPath.row].day
        
        return cell
    }
}
