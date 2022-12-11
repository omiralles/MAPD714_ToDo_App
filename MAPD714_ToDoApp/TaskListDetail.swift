//
//  TaskListDetail.swift
//  MAPD714_ToDoApp
//
// Student Name: Carlos Hernandez Galvan
// Student ID: 301290263
//
// Student Name: Oscar Miralles Fernandez
// Student ID: 301250756
//
// Class to store detailed task inforamtion
//

import Foundation

class TaskListDetail
{
    var name: String = ""
    var description: String = ""
    var date: Date? = nil
    var notes: String = ""
    var done: Bool = false
    var schelude: Bool = false
    
    init(name: String, description: String, date: Date, notes: String, done: Bool, schelude: Bool) {
        self.name = name
        self.description = description
        self.date = date
        self.notes = notes
        self.done = done
        self.schelude = schelude
    }
}
