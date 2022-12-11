//
//  TaskList.swift
//  MAPD714_ToDoApp
//
// Student Name: Carlos Hernandez Galvan
// Student ID: 301290263
//
// Student Name: Oscar Miralles Fernandez
// Student ID: 301250756
//
// Class to store Task basic information
//

import Foundation

class TaskList
{
    var image: String = ""
    var name: String = ""
    var day: String = ""
    var hour: String = ""
    var done: Int = 0
    var id: Int = 0
    var description: String = ""
    
    init(image: String, name: String, day: String, hour: String, done: Int, id: Int, description: String) {
        self.image = image
        self.name = name
        self.day = day
        self.hour = hour
        self.done = done
        self.id = id
        self.description = description
    }
}
