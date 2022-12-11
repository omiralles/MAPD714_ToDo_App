//
//  DetailListViewController.swift
//  MAPD714_ToDoApp
//
// Student Name: Carlos Hernandez Galvan
// Student ID: 301290263
//
// Student Name: Oscar Miralles Fernandez
// Student ID: 301250756
//
//  ViewController to show detailed list information.
//  Here you can specify name description and category.
//
//  Class to show the detailed list data

import UIKit
//import SQLite3

class DetailListViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var titleLabel: UITextField!
    @IBOutlet var texDescription: UITextView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var pickerViewH: UIPickerView!
    
    // Database instance
    var db:DBManagement = DBManagement()
    
    //Original list info to restore in caso of cancelation
    var toDoDetailList: [ToDoList] = []
    
    //Category list
    var list = ["Things to do", "Groceries", "Home", "Sopping", "Custom"]
    var pickerRow: Int?
    
    //Get/Store search keys
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Delegate and datasource for pickerViews
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.pickerViewH.delegate = self
        self.pickerViewH.dataSource = self

        //Elements border configuration
        self.pickerView.layer.borderWidth = CGFloat(3)
        self.texDescription.layer.borderWidth = CGFloat(3)
        self.titleLabel.layer.borderWidth = CGFloat(3)
        
        //Get keys
        let listKey = userDefaults.integer(forKey: "ListId")
        let category = userDefaults.string(forKey: "Category")
        
        //Select correct category
        var position: Int?
        for i in (0...list.count - 1){
            if list[i] == category {
                position = i
            }
        }
        pickerViewH.selectRow(position ?? 0, inComponent: 0, animated: false)
        
        if listKey != 0 {
            //Retrieve Data
            toDoDetailList = db.fetchTodoListDetailData(listKey: listKey)
            if(!toDoDetailList.isEmpty) {
                // Fecth information in components
                titleLabel.text = toDoDetailList[0].title
                texDescription.text = toDoDetailList[0].description
            }
        }
        
        //Button to acces to list tasks
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "View Tasks", style: .done, target: self, action: #selector(ViewTasks))
    
    }
    
    //Insert/Update data
    @IBAction func SaveList(_ sender: Any) {
        let listKey = userDefaults.integer(forKey: "ListId")
        var newListKey: Int = 1
        
        //Create alert
        let createOkCancelAlert = UIAlertController(title: "Save list data", message: "Are you sure do you want save \(titleLabel.text ?? "") data?", preferredStyle: UIAlertController.Style.alert)
        
        let OkAction = UIAlertAction(title: "Ok", style: .default) { [self] (action:UIAlertAction!) in
            
            //Find the last id or create a new
            newListKey = db.getLastKey(listKey: listKey)
            
            //Insertion
            if (db.insertToDoList(title: self.titleLabel.text ?? "", category: self.list[pickerRow ?? 0], description: self.texDescription.text ?? "", newListKey: newListKey))
            {
                
                //Create alert
                let createAlert = UIAlertController(title: "List created", message: "Your list \(titleLabel.text ?? "") has been created", preferredStyle: UIAlertController.Style.alert)
                
                // add an action (button)
                createAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                
                // show the alert
                self.present(createAlert, animated: true, completion: nil)
            }
            else {
                //Update record
                if (db.updateToDoList(title: self.titleLabel.text ?? "", category: self.list[pickerRow ?? 0], description: self.texDescription.text ?? "", newListKey: newListKey))
                {
                    //Create alert
                    let updateAlert = UIAlertController(title: "List updated", message: "Your list \(titleLabel.text ?? "") has been updated", preferredStyle: UIAlertController.Style.alert)
                    
                    // add an action (button)
                    updateAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    
                    // show the alert
                    self.present(updateAlert, animated: true, completion: nil)
                }
                else {
                    print("Error inserting or updating")
                }
            }
        }
        createOkCancelAlert.addAction(OkAction)
        
        //Cancelation action
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) in
            //Retrieve original info
            if (!self.toDoDetailList.isEmpty) {
                self.titleLabel.text = self.toDoDetailList[0].title
                self.texDescription.text = self.toDoDetailList[0].description
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
    
    
    //Delete record
    @IBAction func DeleteList(_ sender: Any) {
        let listKey = userDefaults.integer(forKey: "ListId")
        
        //Create confirmation alert
        let createOkCancelAlert = UIAlertController(title: "Delete list data", message: "Are you sure do you want delete \(titleLabel.text ?? "") data?", preferredStyle: UIAlertController.Style.alert)
        
        let OkAction = UIAlertAction(title: "Ok", style: .default) { [self] (action:UIAlertAction!) in
            //Delete the list
            if (db.deleteToDoList(listKey: listKey))
            {
                
                //Create warning alert
                let deleteAlert = UIAlertController(title: "Tasks and list deleted", message: "Your list \(titleLabel.text ?? "") and its tasks has been deleted", preferredStyle: UIAlertController.Style.alert)
                
                // add an action (button)
                deleteAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                // show the alert
                self.present(deleteAlert, animated: true, completion: nil)
                
                titleLabel.text = ""
                texDescription.text = ""
                
                userDefaults.set(0, forKey: "ListId")
            }
            else {
                print("Delete statment fail")
            }
        }
        createOkCancelAlert.addAction(OkAction)
        
        //Cancelation alert
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
    
    
    @objc func ViewTasks() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "taskList") as! TaskListViewController
        
        vc.title = "Task List"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerRow = row
        return list[row]
    }
}
