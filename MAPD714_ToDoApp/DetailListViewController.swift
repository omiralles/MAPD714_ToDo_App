//
//  DetailListViewController.swift
//  MAPD714_ToDoApp
//
//  ViewController to show detailed list information.
//  Here you can specify name description and category.
//

import UIKit
import SQLite3

class DetailListViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var titleLabel: UITextField!
    @IBOutlet var texDescription: UITextView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var pickerViewH: UIPickerView!
    
    //Original list info to restore in caso of cancelation
    struct listInfo {
        var title: String
        var description: String
    }
    var oldListInfo = [listInfo]()
    
    //Category list
    var list = ["Things to do", "Groceries", "Home", "Sopping", "Custom"]
    var pickerRow: Int?
    
    //Get/Store search keys
    let userDefaults = UserDefaults.standard
    
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
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
            fetchData()
        }
        
        //Button to acces to list tasks
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "View Tasks", style: .done, target: self, action: #selector(ViewTasks))
    
    }
    
    //Retrieve data from database
    func fetchData() {
        
        let listKey = userDefaults.integer(forKey: "ListId")
        
        let selectStatmentString = "SELECT ListName, ListCategory, ListDescription FROM Lists WHERE ListId = '\(listKey)';"
        
        var selectStatmentQuery: OpaquePointer?
        
        if sqlite3_prepare_v2(dbQueque, selectStatmentString, -1, &selectStatmentQuery, nil) == SQLITE_OK {
            
            while sqlite3_step(selectStatmentQuery) == SQLITE_ROW {
                titleLabel.text = String(String(cString: sqlite3_column_text(selectStatmentQuery, 0)))
                texDescription.text = String(String(cString: sqlite3_column_text(selectStatmentQuery, 2)))
                
                oldListInfo.append(listInfo(title: String(String(cString: sqlite3_column_text(selectStatmentQuery, 0))), description: String(String(cString: sqlite3_column_text(selectStatmentQuery, 2)))))
            }
            
            sqlite3_finalize(selectStatmentQuery)
        }
    }
    
    //Insert/Update data
    @IBAction func SaveList(_ sender: Any) {
        let listKey = userDefaults.integer(forKey: "ListId")
        var newListKey: Int = 1
        
        //Create alert
        let createOkCancelAlert = UIAlertController(title: "Save list data", message: "Are you sure do you want save \(titleLabel.text ?? "") data?", preferredStyle: UIAlertController.Style.alert)
        
        let OkAction = UIAlertAction(title: "Ok", style: .default) { [self] (action:UIAlertAction!) in
            
            //Find the last id or create a new
            if (listKey == 0){
                let selectStatmentString = "SELECT MAX(ListId) FROM Lists;"
                
                var selectStatmentQuery: OpaquePointer?
                
                if sqlite3_prepare_v2(dbQueque, selectStatmentString, -1, &selectStatmentQuery, nil) == SQLITE_OK {
                    
                    while sqlite3_step(selectStatmentQuery) == SQLITE_ROW {
                        newListKey = Int(Int(sqlite3_column_int(selectStatmentQuery, 0)))
                        newListKey += 1
                    }
                    
                    sqlite3_finalize(selectStatmentQuery)
                }
            }
            else {
                newListKey = listKey
            }
            
            //Insertion
            let insertStatmentString = "INSERT INTO Lists (ListId, ListName, ListCategory, ListDescription) VALUES (?, ?, ?, ?);"
            
            var insertStatmentQuery: OpaquePointer?
            
            if (sqlite3_prepare_v2(dbQueque, insertStatmentString, -1, &insertStatmentQuery, nil)) == SQLITE_OK {
                sqlite3_bind_int(insertStatmentQuery, 1, Int32(newListKey))
                sqlite3_bind_text(insertStatmentQuery, 2, self.titleLabel.text ?? "", -1, self.SQLITE_TRANSIENT)
                sqlite3_bind_text(insertStatmentQuery, 3, self.list[pickerRow ?? 0] , -1, self.SQLITE_TRANSIENT)
                sqlite3_bind_text(insertStatmentQuery, 4, self.texDescription.text ?? "", -1, self.SQLITE_TRANSIENT)
                
                if (sqlite3_step(insertStatmentQuery)) == SQLITE_DONE
                {
                    print("Succesfull insert")
                    
                    //Create alert
                    let createAlert = UIAlertController(title: "List created", message: "Your list \(titleLabel.text ?? "") has been created", preferredStyle: UIAlertController.Style.alert)
                    
                    // add an action (button)
                    createAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    
                    // show the alert
                    self.present(createAlert, animated: true, completion: nil)
                }
                else {
                    //Update record
                    let updateStatmentString = "UPDATE Lists SET ListName = ?, ListCategory = ?, ListDescription = ? WHERE ListId = '\(newListKey)';"
                    
                    var updateStatmentQuery: OpaquePointer?
                    
                    if (sqlite3_prepare_v2(dbQueque, updateStatmentString, -1, &updateStatmentQuery, nil)) == SQLITE_OK {
                        sqlite3_bind_text(updateStatmentQuery, 1, self.titleLabel.text ?? "", -1, self.SQLITE_TRANSIENT)
                        sqlite3_bind_text(updateStatmentQuery, 2, self.list[pickerRow ?? 0] , -1, self.SQLITE_TRANSIENT)
                        sqlite3_bind_text(updateStatmentQuery, 3, self.texDescription.text ?? "", -1, self.SQLITE_TRANSIENT)
                        
                        if (sqlite3_step(updateStatmentQuery)) == SQLITE_DONE
                        {
                            print("Succesfull updated")
                            
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
                
                sqlite3_finalize(insertStatmentQuery)
            }
        }
        createOkCancelAlert.addAction(OkAction)
        
        //Cancelation action
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) in
            //Retrieve original info
            self.titleLabel.text = self.oldListInfo[0].title
            self.texDescription.text = self.oldListInfo[0].description
            
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
        
        let createOkCancelAlert = UIAlertController(title: "Delete list data", message: "Are you sure do you want delete \(titleLabel.text ?? "") data?", preferredStyle: UIAlertController.Style.alert)
        
        let OkAction = UIAlertAction(title: "Ok", style: .default) { [self] (action:UIAlertAction!) in
            
            var deleteStatmentString = "DELETE FROM Lists WHERE ListId = \(listKey);"
            
            var deleteStatmentQuery: OpaquePointer?
            
            if sqlite3_prepare_v2(dbQueque, deleteStatmentString, -1, &deleteStatmentQuery, nil) == SQLITE_OK {
                
                if sqlite3_step(deleteStatmentQuery) == SQLITE_DONE
                {
                    print("Register deleted")
                    
                    sqlite3_finalize(deleteStatmentQuery)
                    
                    deleteStatmentString = "DELETE FROM Tasks WHERE ListId = \(listKey);"
                    
                    if sqlite3_prepare_v2(dbQueque, deleteStatmentString, -1, &deleteStatmentQuery, nil) == SQLITE_OK {
                        
                        if sqlite3_step(deleteStatmentQuery) == SQLITE_DONE
                        {
                            print("Tasks deleted")
                            
                        }
                        else {
                            print("Delete statment fail")
                        }
                    }
                    
                    //Create alert
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
