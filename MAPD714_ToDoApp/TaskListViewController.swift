//
//  TaskListViewController.swift
//  MAPD714_ToDoApp
//
// Student Name: Carlos Hernandez Galvan
// Student ID: 301290263
//
// Student Name: Oscar Miralles Fernandez
// Student ID: 301250756
//
//  ViewController to show To Do list tasks.
//  Use a tableView with custom cell.
//
//  Class to show the to do list tasks

import UIKit
//import SQLite3

class TaskListViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    //Task list information to whow in the tableView
    var tasksList: [TaskList] = []
    
    // Database instance
    var db:DBManagement = DBManagement()
    
    let userDefaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let listKey = userDefaults.integer(forKey: "ListId")
        
        //Remove data
        tasksList.removeAll()
        
        //Fetch Data
        tasksList = db.fetchTaskListData(listKey: listKey)
        
        
        //Reload tableView
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
    
    //Function to delete a task
    func deleteTask(listId: Int, taskId: Int, name: String)
    {
        //Create alert
        let createOkCancelAlert = UIAlertController(title: "Delete task", message: "Are you sure do you want delete \(name) task?", preferredStyle: UIAlertController.Style.alert)
        
        let OkAction = UIAlertAction(title: "Ok", style: .default) { [self] (action:UIAlertAction!) in
            //Delete task
            if (db.deleteTask(listId: listId, taskId: taskId))
            {
                self.tasksList.removeAll()
                self.tasksList = db.fetchTaskListData(listKey: listId)
                self.tableView.reloadData()
            }
        }
        createOkCancelAlert.addAction(OkAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) in
            
        }
        createOkCancelAlert.addAction(cancelAction)
        
        self.present(createOkCancelAlert, animated: true, completion: nil)
    }
    
    //Function to update the task status
    func updateTask(listId: Int, taskId: Int, value: Int)
    {
        //Update task
        if (db.updateTask(listId: listId, taskId: taskId, value: value))
        {
                self.tasksList.removeAll()
                self.tasksList = db.fetchTaskListData(listKey: listId)
                self.tableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksList.count
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //Get the keys
        let listKey = userDefaults.integer(forKey: "ListId")
        
        //Show check/uncheck action on slide
        if (tasksList[indexPath.row].done != 0){
            let unCheck = UIContextualAction(style: .normal, title: "Uncheck") { (action, view, completion) in
                //Update task undone
                self.updateTask(listId: listKey, taskId: self.tasksList[indexPath.row].id, value: 0)
                
                completion(true)
            }
            unCheck.image = UIImage(named: "Unchecked")
            unCheck.backgroundColor = .systemYellow
            
            //Add delete action on complete slide
            let delete = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
               //Delete a task
                self.deleteTask(listId: listKey, taskId: self.tasksList[indexPath.row].id, name: self.tasksList[indexPath.row].name)
                
                completion(true)
            }
            delete.image = UIImage(named: "bin")
            delete.backgroundColor = .systemYellow
            
            let config = UISwipeActionsConfiguration(actions: [delete, unCheck])
            config.performsFirstActionWithFullSwipe = true
            
            return config
        }
        else {
            let check = UIContextualAction(style: .normal, title: "Check") { (action, view, completion) in
                //Update task done
                self.updateTask(listId: listKey, taskId: self.tasksList[indexPath.row].id, value: 1)
                completion(true)
            }
            check.image = UIImage(named: "checked")
            check.backgroundColor = .systemYellow
            
            // Add delete action on complete slide
            let delete = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
                //Delete task
                self.deleteTask(listId: listKey, taskId: self.tasksList[indexPath.row].id, name: self.tasksList[indexPath.row].name)
                
                completion(true)
            }
            delete.image = UIImage(named: "bin")
            delete.backgroundColor = .systemYellow
            
            let config = UISwipeActionsConfiguration(actions: [delete, check])
            config.performsFirstActionWithFullSwipe = true
            
            return config
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //Action to go to edit task information on slide
        let edit = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            self.userDefaults.set(self.tasksList[indexPath.row].id, forKey: "taskId")
            
            //Load the view to display detailed task information.
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TaskCardView") as! TaskCardViewController
            
            
            self.navigationController?.pushViewController(vc, animated: true)
            
            completion(true)
        }
        edit.image = UIImage(named: "edit_icon")
        edit.backgroundColor =  .systemBlue
     
        let config = UISwipeActionsConfiguration(actions: [edit])
        config.performsFirstActionWithFullSwipe = true
     
        return config
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Load information in our custom cell.
        let cell = Bundle(for:CardTaskTableViewCell.self).loadNibNamed("CardTaskTableViewCell", owner: self,options:nil)?.first as! CardTaskTableViewCell
        
        cell.imageTask.image = UIImage(named: tasksList[indexPath.row].image)
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
