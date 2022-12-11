//
//  DBManagement.swift
//  MAPD714_ToDoApp
//
// Student Name: Carlos Hernandez Galvan
// Student ID: 301290263
//
// Student Name: Oscar Miralles Fernandez
// Student ID: 301250756
//
// Class to manage the interaction wuth de database
//

import Foundation
import SQLite3

class DBManagement
{
    //Database location
    var dbURL = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    var dbQueque: OpaquePointer! //C Pointer
    
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    init()
    {
        //Create and open database
        dbQueque = createOpenDatabase()
        
        if (createTable() == false)
        {
            print("Error table creation")
        }
        else {
            print("Table created")
        }
    }
    
    //Open or create database
    func createOpenDatabase () -> OpaquePointer? //C pointer
    {
        var db: OpaquePointer?
        
        let url = NSURL(fileURLWithPath: dbURL) //Set up database URL
        
        //Database name
        if let pathComponent = url.appendingPathComponent("ToDo.sqlite")
        {
            let filePath = pathComponent.path
            
            if sqlite3_open(filePath, &db) == SQLITE_OK
            {
                print("Database Open")
                
                return db
            }
            else
            {
                print("Database doesn't exist")
            }
        }
        else
        {
            print("File path not aviable")
        }
        
        return db
    }
    
    //Create table in case that It doesn't exist.
    func createTable() -> Bool {
        var returnVal: Bool = false
        
        let createTableList = sqlite3_exec(dbQueque,
                                       "CREATE TABLE IF NOT EXISTS Lists (ListId INTGER, ListName TEXT, ListCategory TEXT, ListDescription TEXT, PRIMARY KEY(ListId))" ,
                                       nil, nil, nil)
        
        let createTableTask = sqlite3_exec(dbQueque,
                                       "CREATE TABLE IF NOT EXISTS Tasks (TaskId INTEGER, ListId INTEGER, TaskName TEXT, TaskDescription TEXT, TaskIsDone INTEGER, TaskIsSchedule INTEGER, TaskDay TEXT, TaskHour TEXT, TaskNotes TEXT, PRIMARY KEY(TaskId, ListId))" ,
                                       nil, nil, nil)
        
        if ((createTableList != SQLITE_OK) || (createTableTask != SQLITE_OK)) {
            print("Error creating table")
            returnVal = false
        }
        else
        {
            returnVal = true
        }
        
        return returnVal
    }
    
    // Get the To Do list information by category
    func fetchTodoListData(category: String) -> [ToDoList] {
        var tdl: [ToDoList] = []
        
        let selectStatmentString = "SELECT ListId, ListName, ListCategory, ListDescription FROM Lists WHERE ListCategory = '\(category )';"
        
        var selectStatmentQuery: OpaquePointer?
        
        if sqlite3_prepare_v2(dbQueque, selectStatmentString, -1, &selectStatmentQuery, nil) == SQLITE_OK {
            
            while sqlite3_step(selectStatmentQuery) == SQLITE_ROW {
                tdl.append(ToDoList(id: Int(String(cString: sqlite3_column_text(selectStatmentQuery, 0))) ?? 0, title: String(String(cString: sqlite3_column_text(selectStatmentQuery, 1))), category: String(String(cString: sqlite3_column_text(selectStatmentQuery, 2))),                         description: String(String(cString: sqlite3_column_text(selectStatmentQuery, 3)))))
            }
        }
        else
        {
            print("SELECT statement fails")
        }
        sqlite3_finalize(selectStatmentQuery)
        
        return tdl
    }
    
    // Get To Do List detailed information
    func fetchTodoListDetailData(listKey: Int) -> [ToDoList] {
        var tdl: [ToDoList] = []
        
        let selectStatmentString = "SELECT ListName, ListCategory, ListDescription FROM Lists WHERE ListId = '\(listKey)';"
        
        var selectStatmentQuery: OpaquePointer?
        
        if sqlite3_prepare_v2(dbQueque, selectStatmentString, -1, &selectStatmentQuery, nil) == SQLITE_OK {
            
            while sqlite3_step(selectStatmentQuery) == SQLITE_ROW {
                tdl.append(ToDoList(id: listKey, title: String(String(cString: sqlite3_column_text(selectStatmentQuery, 0))), category: String(String(cString: sqlite3_column_text(selectStatmentQuery, 1))), description: String(String(cString: sqlite3_column_text(selectStatmentQuery, 2)))))
            }
        }
        sqlite3_finalize(selectStatmentQuery)
        
        return tdl
    }
    
    // Get the last key from the to do list table
    func getLastKey(listKey: Int) -> Int
    {
        var newListKey: Int = 1
        
        let selectStatmentString = "SELECT MAX(ListId) FROM Lists;"
        
        var selectStatmentQuery: OpaquePointer?
        
        if (listKey == 0)
        {
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
        
        return newListKey
    }
    
    // Insert to do list data into the table
    func insertToDoList (title: String, category: String, description: String, newListKey: Int) -> Bool
    {
        let insertStatmentString = "INSERT INTO Lists (ListId, ListName, ListCategory, ListDescription) VALUES (?, ?, ?, ?);"
        
        var insertStatmentQuery: OpaquePointer?
        var insert: Bool = false
        
        if (sqlite3_prepare_v2(dbQueque, insertStatmentString, -1, &insertStatmentQuery, nil)) == SQLITE_OK {
            sqlite3_bind_int(insertStatmentQuery, 1, Int32(newListKey))
            sqlite3_bind_text(insertStatmentQuery, 2, title , -1, self.SQLITE_TRANSIENT)
            sqlite3_bind_text(insertStatmentQuery, 3, category , -1, self.SQLITE_TRANSIENT)
            sqlite3_bind_text(insertStatmentQuery, 4, description, -1, self.SQLITE_TRANSIENT)
        }
            
        if (sqlite3_step(insertStatmentQuery)) == SQLITE_DONE
        {
            print("List succesfull insert")
            insert = true
        }
        else
        {
            print("List insertion fail")
        }
        sqlite3_finalize(insertStatmentQuery)
        
        return insert
    }
    
    // Update to do list data into the table
    func updateToDoList (title: String, category: String, description: String, newListKey: Int) -> Bool
    {
        let updateStatmentString = "UPDATE Lists SET ListName = ?, ListCategory = ?, ListDescription = ? WHERE ListId = '\(newListKey)';"
        
        var updateStatmentQuery: OpaquePointer?
        var update: Bool = false
        
        if (sqlite3_prepare_v2(dbQueque, updateStatmentString, -1, &updateStatmentQuery, nil)) == SQLITE_OK {
            sqlite3_bind_text(updateStatmentQuery, 1, title, -1, self.SQLITE_TRANSIENT)
            sqlite3_bind_text(updateStatmentQuery, 2, category , -1, self.SQLITE_TRANSIENT)
            sqlite3_bind_text(updateStatmentQuery, 3, description, -1, self.SQLITE_TRANSIENT)
            
            if (sqlite3_step(updateStatmentQuery)) == SQLITE_DONE
            {
                print("List succesfull updated")
                update = true
            }
            else {
                print("Error inserting or updating list")
            }
        }
        sqlite3_finalize(updateStatmentQuery)
        
        return update
    }
    
    // Delete to do list data into the table
    func deleteToDoList (listKey: Int) -> Bool
    {
        var deleteStatmentString = "DELETE FROM Lists WHERE ListId = \(listKey);"
        
        var deleteStatmentQuery: OpaquePointer?
        var delete: Bool = false
        
        if sqlite3_prepare_v2(dbQueque, deleteStatmentString, -1, &deleteStatmentQuery, nil) == SQLITE_OK {
            
            if sqlite3_step(deleteStatmentQuery) == SQLITE_DONE
            {
                print("List register deleted")
                
                sqlite3_finalize(deleteStatmentQuery)
                
                //Delete all the list tasks
                deleteStatmentString = "DELETE FROM Tasks WHERE ListId = \(listKey);"
                
                if sqlite3_prepare_v2(dbQueque, deleteStatmentString, -1, &deleteStatmentQuery, nil) == SQLITE_OK {
                    
                    if sqlite3_step(deleteStatmentQuery) == SQLITE_DONE
                    {
                        print("Tasks deleted")
                        delete = true
                    }
                    else {
                        print("Delete statment fail")
                    }
                }
            }
            else {
                print("Delete statment fail")
            }
        }
        sqlite3_finalize(deleteStatmentQuery)
        
        return delete
    }
    
    // Get the to do list tasks data
    func fetchTaskListData(listKey: Int) -> [TaskList] {
        var tskl: [TaskList] = []
        
        let selectStatmentString = "SELECT TaskName, TaskDay, TaskHour, TaskIsDone, TaskId, TaskDescription FROM Tasks WHERE ListId = '\(listKey)';"
        
        var selectStatmentQuery: OpaquePointer?
        
        if sqlite3_prepare_v2(dbQueque, selectStatmentString, -1, &selectStatmentQuery, nil) == SQLITE_OK {
            
            while sqlite3_step(selectStatmentQuery) == SQLITE_ROW {
                if (Int(String(cString: sqlite3_column_text(selectStatmentQuery, 3))) == 0) {
                    tskl.append(TaskList(image: "Unchecked", name: String(String(cString: sqlite3_column_text(selectStatmentQuery, 0))),
                                           day: String(String(cString: sqlite3_column_text(selectStatmentQuery, 1))) ,
                                              hour: String(String(cString: sqlite3_column_text(selectStatmentQuery, 2))), done: Int(String(cString: sqlite3_column_text(selectStatmentQuery, 3))) ?? 0, id: Int(String(cString: sqlite3_column_text(selectStatmentQuery, 4))) ?? 0, description: String(String(cString: sqlite3_column_text(selectStatmentQuery, 5)))))
                }
                else {
                    tskl.append(TaskList(image: "checked", name: String(String(cString: sqlite3_column_text(selectStatmentQuery, 0))),
                                           day: String(String(cString: sqlite3_column_text(selectStatmentQuery, 1))) ,
                                              hour: String(String(cString: sqlite3_column_text(selectStatmentQuery, 2))), done: Int(String(cString: sqlite3_column_text(selectStatmentQuery, 3))) ?? 0, id: Int(String(cString: sqlite3_column_text(selectStatmentQuery, 4))) ?? 0, description: String(String(cString: sqlite3_column_text(selectStatmentQuery, 5)))))
                }
                    
            }
        }
        sqlite3_finalize(selectStatmentQuery)
        
        return tskl
    }
    
    // Delete a task
    func deleteTask(listId: Int, taskId: Int) -> Bool
    {
        var delete: Bool = false
        
        let deleteStatmentString = "DELETE FROM Tasks WHERE ListId = '\(listId)' AND TaskId = '\(taskId)';"
        
        var deleteStatmentQuery: OpaquePointer?
        
        if sqlite3_prepare_v2(dbQueque, deleteStatmentString, -1, &deleteStatmentQuery, nil) == SQLITE_OK {
            
            if sqlite3_step(deleteStatmentQuery) == SQLITE_DONE
            {
                print("Task register deleted")
                
                delete = true
            }
            else {
                print("Delete task statment fail")
            }
        }
        sqlite3_finalize(deleteStatmentQuery)
        
        return delete
    }
    
    // Update a task
    func updateTask(listId: Int, taskId: Int, value: Int) -> Bool
    {
        var updated: Bool = false
        
        let updateStatmentString = "UPDATE Tasks SET TaskIsDone = ? WHERE ListId = \(listId) AND TaskId = \(taskId);"
        
        var updateStatmentQuery: OpaquePointer?
        
        if (sqlite3_prepare_v2(dbQueque, updateStatmentString, -1, &updateStatmentQuery, nil)) == SQLITE_OK {
            sqlite3_bind_int(updateStatmentQuery, 1, Int32(value))
            
            if (sqlite3_step(updateStatmentQuery)) == SQLITE_DONE
            {
                print("Succesfull updated")
                updated = true
            }
            else {
                print("Error inserting or updating")
            }
        }
        sqlite3_finalize(updateStatmentQuery)
        
        return updated
    }
    
    // Get tasks detailed information
    func fetchTaskListDetailData(listKey: Int, taskKey: Int) -> [TaskListDetail] {
        var tskld: [TaskListDetail] = []
        
        let selectStatmentString = "SELECT TaskName, TaskDay, TaskHour, TaskIsDone,  TaskIsSchedule, TaskDescription, TaskNotes FROM Tasks WHERE ListId = '\(listKey)' AND TaskId = '\(taskKey)';"
        
        var selectStatmentQuery: OpaquePointer?
        
        var done: Bool = false
        var schelude: Bool = false
        
        if sqlite3_prepare_v2(dbQueque, selectStatmentString, -1, &selectStatmentQuery, nil) == SQLITE_OK {
            
            while sqlite3_step(selectStatmentQuery) == SQLITE_ROW {
                
                let day = String(String(cString: sqlite3_column_text(selectStatmentQuery, 1)))
                let hour = String(String(cString: sqlite3_column_text(selectStatmentQuery, 2)))
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                let value = formatter.date(from: "\(day) \(hour)") ?? Date.now
                
                var onOff = String(String(cString: sqlite3_column_text(selectStatmentQuery, 3)))
                if onOff == "0" {
                    done = false
                }
                else {
                    done = true
                }
                
                onOff = String(String(cString: sqlite3_column_text(selectStatmentQuery, 4)))
                if onOff == "0" {
                    schelude = false
                }
                else {
                    schelude = true
                }
                
                tskld.append(TaskListDetail(name: String(String(cString: sqlite3_column_text(selectStatmentQuery, 0))), description: String(String(cString: sqlite3_column_text(selectStatmentQuery, 5))), date: value, notes: String(String(cString: sqlite3_column_text(selectStatmentQuery, 6))), done: done, schelude: schelude))
            }
        }
        sqlite3_finalize(selectStatmentQuery)
        
        return tskld
    }
    
    // Get last key from Tasks table
    func getLasTasktKey(listKey: Int, taskKey: Int) -> Int
    {
        var newTaskKey: Int = 1
        
        let selectStatmentString = "SELECT MAX(TaskId) FROM Tasks WHERE ListId = '\(listKey)';"
        
        var selectStatmentQuery: OpaquePointer?
        
        if (taskKey == 0){
            
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
        
        return newTaskKey
    }
    
    // Insert detailed task data
    func insertTaskDatail (listKey: Int, taskKey: Int, name: String, description: String, done: Bool, schedule: Bool, day: String, hour: String, notes: String) -> Bool
    {
        var inserted: Bool = false
        
        let insertStatmentString = "INSERT INTO Tasks (TaskId, ListId, TaskName, TaskDescription, TaskIsDone, TaskIsSchedule, TaskDay, TaskHour, TaskNotes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);"
        
        var insertStatmentQuery: OpaquePointer?
        
        if (sqlite3_prepare_v2(dbQueque, insertStatmentString, -1, &insertStatmentQuery, nil)) == SQLITE_OK {
            sqlite3_bind_int(insertStatmentQuery, 1, Int32(taskKey))
            sqlite3_bind_int(insertStatmentQuery, 2, Int32(listKey))
            sqlite3_bind_text(insertStatmentQuery, 3, name, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(insertStatmentQuery, 4, description, -1, SQLITE_TRANSIENT)
            if done
            {
                sqlite3_bind_int(insertStatmentQuery, 5, Int32(1))
            }
            else
            {
                sqlite3_bind_int(insertStatmentQuery, 5, Int32(0))
            }
            if schedule
            {
                sqlite3_bind_int(insertStatmentQuery, 6, Int32(1))
                
                sqlite3_bind_text(insertStatmentQuery, 7, day , -1, SQLITE_TRANSIENT)
                
                sqlite3_bind_text(insertStatmentQuery, 8, hour , -1, SQLITE_TRANSIENT)
            }
            else {
                sqlite3_bind_int(insertStatmentQuery, 6, Int32(0))
                sqlite3_bind_text(insertStatmentQuery, 7, "" , -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(insertStatmentQuery, 8, "" , -1, SQLITE_TRANSIENT)
            }
            
            sqlite3_bind_text(insertStatmentQuery, 9, notes, -1, SQLITE_TRANSIENT)
            
            if (sqlite3_step(insertStatmentQuery)) == SQLITE_DONE
            {
                print("Task detail succesfull insert")
                
                inserted = true
            }
            else
            {
                print("Error inserting task")
            }
        }
        sqlite3_finalize(insertStatmentQuery)
        
        return inserted
    }
    
    // Update detailed task data
    func updateTaskDatail (listKey: Int, taskKey: Int, name: String, description: String, done: Bool, schedule: Bool, day: String, hour: String, notes: String) -> Bool
    {
        var updated: Bool = false
        
        let updateStatmentString = "UPDATE Tasks SET TaskName = ?, TaskDescription = ?, TaskIsDone = ?, TaskIsSchedule = ?, TaskDay = ?, TaskHour = ?, TaskNotes = ? WHERE ListId = '\(listKey)' AND TaskId = \(taskKey);"
        
        var updateStatmentQuery: OpaquePointer?
        
        if (sqlite3_prepare_v2(dbQueque, updateStatmentString, -1, &updateStatmentQuery, nil)) == SQLITE_OK {
            sqlite3_bind_text(updateStatmentQuery, 1, name , -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(updateStatmentQuery, 2, description , -1, SQLITE_TRANSIENT)
            if done {
                sqlite3_bind_int(updateStatmentQuery, 3, Int32(1))
            }
            else {
                sqlite3_bind_int(updateStatmentQuery, 3, Int32(0))
            }
            if schedule {
                sqlite3_bind_int(updateStatmentQuery, 4, Int32(1))
                
                sqlite3_bind_text(updateStatmentQuery, 5, day , -1, SQLITE_TRANSIENT)
                
                sqlite3_bind_text(updateStatmentQuery, 6, hour , -1, SQLITE_TRANSIENT)
            }
            else {
                sqlite3_bind_int(updateStatmentQuery, 4, Int32(0))
                sqlite3_bind_text(updateStatmentQuery, 5, "" , -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(updateStatmentQuery, 6, "" , -1, SQLITE_TRANSIENT)
            }
            
            sqlite3_bind_text(updateStatmentQuery, 7, notes , -1, SQLITE_TRANSIENT)
            
            
            if (sqlite3_step(updateStatmentQuery)) == SQLITE_DONE
            {
                print("Task succesfull updated")
                
                updated = true
            }
            else {
                print("Error updating task")
            }
        }
        sqlite3_finalize(updateStatmentQuery)
        
        return updated
    }
    
    // Delete detailed task data
    func deleteTaskDatail (listKey: Int, taskKey: Int) -> Bool
    {
        var deleted: Bool = false
        
        let deleteStatmentString = "DELETE FROM Tasks WHERE ListId = '\(listKey)' AND TaskId = '\(taskKey)';"
        
        var deleteStatmentQuery: OpaquePointer?
        
        if sqlite3_prepare_v2(dbQueque, deleteStatmentString, -1, &deleteStatmentQuery, nil) == SQLITE_OK {
            
            if sqlite3_step(deleteStatmentQuery) == SQLITE_DONE
            {
                print("Task register deleted")
                
                deleted = true
            }
            else {
                print("Delete task statment fail")
            }
        }
        sqlite3_finalize(deleteStatmentQuery)
        
        return deleted
    }
}
