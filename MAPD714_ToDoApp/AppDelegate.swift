//
//  AppDelegate.swift
//  MAPD714_ToDoApp
//
//  Created by Oscar Miralles on 2022-11-12.
//

import UIKit
import SQLite3

//Database location
var dbURL = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
var dbQueque: OpaquePointer! //C Pointer

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //Create and open database
        dbQueque = createOpenDatabase()
        
        if (createTable() == false)
        {
            print("Error table creation")
        }
        else {
            print("Table created")
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
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
    
}

