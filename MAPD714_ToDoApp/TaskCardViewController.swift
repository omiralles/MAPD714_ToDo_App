//
//  TaskCardViewController.swift
//  MAPD714_ToDoApp
//
// Student Name: Carlos Hernandez Galvan
// Student ID: 301290263
//
// Student Name: Oscar Miralles Fernandez
// Student ID: 301250756
//
//  ViewController to display detailed task information
//  We can especify a name, description a schedule time-hour and
//  mark a task as done or not.
//
//  Class to show detailed task information

import UIKit

class TaskCardViewController: UIViewController {

    @IBOutlet var nameLabel: UITextField!
    @IBOutlet var texDescription: UITextView!
    @IBOutlet weak var scheduleSwitch: UISwitch!
    @IBOutlet weak var doneSwitch: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var texNotes: UITextView!
    
    //Store original data to retrieve in case of cancelation
    var oldTaskInfo: [TaskListDetail] = []
    
    // Database instance
    var db:DBManagement = DBManagement()
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Default component status
        self.nameLabel.layer.borderWidth = CGFloat(3)
        self.texDescription.layer.borderWidth = CGFloat(3)
        self.texNotes.layer.borderWidth = CGFloat(3)
        self.scheduleSwitch.isOn = false
        self.doneSwitch.isOn = false
        datePicker.isUserInteractionEnabled = false
        
        // Get keys
        let listKey = userDefaults.integer(forKey: "ListId")
        let taskKey = userDefaults.integer(forKey: "taskId")
        
        if ((listKey != 0) && (taskKey != 0)) {
            // Get data from database
            fetchData()
        }

    }
    
    //Fucntion to enable/disable datePicker
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
        
        self.oldTaskInfo = self.db.fetchTaskListDetailData(listKey: listKey, taskKey: taskKey)
        
        if (!self.oldTaskInfo.isEmpty)
        {
            nameLabel.text = self.oldTaskInfo[0].name
            
            datePicker.date = self.oldTaskInfo[0].date ?? Date.now
            
            doneSwitch.isOn = self.oldTaskInfo[0].done
            if (!self.oldTaskInfo[0].schelude)
            {
                scheduleSwitch.isOn = false
                datePicker.isUserInteractionEnabled = false
            }
            else
            {
                scheduleSwitch.isOn = true
                datePicker.isUserInteractionEnabled = true
            }
            
            texDescription.text = self.oldTaskInfo[0].description
            texNotes.text = self.oldTaskInfo[0].notes
        }
    }
    
    //Insert/update data from the task
    @IBAction func SaveTask(_ sender: Any) {
        let listKey = userDefaults.integer(forKey: "ListId")
        let taskKey = userDefaults.integer(forKey: "taskId")
        var newTaskKey: Int = 1
        
        //Create alert
        let createOkCancelAlert = UIAlertController(title: "Save task data", message: "Are you sure do you want save \(nameLabel.text ?? "") data?", preferredStyle: UIAlertController.Style.alert)
        
        //Action message Ok/Cancel
        let OkAction = UIAlertAction(title: "Ok", style: .default) { [self] (action:UIAlertAction!) in
            
            //Retrive the last id or asign a new value
            newTaskKey = self.db.getLasTasktKey(listKey: listKey, taskKey: taskKey)
            
            var day = ""
            var hour = ""
            
            //Insertion
            if (scheduleSwitch.isOn)
            {
                // Format date and hour
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                day = formatter.string(from: datePicker.date)
                
                formatter.dateFormat = "HH:mm"
                hour = formatter.string(from: datePicker.date)
            }
            
            if (self.db.insertTaskDatail(listKey: listKey, taskKey: newTaskKey, name: nameLabel.text ?? "", description: texDescription.text ?? "", done: doneSwitch.isOn, schedule: scheduleSwitch.isOn, day: day, hour: hour, notes: texNotes.text ?? ""))
            {
                //Create alert
                let createAlert = UIAlertController(title: "Task created", message: "Your task \(nameLabel.text ?? "") has been created", preferredStyle: UIAlertController.Style.alert)
                
                // add an action (button)
                createAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                // show the alert
                self.present(createAlert, animated: true, completion: nil)
            }
            else
            {
                //Update data if the record already exist
                if (scheduleSwitch.isOn)
                {
                    // Format date and hour
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    day = formatter.string(from: datePicker.date)
                    
                    formatter.dateFormat = "HH:mm"
                    hour = formatter.string(from: datePicker.date)
                }
                
                if (self.db.updateTaskDatail(listKey: listKey, taskKey: newTaskKey, name: nameLabel.text ?? "", description: texDescription.text ?? "", done: doneSwitch.isOn, schedule: scheduleSwitch.isOn, day: day, hour: hour, notes: texNotes.text ?? ""))
                {
                        //Create alert
                        let updateAlert = UIAlertController(title: "Task updated", message: "Your task \(nameLabel.text ?? "") has been updated", preferredStyle: UIAlertController.Style.alert)
                        
                        // add an action (button)
                        updateAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        
                        // show the alert
                        self.present(updateAlert, animated: true, completion: nil)
                }
            }
        }
        createOkCancelAlert.addAction(OkAction)
        
        //Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) in
            //Retrieve original info
            if (!self.oldTaskInfo.isEmpty){
                self.nameLabel.text = self.oldTaskInfo[0].name
                self.texDescription.text = self.oldTaskInfo[0].description
                self.texNotes.text = self.oldTaskInfo[0].notes
                self.doneSwitch.isOn = self.oldTaskInfo[0].done
                self.scheduleSwitch.isOn = self.oldTaskInfo[0].schelude
                self.datePicker.date = self.oldTaskInfo[0].date ?? Date.now
            }
            
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
        let createOkCancelAlert = UIAlertController(title: "Delete task data", message: "Are you sure do you want to delete \(nameLabel.text ?? "") data?", preferredStyle: UIAlertController.Style.alert)
        
        let OkAction = UIAlertAction(title: "Ok", style: .default) { [self] (action:UIAlertAction!) in
            //Delete task register
            if (self.db.deleteTaskDatail(listKey: listKey, taskKey: taskKey))
            {
                //Create alert
                let deleteAlert = UIAlertController(title: "Task deleted", message: "Your task \(nameLabel.text ?? "") has been deleted", preferredStyle: UIAlertController.Style.alert)
                
                // add an action (button)
                deleteAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                // show the alert
                self.present(deleteAlert, animated: true, completion: nil)
                
                // Clear keys and components
                userDefaults.set(0, forKey: "taskId")
                
                nameLabel.text = ""
                scheduleSwitch.isOn = false
                doneSwitch.isOn = false
                texDescription.text = ""
                texNotes.text = ""
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
