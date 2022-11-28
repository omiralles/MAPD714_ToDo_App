//
//  TaskCardViewController.swift
//  MAPD714_ToDoApp
//
//  ViewController to display detailed task information
//  We can especify a name, description a schedule time-hour and
//  mark a task as done or not.
//

import UIKit
import SQLite3

class TaskCardViewController: UIViewController {

    @IBOutlet var nameLabel: UITextField!
    @IBOutlet var texDescription: UITextView!
    @IBOutlet weak var scheduleSwitch: UISwitch!
    @IBOutlet weak var doneSwitch: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var texNotes: UITextView!
    
    //Store original data to retrieve in case of cancelation
    struct taskInfo {
        var name: String
        var description: String
        var date: Date
        var notes: String
        var done: Bool
        var schelude: Bool
    }
    var oldTaskInfo = [taskInfo]()
    
    let userDefaults = UserDefaults.standard
    
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.nameLabel.layer.borderWidth = CGFloat(3)
        self.texDescription.layer.borderWidth = CGFloat(3)
        self.texNotes.layer.borderWidth = CGFloat(3)
        self.scheduleSwitch.isOn = false
        self.doneSwitch.isOn = false
        
        let listKey = userDefaults.integer(forKey: "ListId")
        let taskKey = userDefaults.integer(forKey: "taskId")
        
        datePicker.isUserInteractionEnabled = false
        
        if ((listKey != 0) && (taskKey != 0)) {
            fetchData()
        }

    }
    
    @IBAction func ScheduleChange(_ sender: Any) {
        if scheduleSwitch.isOn {
            datePicker.isUserInteractionEnabled = true
        }
        else {
            datePicker.isUserInteractionEnabled = false
        }
    }
    
    //Get the task data from database
    func fetchData() {
        let listKey = userDefaults.integer(forKey: "ListId")
        let taskKey = userDefaults.integer(forKey: "taskId")
        
        let selectStatmentString = "SELECT TaskName, TaskDay, TaskHour, TaskIsDone,  TaskIsSchedule, TaskDescription, TaskNotes FROM Tasks WHERE ListId = '\(listKey)' AND TaskId = '\(taskKey)';"
        
        var selectStatmentQuery: OpaquePointer?
        
        if sqlite3_prepare_v2(dbQueque, selectStatmentString, -1, &selectStatmentQuery, nil) == SQLITE_OK {
            
            while sqlite3_step(selectStatmentQuery) == SQLITE_ROW {
                nameLabel.text = String(String(cString: sqlite3_column_text(selectStatmentQuery, 0)))
                
                let day = String(String(cString: sqlite3_column_text(selectStatmentQuery, 1)))
                let hour = String(String(cString: sqlite3_column_text(selectStatmentQuery, 2)))
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                let value = formatter.date(from: "\(day) \(hour)")
                datePicker.date = value ?? Date.now
                
                var onOff = String(String(cString: sqlite3_column_text(selectStatmentQuery, 3)))
                if onOff == "0" {
                    doneSwitch.isOn = false
                }
                else {
                    doneSwitch.isOn = true
                }
                
                onOff = String(String(cString: sqlite3_column_text(selectStatmentQuery, 4)))
                if onOff == "0" {
                    scheduleSwitch.isOn = false
                    datePicker.isUserInteractionEnabled = false
                }
                else {
                    scheduleSwitch.isOn = true
                    datePicker.isUserInteractionEnabled = true
                }
                
                texDescription.text = String(String(cString: sqlite3_column_text(selectStatmentQuery, 5)))
                texNotes.text = String(String(cString: sqlite3_column_text(selectStatmentQuery, 6)))
                
                oldTaskInfo.append(taskInfo(name: nameLabel.text ?? "", description: texDescription.text ?? "", date: datePicker.date, notes: texNotes.text ?? "", done: doneSwitch.isOn, schelude: scheduleSwitch.isOn))
            }
            
            sqlite3_finalize(selectStatmentQuery)
        }
    }
    
    //Insert/update data from the task
    @IBAction func SaveTask(_ sender: Any) {
        let listKey = userDefaults.integer(forKey: "ListId")
        let taskKey = userDefaults.integer(forKey: "taskId")
        var newTaskKey: Int = 1
        
        //Create alert
        let createOkCancelAlert = UIAlertController(title: "Save list data", message: "Are you sure do you want save \(nameLabel.text ?? "") data?", preferredStyle: UIAlertController.Style.alert)
        
        //Action message Ok/Cancel
        let OkAction = UIAlertAction(title: "Ok", style: .default) { [self] (action:UIAlertAction!) in
            
            //Retrive the last id or asign a new value
            if (taskKey == 0){
                let selectStatmentString = "SELECT MAX(TaskId) FROM Tasks WHERE ListId = '\(listKey)';"
                
                var selectStatmentQuery: OpaquePointer?
                
                if sqlite3_prepare_v2(dbQueque, selectStatmentString, -1, &selectStatmentQuery, nil) == SQLITE_OK {
                    
                    while sqlite3_step(selectStatmentQuery) == SQLITE_ROW {
                        newTaskKey = Int(Int(sqlite3_column_int(selectStatmentQuery, 0)))
                        newTaskKey += 1
                    }
                    
                    sqlite3_finalize(selectStatmentQuery)
                }
            }
            else {
                newTaskKey = taskKey
            }
            
            //Insertion
            let insertStatmentString = "INSERT INTO Tasks (TaskId, ListId, TaskName, TaskDescription, TaskIsDone, TaskIsSchedule, TaskDay, TaskHour, TaskNotes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);"
            
            var insertStatmentQuery: OpaquePointer?
            
            if (sqlite3_prepare_v2(dbQueque, insertStatmentString, -1, &insertStatmentQuery, nil)) == SQLITE_OK {
                sqlite3_bind_int(insertStatmentQuery, 1, Int32(newTaskKey))
                sqlite3_bind_int(insertStatmentQuery, 2, Int32(listKey))
                sqlite3_bind_text(insertStatmentQuery, 3, nameLabel.text ?? "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(insertStatmentQuery, 4, texDescription.text ?? "", -1, SQLITE_TRANSIENT)
                if doneSwitch.isOn {
                    sqlite3_bind_int(insertStatmentQuery, 5, Int32(1))
                }
                else {
                    sqlite3_bind_int(insertStatmentQuery, 5, Int32(0))
                }
                if scheduleSwitch.isOn {
                    sqlite3_bind_int(insertStatmentQuery, 6, Int32(1))
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    let day = formatter.string(from: datePicker.date)
                    
                    sqlite3_bind_text(insertStatmentQuery, 7, day , -1, SQLITE_TRANSIENT)
                    
                    formatter.dateFormat = "HH:mm"
                    let hour = formatter.string(from: datePicker.date)
                    
                    sqlite3_bind_text(insertStatmentQuery, 8, hour , -1, SQLITE_TRANSIENT)
                }
                else {
                    sqlite3_bind_int(insertStatmentQuery, 6, Int32(0))
                    sqlite3_bind_text(insertStatmentQuery, 7, "" , -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(insertStatmentQuery, 8, "" , -1, SQLITE_TRANSIENT)
                }
                
                sqlite3_bind_text(insertStatmentQuery, 9, texNotes.text ?? "" , -1, SQLITE_TRANSIENT)
                
                if (sqlite3_step(insertStatmentQuery)) == SQLITE_DONE
                {
                    print("Succesfull insert")
                    
                    //Create alert
                    let createAlert = UIAlertController(title: "Task created", message: "Your task \(nameLabel.text ?? "") has been created", preferredStyle: UIAlertController.Style.alert)
                    
                    // add an action (button)
                    createAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    
                    // show the alert
                    self.present(createAlert, animated: true, completion: nil)
                }
                else {
                    //Update data if the record already exist
                    let updateStatmentString = "UPDATE Tasks SET TaskName = ?, TaskDescription = ?, TaskIsDone = ?, TaskIsSchedule = ?, TaskDay = ?, TaskHour = ?, TaskNotes = ? WHERE ListId = '\(listKey)' AND TaskId = \(taskKey);"
                    
                    var updateStatmentQuery: OpaquePointer?
                    
                    if (sqlite3_prepare_v2(dbQueque, updateStatmentString, -1, &updateStatmentQuery, nil)) == SQLITE_OK {
                        sqlite3_bind_text(updateStatmentQuery, 1, nameLabel.text ?? "", -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(updateStatmentQuery, 2, texDescription.text ?? "", -1, SQLITE_TRANSIENT)
                        if doneSwitch.isOn {
                            sqlite3_bind_int(updateStatmentQuery, 3, Int32(1))
                        }
                        else {
                            sqlite3_bind_int(updateStatmentQuery, 3, Int32(0))
                        }
                        if scheduleSwitch.isOn {
                            sqlite3_bind_int(updateStatmentQuery, 4, Int32(1))
                            
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd"
                            let day = formatter.string(from: datePicker.date)
                            
                            sqlite3_bind_text(updateStatmentQuery, 5, day , -1, SQLITE_TRANSIENT)
                            
                            formatter.dateFormat = "HH:mm"
                            let hour = formatter.string(from: datePicker.date)
                            
                            sqlite3_bind_text(updateStatmentQuery, 6, hour , -1, SQLITE_TRANSIENT)
                        }
                        else {
                            sqlite3_bind_int(updateStatmentQuery, 4, Int32(0))
                            sqlite3_bind_text(updateStatmentQuery, 5, "" , -1, SQLITE_TRANSIENT)
                            sqlite3_bind_text(updateStatmentQuery, 6, "" , -1, SQLITE_TRANSIENT)
                        }
                        
                        sqlite3_bind_text(updateStatmentQuery, 7, texNotes.text ?? "", -1, SQLITE_TRANSIENT)
                        
                        
                        if (sqlite3_step(updateStatmentQuery)) == SQLITE_DONE
                        {
                            print("Succesfull updated")
                            
                            //Create alert
                            let updateAlert = UIAlertController(title: "Task updated", message: "Your task \(nameLabel.text ?? "") has been updated", preferredStyle: UIAlertController.Style.alert)
                            
                            // add an action (button)
                            updateAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            
                            // show the alert
                            self.present(updateAlert, animated: true, completion: nil)
                        }
                        else {
                            print("Error inserting or updating")
                        }
                    }
                }
                
                sqlite3_finalize(insertStatmentQuery)
            }
        }
        createOkCancelAlert.addAction(OkAction)
        
        //Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) in
            //Retrieve original info
            self.nameLabel.text = self.oldTaskInfo[0].name
            self.texDescription.text = self.oldTaskInfo[0].description
            self.texNotes.text = self.oldTaskInfo[0].notes
            self.doneSwitch.isOn = self.oldTaskInfo[0].done
            self.scheduleSwitch.isOn = self.oldTaskInfo[0].schelude
            self.datePicker.date = self.oldTaskInfo[0].date
            
            //Create alert
            let cancelationAlert = UIAlertController(title: "Operation canceled", message: "The operation has been canceled", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            cancelationAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(cancelationAlert, animated: true, completion: nil)
        }
        createOkCancelAlert.addAction(cancelAction)
        
        self.present(createOkCancelAlert, animated: true, completion: nil)
    }
    
    //Delete task
    @IBAction func DeleteTask(_ sender: Any) {
        let listKey = userDefaults.integer(forKey: "ListId")
        let taskKey = userDefaults.integer(forKey: "taskId")
        
        //Create alert
        let createOkCancelAlert = UIAlertController(title: "Save list data", message: "Are you sure do you want save \(nameLabel.text ?? "") data?", preferredStyle: UIAlertController.Style.alert)
        
        let OkAction = UIAlertAction(title: "Ok", style: .default) { [self] (action:UIAlertAction!) in
            
            let deleteStatmentString = "DELETE FROM Tasks WHERE ListId = '\(listKey)' AND TaskId = '\(taskKey)';"
            
            var deleteStatmentQuery: OpaquePointer?
            
            if sqlite3_prepare_v2(dbQueque, deleteStatmentString, -1, &deleteStatmentQuery, nil) == SQLITE_OK {
                
                if sqlite3_step(deleteStatmentQuery) == SQLITE_DONE
                {
                    print("Register deleted")
                    
                    //Create alert
                    let deleteAlert = UIAlertController(title: "Task deleted", message: "Your task \(nameLabel.text ?? "") has been deleted", preferredStyle: UIAlertController.Style.alert)
                    
                    // add an action (button)
                    deleteAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    
                    // show the alert
                    self.present(deleteAlert, animated: true, completion: nil)
                    
                    userDefaults.set(0, forKey: "taskId")
                    
                    nameLabel.text = ""
                    scheduleSwitch.isOn = false
                    doneSwitch.isOn = false
                    texDescription.text = ""
                    texNotes.text = ""
                }
                else {
                    print("Delete statment fail")
                }
                
                sqlite3_finalize(deleteStatmentQuery)
            }
        }
        createOkCancelAlert.addAction(OkAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) in
            
            //Create alert
            let cancelationAlert = UIAlertController(title: "Operation canceled", message: "The operation has been canceled", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            cancelationAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(cancelationAlert, animated: true, completion: nil)
        }
        createOkCancelAlert.addAction(cancelAction)
        
        self.present(createOkCancelAlert, animated: true, completion: nil)
    }
    
}
