//
//  ToDoList.swift
//  MAPD714_ToDoApp
//
// Student Name: Carlos Hernandez Galvan
// Student ID: 301290263
//
// Student Name: Oscar Miralles Fernandez
// Student ID: 301250756
//
// Class to store the Todo List information
//

import Foundation

class ToDoList
{
    var id: Int = 0
    var title: String = ""
    var category: String = ""
    var description: String = ""
    
    init(id: Int, title: String, category: String, description: String)
    {
        self.id = id
        self.title = title
        self.category = category
        self.description = description
    }
}
