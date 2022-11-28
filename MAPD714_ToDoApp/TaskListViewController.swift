//
//  TaskListViewController.swift
//  MAPD714_ToDoApp
//
//  ViewController to show To Do list tasks.
//  Use a tableView with custom cell.
//

import UIKit
import SQLite3

class TaskListViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    //Task list information to whow in the tableView
    struct taskInfo {
        var image: UIImage
        var name: String
        var day: String
        var hour: String
        var done: Bool
        var id: Int
        var description: String
    }
    var tasksList = [taskInfo]()
    
    let userDefaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tasksList.removeAll()
        
        //Fetch Data
        fetchData()
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Delegate and datasource for tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
    }
    
    @IBAction func NewTaskBtn(_ sender: Any) {
        //Load the view to create a new task
        let vc = storyboard?.instantiateViewController(withIdentifier: "TaskCardView") as! TaskCardViewController
        
        tasksList.removeAll()
        userDefaults.set("", forKey: "taskId")
        
        vc.title = "New Task"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //Assign data to the task list
    func fetchData() {
        let listKey = userDefaults.integer(forKey: "ListId")
        
        let selectStatmentString = "SELECT TaskName, TaskDay, TaskHour, TaskIsDone, TaskId, TaskDescription FROM Tasks WHERE ListId = '\(listKey)';"
        
        var selectStatmentQuery: OpaquePointer?
        
        if sqlite3_prepare_v2(dbQueque, selectStatmentString, -1, &selectStatmentQuery, nil) == SQLITE_OK {
            
            while sqlite3_step(selectStatmentQuery) == SQLITE_ROW {
                if (Int(String(cString: sqlite3_column_text(selectStatmentQuery, 3))) == 0) {
                    tasksList.append(taskInfo(image: UIImage(named: "Unchecked")!, name: String(String(cString: sqlite3_column_text(selectStatmentQuery, 0))),
                                           day: String(String(cString: sqlite3_column_text(selectStatmentQuery, 1))) ,
                                              hour: String(String(cString: sqlite3_column_text(selectStatmentQuery, 2))), done: Bool(String(cString: sqlite3_column_text(selectStatmentQuery, 3))) ?? false, id: Int(String(cString: sqlite3_column_text(selectStatmentQuery, 4))) ?? 0, description: String(String(cString: sqlite3_column_text(selectStatmentQuery, 5)))))
                }
                else {
                    tasksList.append(taskInfo(image: UIImage(named: "checked")!, name: String(String(cString: sqlite3_column_text(selectStatmentQuery, 0))),
                                           day: String(String(cString: sqlite3_column_text(selectStatmentQuery, 1))) ,
                                              hour: String(String(cString: sqlite3_column_text(selectStatmentQuery, 2))), done: Bool(String(cString: sqlite3_column_text(selectStatmentQuery, 3))) ?? false, id: Int(String(cString: sqlite3_column_text(selectStatmentQuery, 4))) ?? 0, description: String(String(cString: sqlite3_column_text(selectStatmentQuery, 5)))))
                }
                    
            }
            
            sqlite3_finalize(selectStatmentQuery)
        }
    }
    
}

extension TaskListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        userDefaults.set(tasksList[indexPath.row].id, forKey: "taskId")
        
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
        cell.descriptionTask.text = tasksList[indexPath.row].description
        
        if (tasksList[indexPath.row].day != "") && (tasksList[indexPath.row].hour != "") {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let taskDay = formatter.date(from: "\(tasksList[indexPath.row].day) \(tasksList[indexPath.row].hour)") ?? Date.now
            
            //If task is expired show in red
            if (taskDay < Date.now) {
                cell.hourTask.textColor = UIColor.red
                cell.dayTask.textColor = UIColor.red
            }
        }
        
        return cell
    }
}
