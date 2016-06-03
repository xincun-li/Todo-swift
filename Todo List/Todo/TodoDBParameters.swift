//
//  TodoDBParameters.swift
//  Todo
//
//  Created by xincun li on 3/8/16.
//  Copyright © 2016 xincun li. All rights reserved.
//

import Foundation
import SQLite

class TodoDBParameters {
    static let dbPath = NSHomeDirectory() + "/Documents"
    static let dbName = "mytodo.sqlite3"
    static let tableName = "todos"
    // Declare table
    static let todosTable = Table("todos")    
    //Table Exist
    static let tableExistSql = "SELECT EXISTS ( SELECT name FROM sqlite_master WHERE name = ?)"
    
    // Declare Columns
    static let id = Expression<String>("id")
    static let image = Expression<String>("image")
    static let title = Expression<String>("title")
    static let date = Expression<String>("date")
}
